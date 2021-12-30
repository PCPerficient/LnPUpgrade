using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.PinPointe.Models;

namespace LeggettAndPlatt.PinPointe.Services.Interfaces
{
    public interface IPinPointeService : IDependency
    {
        PinPointeResponseModel AddSubscriberToList(PinPointeRequestModel pinPointeRequestModel, string url);

        PinPointeResponseModel DeleteSubscriberFromList(PinPonteDeleteSubscriberRequestModel pinPonteDeleteSubscriberRequestModel, string url);

        PinPointeResponseModel UnsubscribeSubscriberFromList(PinPonteUnSubscriberRequestModel pinPonteUnSubscriberRequestModel, string url);

        PinPointeResponseModel IsUnSubscriber(PinPointeRequestModel pinPointeRequestModel, string url);
    }
}
