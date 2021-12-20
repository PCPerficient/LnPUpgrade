using Insite.Common.Extensions;
using Insite.Common.Helpers;
using Insite.Integration.Enums;
using Insite.WIS.Broker;
using Insite.WIS.Broker.Interfaces;
using Insite.WIS.Broker.Plugins;
using Insite.WIS.Broker.WebIntegrationService;
using LeggettAndPlatt.IntegrationProcessor.Models;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace LeggettAndPlatt.IntegrationProcessor.Plugins
{
    public class IntegrationProcessorOrderHistoryXml : IIntegrationProcessor
    {
        IntegrationJobLogger JobLogger;
        IntegrationJob IntegrationJob;
        private readonly FileFinder fileFinder;

        public IntegrationProcessorOrderHistoryXml(FileFinder fileFinder)
        {
            this.fileFinder = fileFinder;
        }

        public DataSet Execute(SiteConnection siteConnection, IntegrationJob integrationJob, JobDefinitionStep jobStep)
        {
           // System.Diagnostics.Debugger.Launch();
            IntegrationConnection integrationConnection = integrationJob.JobDefinition.IntegrationConnection;
            this.JobLogger = new IntegrationJobLogger(siteConnection, integrationJob);
            this.IntegrationJob = integrationJob;

            this.JobLogger.Info("OrderHistoryXml Integration Processor Start");
            DataSet resultDataSet = new DataSet();


            List<string> files = this.GetFiles(integrationJob, jobStep, integrationConnection);
            this.LogFilesFoundMessage(jobStep, files.Count);
           
            resultDataSet = ProcessFiles(files, resultDataSet, integrationJob);

            return resultDataSet;

        }

        private DataSet ProcessFiles(List<string> files, DataSet resultDataSet, IntegrationJob integrationJob)
        {
            
            List<OrderHistoryModel> orderHistoryModelList = new List<OrderHistoryModel>();
            List<List<OrderHistoryLineModel>> orderHistoryLineModelAllList = new List<List<OrderHistoryLineModel>>();
            List<ShipmentModel> shipmentModelList = new List<ShipmentModel>();
            List<ShipmentPackageModel> shipmentPackageModelList = new List<ShipmentPackageModel>();
            List<ShipmentPackageLineModel> shipmentPackageLineModelList = new List<ShipmentPackageLineModel>();

            foreach (var file in files.Distinct<string>())
            {
                string str1 = file;
                try
                {
                    this.JobLogger.Info("XML Parsing start for file " + file);
                    OrderHistoryStatusXmlOrderModel model = DeserializeXMLFileToObject<OrderHistoryStatusXmlOrderModel>(file);
                    if (model != null)
                    {
                        OrderHistoryModel orderHistoryModel = FillOrderHistoryModel(model);
                        orderHistoryModelList.Add(orderHistoryModel);

                        List<OrderHistoryLineModel> orderHistoryLineModelList = FillOrderHistoryLine(model);
                        orderHistoryLineModelAllList.Add(orderHistoryLineModelList);

                        List<ShipmentModel> shipmentModelList1 = FillShipmentModel(model);
                        shipmentModelList.AddRange(shipmentModelList1);

                        List<ShipmentPackageModel> shipmentPackageModelList1 = FillShipmentPackageModel(model);
                        shipmentPackageModelList.AddRange(shipmentPackageModelList1);

                        List<ShipmentPackageLineModel> shipmentPackageLineModelList1 = FillShipmentPackageLineModel(model);
                        shipmentPackageLineModelList.AddRange(shipmentPackageLineModelList1);
                    }
                    this.JobLogger.Info("XML Parsing end for file " + file);

                    if (!str1.EndsWith(integrationJob.JobNumber.ToString() + ".processed"))
                    {
                        string destFileName = str1 + "." + (object)integrationJob.JobNumber + ".processed";
                        File.Move(str1, destFileName);
                    }
                }
                catch (Exception ex)
                {
                    this.JobLogger.Error(string.Format("Exception Reading File {0} Moving to Bad Folder.  Message: {1}", (object)str1, (object)ex.Message), true);
                    string directoryName = Path.GetDirectoryName(str1);
                    if (directoryName != null)
                    {
                        string str3 = Path.Combine(directoryName, "BadFiles");
                        if (!Directory.Exists(str3))
                            Directory.CreateDirectory(str3);
                        File.Move(str1, Path.Combine(str3, Path.GetFileName(str1)));
                        continue;
                    }
                    continue;
                }

            }

            resultDataSet = FilDataSet(resultDataSet, orderHistoryModelList, orderHistoryLineModelAllList, shipmentModelList, shipmentPackageModelList, shipmentPackageLineModelList);

            return resultDataSet;
        }
        private string GetParameterValue(IEnumerable<IntegrationJobParameter> integrationJobParameters, string parameterName, string notFoundMessage, IntegrationJobLogType logType = IntegrationJobLogType.Fatal)
        {
            this.JobLogger.Info("Get Parameter Value for " + parameterName + " Parameters count " + integrationJobParameters.Count());

            IntegrationJobParameter integrationJobParameter = integrationJobParameters.FirstOrDefault<IntegrationJobParameter>((Func<IntegrationJobParameter, bool>)(p => p.JobDefinitionParameter.Name.EqualsIgnoreCase(parameterName)));
            if (integrationJobParameter != null)
                return integrationJobParameter.Value;
            this.JobLogger.AddLogMessage(notFoundMessage, true, logType);
            return (string)null;
        }
        private DataSet FilDataSet(DataSet ds, List<OrderHistoryModel> orderHistoryModelList, List<List<OrderHistoryLineModel>> orderHistoryLineModelAllList, List<ShipmentModel> shipmentModelList, List<ShipmentPackageModel> shipmentPackageModelList, List<ShipmentPackageLineModel> shipmentPackageLineModelList)
        {
            this.JobLogger.Info("DataSet Creation start");
            if (orderHistoryModelList.Count > 0)
            {
                ds.Tables.Add(ObjectHelper.GetDataTableFromList((IList)orderHistoryModelList.ToList<OrderHistoryModel>(), typeof(OrderHistoryModel)));
            }

            if (orderHistoryLineModelAllList.Count > 0)
            {
                foreach (var item in orderHistoryLineModelAllList)
                {
                    if (ds.Tables["OrderHistoryLineModel"] == null)
                    {
                        ds.Tables.Add(ObjectHelper.GetDataTableFromList((IList)item.ToList<OrderHistoryLineModel>(), typeof(OrderHistoryLineModel)));
                    }
                    else
                    {
                        DataTable dt = ObjectHelper.GetDataTableFromList((IList)item.ToList<OrderHistoryLineModel>(), typeof(OrderHistoryLineModel));
                        foreach (DataRow row in dt.Rows)
                        {
                            DataRow newRow = ds.Tables["OrderHistoryLineModel"].NewRow();
                            newRow = row;
                            ds.Tables["OrderHistoryLineModel"].ImportRow(newRow);
                        }
                    }

                }

            }

            if (shipmentModelList.Count > 0)
            {
                ds.Tables.Add(ObjectHelper.GetDataTableFromList((IList)shipmentModelList.ToList<ShipmentModel>(), typeof(ShipmentModel)));
            }

            if (shipmentPackageModelList.Count > 0)
            {
                ds.Tables.Add(ObjectHelper.GetDataTableFromList((IList)shipmentPackageModelList.ToList<ShipmentPackageModel>(), typeof(ShipmentPackageModel)));
            }

            if (shipmentPackageLineModelList.Count > 0)
            {
                ds.Tables.Add(ObjectHelper.GetDataTableFromList((IList)shipmentPackageLineModelList.ToList<ShipmentPackageLineModel>(), typeof(ShipmentPackageLineModel)));
            }

            this.JobLogger.Info("DataSet Creation end");
            return ds;
        }
        private T DeserializeXMLFileToObject<T>(string xmlFilename)
        {
            this.JobLogger.Info("Xml Deserialization start for xml file " + xmlFilename);
            T returnObject = default(T);
            if (string.IsNullOrEmpty(xmlFilename)) return default(T);

            using (var fs = new FileStream(xmlFilename, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            using (var sr = new StreamReader(fs, Encoding.Default))
            {
                XmlSerializer serializer = new XmlSerializer(typeof(T));
                returnObject = (T)serializer.Deserialize(sr);
            }
            this.JobLogger.Info("Xml Deserialization end for xml file " + xmlFilename);
            return returnObject;
        }

        private OrderHistoryModel FillOrderHistoryModel(OrderHistoryStatusXmlOrderModel model)
        {
            OrderHistoryModel orderHistoryModel = new OrderHistoryModel();
            orderHistoryModel.EnterpriseCode = model.EnterpriseCode;
            orderHistoryModel.OrderNo = model.OrderNo;
            orderHistoryModel.OrderDate = model.OrderDate;
            orderHistoryModel.Status = model.Status;
            orderHistoryModel.CustomerContactID = model.CustomerContactID;
            orderHistoryModel.BillToID = model.BillToID;
            orderHistoryModel.OriginalTotalAmount = model.OriginalTotalAmount;

            FillBTAddress(model, orderHistoryModel);

            FillSTAddress(model, orderHistoryModel);

            FillOrderTotal(model, orderHistoryModel);

            return orderHistoryModel;
        }

        private void FillBTAddress(OrderHistoryStatusXmlOrderModel model, OrderHistoryModel orderHistoryModel)
        {
            if (model.PersonInfoBillTo != null)
            {
                orderHistoryModel.BTAddressLine1 = model.PersonInfoBillTo.AddressLine1;
                orderHistoryModel.BTAddressLine2 = model.PersonInfoBillTo.AddressLine2;
                orderHistoryModel.BTCity = model.PersonInfoBillTo.City;
                orderHistoryModel.BTCompany = model.PersonInfoBillTo.Company;
                orderHistoryModel.BTCountry = model.PersonInfoBillTo.Country;
                orderHistoryModel.BTDayPhone = model.PersonInfoBillTo.DayPhone;
                orderHistoryModel.BTEMailID = model.PersonInfoBillTo.EMailID;
                orderHistoryModel.BTFirstName = model.PersonInfoBillTo.FirstName;
                orderHistoryModel.BTLastName = model.PersonInfoBillTo.LastName;
                orderHistoryModel.BTState = model.PersonInfoBillTo.State;
                orderHistoryModel.BTZipCode = model.PersonInfoBillTo.ZipCode;
            }
        }

        private void FillSTAddress(OrderHistoryStatusXmlOrderModel model, OrderHistoryModel orderHistoryModel)
        {
            if (model.PersonInfoShipTo != null)
            {
                orderHistoryModel.STAddressLine1 = model.PersonInfoShipTo.AddressLine1;
                orderHistoryModel.STAddressLine2 = model.PersonInfoShipTo.AddressLine2;
                orderHistoryModel.STCity = model.PersonInfoShipTo.City;
                orderHistoryModel.STCompany = model.PersonInfoShipTo.Company;
                orderHistoryModel.STCountry = model.PersonInfoShipTo.Country;
                orderHistoryModel.STDayPhone = model.PersonInfoShipTo.DayPhone;
                orderHistoryModel.STEMailID = model.PersonInfoShipTo.EMailID;
                orderHistoryModel.STFirstName = model.PersonInfoShipTo.FirstName;
                orderHistoryModel.STLastName = model.PersonInfoShipTo.LastName;
                orderHistoryModel.STState = model.PersonInfoShipTo.State;
                orderHistoryModel.STZipCode = model.PersonInfoShipTo.ZipCode;
            }
        }

        private void FillOrderTotal(OrderHistoryStatusXmlOrderModel model, OrderHistoryModel orderHistoryModel)
        {
            if (model.OverallTotals != null)
            {
                orderHistoryModel.GrandShippingCharges = model.OverallTotals.GrandShippingCharges;
                orderHistoryModel.GrandTax = model.OverallTotals.GrandTax;
                orderHistoryModel.GrandTotal = model.OverallTotals.GrandTotal;
                orderHistoryModel.LineSubTotal = model.OverallTotals.LineSubTotal;
            }
        }

        private List<OrderHistoryLineModel> FillOrderHistoryLine(OrderHistoryStatusXmlOrderModel model)
        {
            List<OrderHistoryLineModel> orderHistoryLineModelList = new List<OrderHistoryLineModel>();
            OrderHistoryLineModel orderHistoryLineModel;
            if (model.OrderLines != null && model.OrderLines.OrderLine.Count > 0)
            {
                foreach (var orderLine in model.OrderLines.OrderLine)
                {
                    orderHistoryLineModel = new OrderHistoryLineModel();
                    orderHistoryLineModel.ExtendedPrice = orderLine.LineOverallTotals.ExtendedPrice;
                    orderHistoryLineModel.LineTotal = orderLine.LineOverallTotals.LineTotal;
                    orderHistoryLineModel.UnitPrice = orderLine.LineOverallTotals.UnitPrice;
                    orderHistoryLineModel.Tax = orderLine.LineOverallTotals.Tax;
                    orderHistoryLineModel.ItemDesc = orderLine.Item.ItemShortDesc;
                    orderHistoryLineModel.ItemID = orderLine.Item.ItemID;
                    orderHistoryLineModel.UnitOfMeasure = orderLine.Item.UnitOfMeasure;
                    orderHistoryLineModel.UnitCost = orderLine.Item.UnitCost;
                    orderHistoryLineModel.OrderedQty = orderLine.OrderedQty;
                    orderHistoryLineModel.OriginalOrderedQty = orderLine.OriginalOrderedQty;
                    orderHistoryLineModel.PrimeLineNo = orderLine.PrimeLineNo;
                    orderHistoryLineModel.Status = orderLine.Status;
                    orderHistoryLineModel.SubLineNo = orderLine.SubLineNo;
                    orderHistoryLineModel.OrderNo = model.OrderNo;

                    orderHistoryLineModelList.Add(orderHistoryLineModel);
                }
            }
            return orderHistoryLineModelList;
        }

        private List<ShipmentModel> FillShipmentModel(OrderHistoryStatusXmlOrderModel model)
        {
            List<ShipmentModel> shipmentModelList = new List<ShipmentModel>();
            if (model.OrderLines != null && model.OrderLines.OrderLine.Count > 0)
            {
                foreach (var orderLine in model.OrderLines.OrderLine)
                {
                    if (orderLine.Containers != null && orderLine.Containers.Container != null && orderLine.Containers.Container.Count > 0)
                    {
                        foreach (var container in orderLine.Containers.Container)
                        {
                            ShipmentModel shipmentModel = new ShipmentModel();
                            shipmentModel.ShipmentNo = container.Shipment.ShipmentNo;
                            shipmentModel.ActualShipmentDate = container.Shipment.ActualShipmentDate;
                            shipmentModel.OrderNumber = model.OrderNo;
                            shipmentModelList.Add(shipmentModel);
                        }

                    }
                }
            }

            return shipmentModelList;
        }

        private List<ShipmentPackageModel> FillShipmentPackageModel(OrderHistoryStatusXmlOrderModel model)
        {
            
            List<ShipmentPackageModel> shipmentPackageModelList = new List<ShipmentPackageModel>();
            if (model.OrderLines != null && model.OrderLines.OrderLine.Count > 0)
            {
                foreach (var orderLine in model.OrderLines.OrderLine)
                {
                    if (orderLine.Containers != null && orderLine.Containers.Container != null && orderLine.Containers.Container.Count > 0)
                    {
                        foreach (var container in orderLine.Containers.Container)
                        {
                            ShipmentPackageModel shipmentPackageModel = new ShipmentPackageModel();
                            shipmentPackageModel.CarrierServiceCode = container.CarrierServiceCode;
                            shipmentPackageModel.SCAC = container.SCAC;
                            shipmentPackageModel.TrackingNo = container.TrackingNo;
                            shipmentPackageModel.ShipmentNo = container.Shipment.ShipmentNo;
                            shipmentPackageModel.TrackingUrl = container.ExtnTracking.ExtnTrackingURL;
                            shipmentPackageModelList.Add(shipmentPackageModel);
                        }

                    }
                }
            }

            return shipmentPackageModelList;
        }

        private List<ShipmentPackageLineModel> FillShipmentPackageLineModel(OrderHistoryStatusXmlOrderModel model)
        {
            List<ShipmentPackageLineModel> shipmentPackageLineModelList = new List<ShipmentPackageLineModel>();
            if (model.OrderLines != null && model.OrderLines.OrderLine.Count > 0)
            {
                foreach (var orderLine in model.OrderLines.OrderLine)
                {
                    if (orderLine.Containers != null && orderLine.Containers.Container != null && orderLine.Containers.Container.Count > 0)
                    {
                        foreach (var container in orderLine.Containers.Container)
                        {
                            if (container.ContainerDetails != null && container.ContainerDetails.ContainerDetail != null)
                            {
                                ShipmentPackageLineModel shipmentPackageLineModel = new ShipmentPackageLineModel();
                                shipmentPackageLineModel.ItemDesc = container.ContainerDetails.ContainerDetail.ShipmentLine.ItemDesc;
                                shipmentPackageLineModel.TrackingNo = container.TrackingNo;
                                shipmentPackageLineModel.PrimeLineNo = container.ContainerDetails.ContainerDetail.ShipmentLine.PrimeLineNo;
                                shipmentPackageLineModel.OrderNumber = container.ContainerDetails.ContainerDetail.ShipmentLine.OrderNo;
                                shipmentPackageLineModel.ShipmentLineNo = container.ContainerDetails.ContainerDetail.ShipmentLine.ShipmentLineNo;
                                shipmentPackageLineModel.Quantity = container.ContainerDetails.ContainerDetail.ShipmentLine.Quantity;
                                shipmentPackageLineModel.ItemID = orderLine.Item.ItemID;
                                shipmentPackageLineModelList.Add(shipmentPackageLineModel);
                            }

                        }

                    }
                }
            }

            return shipmentPackageLineModelList;
        }

        protected virtual List<string> GetFiles(IntegrationJob integrationJob, JobDefinitionStep jobStep, IntegrationConnection integrationConnection)
        {
            List<string> list1 = ((IEnumerable<string>)jobStep.FromClause.Split(',')).Select<string, string>((Func<string, string>)(o => o.Trim())).ToList<string>();
            List<string> list2 = this.fileFinder.GetFiles(integrationConnection.Url, (IList<string>)list1).ToList<string>();
            List<string> list3 = list1.Select<string, string>((Func<string, string>)(o => o + "." + (object)integrationJob.JobNumber + ".processed")).ToList<string>();
            list2.AddRange((IEnumerable<string>)this.fileFinder.GetFiles(integrationConnection.Url, (IList<string>)list3));
            return list2;
        }

        protected virtual void LogFilesFoundMessage(JobDefinitionStep jobStep, int fileCount)
        {
            string message = fileCount == 0 ? string.Format("No files found matching '{0}'", (object)jobStep.FromClause) : string.Format("Found {0} files matching '{1}'", (object)fileCount, (object)jobStep.FromClause);
            if (fileCount == 0)
            {
                switch (jobStep.FlatFileErrorHandling.EnumParse<LookupErrorHandlingType>())
                {
                    case LookupErrorHandlingType.Warning:
                        this.JobLogger.Warn(message, true);
                        break;
                    case LookupErrorHandlingType.Error:
                        this.JobLogger.Error(message, true);
                        break;
                    case LookupErrorHandlingType.Ignore:
                        this.JobLogger.Info(message, true);
                        break;
                    default:
                        this.JobLogger.Warn(message, true);
                        break;
                }
            }
            else
                this.JobLogger.Info(message, true);
        }

        protected virtual string RenameFile(IntegrationJob integrationJob, string flatFileName)
        {
            string destFileName;
            if (flatFileName.EndsWith(integrationJob.JobNumber.ToString() + ".processed"))
            {
                destFileName = flatFileName;
            }
            else
            {
                destFileName = flatFileName + "." + (object)integrationJob.JobNumber + ".processing";
                File.Move(flatFileName, destFileName);
            }
            return destFileName;
        }

        //protected virtual List<string> GetFiles(JobDefinitionStep jobStep)
        //{
        //    IntegrationJobParameter[] integrationJobParameters = this.IntegrationJob.IntegrationJobParameters.Where(x => x.JobDefinitionParameter != null).ToArray();

        //    string path = this.GetParameterValue((IEnumerable<IntegrationJobParameter>)integrationJobParameters, "LocalFilePath", "Unable to find job definition parameter 'LocalFilePath'. This is an required parameter used to read order status xml files.", IntegrationJobLogType.Fatal);
        //    List<string> list1 = ((IEnumerable<string>)jobStep.FromClause.Split(',')).Select<string, string>((Func<string, string>)(o => o.Trim())).ToList<string>();

        //    List<string> list2 = new List<string>();
        //    list2.AddRange((IEnumerable<string>)this.fileFinder.GetFiles(path, (IList<string>)list1));
        //    if (list2.Count == 0)
        //    {
        //        this.JobLogger.Info("There is no file found at location " + path);
        //    }
        //    return list2;
        //}
    }
}
