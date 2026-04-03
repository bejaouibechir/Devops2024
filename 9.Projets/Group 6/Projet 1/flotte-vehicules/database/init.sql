IF DB_ID('FlotteDB') IS NULL
BEGIN
    CREATE DATABASE FlotteDB;
END
GO

USE FlotteDB;
GO

IF OBJECT_ID('dbo.SitesDeVente', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SitesDeVente (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Nom NVARCHAR(200) NOT NULL,
        Ville NVARCHAR(100) NOT NULL,
        Adresse NVARCHAR(300) NULL,
        Responsable NVARCHAR(200) NULL
    );
END
GO

IF OBJECT_ID('dbo.Acheteurs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Acheteurs (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Nom NVARCHAR(200) NOT NULL,
        Prenom NVARCHAR(200) NOT NULL,
        Email NVARCHAR(200) NOT NULL,
        Telephone NVARCHAR(20) NULL
    );
    CREATE UNIQUE INDEX IX_Acheteurs_Email ON dbo.Acheteurs(Email);
END
GO

IF OBJECT_ID('dbo.Vehicules', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Vehicules (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Marque NVARCHAR(100) NOT NULL,
        Modele NVARCHAR(100) NOT NULL,
        Annee INT NOT NULL,
        Kilometrage INT NOT NULL,
        Prix DECIMAL(10,2) NOT NULL,
        Statut NVARCHAR(50) NOT NULL CONSTRAINT DF_Vehicules_Statut DEFAULT('Disponible'),
        SiteDeVenteId INT NULL,
        AcheteurId INT NULL,
        CONSTRAINT CK_Vehicules_Statut CHECK (Statut IN ('Disponible', 'Vendu')),
        CONSTRAINT CK_Vehicules_Annee CHECK (Annee BETWEEN 1900 AND 2100),
        CONSTRAINT CK_Vehicules_Kilometrage CHECK (Kilometrage >= 0),
        CONSTRAINT CK_Vehicules_Prix CHECK (Prix >= 0)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Vehicules_SitesDeVente')
BEGIN
    ALTER TABLE dbo.Vehicules
    ADD CONSTRAINT FK_Vehicules_SitesDeVente
        FOREIGN KEY (SiteDeVenteId) REFERENCES dbo.SitesDeVente(Id)
        ON DELETE SET NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Vehicules_Acheteurs')
BEGIN
    ALTER TABLE dbo.Vehicules
    ADD CONSTRAINT FK_Vehicules_Acheteurs
        FOREIGN KEY (AcheteurId) REFERENCES dbo.Acheteurs(Id)
        ON DELETE SET NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SitesDeVente)
BEGIN
    INSERT INTO dbo.SitesDeVente (Nom, Ville, Adresse, Responsable) VALUES
      ('AutoCenter Paris', 'Paris', '12 Rue de la République, 75011 Paris', 'Nadia Benali'),
      ('Garage Lyon Sud', 'Lyon', '8 Avenue des Frères Lumière, 69008 Lyon', 'Marc Durand'),
      ('Occasions Marseille', 'Marseille', '3 Boulevard du Prado, 13008 Marseille', 'Sophie Martin');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Acheteurs)
BEGIN
    INSERT INTO dbo.Acheteurs (Nom, Prenom, Email, Telephone) VALUES
      ('Dupont', 'Alice', 'alice.dupont@example.com', '0601020304'),
      ('Bernard', 'Karim', 'karim.bernard@example.com', '0611223344'),
      ('Moreau', 'Ines', 'ines.moreau@example.com', '0622334455'),
      ('Petit', 'Thomas', 'thomas.petit@example.com', '0633445566'),
      ('Rossi', 'Luca', 'luca.rossi@example.com', '0644556677');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Vehicules)
BEGIN
    DECLARE @siteParis INT = (SELECT TOP 1 Id FROM dbo.SitesDeVente WHERE Nom = 'AutoCenter Paris');
    DECLARE @siteLyon INT = (SELECT TOP 1 Id FROM dbo.SitesDeVente WHERE Nom = 'Garage Lyon Sud');
    DECLARE @siteMarseille INT = (SELECT TOP 1 Id FROM dbo.SitesDeVente WHERE Nom = 'Occasions Marseille');

    DECLARE @aAlice INT = (SELECT TOP 1 Id FROM dbo.Acheteurs WHERE Email = 'alice.dupont@example.com');
    DECLARE @aKarim INT = (SELECT TOP 1 Id FROM dbo.Acheteurs WHERE Email = 'karim.bernard@example.com');
    DECLARE @aInes INT = (SELECT TOP 1 Id FROM dbo.Acheteurs WHERE Email = 'ines.moreau@example.com');
    DECLARE @aThomas INT = (SELECT TOP 1 Id FROM dbo.Acheteurs WHERE Email = 'thomas.petit@example.com');

    INSERT INTO dbo.Vehicules (Marque, Modele, Annee, Kilometrage, Prix, Statut, SiteDeVenteId, AcheteurId) VALUES
      ('Peugeot', '208', 2019, 52000, 10990.00, 'Disponible', @siteParis, NULL),
      ('Renault', 'Clio', 2018, 68000, 9990.00, 'Vendu', @siteParis, @aAlice),
      ('Volkswagen', 'Golf', 2017, 88000, 12990.00, 'Disponible', @siteLyon, NULL),
      ('Toyota', 'Yaris', 2020, 42000, 13990.00, 'Vendu', @siteLyon, @aKarim),
      ('Citroën', 'C3', 2016, 99000, 8490.00, 'Disponible', @siteMarseille, NULL),
      ('Ford', 'Focus', 2015, 112000, 7990.00, 'Disponible', @siteMarseille, NULL),
      ('BMW', 'Serie 1', 2019, 61000, 18990.00, 'Vendu', @siteParis, @aInes),
      ('Audi', 'A3', 2018, 73000, 19990.00, 'Disponible', @siteLyon, NULL),
      ('Mercedes', 'Classe A', 2021, 31000, 24990.00, 'Disponible', @siteParis, NULL),
      ('Dacia', 'Sandero', 2020, 39000, 10990.00, 'Vendu', @siteMarseille, @aThomas);
END
GO

