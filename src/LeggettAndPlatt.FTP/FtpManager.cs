using FluentFTP;
using LeggettAndPlatt.FTP.Interface;
using LeggettAndPlatt.FTP.RequestModel;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Security.Authentication;

namespace LeggettAndPlatt.FTP
{
    public class FtpManager : IFtpManager
    {
        private readonly string server;
        private readonly string username;
        private readonly string password;
        private readonly int port;
        private readonly string remotePath;
        private readonly string localPath;
        private const string archiveFolderName = "Archive/";

        public FtpManager(FTPRequestModel requestModel)
        {
            this.server = requestModel.FTPAddress;
            this.username = requestModel.FTPUsername;
            this.password = requestModel.FTPPassword;
            this.port = requestModel.FTPPort;
            this.remotePath = UpdatePath(requestModel.FTPRemoteFolderPath);
            this.localPath = requestModel.LocalFolderPath;
        }

        #region Global Method
        public void MoveFiles()
        {
            string archiveFolderPath = this.remotePath + archiveFolderName;
            List<string> fileNameList = new List<string>();

            using (FtpClient ftp = new FtpClient(this.server,this.port,this.username, this.password))
            {
                ftp.Connect();
                ftp.CreateDirectory(archiveFolderPath);
                fileNameList = GetRemoteFileNameList(ftp,this.remotePath);
                foreach (string remoteFileName in fileNameList)
                {
                    ftp.MoveFile(this.remotePath + remoteFileName, archiveFolderPath + remoteFileName);
                }
                ftp.Disconnect();
            }
        }

        public void MoveFilesFromRemoteToLocal()
        {
            List<string> fileNameList = new List<string>();
            string path = UpdateLocelPath();
            using (FtpClient ftp = new FtpClient(this.server,this.port, this.username, this.password))
            {
                ftp.Connect();
                List<string> ftpPathList = this.GetFtpPathList();
                foreach(string ftPath in ftpPathList)
                {
                    string updatedRemotePath = UpdatePath(ftPath);
                    fileNameList = GetRemoteFileNameList(ftp, updatedRemotePath);
                    //DownLoad files
                    foreach (string remoteFileName in fileNameList)
                    {
                        ftp.DownloadFile(path + remoteFileName, updatedRemotePath + remoteFileName);
                    }
                    //Delete file
                    foreach (string remoteFileName in fileNameList)
                    {
                        ftp.DeleteFile(updatedRemotePath + remoteFileName);
                    }
                }
                ftp.Disconnect();
            }
        }
        public void Upload(string fileName)
        {
            string path = GetLocalFilePath(fileName);
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftp.Connect();
                ftp.UploadFile(path, this.remotePath + fileName);
                ftp.Disconnect();
            }
        }
       
        public void Download(string fileName)
        {
            string path = GetLocalFilePath(fileName);
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
              
                ftp.EncryptionMode = FtpEncryptionMode.Explicit;
                ftp.Connect();
                ftp.DownloadFile(path, this.remotePath + fileName);
                ftp.Disconnect();
            }
        }
        public List<string> GetList()
        {
            List<string> fileNames = new List<string>();
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftp.Connect();
                foreach (FtpListItem item in ftp.GetListing(this.remotePath))
                {
                    if (item.Type == FtpFileSystemObjectType.File)
                        fileNames.Add(item.Name);
                }
                ftp.Disconnect();
            }
            return fileNames;
        }
        public void DownloadFiles()
        {
            List<string> fileNameList = GetRemotePathList();
            IEnumerable<string> serverPathList = (IEnumerable<string>)fileNameList;
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftp.Connect();
                ftp.DownloadFiles(this.localPath, serverPathList, true);
                ftp.Disconnect();
            }
        }
        public void DeleteFile(string fileName)
        {
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftp.Connect();
                ftp.DeleteFile(this.remotePath + fileName);
                ftp.Disconnect();
            }
        }
        #endregion

        #region Helper Method
        private List<string> GetFtpPathList()
        {
            return this.remotePath.Split(',').ToList();
        }
        private List<string> GetRemoteFileNameList(FtpClient ftp,string ftpPath)
        {
            List<string> fileNames = new List<string>();
            foreach (FtpListItem item in ftp.GetListing(ftpPath))
            {
                if (item.Type == FtpFileSystemObjectType.File)
                    fileNames.Add(item.Name);
            }
            return fileNames;
        }
        private string UpdateLocelPath()
        {
            string resultPath = this.localPath;

            if (!this.localPath.EndsWith(@"\"))
                return this.localPath + @"\";

            return resultPath;
        }
        private List<string> GetRemotePathList()
        {
            List<string> fileNames = new List<string>();
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftp.Connect();
                foreach (FtpListItem item in ftp.GetListing(this.remotePath))
                {
                    if (item.Type == FtpFileSystemObjectType.File)
                        fileNames.Add(this.remotePath + item.Name);
                }
                ftp.Disconnect();
            }
            return fileNames;
        }
        private string GetLocalFilePath(string fileName)
        {
            string path = this.localPath;

            if (!this.localPath.EndsWith(@"\"))
                path = this.localPath + @"\";

            return path + fileName;
        }
        private string UpdatePath(string path)
        {
            string resultPath = path;

            if (!path.EndsWith("/"))
            {
                return path + "/";
            }
            return resultPath;
        }

        #endregion
        public void FTPSUpload(string fileName)
        {
            string path = GetLocalFilePath(fileName);
            using (FtpClient ftp = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftp.EncryptionMode = FtpEncryptionMode.Implicit;
                ftp.SslProtocols = SslProtocols.Tls12;
                ftp.ValidateCertificate += new FtpSslValidation(OnValidateCertificate);
                ftp.Connect();
                ftp.UploadFile(path, this.remotePath + fileName);
                ftp.Disconnect();
            }
        }
        static void OnValidateCertificate(FtpClient control, FtpSslValidationEventArgs e)
        {
            // add logic to test if certificate is valid here
            e.Accept = true;
        }

    }

}
