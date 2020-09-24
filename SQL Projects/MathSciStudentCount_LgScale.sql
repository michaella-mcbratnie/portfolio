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
  --Results 1 = CPU Time: 17,980 ms, Elapsed Time: 4,691 ms

--Test Query 2: Filtering using WHERE (More appropriate since Month is not an Aggregated value)
  SELECT DATEname(month, CreationDate) AS Month, 
	  DATEPART(Year, CreationDate) AS Year,
	  COUNT(ID)
  FROM Posts
  WHERE DATENAME(month,CreationDate) IN ('June', 'July', 'August')
  GROUP BY DATEPART(Year, CreationDate) , DATENAME(Month, CreationDate) 
  --Results 2 = CPU Time: 17,818 ms (used less cpu), Elapsed Time: 4,750 ms  

--Edited Original Query: changed HAVING to a WHERE statement.
  SELECT term, 
    LEFT(course, 3) AS Course_Prefix, --used to create discipline prefix ids.
    COUNT(Student_ID) as StudentCounts
  FROM CourseRegistration
  WHERE LEFT(course, 3) in ('MAT', 'BIO', 'CHE', 'PHY', 'GSC') --Change from HAVING to WHERE to filter
  GROUP BY term, LEFT(course, 3)
  ORDER BY term, Course_prefix 
  
--Test Query 3: Removing the month value and aggregating by year == "Course Prefix Variable" and only provide the aggregate number of STEM enrollments.
  SELECT DatePart(Year, CreationDate) AS Year,
	  COUNT(Id)
  FROM Posts 
  WHERE DATENAME(Month, CreationDate) in ('July', 'June', 'August')
  GROUP BY DATEPART(Year, CreationDate)
  --RESULTS 3 = CPU Time: 18171 ms , Elapsed Time: 78507 ms (These numbers reflect querying a database with a malaligned index, therefore they no longer compare to the above.)
  --Obviously this would create a query that produces results that are not separated by "Month" or Discipline.
	--Edited Original Query 
	SELECT Term, count(student_id) as StudentCounts
	FROM CourseRegistration
	WHERE Course IN ('MAT%', 'BIO%', 'CHE%', 'PHY%', 'GSC%')
	GROUP BY Term
	
/* Potential Alternative for the above query that removes the need to use any formatting functions to create the desired data. This would require
potentially adjustments to the database to have a CourseDescription table.*/

--Test Query 4: Join instead of formatting functions. A temp. table (#1) was created with Distinct CreationDate_Date(Date), MonthofPost (month datepart), Year (Yr Datepart)
	SELECT MonthofPost, 
		yearofpost,
		COUNT(Id) as TotalPosts
	FROM Posts as p
	LEFT JOIN #1
		on p.CreationDate_Date = #1.Dateofpost
	WHERE MonthofPost IN ('June', 'July', 'August')
	GROUP BY YearofPost, MonthofPost
	--Results 4 = CPU time 11,592 ms, Elapsed Time = 3,342 ms.

  SELECT term,  
	  d.Course_Prefix, 
	  Count(StudentId) as StudentCounts
  FROM CourseRegistration as c
  LEFT JOIN CourseDescription as d --joining allows us to avoid manipulating the data from the Course column to generate a course_prefix
  	ON c.Course = d.CourseCode
  WHERE d.Course_Prefix in ('MAT', 'BIO', 'CHE', 'PHY', 'GSC')
  GROUP BY term, d.Course_prefix

SET STATISTICS TIME OFF
  
  
