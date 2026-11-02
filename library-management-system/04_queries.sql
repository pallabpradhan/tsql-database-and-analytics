USE LibraryDB;
GO

-- 1. All books with category and availability
SELECT b.BookID, b.Title, b.Author, c.CategoryName, b.AvailableCopies, b.TotalCopies
FROM Books b
JOIN Categories c ON c.CategoryID = b.CategoryID
ORDER BY c.CategoryName, b.Title;

-- 2. Currently overdue loans (uses the view)
SELECT * FROM vw_OverdueLoans ORDER BY DaysOverdue DESC;

-- 3. Most borrowed books (Top 3)
SELECT TOP 3 b.Title, COUNT(*) AS TimesBorrowed
FROM Loans l
JOIN Books b ON b.BookID = l.BookID
GROUP BY b.Title
ORDER BY TimesBorrowed DESC;

-- 4. Members who have never borrowed (LEFT JOIN + NULL check)
SELECT m.MemberID, m.FullName
FROM Members m
LEFT JOIN Loans l ON l.MemberID = m.MemberID
WHERE l.LoanID IS NULL;

-- 5. Total unpaid fines per member
SELECT m.FullName, SUM(f.Amount) AS UnpaidFines
FROM Fines f
JOIN Loans   l ON l.LoanID = f.LoanID
JOIN Members m ON m.MemberID = l.MemberID
WHERE f.Paid = 0
GROUP BY m.FullName;

-- 6. Borrowing activity by category (with share of total)
SELECT c.CategoryName,
       COUNT(l.LoanID) AS Loans,
       CAST(100.0 * COUNT(l.LoanID) / SUM(COUNT(l.LoanID)) OVER () AS DECIMAL(5,2)) AS PctOfTotal
FROM Categories c
LEFT JOIN Books b ON b.CategoryID = c.CategoryID
LEFT JOIN Loans l ON l.BookID = b.BookID
GROUP BY c.CategoryName
ORDER BY Loans DESC;

-- 7. Try the stored procedures
-- EXEC sp_IssueBook @BookID = 3, @MemberID = 1004;
-- EXEC sp_ReturnBook @LoanID = 6;
