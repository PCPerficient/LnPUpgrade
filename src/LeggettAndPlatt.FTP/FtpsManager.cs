using FluentFTP;
using LeggettAndPlatt.FTP.Interface;
using LeggettAndPlatt.FTP.RequestModel;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Authentication;

namespace LeggettAndPlatt.FTP
{
    public class FtpsManager : IFtpsManager
    {
        private readonly string server;
        private readonly string username;
        private readonly string password;
        private readonly int port;
        private readonly string remotePath;
        private readonly string localPath;
        private const string archiveFolderName = "Archive/";

        public FtpsManager(FTPRequestModel requestModel)
        {
            this.server = requestModel.FTPAddress;
            this.username = requestModel.FTPUsername;
            this.password = requestModel.FTPPassword;
            this.port = requestModel.FTPPort;
            this.remotePath = UpdatePath(requestModel.FTPRemoteFolderPath);
            this.localPath = requestModel.LocalFolderPath;
        }

        #region Global Method


        public void MoveFilesFromRemoteToLocal()
        {
            List<string> fileNameList = new List<string>();
            string path = UpdateLocelPath();
            using (FtpClient ftps = new FtpClient(this.server, this.port, this.username, this.password))
            {
                ftps.EncryptionMode = FtpEncryptionMode.Implicit;
                ftps.SslProtocols = SslProtocols.Tls12;
                ftps.ValidateCertificate += new FtpSslValidation(OnValidateCertificate);
                ftps.DataConnectionType = FtpDataConnectionType.PASV;
                ftps.DataConnectionReadTimeout = 999999;
                ftps.ReadTimeout = 999999;
                ftps.Connect();
                var itemList = GetRemoteFileNameList(ftps, this.remotePath);

                if (itemList.Count() > 0)
                {
                    foreach (string item in itemList)
                    {
                        var remoteItem = this.UpdatePath(this.remotePath) + item;
                        //detect whether its a directory or file
                        if (ftps.DirectoryExists(remoteItem))
                        {
                            var fileList = GetRemoteFileNameList(ftps, remoteItem);
                            if (fileList.Count() > 0 && fileList.Contains("ExportSucceed.txt"))
                            {
                                string destinationPath = this.localPath + item;
                                // Try to create the directory.
                                if (!Directory.Exists(destinationPath))
                                {
                                    DirectoryInfo di = Directory.CreateDirectory(destinationPath);
                                }

                                foreach (string fileItem in fileList)
                                {
                                    var filePath = this.UpdatePath(remoteItem) + fileItem;
                                    //detect whether its a directory or file
                                    if (ftps.FileExists(filePath))
                                    {
                                        ftps.DownloadFile(this.UpdatePath(destinationPath) + fileItem, filePath);
                                    }
                                }
                                ftps.DeleteDirectory(remoteItem);
                            }
                        }
                        else
                        {
                            string localFile = this.UpdatePath(this.localPath) + item;
                            ftps.DownloadFile(localFile, remoteItem);
                            ftps.DeleteFile(remoteItem);
                        }
                    }
                }
                ftps.Disconnect();
            }
        }
        #endregion

        #region Helper Method



        static void OnValidateCertificate(FtpClient control, FtpSslValidationEventArgs e)
        {
            // add logic to test if certificate is valid here
            e.Accept = true;
        }


        private string UpdateLocelPath()
        {
            string resultPath = this.localPath;

            if (!this.localPath.EndsWith(@"\"))
                return this.localPath + @"\";

            return resultPath;
        }
        private List<string> GetRemoteFileNameList(FtpClient ftp, string ftpPath)
        {
            List<string> fileNames = new List<string>();
            var dirListing = ftp.GetListing(ftpPath);
            if (dirListing.Count() > 0)
            {
                foreach (FtpListItem item in dirListing)
                {
                    fileNames.Add(item.Name);
                }
            }

            return fileNames;
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
    }
}
