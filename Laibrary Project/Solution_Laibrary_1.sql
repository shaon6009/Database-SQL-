use laibrary;

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Task 2: Update an Existing Member's Address
update members set member_address= '125 Main St'
where member_id= 'C101';
select * from members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
select * from issued_status where issued_id= 'IS121';

delete from issued_status WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book. Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id, emp_name from issued_status 
join employees on employees.emp_id= issued_status.issued_emp_id 
group by issued_emp_id, emp_name having count(issued_status.issued_emp_id)>2;

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE VIEW book_cnts_view AS 
SELECT b.isbn, b.book_title, COUNT(i.issued_id) AS no_issued 
FROM books b 
JOIN issued_status i ON b.isbn = i.issued_book_isbn 
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_cnts_view;

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

    
-- Task 8: Find Total Rental Income by Category:
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.category;

-- List Members Who Registered in the Last 180 Days:
select *from members where reg_date >= DATEADD(day, -180, GETDATE());

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C118', 'sam', '145 Main St', '2024-06-01'),
('C119', 'john', '133 Main St', '2024-05-01');

-- task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT * INTO books_price_greater_than_seven 
FROM Books WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs ON ist.issued_id = rs.issued_id WHERE rs.return_id IS NULL;
   
SELECT * FROM return_status;