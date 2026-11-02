USE LibraryDB;
GO

-- Issue a book for 14 days (checks availability, updates stock atomically)
CREATE OR ALTER PROCEDURE sp_IssueBook
    @BookID INT,
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID = @MemberID)
    BEGIN RAISERROR('Member not found.', 16, 1); RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        UPDATE Books
        SET AvailableCopies = AvailableCopies - 1
        WHERE BookID = @BookID AND AvailableCopies > 0;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK;
            RAISERROR('Book not found or no copies available.', 16, 1);
            RETURN;
        END

        INSERT INTO Loans (BookID, MemberID, IssueDate, DueDate)
        VALUES (@BookID, @MemberID,
                CAST(GETDATE() AS DATE),
                DATEADD(DAY, 14, CAST(GETDATE() AS DATE)));
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- Return a book; adds a fine of Rs.5 per overdue day
CREATE OR ALTER PROCEDURE sp_ReturnBook
    @LoanID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BookID INT, @Due DATE, @Ret DATE;
    SELECT @BookID = BookID, @Due = DueDate, @Ret = ReturnDate
    FROM Loans WHERE LoanID = @LoanID;

    IF @BookID IS NULL BEGIN RAISERROR('Loan not found.', 16, 1); RETURN; END
    IF @Ret IS NOT NULL BEGIN RAISERROR('Book already returned.', 16, 1); RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        DECLARE @Today DATE = CAST(GETDATE() AS DATE);
        DECLARE @LateDays INT = DATEDIFF(DAY, @Due, @Today);

        UPDATE Loans SET ReturnDate = @Today WHERE LoanID = @LoanID;
        UPDATE Books SET AvailableCopies = AvailableCopies + 1 WHERE BookID = @BookID;

        IF @LateDays > 0
            INSERT INTO Fines (LoanID, Amount) VALUES (@LoanID, @LateDays * 5);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- Currently overdue loans with estimated fine
CREATE OR ALTER VIEW vw_OverdueLoans AS
SELECT  l.LoanID,
        m.FullName,
        m.Phone,
        b.Title,
        l.DueDate,
        DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE))     AS DaysOverdue,
        DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) * 5 AS EstimatedFine
FROM Loans l
JOIN Members m ON m.MemberID = l.MemberID
JOIN Books   b ON b.BookID   = l.BookID
WHERE l.ReturnDate IS NULL
  AND l.DueDate < CAST(GETDATE() AS DATE);
GO
