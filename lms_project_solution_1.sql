-- SQL Project - Library Management System N2

-- View tables
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- Task 1: Create a New Book Record
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table
SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Employees Who Have Issued More Than One Book
SELECT 
    ist.issued_emp_id,
    e.emp_name,
    COUNT(ist.issued_id) AS issued_count
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
GROUP BY ist.issued_emp_id, e.emp_name
HAVING COUNT(ist.issued_id) > 1;

-- Task 6: Create Summary Table of Book Issue Counts (CTAS)
CREATE TABLE book_cnts AS    
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status AS ist ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_cnts;

-- Task 7: Retrieve All Books in a Specific Category
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category
SELECT
    b.category,
    SUM(b.rental_price) AS total_income,
    COUNT(*) AS issue_count
FROM books AS b
JOIN issued_status AS ist ON ist.issued_book_isbn = b.isbn
GROUP BY b.category;

-- Task 9: List Members Who Registered in the Last 180 Days
SELECT * FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Insert new members (if needed)
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C118', 'sam', '145 Main St', '2024-06-01'),
('C119', 'john', '133 Main St', '2024-05-01');

-- Task 10: List Employees with Their Branch Manager's Name and Branch Details
SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b ON b.branch_id = e1.branch_id
JOIN employees AS e2 ON b.manager_id = e2.emp_id;

-- Task 11: Create Table of Books with Rental Price > 7 USD
CREATE TABLE books_price_greater_than_seven AS    
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_seven;

-- Task 12: Retrieve List of Books Not Yet Returned
SELECT DISTINCT ist.issued_book_name
FROM issued_status AS ist
LEFT JOIN return_status AS rs ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

SELECT * FROM return_status;
