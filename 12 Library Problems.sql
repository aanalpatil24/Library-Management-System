-- Library Management System Project

--  ### 1. Create Database Setup.

-- Create and select the database
CREATE DATABASE IF NOT EXISTS Library;
USE Library;

-- Drop and create 'branch' table 
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
    branch_id VARCHAR(15) PRIMARY KEY,
    manager_id VARCHAR(15) NOT NULL,
    branch_address VARCHAR(255) NOT NULL,
    contact_no VARCHAR(15) NOT NULL
);

-- Drop and create 'employees' table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id VARCHAR(15) PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    position VARCHAR(25),
    salary DECIMAL(10,2),
    branch_id VARCHAR(15),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
	FOREIGN KEY (emp_id) REFERENCES branch(manager_id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

-- Drop and create 'members' table
DROP TABLE IF EXISTS members;
CREATE TABLE members (
    member_id VARCHAR(15) PRIMARY KEY,
    member_name VARCHAR(50) NOT NULL,
    member_address VARCHAR(255),
    reg_date DATE
);

-- Drop and create 'books' table
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn VARCHAR(100) PRIMARY KEY,
    book_title VARCHAR(255) NOT NULL,
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status ENUM ('Yes','No') DEFAULT 'Yes',  -- 'Yes' available, 'No' issued
    author VARCHAR(50),
    publisher VARCHAR(100)
);

-- Drop and create 'issued_status' table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
    issued_id VARCHAR(15) PRIMARY KEY,
    issued_member_id VARCHAR(15) NOT NULL,
    issued_book_name VARCHAR(255),
    issued_date DATE,
    issued_book_isbn VARCHAR(100),
    issued_emp_id VARCHAR(15),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id)
        ON DELETE CASCADE 
		ON UPDATE CASCADE,
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

-- Drop and create 'return_status' table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id VARCHAR(15) PRIMARY KEY,
    issued_id VARCHAR(15) NOT NULL,
    return_book_name VARCHAR(255),
    return_date DATE,
    return_book_isbn VARCHAR(100),
    book_quality ENUM('Good', 'Damaged') DEFAULT 'Good',
    FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);



Project Tasks :-


### 2. CRUD Operations


Task 1. Create a New Book Record.
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

Task 2: Update an Existing Member''s Address.


Task 3: Delete a Record from the Issued Status Table.
Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

Task 4: Retrieve All Books Issued by a Specific Employee.
Objective: Select all books issued by the employee with emp_id = 'E101'.


Task 5: List Members Who Have Issued More Than One Book.
Objective: Use GROUP BY to find members who have issued more than one book.


### 3. CTAS (Create Table As Select)

Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt.


### 4. Data Analysis & Findings.

Task 7. Retrieve All Books in a Specific Category.

Task 8: Find Total Rental Income by Category.

Task 9. List Members Who Registered in the Last 180 Days.

Task 10: List Employees with Their Branch Manager''s Name and their branch details.

Task 11. Create a Table of Books with Rental Price Above a Certain Threshold.

Task 12: Retrieve the List of Books Not Yet Returned.
