using System;
using System.Collections.Generic;

namespace LeggettAndPlatt.Vertex.RequestModels
{
    public class VertexTaxRateRequestModel : VertexLoginRequestModel
    {
        public VertexTaxRateRequestModel()
        {
            LineItems = new List<LineItemRequestModel>();
        }
        public string StreetAddress1 { get; set; }
        public string StreetAddress2 { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public string State { get; set; }
        public string Zip { get; set; }
        public DateTime Date { get; set; }
        public string Branch { get; set; }
        public string TaxAreaId { get; set; }
        public string LegalEntity { get; set; }
        public string CustomerNumber { get; set; }
        public string CurrencyCode { get; set; }
        public string Company { get; set; }

        public List<LineItemRequestModel> LineItems { get; set; }

        public bool EnableLog { get; set; }

    }

    public class LineItemRequestModel
    {
        public string Sku { get; set; }
        public int Qty { get; set; }
        public decimal UnitPrice { get; set; }
        public string UnitOfMeasure { get; set; }
        public string TaxClass { get; set; }
        public string Branch { get; set; }
        public string LegalEntity { get; set; }
        public string TaxAreaId { get; set; }
    }
}
