
/* delete data from each specialist table and jana_pk */
DELETE FROM JANA_PK;
DELETE FROM AMBER;

/* upload the data from each specialist */
/* Do this on each table to set the specialist name*/
UPDATE CHRISTINA SET SPECIALIST = 'CHRISTINA';

THERE WILL BE DUPLICATES OF COURSES SO WE MUST CREATE A SEPERATE TABLE TO DEAL WITH THE DATA */
/*Run this on each academic specialists tables*/
INSERT INTO JANA_PK pk (pk.COURSE_NUMBER, pk.PROGRAM_PK, pk.RESTRICTED_TO_MAJORS, pk.MAIN_CAMPUS_ONLY, pk.SPECIALIST)
SELECT COURSE_NUMBER, PROGRAM_PK, RESTRICTED_TO_MAJORS, MAIN_CAMPUS, SPECIALIST
FROM SAM;

/* CORRECT YES AND NOS FOR CAMPUS AND RESTRICTED TO MAJORS */
UPDATE JANA_PK SET MAIN_CAMPUS_ONLY = 'n' WHERE MAIN_CAMPUS_ONLY is NULL 
                                                or MAIN_CAMPUS_ONLY = 'N'
                                                or MAIN_CAMPUS_ONLY = 'no'
                                                or MAIN_CAMPUS_ONLY = 'NO';
UPDATE JANA_PK SET MAIN_CAMPUS_ONLY = 'y' WHERE MAIN_CAMPUS_ONLY = 'Y'
                                                or MAIN_CAMPUS_ONLY = 'Yes'
                                                or MAIN_CAMPUS_ONLY = 'yes';
/* CHECK Y OR N */
SELECT DISTINCT MAIN_CAMPUS_ONLY FROM JANA_PK;

UPDATE JANA_PK SET RESTRICTED_TO_MAJORS = 'y' WHERE RESTRICTED_TO_MAJORS = 'Y'
                                                    OR RESTRICTED_TO_MAJORS = 'Yes';
                                                    
UPDATE JANA_PK SET RESTRICTED_TO_MAJORS = 'n' WHERE RESTRICTED_TO_MAJORS = 'N'
                                                    OR RESTRICTED_TO_MAJORS = 'No';



/* make sure all specialists are listed and none are null */
SELECT DISTINCT SPECIALIST FROM JANA_PK;



SELECT COURSE_NUMBER, COURSE_PK, PROGRAM_PK FROM JANA_PK;

/*run this on each table other than jana pk*/
 /*get rid of duplicates
 CAROL
 CHRISTINA
 SAM
 AMBER
  FIND ERRORS IN DEPARTMENT NAME */
 SELECT DISTINCT DEPARTMENT_NAME FROM CHRISTINA;
 
 /* correct a misspelled word if there is one */
 UPDATE CHRISTINA SET DEPARTMENT_NAME = 'Sociology' WHERE DEPARTMENT_NAME = 'Sociolgy';
 
/* save point before adding course data */
SAVEPOINT ADDING; 

/* delete all duplicates from specialist tables, not from jana_pk */
DELETE FROM drupal.SAM WHERE ROWID NOT IN (SELECT MIN(ROWID) FROM drupal.SAM GROUP BY course_number);

/* after deleting, run this on each specialist table */
/* this uploads all course data */
MERGE INTO drupal.DL_COURSES dlc
    USING drupal.CAROL new /* change specialist name here */
    ON (dlc.COURSE_NUMBER = new.COURSE_NUMBER)
    WHEN MATCHED THEN
 UPDATE
      SET dlc.COURSE_TITLE       = new.COURSE_TITLE,
          dlc.CREDIT_HOURS       = new.CREDIT_HOURS,
          dlc.COURSE_DESCRIPTION = new.COURSE_DESCRIPTION,
          dlc.DEPARTMENT_NAME    = new.DEPARTMENT_NAME
    WHEN NOT MATCHED THEN
 INSERT (dlc.COURSE_TITLE, dlc.COURSE_DESCRIPTION, dlc.CREDIT_HOURS, dlc.DEPARTMENT_NAME, dlc.COURSE_NUMBER)
 VALUES (new.COURSE_TITLE, new.COURSE_DESCRIPTION, new.CREDIT_HOURS, new.DEPARTMENT_NAME, new.COURSE_NUMBER);

/*insert association numbers to jana_pk*/
UPDATE DRUPAL.JANA_PK pk
   SET pk.COURSE_PK =
  (SELECT pka.COURSE_PK
     FROM DL_COURSES pka
    WHERE pk.COURSE_NUMBER = pka.COURSE_NUMBER
      AND rownum = 1);

      
/* Date query just in case you need it */
select course_number, course_pk from drupal.dl_courses where trunc(last_updated) = '21-NOV-16';


