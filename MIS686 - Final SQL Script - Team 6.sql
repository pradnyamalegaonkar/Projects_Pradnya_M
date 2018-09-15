/* Create Database and Tables, Establish Constraints, Insert data into tables, display the tables */

-- =========================================
--            CREATE DATABASE
-- =========================================

/* DROP EXISTING DATABASE */
USE master;
GO
IF EXISTS (SELECT * FROM Master.dbo.sysdatabases WHERE NAME = 'WS_Inventory')
	DROP DATABASE WS_Inventory;
	GO

/* CREATE WS_Inventory DATABASE */
CREATE DATABASE WS_Inventory;
GO

/*SET CONTEXT TO WS_Inventory */
USE WS_Inventory;
GO

-- =========================================
--               CREATE TABLES
-- =========================================

/* CREATE Customer TABLE */
CREATE TABLE TblCustomer
(
	CustomerID			VARCHAR(20)	PRIMARY KEY		NOT NULL,
	CustomerName		VARCHAR(64)					NOT NULL,
	CustomerAddress		VARCHAR(128),
	CustomerContact		VARCHAR(32)
);
GO

INSERT INTO TblCustomer -- load the table with Customer and their details
	VALUES
	('01','Bruce Wayne', '5471,55th Street, Apartment 12, San Diego, CA 92115', '6197574589' ),
	('02','Peter Parker', '9888 Mira Mesa Boulevard, San Diego, CA 92131', '6197574089' ), 
	('03','Tony Stark', '4610 De Soto Street,San Diego, CA 92109', '6198574589' ), 
	('04', 'Hal Jordan','3900 Old Town Avenue, San Diego, 92110', '6198554589'), 
	('05',' Steve Rogers', '707 Pacific Beach Drive,San Diego, CA 92109', '6199574589' ),
	('06',' Clark Kent', '4041 Harney Street ,San Diego, CA 92110', '6199574389' );
	-- Show contents of TblCustomer

	SELECT *
	FROM TblCustomer

	GO


	/* CREATE Branch TABLE */
CREATE TABLE TblBranch
(
	BranchID		VARCHAR(20)	PRIMARY KEY		NOT NULL,
	BranchLocation	VARCHAR(64)					NOT NULL
);
Go

INSERT INTO TblBranch -- load the table with Branches
	VALUES
	('B001', '1772 A Garnet Ave., San Diego, CA 92109' ),
	('B002', '5401 Linda Vista Rd #402, San Diego, CA 92110' ),
	('B003', '616 El Cajon Blvd, San Diego, CA 92115' ),
	('B004', '5006 El Cajon Blvd, San Diego, CA 92115' ),
	('B005', '10299 Scripps Trail Suite E, San Diego, CA 92131' );

	-- Show contents of TblBranch

	SELECT *
	FROM TblBranch;

	GO

	/* CREATE Employee TABLE */

CREATE TABLE TblEmployee
(
	EmployeeID			VARCHAR(20)	PRIMARY KEY		NOT NULL,
	BranchID			VARCHAR(20),
	EmployeeName		VARCHAR(64)					NOT NULL,
	EmployeeAddress		VARCHAR(128),
	EmployeeContact		VARCHAR(32),
	EmployeeRole		CHAR(20)
	CONSTRAINT fk_EBranchID FOREIGN KEY (BranchID) REFERENCES TblBranch (BranchID) --Define Branch ID as Foreign Key
	
);
GO

INSERT INTO TblEmployee -- load the table with Employees
	VALUES
	
	('E001','B001','Monish Thakore', '5485 55th Street #12', '6197548888', 'Salesperson' ),
	('E002','B002','Vidushi Mankotia', '5475 55th Street #11', '6197574520', 'Product Manager' ),
	('E003','B002','Pradnya Malegaonkar', '5445 55th Street #2', '6197574511', 'Production Manager' ),
	('E004','B002','Swathika Rameshchandran', '5485 75th Street #20', '6194582213', 'Quality Control Tech' ), 
	('E005','B001','Preethi Narayanan', '5485 La Mesa #7', '6198425543', 'Accountant Clerk' ),
	('E006','B003','Amit Gupte', '5495 55th Street #23', '6194875612', 'Accontant Admin' ),
	('E007','B004','Vaibhav Raut', '4195 45th Street #5', '6194857544', 'Shipping Clerk' ),
	('E008','B005','William Shakespear', '5485 55th Street #1', '6197548881', 'Salesperson' ),
	('E009','B005','Robert Taylor', '5410 55th Street #12', '6197548882', 'Salesperson' ),
	('E010','B005','David Smith', '5411 55th Street #12', '6197548883', 'Salesperson' ),
	('E011','B003','Albert Johnson', '5201 55th Street #13', '6197548884', 'Salesperson' ),
	('E012','B004','Tom Cruise', '5200 55th Street #10', '6197548885', 'Salesperson' ),
	('E013','B005','Zayn Malik', '5111 55th Street #8', '6197548886', 'Salesperson' ),
	('E014','B003','Harry Styles', '5444 55th Street #09', '6197548887', 'Salesperson' );
	-- Show contents of TblEmployee

	SELECT *
	FROM TblEmployee;

	GO
	
	/* CREATE Customer Order TABLE */
