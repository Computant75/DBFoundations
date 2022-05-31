--*************************************************************************--
-- Title: Assignment07
-- Author: ABaker
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-05-30, ABaker, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_ABaker')
	 Begin 
	  Alter Database [Assignment07DB_ABaker] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_ABaker;
	 End
	Create Database Assignment07DB_ABaker;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_ABaker;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
--SELECT FORMAT(UnitPrice,"$####.##")   FROM vProducts --failed
--SELECT FORMAT(UnitPrice,'C')   FROM vProducts  --worked, gave currency
SELECT prod.ProductName, FORMAT(prod.UnitPrice,'C') AS UnitPrice
FROM vProducts prod
ORDER BY prod.ProductName
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
--SELECT cat.CategoryName prod.ProductName, FORMAT(prod.UnitPrice,'C') AS UnitPrice --ACK, missed a comma.
--FROM vProducts prod
--INNER JOIN vCategories cat ON prod.CategoryID = cat.CategoryID
--ORDER BY cat.CategoryName, ProductName
SELECT cat.CategoryName, prod.ProductName, FORMAT(prod.UnitPrice,'C') AS UnitPrice
FROM vProducts prod
INNER JOIN vCategories cat ON prod.CategoryID = cat.CategoryID
ORDER BY cat.CategoryName, prod.ProductName
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
--SELECT prod.ProductName, FORMAT(inv.InventoryDate,???) AS InventoryDate, inv.Count  --don't see a function I can use, guess I'll write my own.
--FROM vProducts prod
--INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
--ORDER BY prod.ProductName, inv.InventoryDate

--CREATE FUNCTION dbo.NoDayDate(@dateinput DATE)
--RETURNS VARCHAR(100)
--  AS
--    BEGIN
--	  RETURN( --@dateinput
--	    CASE WHEN 1 = 1 THEN 1 ELSE 2 END --test
--		);
--	END
--CREATE FUNCTION dbo.WordMonth(@dateinput DATE)
--RETURNS VARCHAR(100)
--  AS
--    BEGIN
--	  RETURN( 
--	    (CASE WHEN @dateinput = '2017-01-01' THEN 1 ELSE 2 END ) --test
--		);
--	END
--CREATE FUNCTION dbo.WordMonth(@dateinput DATE)
--RETURNS VARCHAR(100)
--  AS
--    BEGIN
--	  RETURN( 
--	    (CASE WHEN MONTH(@dateinput) = 1 THEN 'January' ELSE 'other' END ) --test
--		);
--	END
CREATE FUNCTION dbo.WordMonth(@dateinput DATE)
RETURNS VARCHAR(100)
  AS
    BEGIN
	  RETURN( 
	    (CASE 
		  WHEN MONTH(@dateinput) = 1 THEN 'January'
		  WHEN MONTH(@dateinput) = 2 THEN 'February'
		  WHEN MONTH(@dateinput) = 3 THEN 'March'
		  WHEN MONTH(@dateinput) = 4 THEN 'April'
		  WHEN MONTH(@dateinput) = 5 THEN 'May'
		  WHEN MONTH(@dateinput) = 6 THEN 'June'
		  WHEN MONTH(@dateinput) = 7 THEN 'July'
		  WHEN MONTH(@dateinput) = 8 THEN 'August'
		  WHEN MONTH(@dateinput) = 9 THEN 'September'
		  WHEN MONTH(@dateinput) = 10 THEN 'October'
		  WHEN MONTH(@dateinput) = 11 THEN 'November'
		  WHEN MONTH(@dateinput) = 12 THEN 'December'
		  ELSE 'other' END ) --test
		);
	END  --DATENAME function would have saved me some time, oops.
go

