
namespace LeggettAndPlatt.FTP.RequestModel
{
    public class FTPRequestModel
    {
        public string FTPAddress { get; set; }
        public string FTPUsername { get; set; }
        public string FTPPassword { get; set; }
        public int FTPPort { get; set; }
        public string FTPRemoteFolderPath { get; set; }
        public string LocalFolderPath { get; set; }
    }
}
