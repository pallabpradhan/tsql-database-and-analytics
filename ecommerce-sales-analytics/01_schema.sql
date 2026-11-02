-- E-Commerce Sales Analytics | Microsoft SQL Server (T-SQL)
IF DB_ID('ShopDB') IS NULL CREATE DATABASE ShopDB;
GO
USE ShopDB;
GO

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName   VARCHAR(100) NOT NULL,
    City       VARCHAR(50)  NOT NULL,
    Email      VARCHAR(100) NOT NULL UNIQUE,
    SignupDate DATE NOT NULL
);

CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category    VARCHAR(50)  NOT NULL,
    Price       DECIMAL(10,2) NOT NULL CHECK (Price > 0)
);

CREATE TABLE Orders (
    OrderID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate  DATE NOT NULL,
    Status     VARCHAR(20) NOT NULL
               CHECK (Status IN ('Delivered','Shipped','Cancelled'))
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID   INT NOT NULL FOREIGN KEY REFERENCES Products(ProductID),
    Quantity    INT NOT NULL CHECK (Quantity > 0),
    UnitPrice   DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0)
);

CREATE INDEX IX_Orders_Customer ON Orders(CustomerID);
CREATE INDEX IX_Orders_Date     ON Orders(OrderDate);
CREATE INDEX IX_Items_Order     ON OrderItems(OrderID);
CREATE INDEX IX_Items_Product   ON OrderItems(ProductID);
GO
