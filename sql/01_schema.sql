/*
 =================================================================
 Schema definition: NASA PCoE Li-ion battery ageing dataset
 ----------------------------------------------------------
 creates the tables for cells B0005, B0006, B0007, B0008:
    cells, cycles, discharge_samples, impedance
 Run after 00_setup.sql, connected as the project user (sadia),
 on the battery_sox database.
 =================================================================
 */

-- -----------------------------------------------------------------
-- Table: cells
-- One row per battery cell in the dataset (B0005, B0006, B0007, B0018).
-- -----------------------------------------------------------------
 CREATE TABLE IF NOT EXISTS cells (
   cell_id VARCHAR(10) NOT NULL, -- cell name e.g. 'B0005'
   rated_capacity_ah DECIMAL(4,2) NOT NULL, -- nominal capacity in ah
   PRIMARY KEY (cell_id)
 );

-- -----------------------------------------------------------------
-- Table: cycles
-- One row per charge, discharge or impedance cycle of each cell.
-- -----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cycles (
    cycle_id INT NOT NULL AUTO_INCREMENT, -- cycle id with increment
    cell_id VARCHAR(10) NOT NULL, -- battery this cell belongs to e.g. 'B0005'
    cycle_number INT NOT NULL, -- cycle's position in the life of the battery under test
    cycle_type VARCHAR(10) NOT NULL, -- type of cycle i.e. charge/discharge/impedance
    ambient_temp_c DOUBLE, -- room temperature during the respective cycle (degree centigrade)
    start_time DATETIME, -- date & time when the cycle started
    capacity_ah DOUBLE, -- measured capacity during the discharge cycles (Ah)
    PRIMARY KEY (cycle_id),
    FOREIGN KEY (cell_id) REFERENCES cells (cell_id),
    UNIQUE (cell_id, cycle_number),
    CHECK (cycle_type IN ('charge', 'discharge', 'impedance'))
);

