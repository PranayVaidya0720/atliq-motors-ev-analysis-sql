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
-- ----------------------------------------------------------
#### Q1: Top 3 & Bottom 3 Makers for 2-Wheelers (FY 2023 & FY 2024)
WITH MarketRankings AS (
    SELECT 
        d.fiscal_year,
        m.maker,
        SUM(m.electric_vehicles_sold) AS units_sold,
        DENSE_RANK() OVER(PARTITION BY d.fiscal_year ORDER BY SUM(m.electric_vehicles_sold) DESC) as top_rnk,
        DENSE_RANK() OVER(PARTITION BY d.fiscal_year ORDER BY SUM(m.electric_vehicles_sold) ASC) as bottom_rnk
    FROM ev_sales_by_makers m
    JOIN dim_date d ON m.date = d.date
    WHERE m.vehicle_category = '2-Wheelers' AND d.fiscal_year IN (2023, 2024)
    GROUP BY d.fiscal_year, m.maker
)
SELECT fiscal_year, maker, units_sold, 'Top Tier Leader' as classification FROM MarketRankings WHERE top_rnk <= 3
UNION ALL
SELECT fiscal_year, maker, units_sold, 'Bottom Tier Laggard' as classification FROM MarketRankings WHERE bottom_rnk <= 3
ORDER BY fiscal_year ASC, classification DESC, units_sold DESC;

#### Q2: Top 5 States by EV Penetration Rate (FY 2024)
SELECT 
    s.state,
    s.vehicle_category,
    SUM(s.electric_vehicles_sold) AS ev_sold,
    SUM(s.total_vehicles_sold) AS total_sold,
    ROUND((SUM(s.electric_vehicles_sold) / SUM(s.total_vehicles_sold)) * 100, 2) AS penetration_rate_pct
FROM ev_sales_by_state s
JOIN dim_date d ON s.date = d.date
WHERE d.fiscal_year = 2024
GROUP BY s.state, s.vehicle_category
ORDER BY s.vehicle_category, penetration_rate_pct DESC;

#### Q3: States Experiencing Negative Penetration Growth (2022 to 2024)
WITH AnnualShare AS (
    SELECT 
        s.state,
        s.vehicle_category,
        ROUND((SUM(CASE WHEN d.fiscal_year = 2022 THEN s.electric_vehicles_sold ELSE 0 END) / 
               NULLIF(SUM(CASE WHEN d.fiscal_year = 2022 THEN s.total_vehicles_sold ELSE 0 END), 0)) * 100, 2) AS rate_22,
        ROUND((SUM(CASE WHEN d.fiscal_year = 2024 THEN s.electric_vehicles_sold ELSE 0 END) / 
               NULLIF(SUM(CASE WHEN d.fiscal_year = 2024 THEN s.total_vehicles_sold ELSE 0 END), 0)) * 100, 2) AS rate_24
    FROM ev_sales_by_state s
    JOIN dim_date d ON s.date = d.date
    WHERE d.fiscal_year IN (2022, 2024)
    GROUP BY s.state, s.vehicle_category
)
SELECT state, vehicle_category, rate_22, rate_24, (rate_24 - rate_22) AS dynamic_decline
FROM AnnualShare
WHERE (rate_24 - rate_22) < 0
ORDER BY dynamic_decline ASC;

#### Q4: Quarterly Sales Volume Trends for Top 5 4-Wheeler Makers
WITH Top5FourWheelerMakers AS (
    SELECT m.maker
    FROM ev_sales_by_makers m
    JOIN dim_date d ON m.date = d.date
    WHERE m.vehicle_category = '4-Wheelers' AND d.fiscal_year IN (2022, 2023, 2024)
    GROUP BY m.maker
    ORDER BY SUM(m.electric_vehicles_sold) DESC
    LIMIT 5
)
SELECT 
    m.maker,
    d.fiscal_year,
    d.quarter,
    SUM(m.electric_vehicles_sold) AS aggregate_units
FROM ev_sales_by_makers m
JOIN dim_date d ON m.date = d.date
WHERE m.maker IN (SELECT maker FROM Top5FourWheelerMakers)
  AND m.vehicle_category = '4-Wheelers'
GROUP BY m.maker, d.fiscal_year, d.quarter
ORDER BY m.maker, d.fiscal_year, d.quarter;

#### Q5: Delhi vs. Karnataka Comparison Matrix (FY 2024)
#### Top 5 4-Wheeler Manufacturer CAGR (Q6)
SELECT 
    s.state,
    s.vehicle_category,
    SUM(s.electric_vehicles_sold) AS units_sold,
    ROUND((SUM(s.electric_vehicles_sold) / SUM(s.total_vehicles_sold)) * 100, 2) AS penetration_rate_pct
FROM ev_sales_by_state s
JOIN dim_date d ON s.date = d.date
WHERE s.state IN ('Delhi', 'Karnataka') AND d.fiscal_year = 2024
GROUP BY s.state, s.vehicle_category
ORDER BY s.vehicle_category, s.state;

