/* The goal of all of the queries below are to achieve the same end: generate a list of unduplicated 
students with the most recent term they were enrolled and their term age. Originally, query one was 
written to answer this question but it poses two problems. The two subsequent queries provide alternative 
routes to properly create the termage and select the most recent term. */

 
--Query 1(INCORRECT) Using what exists in the students table alone there and GETDATE function

SELECT StudentID, 
	Term, 
	DATEDIFF(day, Birthdate, Getdate())/365.25 as Termage --incorrect because GetDate gets today's date, therefore age of each indivual today was caluclated not term age
FROM Students as a
WHERE a.term = (SELECT MAX(b.term)--Incorrect, because term is a varchar data type using max provides the last data point based on alphabetic order
		FROM Students as b
		WHERE a.studentID=b.studentID
		GROUP BY StudentID)


--Query 2 joining Students with table with the term, and term date for calculating max term and term age

SELECT StudentID, 
	s.Term, 
	DATEDIFF(day, Birthdate, t.date)/365.25 as Termage
FROM Students as s
JOIN Terms as t
	ON s.Term = t.term
WHERE Date = (SELECT max(Date) as date
		FROM Students as sb
		JOIN terms as tb
			On sb.Term= tb.Term
		GROUP BY StudentID
		Having sb.StudentID = s.StudentID)

--Query 3: adding a rundate column to the Students table to squence the records and joining term table to draw in term.date data

SELECT StudentID,
	a.Term,
	DATEDIFF(day, Birthdate, t.Date)/365.25 AS TermAge, 
	T.Date,
	Birthdate
FROM StudentsRun a
JOIN terms as t
	ON a.term = t.Term
WHERE Rundate = (SELECT max(rundate)
		FROM StudentsRun b
		GROUP BY StudentID
		HAVING a.StudentID = b.studentId)

/*Tables used for creating / testing these queries */			
CREATE TABLE Terms(
Term varchar(255) NOT NULL Primary Key,
Date date NOT NULL);

INSERT INTO Terms
Values ('2017/Fall', '09/01/2017'),
	('2018/Winter', '01/04/2018'),
	('2018/Fall', '09/10/2018'),
	('2019/Winter','01/04/2019');

	SELECT * FROM Terms

CREATE TABLE Students(
StudentID INT NOT NULL,
Term varchar(255) NOT NULL,
Birthdate date NOT NULL,
Credits int NOT NULL);

INSERT INTO Students (StudentID, Term, Birthdate, Credits)
Values (12345, '2017/Fall', '9/12/1990', 3), 
	(12345, '2018/Winter', '9/12/1990', 6),
	(12345, '2018/Fall', '9/12/1990', 4),
	(12346, '2017/Fall', '1/13/1985', 2),
	(12346, '2018/Fall', '1/13/1985',3),
	(12347, '2018/Winter', '11/21/1999', 7),
	(12348, '2018/Fall', '06/01/1989', 8);

CREATE TABLE StudentsRun(
StudentID INT NOT NULL,
Term varchar(255) NOT NULL,
Birthdate date NOT NULL,
Credits int NOT NULL,
Rundate date NOT NULL);

INSERT INTO Studentsrun (StudentID, Term, Birthdate, Credits, Rundate)
Values (12345, '2017/Fall', '9/12/1990', 3, '09/01/2017'), 
	(12345, '2018/Winter', '9/12/1990', 6, '01/04/2018'),
	(12345, '2018/Fall', '9/12/1990', 4, '09/10/2018'),
	(12346, '2017/Fall', '1/13/1985', 2, '09/01/2017'),
	(12346, '2018/Fall', '1/13/1985',3, '09/10/2018'),
	(12347, '2018/Winter', '11/21/1999', 7, '01/04/2018'),
	(12348, '2018/Fall', '06/01/1989', 8, '09/10/2018');
