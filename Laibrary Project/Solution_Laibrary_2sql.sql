use laibrary;

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


--Task 13: 
--Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT ist.issued_member_id,m.member_name, ist.issued_date, bk.book_title, rs.return_date,
 DATEDIFF(day, ist.issued_date, GETDATE()) AS Over_Due_Days
FROM issued_status AS ist 
JOIN members AS m ON m.member_id = ist.issued_member_id 
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL 
AND DATEDIFF(day, ist.issued_date, GETDATE()) > 30 
ORDER BY Over_Due_Days DESC;


--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
UPDATE Books
SET status = 'Yes'
WHERE isbn IN (SELECT ist.issued_book_isbn FROM issued_status as ist
JOIN return_status rs ON ist.issued_id = rs.issued_id);

SELECT isbn, book_title, status FROM Books WHERE status = 'Yes';

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, 
--the number of books returned, and the total revenue generated from book rentals.
SELECT b.branch_id, b.manager_id,
COUNT(ist.issued_id) as number_book_issued,
COUNT(rs.return_id) as number_of_book_return,
SUM(bk.rental_price) as total_revenue
into branch_reports
FROM issued_status as ist
JOIN employees as e ON e.emp_id = ist.issued_emp_id
JOIN branch as b
ON e.branch_id = b.branch_id LEFT JOIN
return_status as rs ON rs.issued_id = ist.issued_id
JOIN books as bk
ON ist.issued_book_isbn = bk.isbn GROUP BY b.branch_id, b.manager_id ;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE VIEW Active_Members AS SELECT * FROM members 
WHERE member_id IN (SELECT DISTINCT issued_member_id FROM issued_status WHERE issued_date >= DATEADD(MONTH, -2, GETDATE()));
SELECT * FROM Active_Members;
