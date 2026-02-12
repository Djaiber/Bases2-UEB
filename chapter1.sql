/* Drop tables if they exist (clean start) */
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE OrderItem CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE OrderHeader CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE TitleAuthor CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE Title CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE Author CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE Customer CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE Promotion CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE MyFirstQuery CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      NULL; -- Ignore errors if tables don't exist
END;
/

/* Create SQL Novel tables with all constraints inline */
CREATE TABLE Title (
   TitleID NUMBER(10) NOT NULL,
   TitleName VARCHAR2(50) NOT NULL,
   Price NUMBER(5,2) NOT NULL,
   Advance NUMBER(8,2) NOT NULL,
   Royalty NUMBER(5,2) NULL,
   PublicationDate DATE NOT NULL,
   CONSTRAINT pk_title PRIMARY KEY (TitleID)
);

CREATE TABLE Author (
   AuthorID NUMBER(10) NOT NULL,
   FirstName VARCHAR2(30) NOT NULL,
   MiddleName VARCHAR2(30) NULL,
   LastName VARCHAR2(30) NOT NULL,
   PaymentMethod VARCHAR2(50) NOT NULL,
   CONSTRAINT pk_author PRIMARY KEY (AuthorID)
);

CREATE TABLE TitleAuthor (
   TitleID NUMBER(10) NOT NULL,
   AuthorID NUMBER(10) NOT NULL,
   AuthorOrder NUMBER(10) NOT NULL,
   CONSTRAINT pk_titleauthor PRIMARY KEY (TitleID, AuthorID),
   CONSTRAINT fk_titleauthor_title FOREIGN KEY (TitleID) REFERENCES Title(TitleID),
   CONSTRAINT fk_titleauthor_author FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

CREATE TABLE Customer (
   CustomerID NUMBER(10) NOT NULL,
   FirstName VARCHAR2(30) NOT NULL,
   LastName VARCHAR2(30) NOT NULL,
   Address VARCHAR2(50) NULL,
   City VARCHAR2(50) NULL,
   State VARCHAR2(5) NULL,
   Zip VARCHAR2(10) NULL,
   Country VARCHAR2(50) NULL,
   CONSTRAINT pk_customer PRIMARY KEY (CustomerID)
);

CREATE TABLE Promotion (
   PromotionID NUMBER(10) NOT NULL,
   PromotionCode VARCHAR2(10) NOT NULL,
   PromotionStartDate DATE NOT NULL,
   PromotionEndDate DATE NOT NULL,
   CONSTRAINT pk_promotion PRIMARY KEY (PromotionID)
);

CREATE TABLE OrderHeader (
   OrderID NUMBER(10) NOT NULL,
   CustomerID NUMBER(10) NOT NULL,
   PromotionID NUMBER(10) NULL,
   OrderDate DATE NOT NULL,
   CONSTRAINT pk_orderheader PRIMARY KEY (OrderID),
   CONSTRAINT fk_orderheader_customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
   CONSTRAINT fk_orderheader_promotion FOREIGN KEY (PromotionID) REFERENCES Promotion(PromotionID)
);

CREATE TABLE OrderItem (
   OrderID NUMBER(10) NOT NULL,
   OrderItem NUMBER(10) NOT NULL,
   TitleID NUMBER(10) NOT NULL,
   Quantity NUMBER(10) NOT NULL,
   ItemPrice NUMBER(5,2) NOT NULL,
   CONSTRAINT pk_orderitem PRIMARY KEY (OrderID, OrderItem),
   CONSTRAINT fk_orderitem_order FOREIGN KEY (OrderID) REFERENCES OrderHeader(OrderID),
   CONSTRAINT fk_orderitem_title FOREIGN KEY (TitleID) REFERENCES Title(TitleID)
);

CREATE TABLE MyFirstQuery (
   Outcome VARCHAR2(20) NOT NULL,
   CONSTRAINT pk_myfirstquery PRIMARY KEY (Outcome)
);

-- Verify tables were created
SELECT table_name FROM user_tables ORDER BY table_name;

-- Verify constraints
SELECT table_name, constraint_name, constraint_type 
FROM user_constraints 
ORDER BY table_name, constraint_type;

/* Populate SQLNovel tables */
-- Title inserts
INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (101, 'Pride and Predicates', 9.95, 5000, 15, DATE '2015-04-30');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (102, 'The Join Luck Club', 9.95, 6000, 12, DATE '2016-02-06');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (103, 'Catcher in the Try', 8.95, 5000, 10, DATE '2017-04-03');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (104, 'Anne of Fact Tables', 12.95, 10000, 15, DATE '2018-01-12');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (105, 'The DateTime Machine', 7.95, 5500, 15, DATE '2019-02-04');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (106, 'The Great GroupBy', 10.95, 0, 20, DATE '2019-12-23');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (107, 'The Call of the While', 8.95, 2500, 15, DATE '2020-03-14');

INSERT INTO Title (TitleID, TitleName, Price, Advance, Royalty, PublicationDate)
VALUES (108, 'The Sum Also Rises', 7.95, 5000, 12, DATE '2021-11-12');

-- Author inserts
INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (1, 'Paul', 'K', 'Tripp', 'Cash');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (2, 'Doug', NULL, 'Li', 'Check');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (3, 'Jen', NULL, 'Strong', 'Check');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (4, 'Jorge', 'Armando', 'Guerra', 'Check');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (5, 'Robert', 'Grant', 'Davidson', 'Check');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (6, 'Gail', 'Anne', 'Shawn', 'Check');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (7, 'Rebecca', NULL, 'Miller', 'Check');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (8, 'Andy', NULL, 'Melkin', 'Direct Deposit');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (9, 'Buck', NULL, 'Fernandez', 'Cash');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (10, 'Chris', NULL, 'Walenski', 'Direct Deposit');

INSERT INTO Author (AuthorID, FirstName, MiddleName, LastName, PaymentMethod)
VALUES (11, 'Deepthi', NULL, 'Mahadevan', 'Direct Deposit');

-- TitleAuthor inserts
INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (101, 2, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (102, 3, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (103, 4, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (104, 5, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (105, 6, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (106, 7, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (107, 11, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (107, 1, 2);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (108, 8, 1);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (108, 9, 2);

INSERT INTO TitleAuthor (TitleID, AuthorID, AuthorOrder)
VALUES (108, 10, 3);

-- Customer inserts
INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (1, 'Chris', 'Dixon', '212 N Rose St', 'Lakewood', 'CO', '80215', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (2, 'David', 'Power', '44 Wiley St', 'Henderson', 'NV', '89002', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (3, 'Arnold', 'Hinchcliffe', '7333 E Levine St', 'Atlanta', 'GA', '30303', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (4, 'Keanu', 'O''Ward', '415 N Hinson St', 'Madison', 'WI', '53703', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (5, 'Lisa', 'Rosenqvist', '56 S Burnett St', 'Reston', 'VA', '20190', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (6, 'Maggie', 'Ilott', '111 Fuson St', 'Flagstaff', 'AZ', '86015', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (7, 'Cora', 'Daly', '55 S Brandt St', 'Anaheim', 'CA', '92802', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (8, 'Dan', 'Wilson', '29 W Pousson St', 'Seattle', 'WA', '98104', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (9, 'Kelly', 'Wheldon', '300 Dewsnup St', 'Boise', 'ID', '83703', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (10, 'Bhaskar', 'Palou', '3443 E Ramella St', 'Evansville', 'IN', '47702', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (11, 'Kevin', 'Daly', '123 Terry St', 'Rochester', 'NY', '02345', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (12, 'Jordan', 'Ericsson', '187 E Boich St', 'Gilbert', 'AZ', '85296', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (13, 'Ming', 'Zhou', '42 S Walsh St', 'Portsmouth', 'NH', '03801', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (14, 'Jack', 'Sato', '242 S Corbett St', 'Burlington', 'VT', '05401', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (15, 'Joe', 'Pagenaud', '59 E Fleming St', 'Detroit', 'MI', '48202', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (16, 'Tara', 'Di Silvestro', '789 N Kizer St', 'San Diego', 'CA', '92101', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (17, 'Sandra', 'Calderon', '5 W Delany St', 'Denver', 'CO', '80014', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (18, 'Margaret', 'Montoya', '48 Clark St', 'Monterey', 'CA', '93940', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (19, 'Monica', 'Newgarden', '99 Lynn St', 'Clayton', 'MO', '63105', 'USA');

INSERT INTO Customer (CustomerID, FirstName, LastName, Address, City, State, Zip, Country)
VALUES (20, 'Mia', 'Rossi', '276 N Morrison St', 'Orlando', 'FL', '32801', 'USA');

-- OrderHeader inserts 
INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1001, 1, NULL, DATE '2015-06-01');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1002, 2, NULL, DATE '2015-06-15');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1003, 3, NULL, DATE '2015-07-03');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1004, 4, NULL, DATE '2015-08-12');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1005, 5, NULL, DATE '2015-09-05');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1006, 6, 1, DATE '2015-11-02');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1007, 7, 1, DATE '2015-11-15');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1008, 8, 1, DATE '2015-11-22');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1009, 9, NULL, DATE '2016-02-12');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1010, 3, NULL, DATE '2016-03-01');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1011, 10, NULL, DATE '2016-06-30');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1012, 1, NULL, DATE '2016-09-02');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1013, 6, 2, DATE '2016-11-03');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1014, 11, 2, DATE '2016-11-12');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1015, 5, 2, DATE '2016-11-14');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1016, 7, 2, DATE '2016-11-23');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1017, 12, NULL, DATE '2016-12-08');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1018, 13, NULL, DATE '2017-01-31');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1019, 3, NULL, DATE '2017-04-05');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1020, 8, NULL, DATE '2017-07-22');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1021, 14, NULL, DATE '2017-10-16');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1022, 13, 3, DATE '2017-11-01');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1023, 2, 3, DATE '2017-11-14');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1024, 14, 3, DATE '2017-11-20');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1025, 4, NULL, DATE '2018-01-23');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1026, 5, NULL, DATE '2018-05-25');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1027, 12, 4, DATE '2018-06-14');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1028, 11, 5, DATE '2018-11-01');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1029, 10, 5, DATE '2018-11-11');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1030, 4, NULL, DATE '2019-02-24');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1031, 15, 6, DATE '2019-06-07');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1032, 16, NULL, DATE '2019-08-11');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1033, 9, 7, DATE '2019-11-04');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1034, 10, 7, DATE '2019-11-14');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1035, 4, NULL, DATE '2019-12-29');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1036, 3, NULL, DATE '2020-01-18');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1037, 4, NULL, DATE '2020-03-15');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1038, 17, NULL, DATE '2020-05-22');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1039, 10, NULL, DATE '2020-09-13');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1040, 7, 9, DATE '2020-11-07');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1041, 8, 9, DATE '2020-11-21');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1042, 6, NULL, DATE '2021-01-29');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1043, 18, NULL, DATE '2021-04-23');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1044, 19, NULL, DATE '2021-06-06');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1045, 11, NULL, DATE '2021-10-01');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1046, 4, NULL, DATE '2021-11-13');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1047, 19, NULL, DATE '2021-11-28');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1048, 16, NULL, DATE '2021-01-15');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1049, 20, 12, DATE '2021-03-05');

