using System;
using System.Collections.Generic;

namespace DataGenerator.Models
{
    public class Customer
    {
        public int Id { get; set; }
        public string Firstname { get; set; }
        public string Lastname { get; set; }
        public DateTime Birthdate { get; set; }
        public Address Address { get; set; }

        public ICollection<Order> Orders { get; } = new HashSet<Order>();
    }
}
