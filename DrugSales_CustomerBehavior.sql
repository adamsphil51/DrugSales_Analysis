
-- Project: DrugSales_CustomerBehavior
-- Purpose: Track drug sales, customer behavior, and campaign performance
-- =====================================================

-- 1. Create Customers table (hospitals/pharmacies, anonymized)
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(50),
    CustomerType VARCHAR(50) -- Hospital or Pharmacy
);

INSERT INTO Customers (CustomerID, CustomerName, City, CustomerType) VALUES
(1, 'Customer 1', 'Nairobi', 'Hospital'),
(2, 'Customer 2', 'Mombasa', 'Pharmacy'),
(3, 'Customer 3', 'Kisumu', 'Hospital'),
(4, 'Customer 4', 'Nakuru', 'Pharmacy'),
(5, 'Customer 5', 'Eldoret', 'Hospital');

-- 2. Create Drugs table
CREATE TABLE Drugs (
    DrugID INT PRIMARY KEY,
    DrugName VARCHAR(100),
    BatchNumber VARCHAR(50),
    Supplier VARCHAR(100)
);

INSERT INTO Drugs (DrugID, DrugName, BatchNumber, Supplier) VALUES
(1, 'Paracetamol 500mg', 'B123', 'Supplier X'),
(2, 'Amoxicillin 250mg', 'A456', 'Supplier Y'),
(3, 'Ibuprofen 400mg', 'I789', 'Supplier Z');

-- 3. Create Campaigns Tables
CREATE TABLE Campaigns (
    CampaignID INT PRIMARY KEY,
    CampaignName VARCHAR(100),
    StartDate DATE,
    EndDate DATE
);

INSERT INTO Campaigns (CampaignID, CampaignName, StartDate, EndDate) VALUES
(1, 'Campaign 1', '2024-03-01', '2024-03-31'),
(2, 'Campaign 2', '2024-06-01', '2024-06-30');

-- 4. Create Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    DrugID INT,
    CampaignID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID),
    FOREIGN KEY (CampaignID) REFERENCES Campaigns(CampaignID)
);

INSERT INTO Orders (OrderID, CustomerID, DrugID, CampaignID, Quantity, UnitPrice, OrderDate) VALUES
(1, 1, 1, 1, 100, 50.00, '2024-03-05'),
(2, 2, 1, 1, 50, 50.00, '2024-03-10'),
(3, 3, 2, 2, 200, 80.00, '2024-06-12'),
(4, 4, 2, 2, 100, 80.00, '2024-06-18'),
(5, 5, 3, NULL, 150, 60.00, '2024-05-05');

-- =====================================================
-- Analysis Queries
-- =====================================================

-- Total spend per customer
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.CustomerType,
    c.City,
    SUM(o.Quantity * o.UnitPrice) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.CustomerType, c.City
ORDER BY TotalSpent DESC;

-- Customer segmentation based on spend
SELECT 
    CustomerID,
    CustomerName,
    CASE 
        WHEN TotalSpent >= 15000 THEN 'High Value'
        WHEN TotalSpent >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Segment
FROM (
    SELECT c.CustomerID, c.CustomerName, SUM(o.Quantity * o.UnitPrice) AS TotalSpent
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
) AS CustomerTotals
ORDER BY TotalSpent DESC;

-- Total revenue per drug
SELECT 
    d.DrugName,
    SUM(o.Quantity * o.UnitPrice) AS DrugRevenue,
    COUNT(DISTINCT o.CustomerID) AS NumberOfCustomers
FROM Drugs d
JOIN Orders o ON d.DrugID = o.DrugID
GROUP BY d.DrugName
ORDER BY DrugRevenue DESC;

-- Campaign performance: total revenue per campaign
SELECT 
    cm.CampaignName,
    SUM(o.Quantity * o.UnitPrice) AS CampaignRevenue,
    COUNT(DISTINCT o.CustomerID) AS NumberOfCustomers
FROM Campaigns cm
JOIN Orders o ON cm.CampaignID = o.CampaignID
GROUP BY cm.CampaignName
ORDER BY CampaignRevenue DESC;

-- Top 3 customers by spend
SELECT 
    c.CustomerID,
    c.CustomerName,
    SUM(o.Quantity * o.UnitPrice) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY TotalSpent DESC
LIMIT 3;
