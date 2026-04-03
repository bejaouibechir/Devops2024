using System.Text.Json;
using System.Text.Json.Serialization;
using FlotteAPI.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseUrls("http://0.0.0.0:5000");

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.DictionaryKeyPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod());
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (string.IsNullOrWhiteSpace(connectionString))
{
    var host = builder.Configuration["DB_HOST"] ?? "db";
    var dbName = builder.Configuration["DB_NAME"] ?? "FlotteDB";
    var user = builder.Configuration["DB_USER"] ?? "sa";
    var password = builder.Configuration["SA_PASSWORD"];
    if (!string.IsNullOrWhiteSpace(password))
    {
        connectionString = $"Server={host},1433;Database={dbName};User Id={user};Password={password};TrustServerCertificate=True";
    }
}

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException("La chaîne de connexion est introuvable. Définissez ConnectionStrings:DefaultConnection ou SA_PASSWORD + DB_HOST/DB_NAME/DB_USER.");
}

builder.Services.AddDbContext<FlotteDbContext>(options =>
    options.UseSqlServer(connectionString));

var app = builder.Build();

app.UseCors();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

await ApplyMigrationsWithRetryAsync(app, maxAttempts: 10, delay: TimeSpan.FromSeconds(5));

app.Run();

static async Task ApplyMigrationsWithRetryAsync(WebApplication app, int maxAttempts, TimeSpan delay)
{
    for (var attempt = 1; attempt <= maxAttempts; attempt++)
    {
        try
        {
            using var scope = app.Services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<FlotteDbContext>();
            await db.Database.MigrateAsync();
            return;
        }
        catch when (attempt < maxAttempts)
        {
            await Task.Delay(delay);
        }
    }
}

