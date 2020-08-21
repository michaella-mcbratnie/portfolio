
/* This query provides total scholarship, full-time/part-time status and major for each student enrolled during Fall 2017 */

SELECT d.student_id, 
   d.Total_scholarship, 
   d.major
   CASE WHEN d.Total_Credits >= 12 THEN 'Full-Time'
   WHEN d.Total_Credits < 12 THEN 'Part-Time'
   Else 'Other' END AS 'FT/PT Status'

FROM (SELECT m.major, 
        m.student_id,
        (SELECT sum(s.amount)
           FROM Scholarship as s
           WHERE s.student_id = m.student_id 
              AND s.term in ('2017/Fall')
          GROUP BY s.student_id) as Total_scholarship,
        (SELECT SUM(credits)
            FROM Person as p
            WHERE p.student_id = m.student_id
              AND p.term in ('2017/Fall')
            GROUP BY p.Student_ID as Total_Credits,
       FROM Major as m) as d
