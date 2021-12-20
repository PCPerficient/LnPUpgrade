using Insite.ContentLibrary.ContentFields;
using Insite.ContentLibrary.Pages;
using Insite.Data.Entities;
using Insite.WebFramework.Content;
using Insite.WebFramework.Content.Attributes;
using Insite.WebFramework.Content.Interfaces;
using System;

namespace LeggettAndPlatt.Extensions.ContentLibrary.Pages
{
    [AllowedParents(new Type[] { typeof(HomePage) })]
    [SkipContentPageUrlValidation]
    public class InternalLinkPages : AbstractPage, ILinkableContent
    {
        [TextContentField(IsRequired = true, SortOrder = 0)]
        public override string Title
        {
            get
            {
                return this.GetValue<string>(nameof(Title), string.Empty, FieldType.Contextual);
            }
            set
            {
                this.SetValue<string>(nameof(Title), value, FieldType.Contextual);
            }
        }

        [TextContentField(InvalidRegExMessage = "The provided URL is not a valid internal resource", IsRequired = true, RegExValidation = "^/.*", SortOrder = 10)]
        public virtual string InternalUrl
        {
            get
            {
                return this.GetValue<string>(nameof(InternalUrl), string.Empty, FieldType.Contextual);
            }
            set
            {
                this.SetValue<string>(nameof(InternalUrl), value, FieldType.Contextual);
            }
        }

        [CheckBoxContentField(SortOrder = 20)]
        public override bool ExcludeFromNavigation
        {
            get
            {
                return this.GetValue<bool>(nameof(ExcludeFromNavigation), false, FieldType.General);
            }
            set
            {
                this.SetValue<bool>(nameof(ExcludeFromNavigation), value, FieldType.General);
            }
        }

        public virtual string Url
        {
            get
            {
                return this.InternalUrl;
            }
        }

        public override string NavigationViewDirectory
        {
            get
            {
                return "~/Views/Pages/ContentPage/Navigation/";
            }
        }
    }
}
