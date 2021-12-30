using Insite.Cart.Services.Parameters;
using Insite.Cart.Services.Results;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Interfaces.Plugins.Emails;
using Insite.Core.Plugins.Emails;
using Insite.Core.Services.Handlers;
using Insite.Data.Repositories.Interfaces;
using System;
using System.Collections.Generic;
using System.Net.Mail;
using LeggettAndPlatt.Extensions.CustomSettings;

namespace LeggettAndPlatt.Extensions.Modules.Cart.Services.Handlers.UpdateCartHandler
{
    [DependencyName("SendConfirmationEmail")]
    public class SendConfirmationEmailDrift : HandlerBase<UpdateCartParameter, UpdateCartResult>
    {
        private readonly Lazy<IBuildEmailValues> buildEmailValues;
        private readonly Lazy<IEmailService> emailService;
        private readonly OrderSettings OrderSettings;
        public override int Order
        {
            get
            {
                return 3200;
            }
        }

        public SendConfirmationEmailDrift(Lazy<IBuildEmailValues> buildEmailValues, Lazy<IEmailService> emailService, OrderSettings orderSettings)
        {
            this.buildEmailValues = buildEmailValues;
            this.emailService = emailService;
            this.OrderSettings = orderSettings;
        }

        public override UpdateCartResult Execute(IUnitOfWork unitOfWork, UpdateCartParameter parameter, UpdateCartResult result)
        {
            if (!parameter.Status.EqualsIgnoreCase("Submitted"))
                return this.NextHandler.Execute(unitOfWork, parameter, result);
            if (OrderSettings.SendOrderEmail)
            {
                //checks if mattress fee is in customer order then add to email model
                if (result.GetCartResult.Cart.OtherCharges > 0)
                {    
                    ((IDictionary<string, object>)result.ConfirmationEmailModel).Add("OtherCharges", result.GetCartResult.Cart.OtherCharges.ToString("C"));
                }

                if (OrderSettings.DepartmentCode.ToLower() == "conwebc")//drift email
                {
                    //this.emailService.Value.SendEmailList(unitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName("LP_DRIFT_STORE_OrderConfirmation_List", "Order Confirmation", "").Id, (IList<string>)this.buildEmailValues.Value.BuildOrderConfirmationEmailToList(result.GetCartResult.Cart.Id), result.ConfirmationEmailModel, (string)null, unitOfWork, SiteContext.Current.WebsiteDto?.Id, (IList<Attachment>)null);
                }
                else //employee email
                {
                    //this.emailService.Value.SendEmailList(unitOfWork.GetTypedRepository<IEmailListRepository>().GetOrCreateByName("LP_EMP_STORE_OrderConfirmation_List", "Order Confirmation", "").Id, (IList<string>)this.buildEmailValues.Value.BuildOrderConfirmationEmailToList(result.GetCartResult.Cart.Id), result.ConfirmationEmailModel, (string)null, unitOfWork, SiteContext.Current.WebsiteDto?.Id, (IList<Attachment>)null);
                }
            }
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }
    }
}

