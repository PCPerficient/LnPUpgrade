using Insite.Core.Interfaces.Dependency;
using System.Collections.Generic;

namespace LeggettAndPlatt.FTP.Interface
{
    public interface IFtpsManager : IDependency
    {
        void MoveFilesFromRemoteToLocal();
    }
}
