CREATE TABLE Employee (
  EmpID INT PRIMARY KEY,
  FName VARCHAR(32) NOT NULL,
  LName VARCHAR(32) NOT NULL,
  Position VARCHAR(32) NOT NULL CHECK (Position IN ('Manager', 'Cashier')),
  HireDate DATE NOT NULL
);
