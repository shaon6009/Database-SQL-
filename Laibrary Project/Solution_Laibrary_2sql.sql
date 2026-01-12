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