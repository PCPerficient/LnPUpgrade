using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Data.Entities;
using Insite.Integration.WebService.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Integration.WebService.PlugIns.Postprocessor.Orders
{
    [DependencyName("OrderHistoryRefresh")]
    class JobPostprocessorOrderHistoryRefresh : IJobPostprocessor, ITransientLifetime, IDependency, IExtension
    {

        protected readonly IUnitOfWork UnitOfWork;
        protected IRepository<OrderHistory> orderHistoryRepository;
        protected IRepository<OrderHistoryLine> orderHistoryLineRepository;
        protected IRepository<Shipment> orderShipmentRepository;
        protected IRepository<ShipmentPackage> orderShipmentPackageRepository;
        protected IRepository<ShipmentPackageLine> orderShipmentPackageLineRepository;

        protected DataSet orderHistoryDataSet;
        protected DataTable orderHistory;
        protected DataTable orderHistoryLine;
        protected DataTable orderShipment;
        protected DataTable orderShipmentPackage;
        protected DataTable orderShipmentPackageLine;

        public IJobLogger JobLogger { get; set; }
        public IntegrationJob IntegrationJob { get; set; }
        public JobPostprocessorOrderHistoryRefresh(IUnitOfWorkFactory unitOfWorkFactory)
        {
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.orderHistoryRepository = UnitOfWork.GetRepository<OrderHistory>();
            this.orderHistoryLineRepository = UnitOfWork.GetRepository<OrderHistoryLine>();
            this.orderShipmentRepository = UnitOfWork.GetRepository<Shipment>();
            this.orderShipmentPackageRepository = UnitOfWork.GetRepository<ShipmentPackage>();
            this.orderShipmentPackageLineRepository = UnitOfWork.GetRepository<ShipmentPackageLine>();
        }

        private void InitiateDataTables()
        {

            this.orderHistory = (this.orderHistoryDataSet.Tables.Contains("OrderHistoryModel")) ? this.orderHistoryDataSet.Tables["OrderHistoryModel"] : new DataTable("OrderHistoryModel");
            this.orderHistoryLine = (this.orderHistoryDataSet.Tables.Contains("OrderHistoryLineModel")) ? this.orderHistoryDataSet.Tables["OrderHistoryLineModel"] : new DataTable("OrderHistoryLineModel");
            this.orderShipment = (this.orderHistoryDataSet.Tables.Contains("ShipmentModel")) ? this.orderHistoryDataSet.Tables["ShipmentModel"] : new DataTable("ShipmentModel");
            this.orderShipmentPackage = (this.orderHistoryDataSet.Tables.Contains("ShipmentPackageModel")) ? this.orderHistoryDataSet.Tables["ShipmentPackageModel"] : new DataTable("ShipmentPackageModel");
            this.orderShipmentPackageLine = (this.orderHistoryDataSet.Tables.Contains("ShipmentPackageLineModel")) ? this.orderHistoryDataSet.Tables["ShipmentPackageLineModel"] : new DataTable("ShipmentPackageLineModel");
        }

        public void Execute(DataSet dataSet, CancellationToken cancellationToken)
        {
            try
            {
                this.orderHistoryDataSet = dataSet;
                Boolean dataSetValidate = IsValidateDataset();
                if (dataSetValidate == false)
                {
                    return;
                }
                this.JobLogger.Info("Starting OrderHistory Refresh");
                InitiateDataTables();
                //System.Diagnostics.Debugger.Launch();
                var orderHistoryRecords = (InternalDataCollectionBase)this.orderHistory.Rows;

                if (orderHistoryRecords == null || orderHistoryRecords.Count == 0)
                {
                    this.JobLogger.Warning("No order history records found to refresh.");
                    return;
                }
                if (orderHistoryRecords.Count > 0)
                {
                    foreach (DataRow orderHistoryDataRow in orderHistoryRecords)
                    {
                        string orderNumber = Convert.ToString(orderHistoryDataRow["OrderNo"]);
                        if (!StringExtensions.IsBlank(orderNumber))
                        {
                            OrderHistory orderHistoryModel = orderHistoryRepository.GetTable().FirstOrDefault(x => x.WebOrderNumber.Equals(orderNumber, StringComparison.InvariantCultureIgnoreCase));
                            if (orderHistoryModel == null)
                            {
                                orderHistoryModel = orderHistoryRepository.GetByNaturalKey(orderNumber);
                            }

                            if (orderHistoryModel == null)
                            {
                                orderHistoryModel = CreateOrderHistory(orderHistoryDataRow);
                            }
                            else
                            {
                                orderHistoryModel = UpdateOrderHistory(orderHistoryModel, orderHistoryDataRow);
                            }

                            if (orderHistoryModel != null)
                            {
                                ProcessOrderHistoryLines(orderHistoryModel);
                                ProcessOrderShipment(orderHistoryModel);
                            }

                        }
                    }
                }

                this.UnitOfWork.Save();
                this.JobLogger.Info("Ending OrderHistory Refresh");
            }
            catch (Exception ex)
            {
                this.JobLogger.Error(string.Format("Exception : OrderHistoryRefresh Error: {0} \n Exception Message : {1}", ex, ex.Message));
                throw;
            }
        }
       
        private Boolean IsValidateDataset()
        {

            if (this.orderHistoryDataSet.Tables.Count > 0)
            {
                this.JobLogger.Info("DataSet has " + Convert.ToString(this.orderHistoryDataSet.Tables[0].Rows.Count) + " OrderHistory.");
                return true;
            }
            else
            {
                this.JobLogger.Info("Dataset Has table Count :" + Convert.ToString(this.orderHistoryDataSet.Tables.Count));
                return false;
            }

        }
        private void ProcessOrderShipment(OrderHistory orderHistoryModel)
        {
            this.JobLogger.Info($"Process Order Shipment Start For Order {orderHistoryModel.WebOrderNumber}");
            if (this.orderShipment.Columns.Count > 0)
            {
                DataRow[] orderShipmentRows = this.orderShipment.Select($"OrderNumber='{ orderHistoryModel.WebOrderNumber}'");
                if (orderShipmentRows.Length > 0)
                {
                    foreach (DataRow orderShipmentRow in orderShipmentRows)
                    {
                        string shipmentNo = SanitizeInput(orderShipmentRow, "ShipmentNo");
                        string orderNo = SanitizeInput(orderShipmentRow, "OrderNumber");
                        Shipment orderShipmentModel = orderShipmentRepository.GetTable().FirstOrDefault(x => x.ShipmentNumber.Equals(shipmentNo) && x.WebOrderNumber.Equals(orderNo, StringComparison.InvariantCultureIgnoreCase));

                        if (orderShipmentModel == null)
                        {
                            orderShipmentModel = CreateShipment(orderShipmentRow);
                        }
                        else
                        {
                            orderShipmentModel = UpdateShipment(orderShipmentRow, orderShipmentModel);
                        }

                        ProcessShipmentPackage(orderShipmentModel);
                    }
                }
            }

            this.JobLogger.Info($"Process Order Shipment End For Order {orderHistoryModel.WebOrderNumber}");

        }
        private void ProcessShipmentPackage(Shipment orderShipmentModel)
        {
            this.JobLogger.Info($"Process Shipment Package Start For Shipment Number {orderShipmentModel.ShipmentNumber}");
            if (this.orderShipmentPackage.Columns.Count > 0)
            {
                DataRow[] orderShipmentPackageRows = this.orderShipmentPackage.Select($"ShipmentNo='{ orderShipmentModel.ShipmentNumber}'");
                if (orderShipmentPackageRows.Length > 0)
                {

                    foreach (DataRow orderShipmentPackageRow in orderShipmentPackageRows)
                    {
                        string trackingNumber = SanitizeInput(orderShipmentPackageRow, "TrackingNo");
                        string packageNumber = SanitizeInput(orderShipmentPackageRow, "TrackingNo");
                        ShipmentPackage orderShipmentPackageModel = orderShipmentPackageRepository.GetTable().FirstOrDefault(x => x.ShipmentId.Equals(orderShipmentModel.Id) && x.TrackingNumber.Equals(trackingNumber) && x.PackageNumber.Equals(packageNumber));
                        if (orderShipmentPackageModel == null)
                        {
                            orderShipmentPackageModel = CreateShipmentPackage(orderShipmentPackageRow, orderShipmentModel);
                        }
                        else
                        {
                            orderShipmentPackageModel = UpdateShipmentPackage(orderShipmentPackageRow, orderShipmentModel, orderShipmentPackageModel);
                        }

                        ProcessShipmentPackageLine(orderShipmentPackageModel);
                    }
                }
            }
            this.JobLogger.Info($"Process Shipment End For Shipment Number {orderShipmentModel.ShipmentNumber}");

        }
        private void ProcessShipmentPackageLine(ShipmentPackage orderShipmentPackageModel)
        {
            this.JobLogger.Info($"Process Shipment Package Line Start For Shipment Packege Number {orderShipmentPackageModel.PackageNumber}");
            if (this.orderShipmentPackageLine.Columns.Count > 0)
            {
                DataRow[] shipmentPackageLineRows = this.orderShipmentPackageLine.Select($"TrackingNo='{ orderShipmentPackageModel.TrackingNumber}'");
                if (shipmentPackageLineRows.Length > 0)
                {

                    foreach (DataRow shipmentPackageLineRow in shipmentPackageLineRows)
                    {
                        string itemId = SanitizeInput(shipmentPackageLineRow, "ItemId");

                        ShipmentPackageLine shipmentPackageLineModel = orderShipmentPackageLineRepository.GetTable().FirstOrDefault(x => x.ShipmentPackageId.Equals(orderShipmentPackageModel.Id) && x.ProductCode.Equals(itemId));
                        if (shipmentPackageLineModel == null)
                        {
                            CreateShipmentPackageLine(shipmentPackageLineRow, orderShipmentPackageModel);
                        }
                        else
                        {
                            UpdateShipmentPackageLine(shipmentPackageLineRow, orderShipmentPackageModel, shipmentPackageLineModel);
                        }

                    }
                }
            }
            this.JobLogger.Info($"Process Shipment Package Line End For Shipment Packege Number {orderShipmentPackageModel.PackageNumber}");
        }
        private void UpdateShipmentPackageLine(DataRow shipmentPackageLineRow, ShipmentPackage orderShipmentPackageModel, ShipmentPackageLine shipmentPackageLineModel)
        {
            this.JobLogger.Info($"Upadte Shipment Line Start for Item  {SanitizeInput(shipmentPackageLineRow, "ItemId")}");

            SetOrderShipmentPackageLineData(shipmentPackageLineRow, orderShipmentPackageModel, shipmentPackageLineModel);
            UnitOfWork.Save();
            this.JobLogger.Info($"Update Shipment Line Start for Item  {SanitizeInput(shipmentPackageLineRow, "ItemId")}");
        }

        private void CreateShipmentPackageLine(DataRow shipmentPackageLineRow, ShipmentPackage orderShipmentPackageModel)
        {
            this.JobLogger.Info($"Create Shipment Line Start for Item  {SanitizeInput(shipmentPackageLineRow, "ItemId")}");

            ShipmentPackageLine shipmentPackageLineModel = orderShipmentPackageLineRepository.Create();
            shipmentPackageLineModel = SetOrderShipmentPackageLineData(shipmentPackageLineRow, orderShipmentPackageModel, shipmentPackageLineModel);
            this.orderShipmentPackageLineRepository.Insert(shipmentPackageLineModel);
            UnitOfWork.Save();
            this.JobLogger.Info($"Create Shipment Line Start for Item  {SanitizeInput(shipmentPackageLineRow, "ItemId")}");
        }
        private ShipmentPackageLine SetOrderShipmentPackageLineData(DataRow shipmentPackageLineRow, ShipmentPackage orderShipmentPackageModel, ShipmentPackageLine shipmentPackageLineModel)
        {
            this.JobLogger.Info($"Set Shipment Package Line Data Start for Item {SanitizeInput(shipmentPackageLineRow, "ItemId")}");

            shipmentPackageLineModel.ShipmentPackageId = orderShipmentPackageModel.Id;
            shipmentPackageLineModel.ProductName = SanitizeInput(shipmentPackageLineRow, "ItemDesc");
            shipmentPackageLineModel.ProductDescription = SanitizeInput(shipmentPackageLineRow, "ItemDesc");
            shipmentPackageLineModel.ProductCode = SanitizeInput(shipmentPackageLineRow, "ItemId");
            shipmentPackageLineModel.QtyOrdered = Convert.ToDecimal(SanitizeInput(shipmentPackageLineRow, "Quantity"));
            shipmentPackageLineModel.QtyShipped = Convert.ToDecimal(SanitizeInput(shipmentPackageLineRow, "Quantity"));

            this.JobLogger.Info($"Set Shipment Package Line Data End for Item {SanitizeInput(shipmentPackageLineRow, "ItemId")}");
            return shipmentPackageLineModel;
        }
        private ShipmentPackage UpdateShipmentPackage(DataRow orderShipmentPackageRow, Shipment orderShipmentModel, ShipmentPackage orderShipmentPackageModel)
        {
            this.JobLogger.Info($"Update Shipment Start for Shipment  {SanitizeInput(orderShipmentPackageRow, "ShipmentNo")}");

            ShipmentPackage orderShipemntPackageResult = SetOrderShipmentPackageData(orderShipmentPackageRow, orderShipmentModel, orderShipmentPackageModel);
            UnitOfWork.Save();
            this.JobLogger.Info($"Update Shipment End for Shipment {SanitizeInput(orderShipmentPackageRow, "ShipmentNo")}");

            return orderShipemntPackageResult;
        }
        private ShipmentPackage CreateShipmentPackage(DataRow orderShipmentPackageRow, Shipment orderShipmentModel)
        {
            this.JobLogger.Info($"Create Shipment Start for Shipment  {SanitizeInput(orderShipmentPackageRow, "ShipmentNo")}");

            ShipmentPackage orderShipmentPackagetModel = orderShipmentPackageRepository.Create();
            ShipmentPackage orderShipemntPackageResult = SetOrderShipmentPackageData(orderShipmentPackageRow, orderShipmentModel, orderShipmentPackagetModel);
            this.orderShipmentPackageRepository.Insert(orderShipemntPackageResult);
            UnitOfWork.Save();
            this.JobLogger.Info($"Create Shipment End for Shipment {SanitizeInput(orderShipmentPackageRow, "ShipmentNo")}");

            return orderShipemntPackageResult;
        }
        private ShipmentPackage SetOrderShipmentPackageData(DataRow orderShipmentPackageRow, Shipment orderShipmentModel, ShipmentPackage orderShipmenPackagetModel)
        {
            this.JobLogger.Info($"Set Shipment Package Data Start for Package {orderShipmenPackagetModel.PackageNumber}");

            orderShipmenPackagetModel.ShipmentId = orderShipmentModel.Id;
            orderShipmenPackagetModel.TrackingNumber = SanitizeInput(orderShipmentPackageRow, "TrackingNo");
            orderShipmenPackagetModel.PackageNumber = SanitizeInput(orderShipmentPackageRow, "TrackingNo");
            orderShipmenPackagetModel.ShipVia = SanitizeInput(orderShipmentPackageRow, "CarrierServiceCode");
            orderShipmenPackagetModel.Carrier = SanitizeInput(orderShipmentPackageRow, "SCAC");
            orderShipmenPackagetModel = AddUpdateTrackinUrlProperty(orderShipmenPackagetModel, "trackingUrl", SanitizeInput(orderShipmentPackageRow, "TrackingUrl"));


            this.JobLogger.Info($"Set Shipment Package Data End for Package {orderShipmenPackagetModel.PackageNumber}");
            return orderShipmenPackagetModel;
        }
        private Shipment UpdateShipment(DataRow orderShipmentRow, Shipment orderShipmentModel)
        {
            this.JobLogger.Info($"Update Shipment Start for order  {SanitizeInput(orderShipmentRow, "OrderNumber")}");
            Shipment orderShipemntResult = SetOrderShipmentData(orderShipmentRow, orderShipmentModel);
            UnitOfWork.Save();
            this.JobLogger.Info($"Update Shipment End for order {SanitizeInput(orderShipmentRow, "OrderNumber")}");
            return orderShipemntResult;
        }

        private Shipment CreateShipment(DataRow orderShipmentRow)
        {
            this.JobLogger.Info($"Create Shipment Start for order  {SanitizeInput(orderShipmentRow, "OrderNumber")}");
            Shipment orderShipmentModel = orderShipmentRepository.Create();
            Shipment orderShipemntResult = SetOrderShipmentData(orderShipmentRow, orderShipmentModel);
            this.orderShipmentRepository.Insert(orderShipemntResult);
            UnitOfWork.Save();
            this.JobLogger.Info($"Create Shipment End for order {SanitizeInput(orderShipmentRow, "OrderNumber")}");
            return orderShipemntResult;
        }
        private Shipment SetOrderShipmentData(DataRow orderShipmentRow, Shipment orderShipmentModel)
        {
            this.JobLogger.Info($"Create Shipment Start for Shipment {SanitizeInput(orderShipmentRow, "ShipmentNo")}");

            orderShipmentModel.ShipmentNumber = SanitizeInput(orderShipmentRow, "ShipmentNo");
            orderShipmentModel.WebOrderNumber = SanitizeInput(orderShipmentRow, "OrderNumber");
            orderShipmentModel.ErpOrderNumber = SanitizeInput(orderShipmentRow, "OrderNumber");
            orderShipmentModel.ShipmentDate = DateTimeOffset.Parse(SanitizeInput(orderShipmentRow, "ActualShipmentDate"));

            this.JobLogger.Info($"Create Shipment End for Shipment {SanitizeInput(orderShipmentRow, "ShipmentNo")}");
            return orderShipmentModel;
        }
        private string SanitizeInput(DataRow dataRow, string fieldName)
        {
            return (dataRow[fieldName] != null) ? dataRow[fieldName].ToString() : "";
        }
        private void ProcessOrderHistoryLines(OrderHistory orderHistoryModel)
        {
            this.JobLogger.Info($"Process Order History Line Start For Order {orderHistoryModel.WebOrderNumber}");
            DataRow[] orderHistoryLineRows = this.orderHistoryLine.Select($"OrderNo='{ orderHistoryModel.WebOrderNumber}'");
            if (orderHistoryLineRows.Length > 0)
            {
                foreach (DataRow historyLine in orderHistoryLineRows)
                {
                    string itemId = SanitizeInput(historyLine, "ItemID");
                    OrderHistoryLine orderHistoryLineModel = orderHistoryLineRepository.GetTable().FirstOrDefault(x => x.OrderHistoryId.Equals(orderHistoryModel.Id) && x.ProductErpNumber.Equals(itemId, StringComparison.InvariantCultureIgnoreCase));
                    if (orderHistoryLineModel == null)
                    {
                        CreateOrderHistoryLine(historyLine, orderHistoryModel);
                    }
                    else
                    {
                        UpdateOrderHistoryLine(historyLine, orderHistoryModel, orderHistoryLineModel);
                    }
                }

            }
            this.JobLogger.Info($"Process Order History Line End For Order {orderHistoryModel.WebOrderNumber}");
        }

        private void CreateOrderHistoryLine(DataRow historyLine, OrderHistory orderHistoryModel)
        {
            this.JobLogger.Info($"Create Order History Line Start For Item {SanitizeInput(historyLine, "ItemID")}");
            OrderHistoryLine orderHistoryLineModel = orderHistoryLineRepository.Create();
            OrderHistoryLine orderHistoryLineResult = SetOrderHistoryLineData(historyLine, orderHistoryModel, orderHistoryLineModel);
            this.orderHistoryLineRepository.Insert(orderHistoryLineResult);
            UnitOfWork.Save();
            this.JobLogger.Info($"Create Order History Line End For Item {SanitizeInput(historyLine, "ItemID")}");
        }
        private void UpdateOrderHistoryLine(DataRow historyLine, OrderHistory orderHistoryModel, OrderHistoryLine orderHistoryLineModel)
        {
            this.JobLogger.Info($"Update Order History Line Start For Item {SanitizeInput(historyLine, "ItemID")}");
            OrderHistoryLine orderHistoryLineResult = SetOrderHistoryLineData(historyLine, orderHistoryModel, orderHistoryLineModel);
            UnitOfWork.Save();
            this.JobLogger.Info($"Update Order History Line End For Item {SanitizeInput(historyLine, "ItemID")}");
        }

        private OrderHistoryLine SetOrderHistoryLineData(DataRow historyLine, OrderHistory orderHistoryModel, OrderHistoryLine orderHistoryLineModel)
        {
            this.JobLogger.Info($"Set Order History Line Data Start For Item {SanitizeInput(historyLine, "ItemID")}");
            orderHistoryLineModel.OrderHistoryId = orderHistoryModel.Id;
            orderHistoryLineModel.CustomerNumber = orderHistoryModel.CustomerNumber;
            orderHistoryLineModel.LineNumber = Convert.ToDecimal(historyLine["PrimeLineNo"]);
            orderHistoryLineModel.QtyShipped = Convert.ToDecimal(historyLine["OrderedQty"]);
            orderHistoryLineModel.QtyOrdered = Convert.ToDecimal(historyLine["OriginalOrderedQty"]);
            orderHistoryLineModel.Status = SanitizeInput(historyLine, "Status");
            orderHistoryLineModel.ProductErpNumber = SanitizeInput(historyLine, "ItemID");
            orderHistoryLineModel.Description = SanitizeInput(historyLine, "ItemDesc");
            orderHistoryLineModel.UnitNetPrice = Convert.ToDecimal(historyLine["UnitPrice"]);
            orderHistoryLineModel.UnitOfMeasure = SanitizeInput(historyLine, "UnitOfMeasure");
            //orderHistoryLineModel.TotalNetPrice = Convert.ToDecimal(historyLine["UnitPrice"]) * Convert.ToDecimal(historyLine["OriginalOrderedQty"]);
            orderHistoryLineModel = AddUpdateOrderHistoryLineProperty(orderHistoryLineModel, SanitizeInput(historyLine, "Tax"));
            this.JobLogger.Info($"Set Order History Line Data End For Item {SanitizeInput(historyLine, "ItemID")}");
            return orderHistoryLineModel;

        }
        private OrderHistory CreateOrderHistory(DataRow orderHistoryDataRow)
        {
            this.JobLogger.Info($"Create Order History Start For Order {SanitizeInput(orderHistoryDataRow, "OrderNo")}");
            OrderHistory orderHistoryModel = orderHistoryRepository.Create();
            OrderHistory orderHistoryResult = SetOrderHistoryData(orderHistoryModel, orderHistoryDataRow);
            this.orderHistoryRepository.Insert(orderHistoryResult);
            UnitOfWork.Save();
            this.JobLogger.Info($"Create Order History For Order {SanitizeInput(orderHistoryDataRow, "OrderNo")} ");
            return orderHistoryResult;

        }

        private OrderHistory UpdateOrderHistory(OrderHistory orderHistoryModel, DataRow orderHistoryDataRow)
        {
            this.JobLogger.Info($"Update Order History Start For Order {SanitizeInput(orderHistoryDataRow, "OrderNo")}");
            OrderHistory orderHistoryResult = SetOrderHistoryData(orderHistoryModel, orderHistoryDataRow);
            UnitOfWork.Save();
            this.JobLogger.Info($"Update Order History End For Order {SanitizeInput(orderHistoryDataRow, "OrderNo")} ");
            return orderHistoryResult;

        }

        private OrderHistory SetOrderHistoryData(OrderHistory orderHistoryModel, DataRow orderHistoryDataRow)
        {
            this.JobLogger.Info($"Set Order History Data Start For Order {SanitizeInput(orderHistoryDataRow, "OrderNo")}");
            var orderDate = DateTimeOffset.Parse(SanitizeInput(orderHistoryDataRow, "OrderDate"));            
            orderHistoryModel.OrderDate = orderDate.DateTime;
            orderHistoryModel.WebOrderNumber = SanitizeInput(orderHistoryDataRow, "OrderNo");
            orderHistoryModel.ErpOrderNumber = SanitizeInput(orderHistoryDataRow, "OrderNo");
            orderHistoryModel.Status = SanitizeInput(orderHistoryDataRow, "Status");
            orderHistoryModel.CustomerNumber = SanitizeInput(orderHistoryDataRow, "BillToID");
            orderHistoryModel.OrderTotal = Convert.ToDecimal(SanitizeInput(orderHistoryDataRow, "GrandTotal"));
            orderHistoryModel.ProductTotal = Convert.ToDecimal(SanitizeInput(orderHistoryDataRow, "LineSubTotal"));

            orderHistoryModel.TaxAmount = Convert.ToDecimal(SanitizeInput(orderHistoryDataRow, "GrandTax"));

            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "btFirstName", SanitizeInput(orderHistoryDataRow, "BTFirstName"));
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "btLastName", SanitizeInput(orderHistoryDataRow, "BTLastName"));
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "btEmail", SanitizeInput(orderHistoryDataRow, "BTEMailID"));
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "btPhone", SanitizeInput(orderHistoryDataRow, "BTDayPhone"));
            orderHistoryModel.BTAddress1 = SanitizeInput(orderHistoryDataRow, "BTAddressLine1");
            orderHistoryModel.BTAddress2 = SanitizeInput(orderHistoryDataRow, "BTAddressLine2");
            orderHistoryModel.BTCountry = SanitizeInput(orderHistoryDataRow, "BTCountry");
            orderHistoryModel.BTCity = SanitizeInput(orderHistoryDataRow, "BTCity");
            orderHistoryModel.BTCompanyName = SanitizeInput(orderHistoryDataRow, "BTCompany");
            orderHistoryModel.BTPostalCode = SanitizeInput(orderHistoryDataRow, "BTZipCode");
            orderHistoryModel.BTState = SanitizeInput(orderHistoryDataRow, "BTState");

            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "stFirstName", SanitizeInput(orderHistoryDataRow, "STFirstName"));
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "stLastName", SanitizeInput(orderHistoryDataRow, "STLastName"));
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "stEmail", SanitizeInput(orderHistoryDataRow, "STEMailID"));
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "stPhone", SanitizeInput(orderHistoryDataRow, "STDayPhone"));
            orderHistoryModel.STAddress1 = SanitizeInput(orderHistoryDataRow, "STAddressLine1");
            orderHistoryModel.STAddress2 = SanitizeInput(orderHistoryDataRow, "STAddressLine2");
            orderHistoryModel.STCountry = SanitizeInput(orderHistoryDataRow, "STCountry");
            orderHistoryModel.STCompanyName = SanitizeInput(orderHistoryDataRow, "STCompany");
            orderHistoryModel.STCity = SanitizeInput(orderHistoryDataRow, "STCity");
            orderHistoryModel.STPostalCode = SanitizeInput(orderHistoryDataRow, "STZipCode");
            orderHistoryModel.STState = SanitizeInput(orderHistoryDataRow, "STState");
            orderHistoryModel = AddUpdateOrderHistoryProperty(orderHistoryModel, "isTaxTBD", "false");



            this.JobLogger.Info($"Set Order History Data End For Order {SanitizeInput(orderHistoryDataRow, "OrderNo")}");
            return orderHistoryModel;
        }

        private OrderHistoryLine AddUpdateOrderHistoryLineProperty(OrderHistoryLine orderHistoryLine, string lineTax)
        {
            CustomProperty customProperty = orderHistoryLine.CustomProperties.FirstOrDefault(c => c.Name.Equals("taxAmount", StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null)
            {
                customProperty.Value = lineTax;
            }
            else
            {
                orderHistoryLine.SetProperty("taxAmount", lineTax);
            }
            return orderHistoryLine;
        }

        private OrderHistory AddUpdateOrderHistoryProperty(OrderHistory orderHistory, string propertyName, string propertyValue)
        {
            CustomProperty customProperty = orderHistory.CustomProperties.FirstOrDefault(c => c.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null)
            {
                customProperty.Value = propertyValue;
            }
            else
            {
                orderHistory.SetProperty(propertyName, propertyValue);
            }
            return orderHistory;
        }
        private ShipmentPackage AddUpdateTrackinUrlProperty(ShipmentPackage orderShipmenPackagetModel, string propertyName, string propertyValue)
        {
            CustomProperty customProperty = orderShipmenPackagetModel.CustomProperties.FirstOrDefault(c => c.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null)
            {
                customProperty.Value = propertyValue;
            }
            else
            {
                orderShipmenPackagetModel.SetProperty(propertyName, propertyValue);
            }
            return orderShipmenPackagetModel;
        }
        
        public void Cancel()
        {


        }
    }
}
