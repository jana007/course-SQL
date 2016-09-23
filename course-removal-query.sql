/****************************************
 query course for removal in one command
  provide course number, year and term
*****************************************/

SELECT x.course_title   AS CName, 
       x.course_number  AS CNumber, 
       x.course_pk      AS CPK, 
       x.DEPARTMENT_NAME,
       y.association_pk AS Assoc, 
       y.program_pk     AS AssocProg, 
       z.program_name,
       y.main_campus_only
FROM   dl_courses x 
       join dl_program_course_association y 
         ON x.course_pk = y.course_pk 
            AND x.course_number in ( 'CEG5115', 'EGN5458'

 )
       join DL_PROGRAM_COURSE_TERMS ct
         ON y.ASSOCIATION_PK = ct.ASSOCIATION_PK
            AND ct.YEAR = 2016
            AND ct.TERM_NUMBER = 9
       join dl_programs z 
         ON y.program_pk = z.program_pk
WHERE  y.program_pk IN (SELECT DISTINCT program_pk 
                        FROM   dl_programs) 

ORDER  BY x.course_title, y.ASSOCIATION_PK desc;

INSERT INTO DL_PROGRAM_COURSE_TERMS (ASSOCIATION_PK, TERM_NUMBER, TERM_TEXT, YEAR)
  VALUES (5123, 9, 'Fall', 2016);

INSERT INTO DL_COURSES (COURSE_NUMBER, CREDIT_HOURS, COURSE_TITLE, COURSE_DESCRIPTION)
  VALUES ('EDG5206', 3, 'Teachers and Curriculum Development', 'his course explores the challenges of curricular design from the institutional role of the teacher and analyzes how a teacher can become an effective contributor in curricular deliberation within the settings of schools and school districts.')
  ;
SELECT * FROM DL_PROGRAMS;
SELECT * FROM DL_COURSES WHERE COURSE_NUMBER = 'S';

INSERT INTO DL_PROGRAM_COURSE_ASSOCIATION (COURSE_PK, PROGRAM_PK, MAIN_CAMPUS_ONLY)
  VALUES (3678, 604, 'n');

select * from DL_PROGRAM_COURSE_TERMS where ASSOCIATION_PK = 1784;
/****************************************
      delete desired course num from
            previous query
    user inpit: association_pk, year
           and term_number
*****************************************/

DELETE FROM DL_PROGRAM_COURSE_TERMS WHERE ASSOCIATION_PK = 5094 AND year = 2016 AND TERM_NUMBER = 9;

/****************************************
        save point in case wrong
           course removed
****************************************/

SAVEPOINT course_rem;
ROLLBACK TO SAVEPOINT course_rem;

SELECT ASSOCIATION_PK,
       TERM_TEXT,
       YEAR
FROM dl_program_course_terms WHERE association_pk = 1234;  --user specified association_pk


select * from dl_program_course_association where program_pk = 564;


SELECT x.course_title   AS CName, 
       x.course_number  AS CNumber, 
       x.course_pk      AS CPK, 
       y.association_pk AS Assoc, 
       y.program_pk     AS AssocProg, 
       y.CORE_COURSE    AS core,
       z.program_name 
FROM   dl_courses x 
       join dl_program_course_association y 
         ON x.course_pk = y.course_pk 
            AND y.program_pk = 564
       join dl_programs z 
         ON y.program_pk = z.program_pk 
WHERE  y.program_pk IN (SELECT DISTINCT program_pk 
                        FROM   dl_programs) 
ORDER  BY x.course_title, y.ASSOCIATION_PK desc;

select course_title, course_pk, course_number from dl_courses where course_number in ('EDF6493', 'EDA6105', 'EDF6xxx');

select course_title, course_pk, course_number from dl_courses where course_pk = 3143;
update DL_PROGRAM_COURSE_ASSOCIATION set core_course = '' where ASSOCIATION_PK = 3984;

update DL_COURSES set 
    COURSE_TITLE = 'Laboratory of Practice Forum II'
where course_pk = 3143;

update DL_PROGRAM_COURSE_ASSOCIATION set core_course = '' where association_pk = 3984;

select * from dl_programs where program_pk = 564;

update dl_programs set COORDINATOR_NAME = 'Kristal Moore Clemons, Ph.D.',
    COORDINATOR_EMAIL = 'Kristal.Clemons@fsu.edu',
    COORDINATOR_PHONE = '850-644-8176',
    ADMISSIONS_CONTACT_EMAIL = 'ljlyons@fsu.edu',
    ADMISSIONS_CONTACT_NAME = 'Linda Lyons',
    ADMISSIONS_CONTACT_PHONE = '850-644-7077'
where program_pk = 564;

select distinct department_name from sam_FA16;

update JANA_PK set MAIN_CAMPUS_ONLY = 'y' where course_number in ('EDE5266', 'MAE5691', 'TSL4324', 'EEX4770');

