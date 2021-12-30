using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.Tax;
using System;
using System.Collections.Generic;
using System.Linq;
using Insite.Core.Interfaces.Data;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Data.Entities;
using LeggettAndPlatt.Extensions.CustomSettings;
using LeggettAndPlatt.Vertex.Services.Interfaces;
using LeggettAndPlatt.Vertex.RequestModels;
using System.Linq.Expressions;
using LeggettAndPlatt.Vertex.ResponseModels;
using Insite.Common.Logging;
using Newtonsoft.Json;
using LeggettAndPlatt.Extensions.Common;
using System.Dynamic;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.TaxCalculator.Vertex.Clients;
using Insite.TaxCalculator.Vertex.Factories;
using Insite.TaxCalculator.Vertex.SystemSettings;

namespace LeggettAndPlatt.Extensions.Plugins.Tax
{
    [DependencyName("Vertex")]
    [Serializable]
    public class TaxCalculatorVertex : ITaxCalculator, IDependency, IExtension
    {
        protected readonly VertexSettings VertexSettings;
        private readonly IVertexTaxClientFactory vertexTaxClientFactory;
        private readonly VertexTaxSettings vertexTaxSettings;
        protected readonly IUnitOfWork UnitOfWork;
        protected readonly IOrderLineUtilities OrderLineUtilities;
        protected readonly EmailHelper EmailHelper;
        protected readonly CommonSettings CommonSettings;
        protected readonly IEmailService EmailService;
        protected readonly CustomPropertyHelper CustomPropertyHelper;
        public TaxCalculatorVertex(IVertexTaxClientFactory vertexTaxClientFactory,
      VertexTaxSettings vertexTaxSettings,IUnitOfWorkFactory unitOfWorkFactory, IOrderLineUtilities orderLineUtilities, VertexSettings vertexSettings,  EmailHelper emailHelper, CommonSettings commonSettings, IEmailService emailService, CustomPropertyHelper customPropertyHelper)
        {
            this.vertexTaxClientFactory = vertexTaxClientFactory;
            this.vertexTaxSettings = vertexTaxSettings;
            this.VertexSettings = vertexSettings;
            this.UnitOfWork = unitOfWorkFactory.GetUnitOfWork();
            this.OrderLineUtilities = orderLineUtilities;
            this.EmailHelper = emailHelper;
            this.CommonSettings = commonSettings;
            this.EmailService = emailService;
            this.CustomPropertyHelper = customPropertyHelper;
        }

        public void CalculateTax(OriginAddress originAddress, CustomerOrder customerOrder)
        {
            try
            {
                if (customerOrder.Website == null)
                    return;

                customerOrder.StateTax = 0M;
                //PRFT Custom Code - START
                ReSetOrderLineTax(customerOrder);
                UpdateCustomerOrderPropertyIfExist(customerOrder, CustomPropertyConstants.customPropertyNameIsTaxTBD, "false");
                //PRFT Custom Code - END

                customerOrder.TaxCalculated = false;
                IVertexTaxClient vertexTaxClient = this.vertexTaxClientFactory.GetVertexTaxClient(this.vertexTaxSettings.ClientVersion.ToString());
                customerOrder.StateTax = vertexTaxClient.CalculateTax(originAddress, customerOrder);
                customerOrder.TaxCalculated = true;
            }
            catch (Exception ex)
            {
                SetCustomerOrderProperty(customerOrder, CustomPropertyConstants.customPropertyNameIsTaxTBD, "true");
                 LogHelper.For((object)this).Error((object)ex.Message, ex, (string)null, (object)null);
                    this.SendExceptionEmail("Vertex Tax Error: " + ex.ToString());
            }
            
        }

        public void PostTax(OriginAddress originAddress, CustomerOrder customerOrder)
        {
            string isTaxTBD = this.CustomPropertyHelper.GetCustomerOrderCustomProperty(CustomPropertyConstants.customPropertyNameIsTaxTBD, customerOrder);
            if (!string.IsNullOrEmpty(isTaxTBD) && isTaxTBD.Equals("true", StringComparison.InvariantCultureIgnoreCase))
            {
                customerOrder.RecalculateTax = true;
            }
        }


        private void SendExceptionEmail(string error)
        {
            if (this.CommonSettings.ExceptionErrorEmailActive)
            {
                string subject = "Vertex - Tax Calulation : Failed On " + DateTime.Now;
                dynamic obj = new ExpandoObject();
                obj.ApiModle = string.Empty;
                obj.MailSubject = subject;
                obj.JsonInput = string.Empty;
                obj.JsonOutput = string.Empty;
                obj.AdditionalInfo = error;

                this.EmailHelper.ErrorEmail(obj, this.EmailService);
            }
        }

       
        private void ReSetOrderLineTax(CustomerOrder customerOrder)
        {
            foreach (var orderLine in customerOrder.OrderLines)
            {
                orderLine.TaxAmount = 0;
                orderLine.TaxCode2 = "0";
            }
        }

        private void SetCustomerOrderProperty(CustomerOrder customerorder, string propertyName, string propertyValue)
        {
            CustomProperty customProperty = customerorder.CustomProperties.FirstOrDefault(o => o.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));

            if (customProperty != null)
            {
                customProperty.Value = propertyValue;
            }
            else
            {
                customerorder.SetProperty(propertyName, propertyValue);
            }

            this.UnitOfWork.Save();
        }

        private void UpdateCustomerOrderPropertyIfExist(CustomerOrder customerorder, string propertyName, string propertyValue)
        {
            CustomProperty customProperty = customerorder.CustomProperties.FirstOrDefault(o => o.Name.Equals(propertyName, StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null && propertyValue.Equals("false", StringComparison.InvariantCultureIgnoreCase))
            {
                customProperty.Value = propertyValue;
                this.UnitOfWork.Save();
            }

        }

    }
}
