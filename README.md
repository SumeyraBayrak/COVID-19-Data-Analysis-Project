# COVID-19 Data Analysis Project

This project presents a complete data analytics pipeline for global COVID-19 data. Using **SQL Server** for data processing and **Tableau** for visualization, the workflow covers everything from raw data extraction to interactive dashboarding – providing actionable insights into infection rates, mortality, and vaccination trends worldwide.

## 🎯 Project Objective
The primary goal is to transform public COVID-19 datasets into meaningful business intelligence. This analysis enables:
- Cross-country performance benchmarking in pandemic response.
- Identification of high-risk regions based on infection and mortality metrics.
- Tracking the global vaccination rollout and its correlation with case trends.

## 🛠️ Tech Stack
| Tool | Role |
|------|------|
| **SQL Server** | Data storage, complex aggregations, and analytical querying |
| **Tableau Public** | Interactive dashboard design and geospatial visualization |
| **Excel** | Initial data inspection and lightweight preprocessing |

## 📂 Datasets
Two primary datasets are used, both structured for time-series analysis:

- **`CovidDeathsData.xlsx`** – Daily records of confirmed cases, new cases, total deaths, and new deaths per location.
- **`CovidVaccinationsData.xlsx`** – Daily vaccination data, including new and cumulative vaccinations per location.

*Key fields include `location`, `date`, `population`, `total_cases`, `total_deaths`, and `new_vaccinations`.*

## ⚙️ Setup & Execution
Follow these steps to replicate the analysis locally:

1. **Clone the Repository**  
   `git clone https://github.com/SumeyraBayrak/COVID-19-Data-Analysis-Project.git`

2. **Import Data into SQL Server**  
   - Open SQL Server Management Studio (SSMS) and create a new database (e.g., `PortfolioProject`).  
   - Use the Import/Export Wizard to load both Excel files as separate tables.

3. **Run Analytical Queries**  
   - Execute `COVID Portfolio Project.sql` to perform exploratory analysis, rolling calculations, and aggregation.  
   - Execute `COVID19_Dashboard_Data.sql` to generate the structured tables specifically designed for the Tableau dashboard.

4. **Launch the Dashboard**  
   - Open the packaged workbook `Covid19_4Panel_Dashboard.twbx` in Tableau Public to interact with the visualizations.

## 🔎 SQL Analysis Approach
The SQL logic is divided into two complementary files:

- **`COVID Portfolio Project.sql`** – Focuses on exploratory data analysis (EDA). It utilizes **CTEs**, **window functions**, and **temporary tables** to calculate death percentages, infection rates per population, and cumulative vaccination rolling averages.

- **`COVID19_Dashboard_Data.sql`** – Optimized for dashboard ingestion. It outputs four clean, aggregated tables that directly feed into Tableau, ensuring real-time responsiveness.

**Sample Query – Infection Rate Ranking:**
```sql
SELECT 
    location, 
    population, 
    MAX(total_cases) AS highest_infection_count, 
    MAX(total_cases/population)*100 AS percent_population_infected
FROM CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;
