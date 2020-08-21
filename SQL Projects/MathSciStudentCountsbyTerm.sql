/* This query provides the count of students taking Math and Science courses by term */

SELECT term, 
  LEFT(course, 3) AS Course_Prefix,
  COUNT(Student_ID) as StudentCounts
FROM CourseRegistration
GROUP BY term, LEFT(course, 3)
HAVING LEFT(course, 3) in ('MAT', 'BIO', 'CHE', 'PHY', 'GSC')
ORDER BY term, Course_prefix
  
