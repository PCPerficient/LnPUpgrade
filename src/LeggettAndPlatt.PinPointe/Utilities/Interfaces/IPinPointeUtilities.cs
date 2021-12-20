using Insite.Core.Interfaces.Dependency;

namespace LeggettAndPlatt.PinPointe.Utilities.Interfaces
{
    public interface IPinPointeUtilities : IDependency
    {
        string Serialize(object dataToSerialize);
        T Deserialize<T>(string xmlText);

        string PostPinPointeWebRequest(string url, string strXML);
    }
}
