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