#### Q6 & Q7: Compounded Annual Growth Rate (CAGR) Engine
WITH CAGR_Calc AS (
    SELECT 
        m.maker,
        SUM(CASE WHEN d.fiscal_year = 2022 THEN m.electric_vehicles_sold ELSE 0 END) AS volume_22,
        SUM(CASE WHEN d.fiscal_year = 2024 THEN m.electric_vehicles_sold ELSE 0 END) AS volume_24
    FROM ev_sales_by_makers m
    JOIN dim_date d ON m.date = d.date
    WHERE m.vehicle_category = '4-Wheelers'
    GROUP BY m.maker
)
SELECT 
    maker, volume_22, volume_24,
    ROUND((POWER((volume_24 / NULLIF(volume_22, 0)), 0.5) - 1) * 100, 2) AS maker_cagr_pct
FROM CAGR_Calc
WHERE volume_22 > 0
ORDER BY volume_24 DESC
LIMIT 5;

####Top 10 States with the Highest Total Vehicle CAGR (Q7)
WITH StateCAGR AS (
    SELECT 
        s.state,
        SUM(CASE WHEN d.fiscal_year = 2022 THEN s.total_vehicles_sold ELSE 0 END) AS total_22,
        SUM(CASE WHEN d.fiscal_year = 2024 THEN s.total_vehicles_sold ELSE 0 END) AS total_24
    FROM ev_sales_by_state s
    JOIN dim_date d ON s.date = d.date
    GROUP BY s.state
)
SELECT 
    state, total_22, total_24,
    ROUND((POWER((total_24 / NULLIF(total_22, 0)), 0.5) - 1) * 100, 2) AS state_market_cagr_pct
FROM StateCAGR
WHERE total_22 > 0
ORDER BY state_market_cagr_pct DESC
LIMIT 10;

#### Q8: Peak and Low Season Months for EV Sales
SELECT 
    SUBSTRING(date, 4, 3) AS extracted_month,
    SUM(electric_vehicles_sold) AS overall_ev_units
FROM ev_sales_by_state
GROUP BY extracted_month
ORDER BY overall_ev_units DESC;

#### Q9: 2030 Horizon Market Volume Forecast
WITH BaselineGrowth AS (
    SELECT 
        s.state,
        SUM(CASE WHEN d.fiscal_year = 2022 THEN s.electric_vehicles_sold ELSE 0 END) AS ev_22,
        SUM(CASE WHEN d.fiscal_year = 2024 THEN s.electric_vehicles_sold ELSE 0 END) AS ev_24
    FROM ev_sales_by_state s
    JOIN dim_date d ON s.date = d.date
    GROUP BY s.state
),
CAGREngine AS (
    SELECT 
        state, ev_24,
        POWER((ev_24 / NULLIF(ev_22, 0)), 0.5) - 1 AS raw_cagr
    FROM BaselineGrowth
    WHERE ev_22 > 0
)
SELECT 
    state, ev_24,
    ROUND(raw_cagr * 100, 2) AS calculated_cagr_pct,
    ROUND(ev_24 * POWER((1 + raw_cagr), 6), 0) AS forecasted_2030_ev_units
FROM CAGREngine
ORDER BY forecasted_2030_ev_units DESC
LIMIT 10;

#### Q10: Projected Revenue Growth (2022 vs. 2024 & 2023 vs. 2024)
WITH ValueAssumptions AS (
    SELECT 
        d.fiscal_year,
        SUM(CASE WHEN s.vehicle_category = '2-Wheelers' THEN s.electric_vehicles_sold ELSE 0 END) AS units_2w,
        SUM(CASE WHEN s.vehicle_category = '4-Wheelers' THEN s.electric_vehicles_sold ELSE 0 END) AS units_4w
    FROM ev_sales_by_state s
    JOIN dim_date d ON s.date = d.date
    GROUP BY d.fiscal_year
),
RevenueComputed AS (
    SELECT 
        fiscal_year,
        units_2w,
        units_4w,
        (units_2w * 85000) AS rev_2w,
        (units_4w * 1500000) AS rev_4w
    FROM ValueAssumptions
)
SELECT 
    curr.fiscal_year AS current_year,
    prev.fiscal_year AS comparison_year,
    ROUND(((curr.rev_2w - prev.rev_2w) / prev.rev_2w) * 100, 2) AS growth_rate_2w_pct,
    ROUND(((curr.rev_4w - prev.rev_4w) / prev.rev_4w) * 100, 2) AS growth_rate_4w_pct
FROM RevenueComputed curr
JOIN RevenueComputed prev ON (curr.fiscal_year = 2024 AND prev.fiscal_year = 2022) 
                          OR (curr.fiscal_year = 2024 AND prev.fiscal_year = 2023);

