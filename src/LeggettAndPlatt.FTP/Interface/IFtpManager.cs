using Insite.Core.Interfaces.Dependency;
using System.Collections.Generic;

namespace LeggettAndPlatt.FTP.Interface
{
    public interface IFtpManager : IDependency
    {
        void Upload(string fileName);
        void Download(string fileName);
        List<string> GetList();
        void DownloadFiles();
        void DeleteFile(string fileName);
        void MoveFiles();
    }
}
