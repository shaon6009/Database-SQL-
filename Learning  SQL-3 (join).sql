create database University;
use university;

CREATE TABLE student (
    student_id INT PRIMARY KEY,
    name VARCHAR(50),
    course_id INT
);

CREATE TABLE teacher (
    teacher_id INT PRIMARY KEY,
    name VARCHAR(50),
    course_id INT
);

CREATE TABLE course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50)
);


INSERT INTO student VALUES
(101, 'Rafi', 1),
(102, 'Sadia', 2),
(103, 'Tanvir', 3),
(104, 'Mithila', 2),
(105, 'Asha', 4);

INSERT INTO course VALUES
(1, 'Database Systems'),
(2, 'Data Science'),
(3, 'Web Development'),
(4, 'AI Fundamentals');

INSERT INTO teacher VALUES
(201, 'Dr. Rahman', 1),
(202, 'Dr. Karim', 2),
(203, 'Dr. Sultana', 4),
(204, 'Dr. Hasan', 5); 



select * from student;
select * from course;
select * from teacher;

-- Inner JOIN
select * from student inner join course on student.course_id= course.course_id;

-- Left JOIN
select * from teacher left join course on teacher.course_id= course.course_id;
select * from teacher left join course on teacher.course_id= course.course_id where course.course_id is null;

-- Right JOIN
select * from teacher right join course on teacher.course_id= course.course_id;

-- Full JOIN
SELECT * FROM teacher LEFT JOIN course ON teacher.course_id = course.course_id
UNION ALL
SELECT * FROM teacher RIGHT JOIN course ON teacher.course_id = course.course_id;

-- Cross JOIN
select * from student CROSS JOIN course;

-- 3 table join fully
SELECT 
    student.student_id,student.name AS student_name,course.course_name,teacher.name AS teacher_name
FROM student INNER JOIN course ON student.course_id = course.course_id
INNER JOIN teacher ON course.course_id = teacher.course_id;


-- 3 table is in 1 table
CREATE TABLE student_info (
    student_id INT,
    student_name VARCHAR(50),
    course_id INT,
    course_name VARCHAR(100),
    teacher_id INT,
    teacher_name VARCHAR(50)
);
INSERT INTO student_info (student_id, student_name, course_id, course_name, teacher_id, teacher_name)
SELECT 
    s.student_id,
    s.name AS student_name,
    c.course_id,
    c.course_name,
    t.teacher_id,
    t.name AS teacher_name
FROM student AS s
INNER JOIN course AS c ON s.course_id = c.course_id
INNER JOIN teacher AS t ON c.course_id = t.course_id;
SELECT * FROM student_info;

-- self join      
select * 
from student as a
join student as b
on a.student_id= b.course_id


