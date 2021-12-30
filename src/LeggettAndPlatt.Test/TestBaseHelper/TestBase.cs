using Insite.Common.Dependencies;
using Insite.Common.Providers;
using Insite.Core.Context;
using Insite.Core.Interfaces.Data;
using Insite.Core.Plugins.Utilities;
using Insite.Core.TestHelpers;
using Insite.Data.Entities;
using Insite.Data.Entities.Dtos;
using Moq;
using NUnit.Framework;
using System;

namespace LeggettAndPlatt.Test.TestBaseHelper
{
    public abstract class TestBase
    {
        protected AutoMoqContainer container;
        protected Mock<ISiteContext> siteContext;
        protected Mock<IDependencyLocator> dependencyLocator;
        protected Mock<IUnitOfWork> unitOfWork;
        protected Mock<IDataProvider> dataProvider;
        protected FakeUnitOfWork fakeUnitOfWork;


        [SetUp]
        public void SetupTest()
        {
            this.container = new AutoMoqContainer();

            this.dataProvider = this.container.GetMock<IDataProvider>();
            this.unitOfWork = this.container.GetMock<IUnitOfWork>();
            this.unitOfWork.Setup(o => o.DataProvider).Returns(this.dataProvider.Object);
            this.fakeUnitOfWork = new FakeUnitOfWork(this.unitOfWork.Object);

            this.siteContext = this.container.GetSettingsMock<ISiteContext>();
            this.dependencyLocator = this.container.GetSettingsMock<IDependencyLocator>();
            TestHelper.MockSiteContext(this.siteContext, this.dependencyLocator);
            TestHelper.MockExpandExtension(this.dependencyLocator, this.dataProvider);
            TestHelper.MockMessageProvider();
            DateTimeProvider.Current = new MockDateTimeProvider(DateTime.UtcNow);

            this.SetUp();

        }

        public abstract void SetUp();


        protected void WhenSiteContextUserProfileDtoIs(UserProfileDto userProfileDto)
        {
            this.siteContext.Setup(o => o.UserProfileDto).Returns(userProfileDto);
        }

    }
}
