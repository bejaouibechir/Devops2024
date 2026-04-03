FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY FlotteAPI/FlotteAPI.csproj FlotteAPI/
RUN dotnet restore FlotteAPI/FlotteAPI.csproj

COPY FlotteAPI/ FlotteAPI/
RUN dotnet publish FlotteAPI/FlotteAPI.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_URLS=http://0.0.0.0:5000
EXPOSE 5000
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet","FlotteAPI.dll"]

