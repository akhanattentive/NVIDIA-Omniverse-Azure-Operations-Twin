using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Net;
using System.Text.Json;
using Xunit;

namespace ProxyApi.Tests;

public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureServices(services =>
        {
            // Add any test-specific services here if needed
        });
    }
}

public class ProxyApiTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;

    public ProxyApiTests(CustomWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Get_Root_ReturnsHelloWorld()
    {
        // Act
        var response = await _client.GetAsync("/");

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        Assert.Equal("Hello World from Proxy API!", content);
    }

    [Fact]
    public async Task Get_ApiHello_ReturnsJsonResponse()
    {
        // Act
        var response = await _client.GetAsync("/api/hello");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("application/json", response.Content.Headers.ContentType?.MediaType);
        
        var content = await response.Content.ReadAsStringAsync();
        var jsonDoc = JsonDocument.Parse(content);
        
        Assert.True(jsonDoc.RootElement.TryGetProperty("Message", out var messageProperty));
        Assert.Equal("Hello World from Proxy API!", messageProperty.GetString());
        
        Assert.True(jsonDoc.RootElement.TryGetProperty("Version", out var versionProperty));
        Assert.Equal("1.0.0", versionProperty.GetString());
    }

    [Fact]
    public async Task Get_ApiStatus_ReturnsStatusInfo()
    {
        // Act
        var response = await _client.GetAsync("/api/status");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("application/json", response.Content.Headers.ContentType?.MediaType);
        
        var content = await response.Content.ReadAsStringAsync();
        var jsonDoc = JsonDocument.Parse(content);
        
        Assert.True(jsonDoc.RootElement.TryGetProperty("Status", out var statusProperty));
        Assert.Equal("Running", statusProperty.GetString());
        
        Assert.True(jsonDoc.RootElement.TryGetProperty("ProcessId", out var processIdProperty));
        Assert.True(processIdProperty.GetInt32() > 0);
    }

    [Fact]
    public async Task Get_Health_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/health");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Get_Swagger_ReturnsSwaggerInDevelopment()
    {
        // Arrange
        var factory = new CustomWebApplicationFactory();
        factory = (CustomWebApplicationFactory)factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Development");
        });

        using var client = factory.CreateClient();

        // Act
        var response = await client.GetAsync("/swagger/index.html");

        // Assert
        response.EnsureSuccessStatusCode();
    }
}
