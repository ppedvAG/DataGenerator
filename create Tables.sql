Create Table Products (
	Productid int IDENTITY constraint pkProducts primary key nonclustered
	, ProductName nvarchar(50)
	, ProductPrice numeric (16,4)
)

Create Table Customers (
	CustomerId int IDENTITY constraint pkCustomers PRIMARY KEY nonclustered,
	Firstname varchar(50) NOT NULL,
	Lastname varchar(50) NOT NULL,
	Birthdate date NOT NULL,
	City varchar(50) NULL,
	ZipCode varchar(50) NULL,
	Street varchar(100) NULL,
	Country varchar(100) NULL
)

create table Orders (
	Orderid int IDENTITY constraint pkOrders primary key
	, CustomerID int not null constraint fkCustomer foreign key references customers(customerid)
	, Orderdate date not null
	, Freight numeric(16,4) not null
)

create table OrderDetails (
	PositionID int IDENTITY constraint pkOrderDetails primary key
	, OrderID int not null constraint fkOrders foreign key references Orders(OrderID)
	, ProductID int not null constraint fkProducts foreign key references Products(ProductID)
	, ProductPrice numeric(16,4) not null
	, Quantity int not null
)