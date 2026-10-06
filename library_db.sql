#Created a new DATABASE
CREATE DATABASE library_db;

#switching DB
USE library_db;

#creating table 1
CREATE TABLE authors(
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);

#table 2
CREATE TABLE books(
    book_id INT AUTO_INCREMENT  PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author_id INT NOT NULL,
    published_year INT,
    available_copies INT DEFAULT 1 CHECK (available_copies >= 0),
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);



#table 3
CREATE TABLE members(
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE NOT NULL
);


#table 4
CREATE TABLE loans(
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    return_date DATE NUll,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
    );

-- 1. Insert Authors (15 rows)
INSERT INTO authors (author_name, country) VALUES
('George Orwell', 'United Kingdom'),
('J.K. Rowling', 'United Kingdom'),
('F. Scott Fitzgerald', 'United States'),
('Jane Austen', 'United Kingdom'),
('Mark Twain', 'United States'),
('Agatha Christie', 'United Kingdom'),
('Gabriel García Márquez', 'Colombia'),
('Haruki Murakami', 'Japan'),
('Leo Tolstoy', 'Russia'),
('Ernest Hemingway', 'United States'),
('Virginia Woolf', 'United Kingdom'),
('Franz Kafka', 'Czech Republic'),
('Toni Morrison', 'United States'),
('Chinua Achebe', 'Nigeria'),
('Arthur Conan Doyle', 'United Kingdom');

-- 2. Insert Books (20 rows)
INSERT INTO books (title, author_id, published_year, available_copies) 
VALUES
('1984', 1, 1949, 4),
('Animal Farm', 1, 1945, 2),
('Harry Potter and the Sorcerer''s Stone', 2, 1997, 6),
('Harry Potter and the Chamber of Secrets', 2, 1998, 3),
('The Great Gatsby', 3, 1925, 0),
('Pride and Prejudice', 4, 1813, 5),
('Sense and Sensibility', 4, 1811, 2),
('Adventures of Huckleberry Finn', 5, 1884, 3),
('The Adventures of Tom Sawyer', 5, 1876, 1),
('And Then There Were None', 6, 1939, 4),
('Murder on the Orient Express', 6, 1934, 0),
('One Hundred Years of Solitude', 7, 1967, 3),
('Norwegian Wood', 8, 1987, 2),
('Kafka on the Shore', 8, 2002, 5),
('War and Peace', 9, 1869, 1),
('The Old Man and the Sea', 10, 1952, 4),
('Mrs Dalloway', 11, 1925, 0),
('The Metamorphosis', 12, 1915, 2),
('Beloved', 13, 1987, 3),
('Things Fall Apart', 14, 1958, 5);

-- 3. Insert Members (15 rows)
INSERT INTO members (full_name, email, join_date) 
VALUES
('Alice Johnson', 'alice.johnson@mail.com', '2026-01-10'),
('Bob Smith', 'bob.smith@inbox.org', '2026-01-15'),
('Charlie Brown', 'charlie.brown@reader.net', '2026-01-20'),
('Diana Prince', 'diana.prince@mail.com', '2026-02-01'),
('Ethan Hunt', 'ethan.hunt@inbox.org', '2026-02-05'),
('Fiona Gallagher', 'fiona.g@reader.net', '2026-02-14'),
('George Clark', 'george.clark@mail.com', '2026-02-20'),
('Hannah Abbott', 'hannah.a@inbox.org', '2026-03-01'),
('Ian Malcolm', 'ian.malcolm@reader.net', '2026-03-05'),
('Julia Roberts', 'julia.r@mail.com', '2026-03-12'),
('Kevin Bacon', 'kevin.bacon@inbox.org', '2026-03-15'),
('Laura Croft', 'laura.croft@reader.net', '2026-03-20'),
('Michael Scott', 'michael.scott@mail.com', '2026-03-22'),
('Nina Simone', 'nina.simone@inbox.org', '2026-03-28'),
('Oscar Martinez', 'oscar.m@reader.net', '2026-04-01');

-- 4. Insert Loans (15 rows)
INSERT INTO loans (book_id, member_id, loan_date, return_date) VALUES
(1, 1, '2026-03-01', '2026-03-15'),
(3, 2, '2026-03-05', NULL),
(6, 3, '2026-03-08', '2026-03-22'),
(8, 4, '2026-03-10', NULL),
(10, 5, '2026-03-12', '2026-03-26'),
(12, 6, '2026-03-15', NULL),
(2, 7, '2026-03-18', '2026-03-30'),
(4, 8, '2026-03-20', NULL),
(13, 9, '2026-03-22', '2026-04-02'),
(14, 10, '2026-03-25', NULL),
(16, 11, '2026-03-28', NULL),
(18, 12, '2026-03-29', '2026-04-03'),
(20, 13, '2026-04-01', NULL),
(7, 14, '2026-04-02', NULL),
(9, 15, '2026-04-03', NULL);


#authors table
SELECT * 
FROM authors;


#books table  
SELECT * 
FROM books;


#members table  
SELECT * 
FROM members;

#loan table 
SELECT * 
FROM loans;




#Task 1: Inventory Stock & Age Filter

SELECT
    title,
    published_year,
    available_copies
FROM 
    books
WHERE 
    published_year < 1950 AND
    available_copies >= 1
ORDER BY
    published_year DESC;


#Task 2: Active Borrowings (Null Check)

SELECT 
    loan_id,
    book_id,
    member_id,
    loan_date
FROM
    loans
WHERE 
    return_date IS NULL;


#Task 3: Borrow Duration Analysis (Date Difference)

SELECT
    loan_id,
    loan_date,
    return_date,
    DATEDIFF(return_date, loan_date) AS days_kept
FROM 
    loans
WHERE 
    return_date IS NOT NULL;


#Task 4: Member Audit & Email Formatting
SELECT 
    member_id,
    UPPER(full_name) AS member_name_upper,
    REPLACE(email,'@mail.com','@library.org') AS domain_check
FROM 
    members;


#Task 5: Loan Due Date Calculation (Interval Math)
SELECT
    loan_id,
    loan_date,
    DATE_ADD(loan_date, INTERVAL 14 DAY) AS due_date
FROM 
    loans;


#Task 6: Record a Return (Data Modification)
UPDATE 
    loans
SET    
    return_date = CURDATE()
WHERE
    loan_id = 2;


#Task 7: Cascade Delete Demonstration
DELETE FROM authors
WHERE
    author_id = 1;

SELECT 
    author_id
FROM
    books
WHERE
    author_id = 1;










