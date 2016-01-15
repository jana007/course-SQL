/*FIRST UPLOAD ALL EXCEL FILES TO ORACLE
THERE WILL BE DUPLICATES OF COURSES SO WE MUST CREATE A SEPERATE TABLE TO DEAL WITH THE DATA */
/*Run this on each academic specialists tables*/
INSERT INTO JANA_PK pk (pk.COURSE_NUMBER, pk.PROGRAM_PK. pk.RESTRICTED_TO_MAJORS, pk.MAIN_CAMPUS_ONLY)
SELECT COURSE_NUMBER, PROGRAM_PK, RESTRICTED_TO_MAJORS, MAIN_CAMPUS_ONLY
FROM AMBER;

/*run this on each table other than jana pk*/
 /*get rid of duplicates*/
 
 DELETE FROM drupal.sam WHERE ROWID NOT IN (SELECT MIN(ROWID) FROM drupal.sam GROUP BY course_number);


/* This grabs all data from each person's uploaded CSV file */

MERGE INTO drupal.DL_COURSES dlc
    USING drupal.sam new
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

 
/* Select all of the new updates, then save as CSV file. We'll make a neato table based off of this data*/
select course_number, course_pk from drupal.dl_courses where trunc(last_updated) = '23-JUN-15';

/*insert association numbers to jana_pk*/
UPDATE DRUPAL.JANA_PK pk
   SET pk.COURSE_PK =
  (SELECT pka.COURSE_PK
     FROM DL_COURSES pka
	  WHERE pk.COURSE_NUMBER = pka.COURSE_NUMBER
      AND rownum = 1);

/*INSERT NEW pk into course association*/
INSERT INTO drupal.DL_PROGRAM_COURSE_ASSOCIATION pka (pka.COURSE_PK, pka.PROGRAM_PK)
SELECT COURSE_PK, PROGRAM_PK
FROM JANA_PK
WHERE ASSOCIATION_PK IS NULL;
	  
	  
/* grab association pk from program course association*/
 
UPDATE DRUPAL.JANA_PK pk
SET pk.ASSOCIATION_PK   = (SELECT pka.ASSOCIATION_PK FROM DL_PROGRAM_COURSE_ASSOCIATION pka 
	WHERE pk.COURSE_PK  = pka.COURSE_PK AND
		  pk.PROGRAM_PK = pka.PROGRAM_PK);

/* FIND NEW ENTRIES THAT NEED ASSOCIATION PK */
		 
 SELECT * FROM JANA_PK WHERE ASSOCIATION_PK IS NULL;
 
 
INSERT INTO PROGRAM_COURSE_ASSOCIATION pka (pka.COURSE_NUMBER, pka.PROGRAM_PK)
SELECT COURSE_NUMBER, PROGRAM_PK
FROM JANA_PK
WHERE ASSOCIATION_PK IS NULL;

 
 
 
/* Run this to insert course pk and program pk that needs association pk */ 
 INSERT /*+ APPEND */ INTO DL_PROGRAM_COURSE_ASSOCIATION pka (pka.COURSE_PK, pka.PROGRAM_PK, pka.CORE_COURSE, pka.MAIN_CAMPUS_ONLY, pka.RESTRICTED_TO_MAJORS)
 SELECT COURSE_PK, PROGRAM_PK, CORE_COURSE, MAIN_CAMPUS_ONLY, RESTRICTED_TO_MAJORS
 FROM JANA_PK 
 WHERE ASSOCIATION_PK IS NULL;
 
/*add restricted to majors and main campus data to jana_pk */
UPDATE DRUPAL.JANA_PK pk
SET pk.RESTRICTED_TO_MAJORS   = (SELECT new.RESTRICTED_TO_MAJORS FROM amber new 
	WHERE pk.COURSE_NUMBER  = new.COURSE_NUMBER);

UPDATE DRUPAL.JANA_PK pk
SET pk.MAIN_CAMPUS_ONLY   = (SELECT new.MAIN_CAMPUS FROM amber new 
	WHERE pk.COURSE_NUMBER  = new.COURSE_NUMBER);


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
 
UPDATE DRUPAL.JANA_PK  SET TERM_TEXT = 'Fall',
                         TERM_NUMBER = '9',
                                YEAR = '2015'; /*If needed add WHERE 'COLUMN_NAME' IS NULL*/

/* append all association pks to course term */
 
INSERT INTO DRUPAL.DL_PROGRAM_COURSE_TERMS pct (pct.ASSOCIATION_PK, pct.TERM_NUMBER, pct.TERM_TEXT, pct.YEAR)
SELECT pk.ASSOCIATION_PK, pk.TERM_NUMBER, pk.TERM_TEXT, pk.YEAR
FROM DRUPAL.JANA_PK PK
WHERE PK.ASSOCIATION_PK IS NOT NULL; /*contact program specialists to find missing info */


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

/*update date*/
UPDATE DL_PROGRAMS 
  SET TOPICAL = REPLACE(TOPICAL, '2015-16', '2016-17');
  
  /* replace topical with fee_type  to replace both*/

UPDATE DL_COURSES SET FEE_TYPE = REPLACE(DL_COURSES.TUITION_AND_FEES, '2014-2015', '2015-2016');
 
UPDATE DL_COURSES SET TUITION_AND_FEES = REPLACE(DL_COURSES.TUITION_AND_FEES, 'Student Business Services website</a >Student Business Services Website</a>', ' Student Business Services Website</a>');
 
 
 

 
 
 
