-- Library Management System | Microsoft SQL Server (T-SQL)
IF DB_ID('LibraryDB') IS NULL CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

DROP TABLE IF EXISTS Fines;
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Categories;
GO

CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Books (
    BookID          INT IDENTITY(1,1) PRIMARY KEY,
    Title           VARCHAR(150) NOT NULL,
    Author          VARCHAR(100) NOT NULL,
    CategoryID      INT NOT NULL FOREIGN KEY REFERENCES Categories(CategoryID),
    TotalCopies     INT NOT NULL CHECK (TotalCopies >= 0),
    AvailableCopies INT NOT NULL,
    CONSTRAINT CK_Books_Available CHECK (AvailableCopies BETWEEN 0 AND TotalCopies)
);

CREATE TABLE Members (
    MemberID INT IDENTITY(1001,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email    VARCHAR(100) NOT NULL UNIQUE,
    Phone    VARCHAR(15),
    JoinDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
);

CREATE TABLE Loans (
    LoanID     INT IDENTITY(1,1) PRIMARY KEY,
    BookID     INT NOT NULL FOREIGN KEY REFERENCES Books(BookID),
    MemberID   INT NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
    IssueDate  DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate    DATE NOT NULL,
    ReturnDate DATE NULL,
    CONSTRAINT CK_Loans_Due CHECK (DueDate >= IssueDate)
);

CREATE TABLE Fines (
    FineID INT IDENTITY(1,1) PRIMARY KEY,
    LoanID INT NOT NULL FOREIGN KEY REFERENCES Loans(LoanID),
    Amount DECIMAL(8,2) NOT NULL CHECK (Amount > 0),
    Paid   BIT NOT NULL DEFAULT 0
);

CREATE INDEX IX_Loans_Member ON Loans(MemberID);
CREATE INDEX IX_Loans_Book   ON Loans(BookID);
GO
