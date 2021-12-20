using Insite.Core.Interfaces.Data;
using Insite.Core.Interfaces.Localization;
using Insite.Data.Entities;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LeggettAndPlatt.Extensions.Entities
{
    [Table("LPEmployee")]
    public class LPEmployee : EntityBase
    {
        [StringLength(100)]
        public virtual string FirstName { get; set; }

        [StringLength(100)]
        public virtual string LastName { get; set; }

        [NaturalKeyField]
        public virtual string UniqueIdNumber { get; set; }

        [StringLength(4)]
        public virtual string ClockNumber { get; set; }

    }
}
