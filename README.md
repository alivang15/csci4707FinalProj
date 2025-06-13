# CSCI 4707 Final Project: Bookstore Database

This project implements a database schema for a bookstore.

## Running SQL Files

The following SQL files should be run in the order listed to correctly set up the database schema.

### 1. `CUSTOMER.sql`
````sql
CREATE TABLE Customer (
  CustID INT PRIMARY KEY,
  Fname VARCHAR(32) NOT NULL,
  Lname VARCHAR(32) NOT NULL,
  EmailAddress VARCHAR(64),
  PhoneNumber BIGINT,
  Street VARCHAR(64),
  ZipCode INT,
  State CHAR(2),
  City VARCHAR(32)
);
`````

### 2. `PUBLISHER.sql`
````sql
CREATE TABLE Publisher (
  CompanyName VARCHAR(32) PRIMARY KEY,
  PhoneNum BIGINT NOT NULL,
  Email VARCHAR(32)
);
`````

### 3. `EMPLOYEE.sql`
````sql
CREATE TABLE Employee (
  EmpID INT PRIMARY KEY,
  FName VARCHAR(32) NOT NULL,
  LName VARCHAR(32) NOT NULL,
  Position VARCHAR(32) NOT NULL CHECK (Position IN ('Manager', 'Cashier')),
  HireDate DATE NOT NULL
);
`````

### 4. `AUTHOR.sql`
````sql
CREATE TABLE Author (
  AuthID INT PRIMARY KEY,
  Fname VARCHAR(32) NOT NULL,
  Lname VARCHAR(32) NOT NULL,
  Biography VARCHAR(512)
);
`````

### 5. `BOOK.sql`
````sql
CREATE TABLE Book (
  BookID INT PRIMARY KEY,
  Title VARCHAR(128) NOT NULL,
  PubName VARCHAR(32),
  Genre VARCHAR(32) NOT NULL,
  Year YEAR,
  Price DECIMAL(10,2) NOT NULL,
  Quantity INT NOT NULL,
  FOREIGN KEY(PubName) REFERENCES Publisher(CompanyName)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);
`````

### 6. `PAYMENT.sql`
````sql
CREATE TABLE Payment (
  PaymentID INT PRIMARY KEY,
  PayDate DATE NOT NULL,
  PayMethod VARCHAR(32) NOT NULL,
  Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0)
);
`````

### 7. `ORDERS.sql`
````sql
CREATE TABLE Orders (
  OrderID INT PRIMARY KEY,
  CustID INT NOT NULL,
  CashID INT,
  PaymentID INT,
  ShipStreet VARCHAR(64) NOT NULL,
  ShipCity VARCHAR(32) NOT NULL,
  ShipState CHAR(2) NOT NULL,
  ShipZip INT NOT NULL,
  PaymentStatus BOOLEAN NOT NULL,
  OrderDate DATE NOT NULL,
  ShipDate DATE,
  FOREIGN KEY(CustID) REFERENCES Customer(CustID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY(CashID) REFERENCES Employee(EmpID)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  FOREIGN KEY(PaymentID) REFERENCES Payment(PaymentID)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);
`````

### 8. `WROTE.sql`
````sql
CREATE TABLE Wrote (
  AuthID INT,
  BookID INT,
  PRIMARY KEY (AuthID, BookID),
  FOREIGN KEY (AuthID) REFERENCES Author(AuthID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
`````

### 9. `CONTAIN.sql`
````sql
CREATE TABLE Contain (
  OrderID INT NOT NULL,
  BookID INT NOT NULL,
  BookQuantity INT NOT NULL CHECK (BookQuantity > 0),
  BookPrice DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (OrderID, BookID),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book(BookID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
`````

### 10. `INVENTORY.sql`
````sql
CREATE TABLE Inventory (
  InventoryName VARCHAR(32) PRIMARY KEY,
  BookID INT UNIQUE,
  ManID INT,
  InvQuantity INT NOT NULL,
  RestockThres INT NOT NULL,
  FOREIGN KEY (BookID) REFERENCES Book(BookID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (ManID) REFERENCES Employee(EmpID)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);
`````

### 11. `ASSISTED.sql`
````sql
CREATE TABLE Assisted (
  CustID INT NOT NULL,
  EmpID INT NOT NULL,
  PRIMARY KEY (CustID, EmpID),
  FOREIGN KEY(CustID) REFERENCES Customer(CustID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY(EmpID) REFERENCES Employee(EmpID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
`````

## Things to do/look at:
1. PAYMENT: One payment can cover multiple orders, but an order can only be associated with one payment, so im wondering if order should have a payment foreign key instead of the other way around
2. I added comments in some files (ex. BOOK, EMPLOYEE, PUBLISHER, WROTE), so take a look
3. There are some designators (ex. NOT NULL, UNIQUE, CHECK, etc.) used throughout, we can check to make sure we that used them properly and that we used them everywhere that we should
4. double check that all names of attributes in foreign keys match both files
5. run the files on the website the ta gave us to ensure the file order is correct and everything works properly
6. Once .sql file order is finalized, maybe write a formal process/commands to run to set up the database? not sure how in depth this needs to be

## ON DELETE/UPDATE Behavior Choices

We've implemented specific referential integrity behaviors throughout our schema:

1. **CASCADE Deletion** - Used when child records cannot meaningfully exist without parent:
   - WROTE (AuthID, BookID): When an author or book is deleted, their authorship records are deleted
   - ASSISTED (CustID, EmpID): When a customer or employee is deleted, their assistance records are deleted
   - CONTAIN (OrderID, BookID): When an order or book is deleted, their line items are deleted

2. **SET NULL on Delete** - Used to preserve important data while removing associations:
   - BOOK (PubName): If a publisher is deleted, books remain but lose publisher association
   - ORDERS (CashID): If an employee is deleted, orders remain but lose cashier reference
   - ORDERS (PaymentID): If a payment is deleted, orders remain but payment reference is removed
   - INVENTORY (ManID): If a manager is deleted, inventory records remain unassigned

3. **CASCADE Updates** - Used throughout the schema to maintain referential integrity when IDs change
   - All foreign keys use ON UPDATE CASCADE to ensure database-wide consistency

These choices balance data integrity with practical business requirements. For example, we preserve order history even when employees leave, but remove order records if a customer is deleted.

## How we run this database to make sure it works:

We use https://www.db-fiddle.com/ to run all the files and use SQL query (CRUD operations) to test if our database is working correctly.

Here are some test cases:

-- Example: Add a new customer
INSERT INTO Customer (CustID, Fname, Lname, EmailAddress, PhoneNumber, Street, ZipCode, State, City)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', 1234567890, '123 Main St', 90210, 'CA', 'Beverly Hills');

-- Example: Retrieve all books by a certain publisher
SELECT Title, Genre, Year, Price
FROM Book
WHERE PubName = 'Example Publisher Inc.';

-- Example: Update a book's quantity
UPDATE Book
SET Quantity = Quantity - 1
WHERE BookID = 101 AND Quantity > 0;

-- Example: Delete an order (this would also delete related entries in 'Contain' due to ON DELETE CASCADE)
DELETE FROM Orders
WHERE OrderID = 201;

