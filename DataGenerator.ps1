[CmdletBinding()]
Param(
    [string]$server,
    [string]$database,
    [string]$user,
    [string]$password,
    [int]$countProducts = 50,
    [int]$countCustomers = 100
)

Add-Type -Path ".\Tynamix.ObjectFiller.dll"
Add-Type -Path ".\DataGenerator.dll"

if($server -eq "") {
    $server = "localhost"
}
if($database -eq "") {
    $database = "SampleData"
}
if($user -eq "") {
    $user = "sa"
}
if($password -eq "") {
    $password = "ppedv!2017"
}

function CreateDb {
    $cleanup1 = "alter database " + $database + " set single_user with rollback immediate"
    $cleanup2 = "drop database if exists " + $database
    $createDbSqlCommand = "Create Database " + $database
    Invoke-Sqlcmd -Query $cleanup1 -ServerInstance $server -Username $user -Password $password -database master
    Invoke-Sqlcmd -Query $cleanup2 -ServerInstance $server -Username $user -Password $password -database master
    Invoke-Sqlcmd -Query $createDbSqlCommand -ServerInstance $server -Username $user -Password $password
    Invoke-Sqlcmd -InputFile ".\create Tables.sql" -ServerInstance $server -Username $user -Password $password -database $database
}
CreateDb


$generator = New-Object DataGenerator.Generator

#process Products
$products = $generator.GetProducts($countProducts)
foreach ($p in $products)
{
    $insertProductCommand = "Insert Into Products (ProductName, ProductPrice) Values ('" + $p.Name + "', " + $p.Price + ")"
    Invoke-Sqlcmd -Query $insertProductCommand -ServerInstance $server -Username $user -Password $password -database $database
}

$customers = $generator.GetCustomers($countCustomers)
$count = 1
foreach ($c in $customers)
{
    write-output ("Processing Customer "+ $count + " of " + $countCustomers)
    $count++
    $c.Address.Street = $c.Address.Street.replace("\'", "''")
    $insertCustomerCommand = "Insert Into Customers (FirstName, LastName, BirthDate, City, ZipCode, Street, Country) Values ('" + $c.Firstname + "', '" + $c.Lastname + "', '" + $c.Birthdate + "', '" + $c.Address.City + "', '" + $c.Address.ZipCode + "', '" + $c.Address.Street + "', '" + $c.Address.Country + "')"
    #write-debug "bl2"
    Invoke-Sqlcmd -Query $insertCustomerCommand -ServerInstance $server -Username $user -Password $password -database $database

    foreach($o in $c.Orders)
    {
        $insertOrderCommand = "insert into orders(CustomerID, OrderDate, Freight) values ((select max(src.customerid) from customers as src), '" + $o.OrderDate + "', " + $o.Freight + ")"
        #$insertOrderCommand
        Invoke-Sqlcmd -Query $insertOrderCommand -ServerInstance $server -Username $user -Password $password -database $database
        
        foreach($od in $o.OrderDetails)
        {
            $ProductIDMax = invoke-SQLCmd -query "select max(ProductID) from Products" -ServerInstance $server -Username $user -Password $password -database $database
            $randomProductID = get-random -minimum 1 -maximum $ProductIDMax.column1
            $insertOrderDetailCommand = "insert into OrderDetails(OrderID, ProductID, ProductPrice, Quantity) values((select max(ohSrc.orderid)from orders as ohSrc), " + $randomProductID + ", (select pSrc.ProductPrice from products as pSrc where psrc.productID = " + $randomProductID + "), " + $od.Quantity +")"
            Invoke-Sqlcmd -Query $insertOrderDetailCommand -ServerInstance $server -Username $user -Password $password -database $database
        }
    }
}
Write-Output "Done..."