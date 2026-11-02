USE LibraryDB;
GO

INSERT INTO Categories (CategoryName) VALUES
('Programming'), ('Database'), ('Data Science'), ('Fiction'), ('Self Help');

INSERT INTO Books (Title, Author, CategoryID, TotalCopies, AvailableCopies) VALUES
('Let Us C',                     'Yashavant Kanetkar', 1, 5, 5),
('Head First Java',              'Kathy Sierra',       1, 3, 3),
('Python Crash Course',          'Eric Matthes',       1, 4, 4),
('SQL in 10 Minutes',            'Ben Forta',          2, 3, 3),
('Database System Concepts',     'Silberschatz',       2, 2, 2),
('Python for Data Analysis',     'Wes McKinney',       3, 2, 2),
('The Alchemist',                'Paulo Coelho',       4, 4, 4),
('Atomic Habits',                'James Clear',        5, 3, 3);

INSERT INTO Members (FullName, Email, Phone, JoinDate) VALUES
('Ankita Das',     'ankita@example.com',  '9000000001', '2025-06-10'),
('Rohit Sahu',     'rohit@example.com',   '9000000002', '2025-07-15'),
('Sneha Mohanty',  'sneha@example.com',   '9000000003', '2025-08-01'),
('Amit Nayak',     'amit@example.com',    '9000000004', '2026-01-20'),
('Priya Behera',   'priya@example.com',   '9000000005', '2026-02-11');

-- Historical returned loans (some late -> fines)
INSERT INTO Loans (BookID, MemberID, IssueDate, DueDate, ReturnDate) VALUES
(1, 1001, '2026-03-01', '2026-03-15', '2026-03-14'),
(4, 1002, '2026-03-05', '2026-03-19', '2026-03-25'),
(3, 1003, '2026-04-02', '2026-04-16', '2026-04-16'),
(7, 1001, '2026-04-10', '2026-04-24', '2026-05-02'),
(6, 1004, '2026-05-01', '2026-05-15', '2026-05-12');

-- Currently open loans (old dates so they show as overdue)
INSERT INTO Loans (BookID, MemberID, IssueDate, DueDate, ReturnDate) VALUES
(2, 1002, '2026-09-01', '2026-09-15', NULL),
(4, 1005, '2026-09-05', '2026-09-19', NULL),
(8, 1003, '2026-10-20', '2026-11-03', NULL);

INSERT INTO Fines (LoanID, Amount, Paid) VALUES (2, 30, 1), (4, 40, 0);

-- Sync stock with open loans
UPDATE b
SET AvailableCopies = b.TotalCopies -
    (SELECT COUNT(*) FROM Loans l WHERE l.BookID = b.BookID AND l.ReturnDate IS NULL)
FROM Books b;
GO
