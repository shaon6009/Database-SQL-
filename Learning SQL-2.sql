CREATE DATABASE college;
USE college;

CREATE TABLE student (
    rollno INT PRIMARY KEY,
    name VARCHAR(50),
    marks INT NOT NULL,
    grade VARCHAR(50),
    city VARCHAR(20)
);

create table dept(
	id int primary key,
    name varchar(100)
);
create table teacher(
	id int primary key,
    name varchar(50),
    dept_id int, foreign key (dept_id) references dept(id) 
    on update cascade
    on delete cascade -- for changing both table
);

INSERT INTO student (rollno, name, marks, grade, city)
VALUES
(101, 'anil', 78, 'C', 'Pune'),
(102, 'bhumika', 93, 'A', 'Mumbai'),
(103, 'chetan', 85, 'B', 'Mumbai'),
(104, 'dhruv', 96, 'A', 'Delhi'),
(105, 'emanuel', 12, 'F', 'Delhi'),
(106, 'farah', 82, 'B', 'Delhi');

select * from student;
select name, marks from student;

select distinct city from student; -- with distinct city will not be repeated

select * from student where marks>80 and city="Mumbai";
select * from student where city in ("Mumbai","Delhi","Gurgaon");
select * from student limit 3;
select * from student order by city asc;
select * from student order by city desc;
select max(marks) from student;
select min(marks) from student;
select count(marks) from student; 
select sum(marks) from student;
select avg(marks) from student;

select distinct city from student;
select city, count(name) from student group by city;
select city, count(name) from student group by city order by avg(marks);
select city, count(name) from student group by city having max(marks)>90;
-- | Clause   | Used for                                 | Example                  |
-- | -------- | ---------------------------------------- | ------------------------ |
-- | `WHERE`  | filter individual rows before grouping   | `WHERE marks > 90`       |
-- | `HAVING` | filter grouped results after aggregation | `HAVING AVG(marks) > 90` |


Alter table student modify grade varchar(10);
set sql_safe_updates=0;
update student set grade= "Shaon" where grade= "B";
update student set grade= "Rakibul" where marks between 70 and 90;
update student set marks= marks+1;
select * from student;

delete from student where marks<33;
set sql_safe_update=1;

alter table student add column age int;
alter table student drop column age;
alter table student add column age int not null default 19;
alter table student modify age varchar(2);
alter table student change age stu_age int;
alter table student rename  stu;
alter table stu rename student;

truncate table student; -- delete the data not the column



select name, marks from student where marks> (select avg(marks) from student);
select max(marks) from (select * from student where  city = 'Delhi') as temp;
SELECT name, marks
FROM student WHERE city = 'Delhi' AND marks = (SELECT MAX(marks) FROM student WHERE city = 'Delhi');

create view view1 as 
select rollno, name, marks from student;
select * from view1;