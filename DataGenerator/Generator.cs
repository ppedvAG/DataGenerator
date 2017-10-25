using DataGenerator.Models;
using System;
using System.Collections.Generic;

namespace DataGenerator
{
    public class Generator
    {
        public IEnumerable<Product> GetProducts(int count) => FillerGenerator.GetProductFiller().Create(count);
        public IEnumerable<Customer> GetCustomers(int count)
        {
            var customers = FillerGenerator.GetCustomerFiller().Create(count);

            var random = new Random();

            foreach (var c in customers)
            {
                var orders = FillerGenerator.GetOrderFiller().Create(random.Next(1, 50));
                foreach (var o in orders)
                {
                    c.Orders.Add(o);

                    var orderDetails = FillerGenerator.GetOrderDetailFiller().Create(random.Next(1, 20));
                    foreach (var od in orderDetails)
                        o.OrderDetails.Add(od);
                }
            }

            return customers;
        }
    }
}