/* grab association pk from program course association*/
 
UPDATE DRUPAL.JANA_PK pk
SET pk.ASSOCIATION_PK   = (SELECT pka.ASSOCIATION_PK FROM DL_PROGRAM_COURSE_ASSOCIATION pka 
    WHERE pk.COURSE_PK  = pka.COURSE_PK AND
        pk.PROGRAM_PK = pka.PROGRAM_PK);

/* FIND NEW ENTRIES THAT NEED ASSOCIATION PK */
SELECT * FROM JANA_PK WHERE ASSOCIATION_PK IS NULL;


/* FIND POTENTIAL ASSOCIATION DUPLICATES */ 
SELECT * FROM JANA_PK WHERE ROWID NOT IN (SELECT MIN(ROWID) FROM JANA_PK GROUP BY ASSOCIATION_PK);

/* TO SEE COUNT */
SELECT COURSE_NUMBER, COURSE_PK, PROGRAM_PK, SPECIALIST, ASSOCIATION_PK, COUNT(ASSOCIATION_PK) FROM JANA_PK
GROUP BY COURSE_NUMBER, COURSE_PK, PROGRAM_PK, SPECIALIST, ASSOCIATION_PK HAVING COUNT(ASSOCIATION_PK) > 1;

/* REMOVE DUPLICATES */
DELETE FROM JANA_PK WHERE ROWID NOT IN (SELECT MIN(ROWID) FROM JANA_PK GROUP BY ASSOCIATION_PK);

 
/* Run this to insert course pk and program pk that needs association pk */ 
/* NOTE!!! The Append comment below is part of the sql statement */

 INSERT /*+ APPEND */ INTO DL_PROGRAM_COURSE_ASSOCIATION pka (pka.COURSE_PK, pka.PROGRAM_PK, pka.MAIN_CAMPUS_ONLY, pka.RESTRICTED_TO_MAJORS)
 SELECT COURSE_PK, PROGRAM_PK, MAIN_CAMPUS_ONLY, RESTRICTED_TO_MAJORS
 FROM JANA_PK 
 WHERE ASSOCIATION_PK IS NULL;

/* fix any null campus locations */
UPDATE JANA_PK SET MAIN_CAMPUS_ONLY = 'n' WHERE PROGRAM_PK = 99 AND MAIN_CAMPUS_ONLY IS NULL;


/* new save point */
SAVEPOINT MAIN_CAMPUS;

/* ADD RESTRICTED TO MAJORS AND MAIN CAMPUS DETAILS */
UPDATE DL_PROGRAM_COURSE_ASSOCIATION pka
   SET pka.MAIN_CAMPUS_ONLY =
  (SELECT new.MAIN_CAMPUS_ONLY
     FROM JANA_PK new
    WHERE new.ASSOCIATION_PK = pka.ASSOCIATION_PK
      AND ROWNUM = 1);
    
UPDATE DL_PROGRAM_COURSE_ASSOCIATION pka
   SET pka.RESTRICTED_TO_MAJORS =
  (SELECT new.RESTRICTED_TO_MAJORS
     FROM JANA_PK new
    WHERE new.ASSOCIATION_PK = pka.ASSOCIATION_PK
      AND ROWNUM = 1);

 
 /* Add all semester information needed before appending to course term */
 
UPDATE DRUPAL.JANA_PK  SET TERM_TEXT = 'Spring',
                         TERM_NUMBER = '1',
                                YEAR = '2017'; /*If needed add WHERE 'COLUMN_NAME' IS NULL*/

/* append all association pks to course term */
 
INSERT INTO
    DRUPAL.DL_PROGRAM_COURSE_TERMS
    pct (         pct.ASSOCIATION_PK, pct.TERM_NUMBER, pct.TERM_TEXT, pct.YEAR)     SELECT
        pk.ASSOCIATION_PK,
        pk.TERM_NUMBER,
        pk.TERM_TEXT,
        pk.YEAR     
    FROM
        DRUPAL.JANA_PK PK     
    WHERE
        PK.ASSOCIATION_PK IS NOT NULL; /*contact program specialists to find missing info */

        
/* in case you need to check for null association pk */
SELECT * FROM JANA_PK WHERE ASSOCIATION_PK IS NULL;


/*****************************
   Extra statements
******************************/
/* fees are not longer added, but this may come in handy in the future
/*For fees*/
BEGIN
  FOR X IN
    (SELECT COURSE_NUMBER, TUITION_AND_FEES FROM amber)
      LOOP
        UPDATE DL_COURSES Y
          SET Y.TUITION_AND_FEES = X.TUITION_AND_FEES
            WHERE Y.COURSE_NUMBER = X.COURSE_NUMBER;
      END LOOP;
