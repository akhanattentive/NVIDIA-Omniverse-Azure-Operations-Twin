using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS policy for Azure environments
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthorization();

// Health check endpoint
app.MapHealthChecks("/health");

// Hello World endpoints
app.MapGet("/", () => "Hello World from Proxy API!")
    .WithName("GetHelloWorld")
    .WithOpenApi();

app.MapGet("/api/hello", () => new { 
    Message = "Hello World from Proxy API!", 
    Timestamp = DateTime.UtcNow,
    Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production",
    Version = "1.0.0"
})
    .WithName("GetHelloWorldApi")
    .WithOpenApi();

app.MapGet("/api/status", () => new { 
    Status = "Running", 
    Uptime = DateTime.UtcNow - System.Diagnostics.Process.GetCurrentProcess().StartTime,
    MachineName = Environment.MachineName,
    ProcessId = Environment.ProcessId
})
    .WithName("GetStatus")
    .WithOpenApi();

app.MapControllers();

var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("Proxy API starting up...");

app.Run();

// Make the Program class public for testing
public partial class Program { }
