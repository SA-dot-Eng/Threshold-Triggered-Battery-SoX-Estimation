/*
====================================================
Database Configuration: Battery SoX
Purpose: Database initialization and user management
====================================================
*/

-- create Li-ion battery database
CREATE DATABASE IF NOT EXISTS battery_sox
	CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- CSV files permission to load
SET PERSIST local_infile = 1;

-- Create a project user (replace the password before running; never commit a real one)
CREATE USER IF NOT EXISTS 'sadia'@'localhost' IDENTIFIED BY 'change-me';
GRANT ALL PRIVILEGES ON battery_sox.* TO 'sadia'@'localhost';
