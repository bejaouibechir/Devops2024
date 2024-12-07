#Créer la base de données
CREATE DATABASE IF NOT EXISTS businessdb;

#Utiliser la base de données
USE businessdb;

#Créer la table employees
CREATE TABLE IF NOT EXISTS  employees (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    salary INT NOT NULL
);