--SELECT dbo.WordMonth(InventoryDate) FROM vInventories --test code used for function test
--SELECT prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ' ' + YEAR(inv.InventoryDate) AS InventoryDate --I was afraid of that, year function returns INT
--, inv.Count  --don't see a function I can use, guess I'll write my own.
--FROM vProducts prod
--INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
--ORDER BY prod.ProductName, inv.InventoryDate
--SELECT prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ' ' + CAST(YEAR(inv.InventoryDate) AS varchar(2) )  AS InventoryDate --year presents as * I don't know why???
--, inv.Count  --don't see a function I can use, guess I'll write my own.
--FROM vProducts prod
--INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
--ORDER BY prod.ProductName, inv.InventoryDate
--SELECT CAST (5 AS varchar(2) ) --this works!!!
--SELECT YEAR('2017-01-01') --this works and gives a 4 digit year!!! feeling really dumb now.

SELECT prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ', ' + CAST(YEAR(inv.InventoryDate) AS varchar(4) )  AS InventoryDate
, inv.Count AS InventoryCount  
FROM vProducts prod
INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
ORDER BY prod.ProductName, inv.InventoryDate
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
CREATE --DROP
  VIEW vProductInventories
  AS
    SELECT TOP 1000000000 prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ', ' + CAST(YEAR(inv.InventoryDate) AS varchar(4) )  AS InventoryDate
	, inv.Count AS InventoryCount  
	FROM vProducts prod
	INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
	ORDER BY prod.ProductName, inv.InventoryDate
go

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
CREATE --DROP
  VIEW vCategoryInventories
  AS
    SELECT TOP 1000000000 bob.CategoryName, bob.InventoryDater AS InventoryDate, bob.InventoryCountByCategory
	FROM 
	  (SELECT cat.CategoryName, dbo.WordMonth(inv.InventoryDate) + ', ' + CAST(YEAR(inv.InventoryDate) AS varchar(4) )  AS InventoryDater, inv.InventoryDate
	  , SUM(inv.Count) AS InventoryCountByCategory  
	  FROM vProducts prod
	  INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
	  INNER JOIN vCategories cat ON prod.CategoryID = cat.CategoryID
	  GROUP BY cat.CategoryName, inv.InventoryDate) bob
	ORDER BY bob.CategoryName, bob.InventoryDate

go
-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

