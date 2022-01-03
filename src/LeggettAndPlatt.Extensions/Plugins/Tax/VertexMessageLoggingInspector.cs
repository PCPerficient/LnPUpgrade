using Insite.Common.Logging;
using Insite.Core.Common;
using System.ServiceModel;
using System.ServiceModel.Channels;

namespace LeggettAndPlatt.Extensions.Plugins.Tax
{
    internal class VertexMessageLoggingInspector : MessageViewerInspector
    {
        private readonly bool logTransactions;

        internal VertexMessageLoggingInspector(bool logTransactions) => this.logTransactions = logTransactions;

        public override void AfterReceiveReply(ref Message reply, object correlationState)
        {
            if (!this.logTransactions)
                return;
            LogHelper.For((object)this).Info((object)string.Format("Tax response: {0}", (object)reply), "TaxCalculator_Vertex");
        }

        public override object BeforeSendRequest(ref Message request, IClientChannel channel)
        {
            if (this.logTransactions)
                LogHelper.For((object)this).Info((object)string.Format("Tax request: {0}", (object)request), "TaxCalculator_Vertex");
            return (object)null;
        }
    }
}
