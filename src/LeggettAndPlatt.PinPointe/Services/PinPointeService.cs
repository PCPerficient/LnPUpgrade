using LeggettAndPlatt.PinPointe.Services.Interfaces;
using LeggettAndPlatt.PinPointe.Models;
using LeggettAndPlatt.PinPointe.Utilities.Interfaces;
using Insite.Core.Interfaces.Dependency;

namespace LeggettAndPlatt.PinPointe.Services
{
    public class PinPointeService : IPinPointeService, IDependency
    {
        protected readonly IPinPointeUtilities PinPointeUtilities;
        public PinPointeService(IPinPointeUtilities pinPointeUtilities)
        {
            this.PinPointeUtilities = pinPointeUtilities;
        }
        public PinPointeResponseModel AddSubscriberToList(PinPointeRequestModel pinPointeRequestModel, string url)
        {
            string strXML = this.PinPointeUtilities.Serialize(pinPointeRequestModel);

            string response = this.PinPointeUtilities.PostPinPointeWebRequest(url, strXML);

            PinPointeResponseModel pinPointeResponseModel = this.PinPointeUtilities.Deserialize<PinPointeResponseModel>(response);

            pinPointeResponseModel.RequestXML = strXML;

            return pinPointeResponseModel;
        }

        public PinPointeResponseModel DeleteSubscriberFromList(PinPonteDeleteSubscriberRequestModel pinPonteDeleteSubscriberRequestModel, string url)
        {
            string strXML = this.PinPointeUtilities.Serialize(pinPonteDeleteSubscriberRequestModel);

            string response = this.PinPointeUtilities.PostPinPointeWebRequest(url, strXML);

            PinPointeResponseModel pinPointeResponseModel = this.PinPointeUtilities.Deserialize<PinPointeResponseModel>(response);

            pinPointeResponseModel.RequestXML = strXML;

            return pinPointeResponseModel;
        }

        public PinPointeResponseModel UnsubscribeSubscriberFromList(PinPonteUnSubscriberRequestModel pinPonteUnSubscriberRequestModel, string url)
        {
            string strXML = this.PinPointeUtilities.Serialize(pinPonteUnSubscriberRequestModel);

            string response = this.PinPointeUtilities.PostPinPointeWebRequest(url, strXML);

            PinPointeResponseModel pinPointeResponseModel = this.PinPointeUtilities.Deserialize<PinPointeResponseModel>(response);

            pinPointeResponseModel.RequestXML = strXML;

            return pinPointeResponseModel;
        }

        public PinPointeResponseModel IsUnSubscriber(PinPointeRequestModel pinPointeRequestModel, string url)
        {
            string strXML = this.PinPointeUtilities.Serialize(pinPointeRequestModel);

            string response = this.PinPointeUtilities.PostPinPointeWebRequest(url, strXML);

            PinPointeResponseModel pinPointeResponseModel = this.PinPointeUtilities.Deserialize<PinPointeResponseModel>(response);

            pinPointeResponseModel.RequestXML = strXML;

            return pinPointeResponseModel;
        }
    }
}
