using System.Collections.Generic;

namespace DataGenerator.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }

        public ICollection<OrderDetail> OrderDetails { get; } = new HashSet<OrderDetail>();
    }
}