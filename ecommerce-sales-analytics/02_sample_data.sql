USE ShopDB;
GO

INSERT INTO Customers (FullName, City, Email, SignupDate) VALUES
('Ankita Das',    'Bhubaneswar', 'ankita@example.com', '2025-11-05'),
('Rohit Sahu',    'Cuttack',     'rohit@example.com',  '2025-12-12'),
('Sneha Mohanty', 'Puri',        'sneha@example.com',  '2026-01-08'),
('Amit Nayak',    'Bhubaneswar', 'amit@example.com',   '2026-01-25'),
('Priya Behera',  'Rourkela',    'priya@example.com',  '2026-02-14'),
('Kiran Patra',   'Cuttack',     'kiran@example.com',  '2026-03-02'),
('Deepak Mishra', 'Berhampur',   'deepak@example.com', '2026-03-18'),
('Lipsa Rout',    'Bhubaneswar', 'lipsa@example.com',  '2026-04-01');

INSERT INTO Products (ProductName, Category, Price) VALUES
('Wireless Mouse',      'Electronics', 599.00),
('Mechanical Keyboard', 'Electronics', 2499.00),
('USB-C Hub',           'Electronics', 1299.00),
('Laptop Backpack',     'Accessories', 1499.00),
('Notebook Pack (5)',   'Stationery',   349.00),
('Desk Lamp',           'Home',         899.00),
('Water Bottle',        'Home',         399.00),
('Webcam HD',           'Electronics', 1899.00);   -- never sold (see query 5)

INSERT INTO Orders (CustomerID, OrderDate, Status) VALUES
(1, '2026-04-05', 'Delivered'),
(2, '2026-04-12', 'Delivered'),
(1, '2026-04-28', 'Delivered'),
(3, '2026-05-03', 'Delivered'),
(4, '2026-05-15', 'Cancelled'),
(5, '2026-05-21', 'Delivered'),
(2, '2026-06-02', 'Delivered'),
(6, '2026-06-18', 'Delivered'),
(1, '2026-07-07', 'Delivered'),
(7, '2026-07-19', 'Delivered'),
(3, '2026-08-09', 'Shipped'),
(4, '2026-08-23', 'Delivered');

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 2,  599.00), (1, 5, 3,  349.00),
(2, 2, 1, 2499.00),
(3, 3, 1, 1299.00), (3, 7, 2,  399.00),
(4, 4, 1, 1499.00), (4, 5, 2,  349.00),
(5, 2, 1, 2499.00),
(6, 6, 2,  899.00), (6, 1, 1,  599.00),
(7, 3, 2, 1299.00),
(8, 4, 1, 1499.00), (8, 7, 3,  399.00),
(9, 2, 1, 2499.00), (9, 1, 1,  599.00),
(10, 6, 1, 899.00), (10, 5, 4,  349.00),
(11, 3, 1, 1299.00),
(12, 4, 2, 1499.00), (12, 1, 3,  599.00);
GO