END; 
/

/*update date, this is done every year */
UPDATE DL_PROGRAMS 
  SET TOPICAL = REPLACE(TOPICAL, '2015-16', '2016-17');
  
/* replace topical with fee_type  to replace both*/

UPDATE DL_COURSES SET FEE_TYPE = REPLACE(DL_COURSES.TUITION_AND_FEES, '2014-2015', '2015-2016');
 
UPDATE DL_COURSES SET TUITION_AND_FEES = REPLACE(DL_COURSES.TUITION_AND_FEES, 'Student Business Services website</a >Student Business Services Website</a>', ' Student Business Services Website</a>');

UPDATE DL_COURSES SET COURSE_DESCRIPTION = REPLACE(COURSE_DESCRIPTION, '“', '"');
UPDATE DL_COURSES SET COURSE_DESCRIPTION = REPLACE(COURSE_DESCRIPTION, '”', '"');
UPDATE DL_COURSES SET COURSE_DESCRIPTION = REPLACE(COURSE_DESCRIPTION, '’', '''');
UPDATE DL_COURSES SET COURSE_DESCRIPTION = REPLACE(COURSE_DESCRIPTION, '–', '-');

SELECT DISTINCT COURSE_NUMBER FROM JANA_PK ORDER BY COURSE_NUMBER ASC;

/*QUERY DUPLICATES*/
SELECT COURSE_NUMBER, PROGRAM_PK, COUNT(*) FROM JANA_PK GROUP BY COURSE_NUMBER, PROGRAM_PK HAVING COUNT(*) > 1;

 CREATE TABLE "DRUPAL"."SAM" 
 (	"PROGRAM_PK" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
"COURSE_NUMBER" VARCHAR2(20 BYTE), 
"COURSE_TITLE" VARCHAR2(150 BYTE), 
"CREDIT_HOURS" VARCHAR2(10 BYTE), 
"COURSE_DESCRIPTION" VARCHAR2(1000 BYTE), 
"TUITION_AND_FEES" VARCHAR2(500 BYTE), 
"DEPARTMENT_NAME" VARCHAR2(100 BYTE), 
"MAIN_CAMPUS" VARCHAR2(1 BYTE), 
"RESTRICTED_TO_MAJORS" VARCHAR2(1 BYTE), 
"PREREQS" VARCHAR2(500 BYTE)
 ) SEGMENT CREATION IMMEDIATE 
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
NOCOMPRESS LOGGING
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
 
/*INSERT FROM COORD CHARTS*/
INSERT INTO PREREQ pk (pk.COURSE_NUMBER, pk.PRERQUISITE, pk.SPECIALIST)
SELECT COURSE_NUMBER, PREREQS, SPECIALIST
FROM SAM;
/*DELETE DUPLICATE ENTRIES*/
DELETE FROM PREREQ WHERE ROWID NOT IN (SELECT MIN(ROWID) FROM PREREQ GROUP BY course_number);
/*CHECK FOR DUPLICATES*/
SELECT DISTINCT COURSE_NUMBER FROM PREREQ;
/*GET COURSE_PK*/
UPDATE PREREQ pka
   SET pka.COURSE_PK =
  (SELECT DISTINCT new.COURSE_PK
     FROM JANA_PK new
    WHERE new.COURSE_NUMBER = pka.COURSE_NUMBER);
    
SELECT x.course_number  AS CNumber, 
       x.course_pk      AS CPK, 
       x.PRERQUISITE   AS NEW_PREREQ,
       x.SPECIALIST,
       y.REQ_COURSE_NUMBER AS REQ_NUM,
       y.COMMENTS     AS COMMENTS,
       y.REQ_TYPE
FROM   PREREQ x 
       join DL_COURSE_REQUISITES y 
         ON x.course_pk = y.course_pk 
       WHERE x.SPECIALIST = 'CHRISTINA'
ORDER  BY x.course_PK desc;

/*ADD SPECIALISTS NAME FOR QUESTIONS AND REFERENCE*/
UPDATE PREREQ pka
   SET pka.SPECIALIST =
  (SELECT DISTINCT new.SPECIALIST
     FROM JANA_PK new
    WHERE new.COURSE_NUMBER = pka.COURSE_NUMBER);
    
delete from prereq where specialist = 'SAM';



SELECT x.COURSE_NUMBER, x.COURSE_PK, x.ASSOCIATION_PK, x.PROGRAM_PK FROM JANA_PK x
LEFT JOIN DL_PROGRAM_COURSE_TERMS y ON x.ASSOCIATION_PK = y.ASSOCIATION_PK WHERE y.YEAR = 2017;

SELECT * FROM DL_PROGRAM_COURSE_TERMS y WHERE y.YEAR = 2017;
