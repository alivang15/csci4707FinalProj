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
