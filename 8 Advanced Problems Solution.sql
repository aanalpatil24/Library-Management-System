-- Library Management System Project

-- View tables
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task 13: Identify Members with Overdue Books
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    DATEDIFF(CURDATE(), ist.issued_date) AS over_dues_days
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND DATEDIFF(CURDATE(), ist.issued_date) > 30
ORDER BY ist.issued_member_id;

-- Task 14: Update Book Status on Return
UPDATE books
SET status = 'Yes'
WHERE isbn IN (
    SELECT t.issued_book_isbn
    FROM (
        SELECT ist.issued_book_isbn
        FROM issued_status ist
        JOIN return_status rs ON rs.issued_id = ist.issued_id
    ) AS t
);

-- Insert a return record
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES ('RS125', 'IS130', CURDATE(), 'Good');

-- MySQL Stored Procedure for Task 14
DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(15),
    IN p_issued_id VARCHAR(15),
    IN p_book_quality ENUM('Good','Damaged')
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(255);

    -- Insert into return_status
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Fetch ISBN and book name
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Output message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END$$

DELIMITER ;

-- Call Procedure
CALL add_return_records('RS138', 'IS135', 'Good');
CALL add_return_records('RS148', 'IS140', 'Good');

-- Task 15: Branch Performance Report
DROP TABLE IF EXISTS branch_reports;
CREATE TABLE branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(DISTINCT ist.issued_id) AS number_book_issued,
    COUNT(DISTINCT rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.emp_branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;

-- Task 16: Create Active Members Table
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members AS
SELECT  member_id, member_name, member_address, reg_date
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURDATE() - INTERVAL 6 MONTH
);

SELECT * FROM active_members;

-- Task 17: Top 3 Employees with Most Issues
SELECT 
    e.emp_name,
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.emp_branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.manager_id
ORDER BY no_book_issued DESC
LIMIT 3;


-- Task 18:  Identify Members Issuing High-Risk Books
SELECT 
    m.member_id,
    m.member_name,
    bk.book_title,
    COUNT(*) AS times_damaged
FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.book_quality = 'Damaged'
GROUP BY m.member_id, m.member_name, bk.book_title
HAVING COUNT(*) > 2
ORDER BY times_damaged DESC;


-- Task 19: Issue Book Procedure
DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(15),
    IN p_issued_member_id VARCHAR(15),
    IN p_issued_book_isbn VARCHAR(50),
    IN p_issued_emp_id VARCHAR(15)
)
BEGIN
     DECLARE v_status ENUM('Yes','No');

    -- Check book status
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'Yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status = 'No'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book issued successfully for book isbn: ', p_issued_book_isbn) AS message;
    ELSE
        SELECT CONCAT('Sorry, book currently unavailable. isbn: ', p_issued_book_isbn) AS message;
    END IF;
END$$

DELIMITER ;

-- Call the procedure
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');
SET SQL_SAFE_UPDATES=0;


SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';

-- Task 20: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
DROP TABLE IF EXISTS overdue_fines;
CREATE TABLE overdue_fines AS
SELECT 
    ist.issued_member_id AS member_id,
    COUNT(*) AS overdue_books,
    SUM(GREATEST(DATEDIFF(CURDATE(), ist.issued_date) - 30, 0) * 0.50) AS total_fine,
    COUNT(ist.issued_id) AS total_books_issued
FROM issued_status AS ist
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
  AND DATEDIFF(CURDATE(), ist.issued_date) > 30
GROUP BY ist.issued_member_id;

-- End of the project
    