CREATE TABLE TblC_Order
(
	COrderID		VARCHAR(20)	PRIMARY KEY		NOT NULL,
	CustomerID		VARCHAR(20)					NOT NULL,
	EmployeeID		VARCHAR(20)					NOT NULL,
	COrderDate		DATE,
	PaymentType		VARCHAR(30),
	PaymentStatus	VARCHAR(30),
	Amount			FLOAT						NOT NULL,

	CONSTRAINT fk_CCustomerID FOREIGN KEY (CustomerID) REFERENCES TblCustomer (CustomerID) --Define Customer ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	CONSTRAINT fk_EEmployeeID FOREIGN KEY (EmployeeID) REFERENCES TblEmployee (EmployeeID) --Define Employee ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);


INSERT INTO tblC_order VALUES -- Load the table with customer order details

('C001','01','E001','2017-04-01','Credit/DebitCardPayment','PaymentReceived','127.00'),
('C002','02','E002','2017-04-20','Credit/DebitCardPayment','PaymentReceived','100.00'),
('C003','03','E003','2018-04-25','Credit/DebitCardPayment','PaymentReceived','80.00'),
('C004','04','E004','2018-05-30','Credit/DebitCardPayment','PaymentReceived','125.00'),
('C005','05','E005','2018-05-01','ElectronicCheque','PaymentReceived','55.00'),
('C006','06','E006','2018-05-02','CashonDelivery','Pending','15.00'),
('C007','01','E007','2017-11-01','Credit/DebitCardPayment','PaymentReceived','20.00'),
('C008','02','E008','2017-10-03','Credit/DebitCardPayment','PaymentReceived','100.00'),
('C009','03','E012','2017-05-03','Credit/DebitCardPayment','PaymentReceived','75.00'),
('C010','04','E012','2017-02-10','Credit/DebitCardPayment','PaymentReceived','125.00'),
('C011','05','E010','2017-01-12','Credit/DebitCardPayment','PaymentReceived','30.00'),
('C012','06','E009','2017-09-15','Credit/DebitCardPayment','PaymentReceived','150.00'),
('C013','01','E011','2017-07-25','Credit/DebitCardPayment','PaymentReceived','110.00'),
('C014','02','E011','2017-05-03','Credit/DebitCardPayment','PaymentReceived','35.00');


SELECT * 
FROM tblC_order;

GO


/* CREATE Category TABLE */


CREATE TABLE TblCategory
(
	CategoryCode	VARCHAR(20)	PRIMARY KEY		NOT NULL,
	CategoryName	VARCHAR(64)					NOT NULL,
	
);

INSERT INTO TblCategory -- load the table with Category
	VALUES
	('C01','Cake'),
	('C02', 'Cookies'), 
	('C03', 'Donuts');
	
	-- Show contents of TblCategory

	SELECT *
	FROM TblCategory

	GO
/* CREATE Products TABLE */