--SELECT YEAR(InventoryDate) + '-' + (MONTH(InventoryDate)-1) + '-' + DAY(InventoryDate)  FROM vInventories --only selects year???
--SELECT YEAR(InventoryDate) , (MONTH(InventoryDate)-1) , DAY(InventoryDate)  FROM vInventories --works but as 3 columns
--SELECT YEAR(InventoryDate) + (MONTH(InventoryDate)-1) + DAY(InventoryDate)  FROM vInventories --only year again
--SELECT bub.iyear + bub.iMonth + bub.iDay FROM
--  (SELECT YEAR(InventoryDate) AS iYear, (MONTH(InventoryDate)-1) AS iMonth, DAY(InventoryDate) AS iDay  FROM vInventories) bub --still only year, I'm on the wrong track
--SELECT CAST(YEAR(InventoryDate) AS varchar(4)) + '-' + CAST(MONTH((InventoryDate)-1) AS varchar(2)) --+ '-' + CAST(DAY(InventoryDate) AS varchar(2))   
--FROM vInventories --On the right track, month needs to be Cast before math, may need to use two conversions
--SELECT CAST(YEAR(InventoryDate) AS varchar(4)) + '-' + CAST((MONTH(InventoryDate)-1) AS varchar(2)) + '-' + CAST(DAY(InventoryDate) AS varchar(2)) FROM vInventories --or I had a misplaced parens, sigh
--SELECT 
----CAST(YEAR(InventoryDate) AS varchar(4)) + '-' + CAST((MONTH(InventoryDate)-1) AS varchar(2)) + '-' + 
--CAST(DAY(InventoryDate) AS varchar(2)) FROM vInventories  --OK, I'm just on the wrong track here
--SELECT inv.ProductID, inv.InventoryDate, invP.InventoryDate
--FROM vInventories inv
--INNER JOIN vInventories invP ON YEAR(inv.InventoryDate) = YEAR(invP.InventoryDate) AND MONTH(inv.InventoryDate) - 1 = MONTH(invP.InventoryDate) --oops, need a ProductID=ProductID, but I'm on the right track!
--Mind you, this only works because it is always on the next month.  Hmm, maybe I could...nah, short of time.
--CREATE --DROP
--  VIEW vProductInventories
--  AS
--    SELECT TOP 1000000000 prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ', ' + CAST(YEAR(inv.InventoryDate) AS varchar(4) )  AS InventoryDate
--	, inv.Count AS InventoryCount, invP.Count as PreviousMonthCount
--	FROM vProducts prod
--	INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
--	LEFT JOIN vInventories invP ON invP.ProductID = invP.ProductID AND YEAR(inv.InventoryDate) = YEAR(invP.InventoryDate) AND MONTH(inv.InventoryDate) - 1 = MONTH(invP.InventoryDate)
--	ORDER BY prod.ProductName, inv.InventoryDate --way too many February lines!!! Oh, typo on the left join...ugh
--CREATE --DROP
--  VIEW vProductInventories
--  AS
--    SELECT TOP 1000000000 prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ', ' + CAST(YEAR(inv.InventoryDate) AS varchar(4) )  AS InventoryDate
--	, inv.Count AS InventoryCount, invP.Count as PreviousMonthCount
--	FROM vProducts prod
--	INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
--	LEFT JOIN vInventories invP ON invP.ProductID = inv.ProductID AND YEAR(inv.InventoryDate) = YEAR(invP.InventoryDate) AND MONTH(inv.InventoryDate) - 1 = MONTH(invP.InventoryDate)
--	ORDER BY prod.ProductName, inv.InventoryDate --close, need to add ifnull to prior month count
--select ifnull(null,0) --this version of SQL doesn't know ifnull?
--select COALESCE(null,0)  --OK, this works
CREATE --DROP
  VIEW vProductInventoriesWithPreviousMonthCounts
  AS
    SELECT TOP 1000000000 prod.ProductName, dbo.WordMonth(inv.InventoryDate) + ', ' + CAST(YEAR(inv.InventoryDate) AS varchar(4) )  AS InventoryDate
	, inv.Count AS InventoryCount, COALESCE(invP.Count,0) as PreviousMonthCount
	FROM vProducts prod
	INNER JOIN vInventories inv ON prod.ProductID = inv.ProductID
	LEFT JOIN vInventories invP ON invP.ProductID = inv.ProductID AND YEAR(inv.InventoryDate) = YEAR(invP.InventoryDate) AND MONTH(inv.InventoryDate) - 1 = MONTH(invP.InventoryDate)
	ORDER BY prod.ProductName, inv.InventoryDate 
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
--SELECT vpi.ProductName, vpi.InventoryDate, vpi.InventoryCount, vpi.PreviousMonthCount
--  , CASE WHEN vpi.InventoryCount > vpi.PreviousMonthCount THEN 1
--         WHEN vpi.InventoryCount = vpi.PreviousMonthCount THEN 0
--		 WHEN vpi.InventoryCount < vpi.PreviousMonthCount THEN -1
--		 ELSE 9999
--		 END KPI
--FROM vProductInventoriesWithPreviousMonthCounts vpi --select worked!
CREATE --DROP
  VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
  AS
    SELECT vpi.ProductName, vpi.InventoryDate, vpi.InventoryCount, vpi.PreviousMonthCount
    , CASE WHEN vpi.InventoryCount > vpi.PreviousMonthCount THEN 1
           WHEN vpi.InventoryCount = vpi.PreviousMonthCount THEN 0
		   WHEN vpi.InventoryCount < vpi.PreviousMonthCount THEN -1
		   ELSE 9999
		   END KPI
    FROM vProductInventoriesWithPreviousMonthCounts vpi


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI INT)
RETURNS TABLE
  AS
	RETURN(
      SELECT vpk.ProductName, vpk.InventoryDate, vpk.InventoryCount, vpk.PreviousMonthCount
	  ,vpk.KPI AS CountVsPreviousCountKPI
	  FROM vProductInventoriesWithPreviousMonthCountsWithKPIs vpk
	  WHERE vpk.KPI = @KPI
	  );
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/