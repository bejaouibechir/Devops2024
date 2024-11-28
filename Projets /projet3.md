### **Projet Web API .NET 8 avec Redis Cache : Structure et Implémentation Complète**

---

### **1. Structure du projet**

#### **Arborescence**
```plaintext
WebApiRedis/
├── Controllers/
│   ├── DepartmentController.cs
│   ├── EmployeeController.cs
├── Models/
│   ├── Department.cs
│   ├── Employee.cs
├── Services/
│   ├── RedisCacheService.cs
├── Properties/
│   ├── launchSettings.json
├── appsettings.json
├── Dockerfile
├── docker-compose.yml
├── Program.cs
├── WebApiRedis.csproj
```

---

### **2. Code Source Complet**

#### **Modèles**

##### `Department.cs`
```csharp
public class Department
{
    public int Id { get; set; }
    public string Name { get; set; }
    public List<Employee> Employees { get; set; } = new();
}
```

##### `Employee.cs`
```csharp
public class Employee
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }
    public int DepartmentId { get; set; }
}
```

---

#### **Service Redis**

##### `RedisCacheService.cs`
```csharp
using StackExchange.Redis;
using System.Text.Json;

public class RedisCacheService
{
    private readonly IDatabase _db;

    public RedisCacheService(IConnectionMultiplexer redis)
    {
        _db = redis.GetDatabase();
    }

    public async Task SetAsync<T>(string key, T value)
    {
        var json = JsonSerializer.Serialize(value);
        await _db.StringSetAsync(key, json);
    }

    public async Task<T?> GetAsync<T>(string key)
    {
        var json = await _db.StringGetAsync(key);
        return json.HasValue ? JsonSerializer.Deserialize<T>(json!) : default;
    }
}
```

---

#### **Contrôleurs**

##### `DepartmentController.cs`
```csharp
[ApiController]
[Route("api/[controller]")]
public class DepartmentController : ControllerBase
{
    private readonly RedisCacheService _redisCacheService;

    public DepartmentController(RedisCacheService redisCacheService)
    {
        _redisCacheService = redisCacheService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateDepartment(Department department)
    {
        await _redisCacheService.SetAsync($"department:{department.Id}", department);
        return CreatedAtAction(nameof(GetDepartment), new { id = department.Id }, department);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetDepartment(int id)
    {
        var department = await _redisCacheService.GetAsync<Department>($"department:{id}");
        return department != null ? Ok(department) : NotFound();
    }
}
```

##### `EmployeeController.cs`
```csharp
[ApiController]
[Route("api/[controller]")]
public class EmployeeController : ControllerBase
{
    private readonly RedisCacheService _redisCacheService;

    public EmployeeController(RedisCacheService redisCacheService)
    {
        _redisCacheService = redisCacheService;
    }

    [HttpPost]
    public async Task<IActionResult> AddEmployee(int departmentId, Employee employee)
    {
        var department = await _redisCacheService.GetAsync<Department>($"department:{departmentId}");
        if (department == null) return NotFound("Department not found");

        employee.Id = department.Employees.Count + 1;
        department.Employees.Add(employee);

        await _redisCacheService.SetAsync($"department:{departmentId}", department);
        return Ok(employee);
    }

    [HttpGet("{departmentId}")]
    public async Task<IActionResult> GetEmployees(int departmentId)
    {
        var department = await _redisCacheService.GetAsync<Department>($"department:{departmentId}");
        return department != null ? Ok(department.Employees) : NotFound();
    }
}
```

---

#### **Configuration et Démarrage**

##### `Program.cs`
```csharp
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

var redisHost = Environment.GetEnvironmentVariable("REDIS_HOST") ?? "localhost";
var redisPort = Environment.GetEnvironmentVariable("REDIS_PORT") ?? "6379";

builder.Services.AddSingleton<IConnectionMultiplexer>(_ =>
    ConnectionMultiplexer.Connect($"{redisHost}:{redisPort}"));
builder.Services.AddScoped<RedisCacheService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.MapControllers();
app.Run();
```

##### `appsettings.json`
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

##### `launchSettings.json`
```json
{
  "profiles": {
    "WebApiRedis": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

---

### **3. Dockerisation**

#### `Dockerfile`
```dockerfile
# Base image for runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Build image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["WebApiRedis.csproj", "./"]
RUN dotnet restore "./WebApiRedis.csproj"
COPY . .
RUN dotnet build "WebApiRedis.csproj" -c Release -o /app/build

# Publish image
FROM build AS publish
RUN dotnet publish "WebApiRedis.csproj" -c Release -o /app/publish

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApiRedis.dll"]
```

---

### **4. Orchestration Docker Compose**

#### `docker-compose.yml`
```yaml
version: '3.8'
services:
  redis:
    image: redis:latest
    container_name: redis
    ports:
      - "6379:6379"

  webapi:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - redis
```

---

### **5. Kubernetes Manifests**

#### Déploiement de l’API
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapi
spec:
  replicas: 4
  selector:
    matchLabels:
      app: webapi
  template:
    metadata:
      labels:
        app: webapi
    spec:
      containers:
      - name: webapi
        image: yourdockerhub/webapi:latest
        ports:
        - containerPort: 80
        env:
        - name: REDIS_HOST
          value: redis-service
        - name: REDIS_PORT
          value: "6379"
```

#### Déploiement Redis
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 3
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:latest
        ports:
        - containerPort: 6379
```

#### ClusterIP Service Redis
```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
  type: ClusterIP
```

#### NodePort Service Web API
```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapi-service
spec:
  selector:
    app: webapi
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```

---

### **6. Dépendance externe (StackExchange.Redis)**

Pour installer la bibliothèque dans le contexte Dockerisé :

1. **Ajoutez la dépendance dans le projet localement :**
   ```bash
   dotnet add package StackExchange.Redis
   ```

2. **Assurez-vous que `WebApiRedis.csproj` contient :**
   ```xml
   <PackageReference Include="StackExchange.Redis" Version="x.x.x" />
   ```

3. **Incluez les étapes dans le Dockerfile :**
   - La commande `RUN dotnet restore` dans la section **build** installe automatiquement les dépendances référencées.

Avec ces configurations, votre projet est complet et prêt pour une exécution locale, conteneurisée ou orchestrée.