INSERT INTO OrderHeader (OrderID, CustomerID, PromotionID, OrderDate)
VALUES (1050, 1, 12, DATE '2022-03-10');


-- OrderItem inserts 
INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1001, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1002, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1003, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1004, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1005, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1006, 1, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1007, 1, 101, 2, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1008, 1, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1009, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1010, 1, 102, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1011, 1, 102, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1011, 2, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1012, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1012, 2, 102, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1013, 1, 101, 3, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1014, 1, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1014, 2, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1015, 1, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1016, 1, 101, 2, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1017, 1, 102, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1018, 1, 102, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1019, 1, 103, 1, 8.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1020, 1, 103, 1, 8.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1021, 1, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1021, 2, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1021, 3, 103, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1022, 1, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1022, 1, 103, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1023, 1, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1024, 1, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1025, 1, 104, 1, 12.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1026, 1, 103, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1027, 1, 101, 1, 8.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1028, 1, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1028, 2, 103, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1029, 1, 103, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1030, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1031, 1, 105, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1032, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1033, 1, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1033, 2, 103, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1034, 1, 102, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1034, 2, 103, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1034, 3, 104, 1, 10.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1034, 4, 105, 1, 5.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1035, 1, 106, 1, 10.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1036, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1037, 1, 107, 1, 8.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1038, 1, 101, 1, 9.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1039, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1040, 1, 105, 1, 5.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1041, 1, 105, 1, 5.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1041, 2, 107, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1042, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1043, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1044, 1, 105, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1044, 2, 103, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1045, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1046, 1, 108, 1, 5.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1047, 1, 108, 1, 5.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1047, 2, 101, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1048, 1, 105, 1, 7.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1049, 1, 101, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1049, 2, 102, 1, 6.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1049, 3, 103, 1, 5.95);

