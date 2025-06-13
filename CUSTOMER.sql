CREATE TABLE Customer (
  CustID  INT  PRIMARY KEY,
  Fname  VARCHAR(32)  NOT NULL,
  Lname  VARCHAR(32)  NOT NULL,
  EmailAddress  VARCHAR(64),
  PhoneNumber  BIGINT,
  Street  VARCHAR(64),
  ZipCode  INT,
  State  CHAR(2),
  City  VARCHAR(32)
);
