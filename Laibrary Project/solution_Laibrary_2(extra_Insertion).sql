use laibrary;

select *from issued_status;
select * from return_status;

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', dateadd(day,-180, getdate()),  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', dateadd(day,-20, getdate()),  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', dateadd(day,-10, getdate()),  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', dateadd(day,-18, getdate()),  '978-0-375-50167-0', 'E101');

alter table return_status add book_quality varchar(15) default 'Good';
update return_status set book_quality= 'GOOD'  where book_quality is NULL;--where book_quality= 'Good';


--alter table return_status drop column book_quality;
--ALTER TABLE return_status DROP CONSTRAINT DF__return_st__book___5BE2A6F2;


update return_status set book_quality= 'Damaged' where issued_id IN ('IS112', 'IS117', 'IS118');
select * from return_status;