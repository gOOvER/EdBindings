namespace EdBindings.Model.BindingsRaw.Tests;

using System;

using Xunit;

public class BindFileTests
{
    [Fact]
    public void TestProcessingBindingFile()
    {
        // Test with Elite Dangerous 4.2 binding configuration (latest game version)
        var path = @".\Custom.4.2.binds";

        var bindingFile = BindingFile.Open(path);

        Assert.Equal("en-US", bindingFile.KeyboardLayout);

        // Elite Dangerous 4.2 contains 1490 total bindings
        Assert.Equal(1490, bindingFile.Bindings.Count);

    }
}
