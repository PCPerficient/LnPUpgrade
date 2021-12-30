using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Net;
using System.Web;

public class ReCaptcha
{
    /// <summary>
    /// Determines if the given reCaptcha response is human, returns true if successful.
    /// <para>Use "Request["g-recaptcha-response"]" in the controller to get response string on form post.</para>
    /// </summary>
    /// <param name="response">Response from the reCaptcha form element</param>
    /// <param name="secretKey">Secret key provided by Google that should be stored in AppSettings</param>
    /// <returns>True if human</returns>
    public static RecaptchaResult GetReCaptchaResponse(string response, string secretKey)
    {
        RecaptchaResult result = new RecaptchaResult { Score = 0, Result = RecaptchaResponse.Failure };

        var client = new WebClient();
        result.Reply =
            client.DownloadString(
                string.Format("https://www.google.com/recaptcha/api/siteverify?secret={0}&response={1}", secretKey, response));

        var captchaResponse = JsonConvert.DeserializeObject<CaptchaResponse>(result.Reply);

        if (captchaResponse.Success)
        {
            result.Result = RecaptchaResponse.Success;
        }
        result.Reply = HttpUtility.UrlEncode(result.Reply);

        return result;
    }
}

internal class CaptchaResponse
{
    [JsonProperty("success")]
    public bool Success { get; set; }
}

public class RecaptchaResult
{
    public double Score { get; set; }
    public RecaptchaResponse Result { get; set; }
    public string Reply { get; set; }
}

public enum RecaptchaResponse
{
    Default = 0,
    Success = 1,
    Failure = 2,
    NotFromSite = 3,
    BelowAverageScore = 4,
    LowScore = 5
}