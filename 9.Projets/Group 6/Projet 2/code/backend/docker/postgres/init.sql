-- Création de la base si elle n'existe pas déjà
SELECT 'CREATE DATABASE stockmaster'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'stockmaster')\gexec

-- Extensions utiles
\c stockmaster;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
