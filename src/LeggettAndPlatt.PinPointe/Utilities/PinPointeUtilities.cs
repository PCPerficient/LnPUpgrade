using Insite.Core.Interfaces.Dependency;
using LeggettAndPlatt.PinPointe.Utilities.Interfaces;
using System;
using System.IO;
using System.Net;
using System.Xml;
using System.Xml.Serialization;

namespace LeggettAndPlatt.PinPointe.Utilities
{
    public class PinPointeUtilities : IPinPointeUtilities, IDependency
    {
        public T Deserialize<T>(string xmlText)
        {
            if (String.IsNullOrWhiteSpace(xmlText)) return default(T);

            using (StringReader stringReader = new System.IO.StringReader(xmlText))
            {
                var serializer = new XmlSerializer(typeof(T));
                return (T)serializer.Deserialize(stringReader);
            }

        }

        public string Serialize(object dataToSerialize)
        {
            XmlDocument xmlDoc = new XmlDocument();        
            XmlSerializer xmlSerializer = new XmlSerializer(dataToSerialize.GetType());          
            using (MemoryStream xmlStream = new MemoryStream())
            {
                xmlSerializer.Serialize(xmlStream, dataToSerialize);
                xmlStream.Position = 0;              
                xmlDoc.Load(xmlStream);
                return xmlDoc.InnerXml;
            }

        }

        public string PostPinPointeWebRequest(string url, string strXML)
        {
            string result = string.Empty;

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);

            byte[] requestInFormOfBytes = System.Text.Encoding.ASCII.GetBytes(strXML);
            request.Method = "POST";
            request.ContentType = "text/xml;charset=utf-8";
            request.ContentLength = requestInFormOfBytes.Length;
            Stream requestStream = request.GetRequestStream();
            requestStream.Write(requestInFormOfBytes, 0, requestInFormOfBytes.Length);
            requestStream.Close();

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            StreamReader respStream = new StreamReader(response.GetResponseStream(), System.Text.Encoding.Default);
            result = respStream.ReadToEnd();

            respStream.Close();
            response.Close();
            return result;
        }
    }
}
