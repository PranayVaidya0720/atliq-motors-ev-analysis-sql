# AtliQ Motors EV Market Strategy Analytics (SQL Project)

## 📌 Project Overview
AtliQ Motors, an automotive leader from the USA specializing in electric vehicles, is planning an expansion strategy into the Indian EV market. This project delivers an end-to-end data analysis framework using SQL to examine regional market penetration rates, manufacturer growth metrics, and future sales volumes.

## 🛠️ Tech Stack & Database Architecture
* **Database Engine:** MySQL / PostgreSQL
* **Core Concepts:** Common Table Expressions (CTEs), Window Functions (`DENSE_RANK`), Advanced Data Type Parsing (`STR_TO_DATE`), Exponentiation for CAGR Calculations, and Multi-Table Joins.

---

## 📈 Key Insights & Results

### 1. Market Penetration Leaders (FY 2024)
* **2-Wheelers:** Goa leads the country with a **17.99%** penetration rate.
* **4-Wheelers:** Kerala leads the country with a **5.76%** penetration rate.

### 2. Competitive Landscape Shifts
* **Ola Electric** established absolute volume dominance in the 2-wheeler space between FY 2023 and FY 2024, whereas infrastructure limitations and environmental variables caused slight adoption drops in union territories like Ladakh and the Andaman & Nicobar Islands.

### 3. Financial Impact & Growth
* **2-Wheeler Revenue:** Grew by **269.28%** from 2022 to 2024.
* **4-Wheeler Revenue:** Sparked a **367.79%** revenue growth over the same 2-year timeline.

---

## 📂 Repository Contents
* `1_Database_Setup.sql`: Contains the initial database creation, table schema setup, and robust string-to-date data transformation scripts.
* `2_Analytical_Core.sql`: Houses the structural SQL queries built to answer the 10 core business and research questions.
