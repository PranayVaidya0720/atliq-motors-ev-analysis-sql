CREATE DATABASE atliq_ev_db;
USE atliq_ev_db;

-- 1. Date Dimensions Mapping Table
CREATE TABLE dim_date (
    date VARCHAR(20),
    fiscal_year INT,
    quarter VARCHAR(10)
);

-- 2. Volumetric Sales Facts Organized by Vehicle Manufacturers
CREATE TABLE ev_sales_by_makers (
    date VARCHAR(20),
    vehicle_category VARCHAR(20),
    maker VARCHAR(100),
    electric_vehicles_sold INT
);

-- 3. Regional Aggregated Sales Facts Across Sovereign Territories
CREATE TABLE ev_sales_by_state (
    date VARCHAR(20),
    state VARCHAR(100),
    vehicle_category VARCHAR(20),
    electric_vehicles_sold INT,
    total_vehicles_sold INT
);