INSERT INTO OrderItem (OrderID, OrderItem, TitleID, Quantity, ItemPrice)
VALUES (1050, 1, 108, 1, 4.95);

-- Promotion inserts
INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (1, '2OFF2015', DATE '2011-11-01', DATE '2011-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (2, '2OFF2016', DATE '2012-11-01', DATE '2012-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (3, '2OFF2017', DATE '2013-11-01', DATE '2013-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (4, '1OFF2018', DATE '2014-06-01', DATE '2014-06-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (5, '2OFF2018', DATE '2014-11-01', DATE '2014-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (6, '1OFF2019', DATE '2015-06-01', DATE '2015-06-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (7, '2OFF2019', DATE '2015-11-01', DATE '2015-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (8, '1OFF2020', DATE '2016-06-01', DATE '2016-06-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (9, '2OFF2020', DATE '2016-11-01', DATE '2016-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (10, '1OFF2021', DATE '2017-06-01', DATE '2017-06-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (11, '2OFF2021', DATE '2017-11-01', DATE '2017-11-30');

INSERT INTO Promotion (PromotionID, PromotionCode, PromotionStartDate, PromotionEndDate)
VALUES (12, '3OFF2022', DATE '2018-03-04', DATE '2018-03-11');

-- MyFirstQuery insert
INSERT INTO MyFirstQuery (Outcome)
VALUES ('Hello, World!');

-- Commit all changes
COMMIT;

-- Verify final counts
SELECT 'Title' AS Table_Name, COUNT(*) AS Row_Count FROM Title UNION ALL
SELECT 'Author', COUNT(*) FROM Author UNION ALL
SELECT 'TitleAuthor', COUNT(*) FROM TitleAuthor UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer UNION ALL
SELECT 'OrderHeader', COUNT(*) FROM OrderHeader UNION ALL
SELECT 'OrderItem', COUNT(*) FROM OrderItem UNION ALL
SELECT 'Promotion', COUNT(*) FROM Promotion UNION ALL
SELECT 'MyFirstQuery', COUNT(*) FROM MyFirstQuery;