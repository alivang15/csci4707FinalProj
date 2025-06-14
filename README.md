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

### First run below code:
````sql

-- Example: Add a new customer (Ensure this is run first if CustID 1 doesn't exist)
INSERT INTO Customer (CustID, Fname, Lname, EmailAddress, PhoneNumber, Street, ZipCode, State, City)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', 1234567890, '123 Main St', 90210, 'CA', 'Beverly Hills');

-- Example: Add a new Publisher
INSERT INTO Publisher (CompanyName, PhoneNum, Email)
VALUES ('Readers Guild Publishing', 5551234567, 'contact@readersguild.com');

-- Example: Add a new Author
INSERT INTO Author (AuthID, Fname, Lname, Biography)
VALUES (101, 'Jane', 'Austen', 'Esteemed English novelist known for her romantic fiction set among the landed gentry.');

-- Example: Add a new Book (assuming 'Readers Guild Publishing' was just added)
INSERT INTO Book (BookID, Title, PubName, Genre, Year, Price, Quantity)
VALUES (101, 'Pride and Prejudice', 'Readers Guild Publishing', 'Classic Romance', 1999, 12.99, 50);

-- Example: Add another Book by the same publisher (Corrected Year)
INSERT INTO Book (BookID, Title, PubName, Genre, Year, Price, Quantity)
VALUES (102, 'Sense and Sensibility', 'Readers Guild Publishing', 'Classic Romance', 1911, 11.99, 30); -- Changed 1811 to 1911 (or any valid year)

-- Example: Link Author to Book in Wrote table
INSERT INTO Wrote (AuthID, BookID)
VALUES (101, 101);
INSERT INTO Wrote (AuthID, BookID)
VALUES (101, 102);

-- Example: Add new Employees
INSERT INTO Employee (EmpID, FName, LName, Position, HireDate)
VALUES (501, 'Alice', 'Smith', 'Cashier', '2024-01-15');

INSERT INTO Employee (EmpID, FName, LName, Position, HireDate)
VALUES (500, 'Bob', 'Brown', 'Manager', '2023-01-10'); -- Ensure this manager is added if referenced later

-- Example: Add a new Payment
INSERT INTO Payment (PaymentID, PayDate, PayMethod, Amount)
VALUES (301, '2024-03-01', 'Credit Card', 25.98);

-- Example: Add a new Order (referencing Customer 1, Employee 501, and Payment 301)
-- Make sure CustID 1, EmpID 501, and PaymentID 301 exist before running this
INSERT INTO Orders (OrderID, CustID, CashID, PaymentID, ShipStreet, ShipCity, ShipState, ShipZip, PaymentStatus, OrderDate, ShipDate)
VALUES (201, 1, 501, 301, '123 Main St', 'Beverly Hills', 'CA', 90210, TRUE, '2024-03-01', '2024-03-02');

-- Example: Add items to the Order in Contain table
-- Make sure OrderID 201 and BookIDs 101, 102 exist
INSERT INTO Contain (OrderID, BookID, BookQuantity, BookPrice)
VALUES (201, 101, 1, 12.99);
INSERT INTO Contain (OrderID, BookID, BookQuantity, BookPrice)
VALUES (201, 102, 1, 11.99);

-- Example: Add an inventory record for a book
-- Make sure BookID 101 and EmpID 500 (Manager) exist
INSERT INTO Inventory (InventoryName, BookID, ManID, InvQuantity, RestockThres)
VALUES ('Main Stock Romance', 101, 500, 50, 10);

-- Example: Record assistance provided by an employee to a customer
-- Make sure CustID 1 and EmpID 501 exist
INSERT INTO Assisted (CustID, EmpID)
VALUES (1, 501);

````

### Uncomment each SQL query to see how it works:

````sql

-- 1. VIEWING CURRENT DATA
-- Show all customers
SELECT * FROM Customer;

-- Show all books
SELECT * FROM Book;

-- Show all orders
SELECT * FROM Orders;

-- Show all items in a specific order (e.g., OrderID 201, if it exists)
SELECT * FROM Contain WHERE OrderID = 201;


-- -- 2. UPDATING DATA
-- -- Update a customer's email address
-- UPDATE Customer
-- SET EmailAddress = 'john.new.email@example.com'
-- WHERE CustID = 1;

-- -- Verify the update
-- SELECT * FROM Customer WHERE CustID = 1;

-- -- Update a book's price and quantity
-- UPDATE Book
-- SET Price = 14.99, Quantity = Quantity - 5
-- WHERE BookID = 101; -- Assuming BookID 101 is 'Pride and Prejudice'

-- -- Verify the book update
-- SELECT * FROM Book WHERE BookID = 101;


-- -- 3. DELETING SPECIFIC DATA (A ROW THAT DOESN'T HAVE MAJOR CASCADE EFFECTS YET)
-- -- Let's assume we add a temporary author and then delete them.
-- INSERT INTO Author (AuthID, Fname, Lname, Biography)
-- VALUES (999, 'Temp', 'Author', 'A temporary author for deletion test.');

-- -- View the temporary author
-- SELECT * FROM Author WHERE AuthID = 999;

-- -- Delete the temporary author
-- DELETE FROM Author WHERE AuthID = 999;

-- -- Verify deletion
-- SELECT * FROM Author WHERE AuthID = 999; -- Should return no rows


-- -- 4. DELETING AN ENTITY AND OBSERVING `ON DELETE SET NULL`
-- -- Scenario: Delete an Employee (e.g., a Cashier) and see their Orders' CashID become NULL.
-- -- First, let's see orders handled by Employee 501 (Alice Smith, Cashier)
-- SELECT OrderID, CustID, CashID FROM Orders WHERE CashID = 501;

-- -- Now, delete Employee Alice Smith
-- DELETE FROM Employee WHERE EmpID = 501;

-- -- Verify Employee 501 is deleted
-- SELECT * FROM Employee WHERE EmpID = 501; -- Should return no rows

-- -- Check the Orders table again. Orders previously handled by EmpID 501 should now have CashID = NULL
-- SELECT OrderID, CustID, CashID FROM Orders WHERE OrderID = 201; -- Assuming Order 201 was handled by EmpID 501

-- -- Also check the Assisted table (if Alice assisted anyone, those records would be gone due to ON DELETE CASCADE on Assisted.EmpID)
-- SELECT * FROM Assisted WHERE EmpID = 501; -- Should return no rows


-- -- 5. DELETING AN ENTITY AND OBSERVING `ON DELETE CASCADE`
-- -- Scenario: Delete a Book and see its records in 'Wrote' and 'Contain' also get deleted.
-- -- Also, its record in 'Inventory' will be deleted because Inventory.BookID has ON DELETE CASCADE.

-- -- First, let's see records related to BookID 102 ('Sense and Sensibility')
-- SELECT * FROM Wrote WHERE BookID = 102;
-- SELECT * FROM Contain WHERE BookID = 102; -- (This would be for any order that contained BookID 102)
-- SELECT * FROM Inventory WHERE BookID = 102;

-- -- Now, delete Book 'Sense and Sensibility' (BookID 102)
-- DELETE FROM Book WHERE BookID = 102;

-- -- Verify Book 102 is deleted
-- SELECT * FROM Book WHERE BookID = 102; -- Should return no rows

-- -- Check Wrote table: Records for BookID 102 should be gone
-- SELECT * FROM Wrote WHERE BookID = 102; -- Should return no rows

-- -- Check Contain table: Line items for BookID 102 in any order should be gone
-- -- (If Order 201 contained BookID 102, that specific line item would be removed)
-- SELECT * FROM Contain WHERE OrderID = 201; -- Re-check order 201 items

-- -- Check Inventory table: Record for BookID 102 should be gone
-- SELECT * FROM Inventory WHERE BookID = 102; -- Should return no rows


-- -- 6. DELETING A CUSTOMER AND OBSERVING `ON DELETE CASCADE` (MORE EXTENSIVE)
-- -- Scenario: Delete Customer 1 (John Doe). This should cascade to Orders, then Contain, and also Assisted.

-- -- First, see records related to Customer 1
-- SELECT * FROM Orders WHERE CustID = 1;
-- SELECT OrderID FROM Orders WHERE CustID = 1; -- Get OrderIDs to check Contain table
-- -- Assuming OrderID 201 belongs to CustID 1:
-- SELECT * FROM Contain WHERE OrderID = 201;
-- SELECT * FROM Assisted WHERE CustID = 1;

-- -- Now, delete Customer 1
-- DELETE FROM Customer WHERE CustID = 1;

-- -- Verify Customer 1 is deleted
-- SELECT * FROM Customer WHERE CustID = 1; -- Should return no rows

-- -- Check Orders table: Orders for CustID 1 should be gone
-- SELECT * FROM Orders WHERE CustID = 1; -- Should return no rows

-- -- Check Contain table: Items for orders belonging to CustID 1 (e.g., OrderID 201) should be gone
-- SELECT * FROM Contain WHERE OrderID = 201; -- Should return no rows

-- -- Check Assisted table: Assistance records for CustID 1 should be gone
-- SELECT * FROM Assisted WHERE CustID = 1; -- Should return no rows

-- -- 7. DELETING A PUBLISHER AND OBSERVING `ON DELETE SET NULL`
-- -- Scenario: Delete a Publisher and see Book.PubName become NULL for books by that publisher.
-- -- Let's assume 'Readers Guild Publishing' is the publisher for BookID 101.
-- SELECT BookID, Title, PubName FROM Book WHERE PubName = 'Readers Guild Publishing';

-- -- Delete the publisher
-- DELETE FROM Publisher WHERE CompanyName = 'Readers Guild Publishing';

-- -- Verify the publisher is deleted
-- SELECT * FROM Publisher WHERE CompanyName = 'Readers Guild Publishing'; -- Should return no rows

-- -- Check the Book table. Books previously published by 'Readers Guild Publishing' should now have PubName = NULL
-- SELECT BookID, Title, PubName FROM Book WHERE BookID = 101;

````

**Important Notes for Testing:**

*   **Run in Order:** Execute these test cases in the order provided, as some depend on the state created by previous ones.
*   **Adapt IDs:** If your actual `INSERT` statements used different IDs (e.g., for `BookID`, `CustID`, `OrderID`), you'll need to adjust the IDs in these test cases accordingly.
*   **Data State:** The outcome of `DELETE` operations, especially those with `CASCADE` or `SET NULL`, heavily depends on the data present in your tables at the time of execution.
*   **db-fiddle.com:** When using db-fiddle, you can put your schema (CREATE TABLE statements) in the left panel and your DML (INSERT, SELECT, UPDATE, DELETE test cases) in the right panel. Run the schema first, then run the DML. You might want to run DML statements in smaller batches to observe the results more clearly.

