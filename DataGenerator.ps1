[CmdletBinding()]
Param(
    [string]$server = "localhost",
    [string]$database = "SampleData",
    [string]$user = "sa",
    [string]$password = "ppedv!2017",
    #[ValidateRange(1,4294967295)]
    [int]$countProducts = 50,
    #[ValidateRange(1,4294967295)]
    [int]$countCustomers = 100
)
#prüfen ob Modul oder die DLL dateien überhaupt existieren ?
Import-Module SqlPs

Add-Type -Path ".\Tynamix.ObjectFiller.dll"
Add-Type -Path ".\DataGenerator.dll"
$generator = New-Object DataGenerator.Generator

function CreateDb {
    $cleanup1 = "Alter Database " + $database + " Set single_user With Rollback Immediate"
    $cleanup2 = "Drop Database If Exists " + $database
    $createDbSqlCommand = "Create Database " + $database
    Invoke-Sqlcmd -Query $cleanup1 -ServerInstance $server -Username $user -Password $password -database master
    Invoke-Sqlcmd -Query $cleanup2 -ServerInstance $server -Username $user -Password $password -database master
    Invoke-Sqlcmd -Query $createDbSqlCommand -ServerInstance $server -Username $user -Password $password
    Invoke-Sqlcmd -InputFile ".\create Tables.sql" -ServerInstance $server -Username $user -Password $password -database $database
}

function CreateAndInsertProducts {
    $products = $generator.GetProducts($countProducts)
    foreach ($p in $products)
    {
        $insertProductCommand = "Insert Into Products (ProductName, ProductPrice) Values ('" + $p.Name + "', " + $p.Price + ")"
        Invoke-Sqlcmd -Query $insertProductCommand -ServerInstance $server -Username $user -Password $password -database $database
    }
}

function CreateAndInsertCustomersWithOrders {
    $customers = $generator.GetCustomers($countCustomers)
    $count = 1
    foreach ($c in $customers)
    {
        write-output ("Processing Customer "+ $count + " of " + $countCustomers)
        $count++
        $c.Address.Street = $c.Address.Street.replace("\'", "''")
        $insertCustomerCommand = "Insert Into Customers (FirstName, LastName, BirthDate, City, ZipCode, Street, Country) Values ('" + $c.Firstname + "', '" + $c.Lastname + "', '" + $c.Birthdate + "', '" + $c.Address.City + "', '" + $c.Address.ZipCode + "', '" + $c.Address.Street + "', '" + $c.Address.Country + "')"
        
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
}

CreateDb
CreateAndInsertProducts
CreateAndInsertCustomersWithOrders

Write-Output "Done..."
