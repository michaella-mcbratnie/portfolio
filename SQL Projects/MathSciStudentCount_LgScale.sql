/*To expand and improve a Theoretical Query I had previously written, Test Queries were written using the StackOverFlow2013 database so that
performance could be tested on a real and larger dataset.*/

/*Original Theoretical Query: 
Goal of this query was to provide a count of students enrolled in a group of disciplines 
(Math, Biology, Chemistry etc.) by term from a table listing the individual courses (e.g. MAT1510)*/

  SELECT term, 
   LEFT(course, 3) AS Course_Prefix, --used to create discipline prefix ids.
   COUNT(Student_ID) as StudentCounts
  FROM CourseRegistration
  GROUP BY term, LEFT(course, 3)
  HAVING LEFT(course, 3) in ('MAT', 'BIO', 'CHE', 'PHY', 'GSC') --Select specific disciplines
  ORDER BY term, Course_prefix 

/*Test queries were created using StackOverflow2013 and query performance metrics (CPU time, Elapsed Time). It was hard to find varchar fields that 
would function similarly to the original query. Therefore, for Test Queries 1-3  DATEPART/DATENAME were used on the creation date. Since these alter/format the appearance 
of the data. */
SET STATISTICS TIME ON

--Test Query 1: This query uses HAVING to filter the records. 
  SELECT DATEname(month, CreationDate) AS Month, 
	  DATEPART(Year, CreationDate) AS Year,
	  COUNT(ID)
  FROM Posts
  GROUP BY DATEPART(Year, CreationDate), DATENAME(Month, CreationDate)
  HAVING DATENAME(month,CreationDate) IN ('June', 'July', 'August')
  --Results 1 = CPU Time: 23218 ms, Elapsed Time: 78522 ms

--Test Query 2: Filtering using WHERE (More appropriate since Month is not an Aggregated value)
  SELECT DATEname(month, CreationDate) AS Month, 
	  DATEPART(Year, CreationDate) AS Year,
	  COUNT(ID)
  FROM Posts
  WHERE DATENAME(month,CreationDate) IN ('June', 'July', 'August')
  GROUP BY DATEPART(Year, CreationDate) , DATENAME(Month, CreationDate) 
  --Results 2 = CPU Time: 21624 ms (used less cpu), Elapsed Time: 78413 ms  

--Test Query 3: Removing the month value and aggregating by year == "Course Prefix Variable" and only provide the aggregate number of STEM enrollments.
  SELECT DatePart(Year, CreationDate) AS Year,
	  COUNT(Id)
  FROM Posts 
  WHERE DATENAME(Month, CreationDate) in ('July', 'June', 'August')
  GROUP BY DATEPART(Year, CreationDate)
  --RESULTS 3 = CPU Time: 18171 ms , Elapsed Time: 78507 ms
  --Obviously this would create a query that produces results that are not separated by "Month" or Discipline.

--Edited Original Query: changed HAVING to a WHERE statement.
  SELECT term, 
    LEFT(course, 3) AS Course_Prefix, --used to create discipline prefix ids.
    COUNT(Student_ID) as StudentCounts
  FROM CourseRegistration
  WHERE LEFT(course, 3) in ('MAT', 'BIO', 'CHE', 'PHY', 'GSC') --Change from HAVING to WHERE to filter
  GROUP BY term, LEFT(course, 3)
  ORDER BY term, Course_prefix 

/* Potential Alternative but adjustments still need to be made to the StackOverFlow Query since CreationDate/MonthofPost creates a
table of data that has too many records and is not comparable to the function of these separate table/Join*/

  SELECT term,  
	  d.Course_Prefix, 
	  Count(StudentId) as StudentCounts
  FROM CourseRegistration as c
  LEFT JOIN CourseDescription as d --joining allows us to avoid manipulating the course column data to generate a course_prefix
  	ON c.Course = d.CourseCode
  WHERE d.Course_Prefix in ('MAT', 'BIO', 'CHE', 'PHY', 'GSC')
  GROUP BY term, d.Course_prefix
