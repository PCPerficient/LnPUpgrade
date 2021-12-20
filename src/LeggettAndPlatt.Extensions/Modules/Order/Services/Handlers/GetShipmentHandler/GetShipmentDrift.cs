using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Dependency;
using Insite.Core.Plugins.EntityUtilities;
using Insite.Core.Plugins.Utilities;
using Insite.Core.Providers;
using Insite.Core.Services;
using Insite.Core.Services.Handlers;
using Insite.Data.Entities;
using Insite.Data.Extensions;
using Insite.Order.Services.Dtos;
using Insite.Order.Services.Parameters;
using Insite.Order.Services.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;

namespace LeggettAndPlatt.Extensions.Modules.Order.Services.Handlers.GetShipmentHandler
{
   
    [DependencyName("GetShipment")]
    public class GetShipmentDrift : HandlerBase<GetShipmentParameter, GetShipmentResult>
    {
        private readonly IObjectToObjectMapper objectToObjectMapper;
        private readonly IShipmentPackageUtilities shipmentPackageUtilities;

        public GetShipmentDrift(IObjectToObjectMapper objectToObjectMapper, IShipmentPackageUtilities shipmentPackageUtilities)
        {
            this.objectToObjectMapper = objectToObjectMapper;
            this.shipmentPackageUtilities = shipmentPackageUtilities;
        }

        public override int Order
        {
            get
            {
                return 500;
            }
        }

        public override GetShipmentResult Execute(IUnitOfWork unitOfWork, GetShipmentParameter parameter, GetShipmentResult result)
        {
            Shipment shipment = parameter.Shipment;
            if (shipment == null)
                shipment = unitOfWork.GetRepository<Shipment>().GetTable().Expand<Shipment, ICollection<ShipmentPackage>>((Expression<Func<Shipment, ICollection<ShipmentPackage>>>)(s => s.ShipmentPackages)).SingleOrDefault<Shipment>((Expression<Func<Shipment, bool>>)(s => s.ShipmentNumber == parameter.ShipmentNumber));
            Shipment source = shipment;
            if (source == null)
                return this.CreateErrorServiceResult<GetShipmentResult>(result, SubCode.NotFound, string.Format(MessageProvider.Current.Not_Found, (object)"Shipment"));
            ShipmentDto shipmentDto = this.objectToObjectMapper.Map<Shipment, ShipmentDto>(source);
            foreach (ShipmentPackageDto shipmentPackage1 in (IEnumerable<ShipmentPackageDto>)shipmentDto.ShipmentPackages)
            {
                ShipmentPackageDto shipmentPackageDto = shipmentPackage1;
                shipmentPackageDto.ShipmentDate = shipmentDto.ShipmentDate;
                ShipmentPackage shipmentPackage2 = source.ShipmentPackages.SingleOrDefault<ShipmentPackage>((Func<ShipmentPackage, bool>)(o => o.Id == shipmentPackageDto.Id));
                if (shipmentPackage2 != null)
                    shipmentPackageDto.TrackingUrl = GetShipmentPackageTrackingUrl(shipmentPackage2);                
            }
            result.Shipment = shipmentDto;
            return this.NextHandler.Execute(unitOfWork, parameter, result);
        }

        private string GetShipmentPackageTrackingUrl(ShipmentPackage shipmentPackage)
        {
            var customProperty = shipmentPackage.CustomProperties.FirstOrDefault(x => x.Name.Equals("trackingUrl", StringComparison.InvariantCultureIgnoreCase));
            if (customProperty != null && !string.IsNullOrEmpty(customProperty.Value))
            {
                return "<a href='" + customProperty.Value + "' target='_blank'>" + shipmentPackage.TrackingNumber + "</a>";
            }
            return shipmentPackage.TrackingNumber;
        }
    }
}
