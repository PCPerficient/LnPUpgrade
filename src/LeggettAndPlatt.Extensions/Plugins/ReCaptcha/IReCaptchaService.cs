using Insite.Core.Interfaces.Dependency;
namespace LeggettAndPlatt.Extensions.Plugins.ReCaptcha
{
    public interface IReCaptchaService : IDependency, IExtension
    {
        bool ValidateRequest(string location);

        bool CheckVerified();

        void SetVerified();

        bool NeedToCheckReCaptchaOnClientSideForLocation(string location);

        bool NeedToCheckReCaptchaOnServerSideForLocation(string location);
    }
}
