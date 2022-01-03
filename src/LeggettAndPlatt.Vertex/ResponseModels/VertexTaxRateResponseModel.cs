using System.Collections.Generic;

namespace LeggettAndPlatt.Vertex.ResponseModels
{
    public class VertexTaxRateResponseModel
    {
        public VertexTaxRateResponseModel()
        {
            LineItems = new List<LineItemResponseModel>();
        }
        public decimal SubTotal { get; set; }
        public decimal TotalTax { get; set; }
        public decimal Total { get; set; }
        public List<LineItemResponseModel> LineItems { get; set; }

        public string RequestXml { get; set; }

        public string ResponseXml { get; set; }
    }

    public class LineItemResponseModel
    {
        public string Sku { get; set; }
        public int Qty { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalTax { get; set; }
    }
}
