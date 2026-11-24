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
    ambient_temp_c DOUBLE, -- room temperature during the respective cycle (°C)
    start_time DATETIME, -- date & time when the cycle started
    capacity_ah DOUBLE, -- measured capacity during the discharge cycles (Ah)
    PRIMARY KEY (cycle_id),
    FOREIGN KEY (cell_id) REFERENCES cells (cell_id),
    UNIQUE (cell_id, cycle_number),
    CHECK (cycle_type IN ('charge', 'discharge', 'impedance'))
);

-- -----------------------------------------------------------------
-- Table: discharge_samples
-- One row per measurement (time, voltage, current, temperature)
-- Within a discharge cycle.
-- -----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS discharge_samples (
    cycle_id INT NOT NULL, -- discharge cycle this sample belongs to
    sample_number INT NOT NULL, -- measurement position within a cycle (1,2,3....)
    time_s DOUBLE NOT NULL, -- seconds since the cycle started (s)
    voltage_v DOUBLE NOT NULL, -- measured terminal voltage (V)
    current_a DOUBLE NOT NULL, -- measured current (A)
    temperature_c DOUBLE NOT NULL, -- measured cell temperature (°C)
    PRIMARY KEY (cycle_id, sample_number),
    FOREIGN KEY (cycle_id) REFERENCES cycles (cycle_id)
);

-- -----------------------------------------------------------------
-- Table: impedance
-- One row per impedance cycle, with the estimated internal
-- resistances Re and Rct (used for state of power estimation).
-- -----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS impedance (
    cycle_id INT NOT NULL,  -- impedance cycle these values belong to
    re_ohm DOUBLE, -- estimated electrolyte resistance Re (ohm)
    rct_ohm DOUBLE, -- estimated charge-transfer resistance Rct (ohm)
    PRIMARY KEY (cycle_id),
    FOREIGN KEY (cycle_id) REFERENCES cycles (cycle_id)
);