CREATE TABLE TblProducts
(
	ProductID			VARCHAR(20) 	PRIMARY KEY		NOT NULL,
	CategoryCode		VARCHAR(20)						NOT NULL,
	ProductName			VARCHAR(128)					NOT NULL,
	ProductPrice		INT								NOT NULL,
	QuantityAvailable	INT	DEFAULT 0,
	
	CONSTRAINT fk_CategoryCode FOREIGN KEY (CategoryCode) REFERENCES TblCategory (CategoryCode) --Define CategoryCode as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

Go

INSERT INTO TblProducts -- load the table with Products
	VALUES
	('1','C01','Chocolate Cake', 15, 10  ),
	('2','C01','Vanilla Cake', 10, 10),
	('3','C01','Mango Cake', 15, 5 ),
	('4','C01','Pineapple Cake', 15, 10),
	('5','C01','Strawberry Cake', 15, 15 ),
	('6','C01','Mix Fruit Cake', 15, 5 ),
	('7','C01','Black Forest Cake', 20, 15 ),
	('8','C01','Cheesecake ', 10, 5 ),
	('9','C01','Eggless Cake', 10, 20 ),
	('10','C02','Chocolate Cookies', 2, 30), 
	('11','C02','Oatmeal Cookies', 3, 50), 
	('12','C02','Walnut Cookies', 3, 50), 
	('13','C02','Raspberry Cookies', 1, 60), 
	('14','C02','Sugar Cookies', 1, 100), 
	('15','C03','Chocolate Donuts', 5, 50),
	('16','C03','Cinnamon Donuts', 5, 40),
	('17', 'C03','Blueberry Donuts', 3, 50),
	('18', 'C03','Coconut Donuts', 3, 50),
	('19', 'C03','Apple Crumb Donuts', 7, 50);
	
	-- Show contents of TblProducts

	SELECT *
	FROM TblProducts;

	GO

	/* CREATE Ingredients TABLE */

CREATE TABLE TblIngredients
(
	IngredientID		VARCHAR(20)	PRIMARY KEY		NOT NULL,
	IngredientName		VARCHAR(60)					NOT NULL,
	QuantityAvailable	INT			DEFAULT 0
);


INSERT INTO TblIngredients -- load the table with Ingredients
	VALUES
	('1001','Vanilla', 50),
	('1002', 'Eggs', 500), 
	('1003', 'Sugar', 100), 
	('1004', 'Flour', 50), 
	('1005', 'Butter',200), 
	('1006', 'Coco Powder', 100), 
	('1007', 'Milk', 150), 
	('1008', 'Baking Soda', 50), 
	('1009', 'Baking Powder', 50), 
	('1010', 'Whipped Cream', 100), 
	('1011', 'Mango', 100), 
	('1012', 'Pineapple', 100), 
	('1013', 'Strawberry', 100), 
	('1014', 'Kiwi', 100), 
	('1015', 'Cherry', 100), 
	('1016', 'Chocolate', 100), 
	('1017', 'Cream Cheese', 150),
	('1018', 'Sour Cream', 50),
	('1019', 'Cracker Crumb', 100),
	('1020', 'Salt', 90),
	('1021', 'Oats', 100),
	('1022', 'Walnut', 90),
	('1023', 'Raspberry', 100),
	('1024', 'Blueberry', 100),
	('1025', 'Cinnamon', 90),
	('1026', 'Apple', 100),
	('1027', 'Nutmeg', 50)
	;
	
	-- Show contents of TblIngredients

	SELECT *
	FROM TblIngredients

	GO


	
/* CREATE Branch Inventory TABLE */ --An associative entity between Branch table and Products table
CREATE TABLE TblBranchInventory
(
	BranchID	VARCHAR(20)		NOT NULL,
	ProductID	VARCHAR(20)		NOT NULL,
	Quantity	INT	DEFAULT 0,

	CONSTRAINT pk_BBranchInv	PRIMARY KEY (BranchID, ProductID),  --Create compound Primary Key
	
	CONSTRAINT fk_BBranchID	FOREIGN KEY (BranchID) REFERENCES TblBranch (BranchID) --Define Branch ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
	CONSTRAINT fk_IProductID FOREIGN KEY (ProductID) REFERENCES TblProducts (ProductID) --Define Product ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

INSERT INTO TblBranchInventory -- load the table with Brach Inventory
	VALUES
	('B001', '1', 10),
	('B001', '2', 0), 
	('B001', '3', 15), 
	('B001', '4', 5), 
	('B001', '5', 5), 
	('B001', '6', 0), 
	('B001', '7', 10), 
	('B001', '8', 13), 
	('B001', '9', 17), 
	('B001', '10', 0), 
	('B001', '11', 20), 
	('B001', '12', 10), 
	('B001', '13', 9), 
	('B001', '14', 5), 
	('B001', '15', 8), 
	('B001', '16', 6), 
	('B001', '17', 4), 
	('B001', '18', 15), 
	('B001', '19', 13), 
	('B002', '1', 12),
	('B002', '2', 20), 
	('B002', '3', 14), 
	('B002', '4', 15), 
	('B002', '5', 20), 
	('B002', '6', 12), 
	('B002', '7', 0), 
	('B002', '8', 14), 
	('B002', '9', 15), 
	('B002', '10', 0), 
	('B002', '11', 0), 
	('B002', '12', 13), 
	('B002', '13', 4), 
	('B002', '14', 5), 
	('B002', '15', 8), 
	('B002', '16', 22), 
	('B002', '17', 24), 
	('B002', '18', 27), 
	('B002', '19', 15), 
	('B003', '1', 0),
	('B003', '2', 0), 
	('B003', '3', 14), 
	('B003', '4', 5), 
	('B003', '5', 20), 
	('B003', '6', 22), 
	('B003', '7', 15), 
	('B003', '8', 0), 
	('B003', '9', 18), 
	('B003', '10', 10), 
	('B003', '11', 0), 
	('B003', '12', 14), 
	('B003', '13', 40), 
	('B003', '14', 5), 
	('B003', '15', 0), 
	('B003', '16', 2), 
	('B003', '17', 29), 
	('B003', '18', 50), 
	('B003', '19', 18); 
	
	
	-- Show contents of TblBranchInventory

	SELECT *
	FROM TblBranchInventory

	GO

	

/* CREATE Warehouse Order TABLE */
CREATE TABLE TblW_Order
(
	WOrderID	VARCHAR(20)	PRIMARY KEY		NOT NULL,
	EmployeeID	VARCHAR(20)					NOT NULL,
	WOrderData	DATE						NOT NULL,

	
	CONSTRAINT fk_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES TblEmployee (EmployeeID) --Define Employee ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

SELECT * FROM TblW_Order;

GO


/* CREATE Warehouse Order items TABLE */ -- An associative entity between Products table and Warehouse order table
CREATE TABLE TblW_OrderItems
(
	WOrderID	VARCHAR(20)		NOT NULL,
	ProductID	VARCHAR(20)		NOT NULL,
	Quantity	INT	DEFAULT 0,
	
	CONSTRAINT pk_WOrderItems	PRIMARY KEY (WOrderID, ProductID),  --Create compound Primary Key
	
	CONSTRAINT fk_WOrderID	FOREIGN KEY (WOrderID) REFERENCES TblW_Order (WOrderID) --Define Warehouse Order ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
	CONSTRAINT fk_WProductID FOREIGN KEY (ProductID) REFERENCES TblProducts (ProductID) --Define Products ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);


GO

/* CREATE Supplier TABLE */

CREATE TABLE TblSupplier
(
	SupplierID			VARCHAR(20)	PRIMARY KEY		NOT NULL,
	SupplierName		VARCHAR(50)					NOT NULL,
	SupplierAddress		VARCHAR(128),
	SupplierContact		VARCHAR(68)					NOT NULL
);
GO

INSERT INTO TblSupplier -- load the table with Supplier Details
	VALUES
	
	('S001','Sadie Rose Baking Co', '8926 Ware Ct, San Diego, CA 92121', '6197189532' ),
	('S002','Sweet Cheeks Baking Co', ' 4564 Alvarado Canyon Rd, San Diego, CA 92120', '6192851220' ),
	('S003','Le Chef Bakery Wholesaler', '4696 Ruffner St A, San Diego, CA 92111', '8005853243' ),
	('S004','Lakeside Bakery Supplies', '11138 Moreno Ave, Lakeside, CA 92040', '6194431387' ), 
	('S005','Bread & Cie Wholesale', '4901 Pacific Hwy, San Diego, CA 92110', '6196881788' ),
	('S006','Northgate Gonzalez Markets', '5403 University Ave, San Diego, CA 92105', '6192659701' );
	-- Show contents of TblSupplier

	SELECT *
	FROM TblSupplier;

	GO
/* CREATE Supplier Order TABLE */

CREATE TABLE TblS_Order
(
	SOrderID		VARCHAR(20)	PRIMARY KEY		NOT NULL,
	EmployeeID		VARCHAR(20)					NOT NULL,
	SupplierID		VARCHAR(20)					NOT NULL,
	OrderDate		DATE						NOT NULL,
	OrderStatus		VARCHAR(20)					NOT NULL,
	PaymentType		VARCHAR(30)					NOT NULL,
	PaymentStatus	VARCHAR(30)					NOT NULL,
	AmountBilled	FLOAT		DEFAULT 0,

	CONSTRAINT fk_SSupplierID FOREIGN KEY (SupplierID) REFERENCES TblSupplier (SupplierID) --Define Supplier ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	CONSTRAINT fk_SEmployeeID FOREIGN KEY (EmployeeID) REFERENCES TblEmployee (EmployeeID) --Define Employee ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);


INSERT INTO TblS_Order -- load the table with Supplier Order
	VALUES
	('SO1', 'E003', 'S001','2018-04-01', 'In Process', 'Cash on Delivery', 'Pending', '450.00' ),
	('SO2', 'E003', 'S002', '2018-05-02', ' Order Received', 'Credit/Debit Card Payment','Payment Received', '500.00' ),
	('SO3', 'E003', 'S003','2018-04-30', 'In Process', ' Electronic Cheque', 'Pending', '600.00'),
	('SO4', 'E003', 'S004','2018-04-28', 'In Process', 'Cash on Delivery', 'Pending', '450.10' ),
	('SO5', 'E003', 'S005','2018-04-20', 'Delivered', 'Electronic Cheque', 'Payment Received', '230.33' ),
	('SO6', 'E003', 'S006','2018-05-01', ' In Process', 'Credit/Debit Card Payment', 'Pending', '500.10' );

	-- Show contents of TblS_Order

	SELECT *
	FROM TblS_Order

	GO







/* CREATE Supplier Order Items TABLE */ -- An associative entity between Supplier table and Supplier Order table
CREATE TABLE TblS_OrderItems
(
	SOrderID		VARCHAR(20)		NOT NULL,
	IngredientID	VARCHAR(20)		NOT NULL,
	Quantity		INT				DEFAULT 0,

	CONSTRAINT pk_SOrderItems	PRIMARY KEY (SOrderID, IngredientID),  --Create compound Primary Key
	
	CONSTRAINT fk_KSOrderID	FOREIGN KEY (SOrderID) REFERENCES TblS_Order (SOrderID) --Define Supplier Order ID as Foreign Key
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	
	CONSTRAINT fk_KIngredientID FOREIGN KEY (IngredientID) REFERENCES TblIngredients (IngredientID) --Define Ingredients ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

INSERT INTO TblS_OrderItems -- load the table with Supplier Order Items
	VALUES

	('SO1', '1001',50),
	('SO1', '1002',200),
	('SO1', '1003',60),
	('SO1', '1004',50),
	('SO2', '1005',100),
	('SO2', '1006',50),
	('SO2', '1007',150),
	('SO2', '1008',100),
	('SO3','1009',50),
	('SO3', '1010',50),
	('SO3', '1011',100),
	('SO3', '1012',100),
	('SO4', '1013',150),
	('SO4', '1014',50),
	('SO4', '1015',150),
	('SO4', '1016',100),
	('SO5','1017',50),
	('SO5','1018',50),
	('SO5', '1019',100),
	('SO5','1020',100),
	('SO6', '1021',70),
	('SO6', '1022',80),
	('SO6', '1023',100),
	('SO6', '1024',50),
	('SO6', '1025',40),
	('SO6', '1026',100),
	('SO6', '1027',45);
	
	-- Show contents of TblS_OrderItems

	SELECT *
	FROM TblS_OrderItems

	GO

	/* CREATE Product Ingredients TABLE */ -- An associative entity between Products table and Ingredients table
Create table TblProductIngredients
(
	ProductID		VARCHAR(20)		NOT NULL,
	IngredientID	VARCHAR(20)		NOT NULL
	
	CONSTRAINT pk_Warehouse	PRIMARY KEY (ProductID, IngredientID),  --Create compound Primary Key
	
	CONSTRAINT fk_ProductID FOREIGN KEY (ProductID) REFERENCES TblProducts (ProductID) --Define Product ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
	CONSTRAINT fk_IngredientID FOREIGN KEY (IngredientID) REFERENCES TblIngredients (IngredientID) --Define Ingredient ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

/* CREATE Customer Order Items TABLE */ -- An associative entity between Customer Order table and Branch Inventory
CREATE TABLE TblC_OrderItems
(
	COrderID	VARCHAR(20)		NOT NULL,
	ProductID	VARCHAR(20)		NOT NULL,
	Quantity	INT				DEFAULT 0,

	CONSTRAINT pk_COrderItems	PRIMARY KEY (COrderID, ProductID),  --Create compound Primary Key
	
	CONSTRAINT fk_COrderID		FOREIGN KEY (COrderID) REFERENCES TblC_Order (COrderID) --Define Customer Order ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
	CONSTRAINT fk_CProductID FOREIGN KEY (ProductID) REFERENCES TblProducts (ProductID) --Define Product ID as Foreign Key
	ON DELETE CASCADE
	ON UPDATE CASCADE
);


INSERT INTO TblC_OrderItems VALUES -- load the table with Customer Order Items
('C001','1',1),
('C001','2',1),
('C001','3',1),
('C001','4',1),
('C001','5',1),
('C001','6',1),
('C001','7',1),
('C001','8',1),
('C001','9',1),
('C001','10',1),
('C002','11',1),
('C002','12',1),
('C002','13',1),
('C002','14',1),
('C002','15',1),
('C002','16',1),
('C002','17',1),
('C003','18',1),
('C003','19',1),
('C003','1',3),
('C003','2',1),
('C003','3',1),
('C004','1',1),
('C004','2',1),
('C004','3',1),
('C004','4',1),
('C004','5',1),
('C004','6',1),
('C004','7',1),
('C004','8',1),
('C004','9',1),
('C005','1',3),
('C005','2',1),
('C006','1',1),
('C007','1',1),
('C007','19',4),
('C007','16',1),
('C007','14',1),
('C008','1',5),
('C009','2',2),
('C010','1',2),
('C011','19',20),
('C012','15',3),
('C013','12',18),
('C014','1',10);

SELECT * 
FROM TblC_Order;

-- =============================================================================================
-- LIST OF ALL CUSTOMERS WHO HAVE BOUGHT PRODUCTS FOR MORE THAN $100 OF VALUE IN 2017
--                             BUT NOT BOUGHT AT ALL IN 2018
-- =============================================================================================

SELECT a.CustomerID, c.CustomerName
FROM TblC_Order AS a
JOIN TblCustomer AS c
ON a.CustomerID = c.CustomerID
WHERE a.COrderDate > '2017-01-01' AND a.COrderDate< '2017-12-31'
AND a.CustomerID 
NOT IN(SELECT TblC_Order.CustomerID
	   FROM TblC_Order
	   WHERE TblC_Order.COrderDate > '2018-01-01')
GROUP BY a.CustomerID, c.CustomerName
HAVING SUM(a.Amount) > =100;

-- =============================================================================================
--                      WHICH CUSTOMERS HAVE PLACED AN ORDER IN MAY 2018?
-- =============================================================================================

SELECT o.CustomerID, c.CustomerName
FROM TblC_Order  AS o
JOIN TblCustomer AS c
ON o.CustomerID =c.CustomerID
WHERE o.COrderDate >= '2018-05-01' AND o.COrderDate <= '2018-05-30';
GO

-- =============================================================================================
-- PRODUCT MANAGER CHECKS FOR THE PRODUCTS' AVAILABILITY AT DIFFERENT BRANCHES TO PLACE THE
--                       WAREHOUSE ORDERS SORTED PRIORITY-WISE
-- =============================================================================================


SELECT bi.BranchID, bi.ProductID, p.ProductName, bi.Quantity
FROM tblBranchInventory AS bi
JOIN tblProducts AS p
ON bi.ProductID = p.ProductID
WHERE bi.Quantity < 10
ORDER BY bi.Quantity ASC;
GO

-- =============================================================================================
--        CHECK FOR THE MOST POPULAR CATEGORY BEING SOLD AMONGST THE CUSTOMERS
-- =============================================================================================

SELECT ct.CategoryName, SUM(oi.Quantity) AS TotalQuantitySold
FROM TblCategory	 AS ct
JOIN TblProducts	 AS pr
ON pr.CategoryCode = ct.CategoryCode
JOIN TblC_OrderItems AS oi
ON pr.ProductID = oi.ProductID
GROUP BY ct.CategoryName 
ORDER BY TotalQuantitySold DESC;
GO


-- =============================================================================================
-- DISPLAY THE CUSTOMERS WHOSE AVERAGE AMOUNT SPENT IS MORE THAN THE TOTAL AVERAGE AMOUNT SPENT 
-- =============================================================================================

SELECT oc.CustomerID, c.CustomerName, (SELECT ROUND (AVG(ic.Amount), 2) AS avgamt 
										FROM TblC_Order AS ic 
										WHERE ic.CustomerID = oc.CustomerID
										) AS CustAvgAmt		
FROM TblC_Order AS oc
JOIN TblCustomer AS c ON c.CustomerID = oc.CustomerID
WHERE oc.Amount > (SELECT AVG(amount) 
				FROM TblC_Order)
GROUP BY oc.CustomerID, c.CustomerName;

-- =====================================================================================================
--         DISPLAY THE MOST POPULAR PRODUCT SOLD AT EVERY BRANCH WITH THE TOTAL QUANTITIES SOLD 
-- =====================================================================================================

SELECT tab1.BranchID, tab1.TotalQtySold, tab2.ProductName  
FROM (SELECT BranchID, MAX(TotalQuantitySold) AS TotalQtySold 
		FROM ( SELECT  b.BranchID, coi.ProductID, t.ProductName, SUM(coi.Quantity) AS TotalQuantitySold
				FROM TblC_OrderItems AS coi
				JOIN TblProducts AS t ON t.ProductID = coi.ProductID 
				JOIN TblC_Order AS o ON o.COrderID = coi.COrderID
				JOIN TblEmployee AS e ON e.EmployeeID = o.EmployeeID
				JOIN TblBranch AS b ON b.BranchID = e.BranchID
				GROUP BY coi.ProductID, t.ProductName, b.BranchID
			 ) TempT1
		GROUP BY BranchID
	) tab1
INNER JOIN 
	(SELECT  b.BranchID, coi.ProductID, t.ProductName, SUM(coi.Quantity) AS TotalQuantitySold
		FROM TblC_OrderItems AS coi
		JOIN TblProducts AS t ON t.ProductID = coi.ProductID 
		JOIN TblC_Order AS o ON o.COrderID = coi.COrderID
		JOIN TblEmployee AS e ON e.EmployeeID = o.EmployeeID
		JOIN TblBranch AS b ON b.BranchID = e.BranchID
		GROUP BY coi.ProductID, t.ProductName, b.BranchID
	)tab2
ON tab1.BranchID = tab2.BranchID 
AND tab1.TotalQtySold = tab2.TotalQuantitySold;


-- =============================================================================================
--         DISPLAY THE CART ITEMS FOR A PARTICULAR ORDER - FOR EXAMPLE ORDER ID = C007
-- =============================================================================================

SELECT p.ProductID, p.ProductName, o.Quantity, p.ProductPrice, (o.Quantity*p.ProductPrice) AS TotalPrice
FROM TblProducts AS p
JOIN TblC_OrderItems AS o ON o.ProductID = p.ProductID
JOIN TblC_Order AS co ON co.COrderID = o.COrderID
WHERE o.COrderID = 'C007';


-- =============================================================================================
--        DISPLAY THE MENU ITEMS BASED ON THE FILTERS APPLIED BY THE CUSTOMERS
-- =============================================================================================

SELECT p.ProductName, p.ProductPrice
FROM TblProducts AS p
WHERE p.CategoryCode = 'C01' AND p.ProductPrice < 20
ORDER BY ProductName ASC;

-- =============================================================================================
--         DISPLAY THE QUANTITY OF AVAILABLE PRODUCTS AT A PARTICULAR BRANCH
-- =============================================================================================


SELECT bi.BranchID, bi.ProductID, p.ProductName, bi.Quantity 
FROM TblBranchInventory AS bi
JOIN TblProducts AS p
ON bi.ProductID = p.ProductID
WHERE bi.Quantity > 0;


-- =============================================================================================
--      IDENTIFY THE SUPPLIER ID FOR THE INGREDIENTS WHICH ARE FALLING BELOW QUANTITY 60
-- =============================================================================================

SELECT TblS_Order.SupplierID, TblS_Order.SOrderID, TblS_OrderItems.IngredientID
FROM TblS_Order 
JOIN (SELECT i.IngredientID, TblS_OrderItems.SOrderID
	  FROM TblIngredients AS i
      INNER JOIN TblS_OrderItems ON i.IngredientID = TblS_OrderItems.IngredientID 
	  WHERE i.QuantityAvailable < 60) AS tab ON tab.SOrderID = TblS_Order.SOrderID
JOIN TblS_OrderItems ON TblS_OrderItems.IngredientID = tab.IngredientID;