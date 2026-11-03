-- =========================================================================
-- Microsoft SQL Server (T-SQL) Setup Script
-- Project: Real-Time Cricket Match & Player Analytics Engine
-- Security: Enforces ACID Transactions, Foreign Keys, and Parameterized SPs
-- =========================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CricketAnalyticsDB')
BEGIN
    CREATE DATABASE CricketAnalyticsDB;
END
GO

USE CricketAnalyticsDB;
GO

-- Drop existing tables if resetting
IF OBJECT_ID('dbo.BallByBall', 'U') IS NOT NULL DROP TABLE dbo.BallByBall;
IF OBJECT_ID('dbo.Players', 'U') IS NOT NULL DROP TABLE dbo.Players;
IF OBJECT_ID('dbo.Matches', 'U') IS NOT NULL DROP TABLE dbo.Matches;
GO

-- 1. Matches Table
CREATE TABLE dbo.Matches (
    MatchID INT IDENTITY(1,1) PRIMARY KEY,
    TeamA NVARCHAR(50) NOT NULL,
    TeamB NVARCHAR(50) NOT NULL,
    Venue NVARCHAR(100) NOT NULL,
    TargetScore INT NOT NULL CHECK (TargetScore > 0),
    MatchDate DATETIME DEFAULT GETDATE()
);
GO

-- 2. Players Table
CREATE TABLE dbo.Players (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    TeamName NVARCHAR(50) NOT NULL,
    PlayerRole NVARCHAR(30) NOT NULL CHECK (PlayerRole IN ('Batter', 'Bowler', 'All-Rounder', 'Wicketkeeper'))
);
GO

-- 3. BallByBall Table (Transactional Fact Table)
CREATE TABLE dbo.BallByBall (
    DeliveryID INT IDENTITY(1,1) PRIMARY KEY,
    MatchID INT NOT NULL FOREIGN KEY REFERENCES dbo.Matches(MatchID),
    OverNumber INT NOT NULL CHECK (OverNumber BETWEEN 1 AND 20),
    BallNumber INT NOT NULL CHECK (BallNumber BETWEEN 1 AND 10),
    BatterID INT NOT NULL FOREIGN KEY REFERENCES dbo.Players(PlayerID),
    BowlerID INT NOT NULL FOREIGN KEY REFERENCES dbo.Players(PlayerID),
    RunsScored INT NOT NULL DEFAULT 0 CHECK (RunsScored BETWEEN 0 AND 6),
    ExtraRuns INT NOT NULL DEFAULT 0 CHECK (ExtraRuns >= 0),
    IsWicket BIT NOT NULL DEFAULT 0,
    DismissalType NVARCHAR(50) NULL,
    Timestamp DATETIME DEFAULT GETDATE()
);
GO

-- 4. Stored Procedure: ACID Transactional Delivery Logger
CREATE OR ALTER PROCEDURE dbo.sp_RecordDelivery
    @MatchID INT,
    @OverNumber INT,
    @BallNumber INT,
    @BatterID INT,
    @BowlerID INT,
    @RunsScored INT,
    @ExtraRuns INT = 0,
    @IsWicket BIT = 0,
    @DismissalType NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO dbo.BallByBall (
            MatchID, OverNumber, BallNumber, BatterID, BowlerID, 
            RunsScored, ExtraRuns, IsWicket, DismissalType
        )
        VALUES (
            @MatchID, @OverNumber, @BallNumber, @BatterID, @BowlerID, 
            @RunsScored, @ExtraRuns, @IsWicket, @DismissalType
        );
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 5. Seed Initial Real-World Sample Data
INSERT INTO dbo.Matches (TeamA, TeamB, Venue, TargetScore)
VALUES ('India', 'Australia', 'Wankhede Stadium, Mumbai', 186);

INSERT INTO dbo.Players (FullName, TeamName, PlayerRole) VALUES
('Virat Kohli', 'India', 'Batter'),
('Hardik Pandya', 'India', 'All-Rounder'),
('Rishabh Pant', 'India', 'Wicketkeeper'),
('Pat Cummins', 'Australia', 'Bowler'),
('Mitchell Starc', 'Australia', 'Bowler'),
('Adam Zampa', 'Australia', 'Bowler');
GO
