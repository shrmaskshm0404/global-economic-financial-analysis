# Project 1 — Global Economic & Financial Indicators (SQL + Python)

## Overview
A portfolio-ready analytics project combining **SQL** and **Python** to explore macroeconomic and financial indicators across eight major economies from 2015–2024.

The project demonstrates:
- Relational data modeling
- SQL filtering, aggregation, CTEs and window functions
- Year-over-year growth calculations
- Country benchmarking
- Python data validation and transformation with pandas
- Matplotlib visualization
- Jupyter notebook storytelling

## Project structure

```text
project1_global_economic_financial_indicators/
├── data/
│   └── global_economic_indicators.csv
├── sql/
│   └── project1_analysis.sql
├── src/
│   └── analysis.py
├── notebooks/
│   └── Project1_Global_Economic_Indicators.ipynb
├── charts/
│   ├── gdp_trend.png
│   ├── inflation_trend.png
│   ├── unemployment_2024.png
│   └── inflation_vs_unemployment.png
├── requirements.txt
└── README.md
```

## Dataset
The included CSV is a **coherent portfolio-project dataset** designed to exercise the complete SQL + Python workflow. It is not presented as a live official extract.

The column definitions mirror common World Bank World Development Indicators concepts:
- `gdp_current_usd_bn`
- `gdp_per_capita_usd`
- `inflation_pct`
- `unemployment_pct`
- `trade_pct_gdp`
- `real_interest_rate_pct`

For a production/live-data version, replace the CSV with an official World Bank WDI API extract. The World Bank Indicators API supports country, indicator, year-range and JSON/CSV queries, and does not require an API key. See the official API documentation:
https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures

## How to run

### 1. Create an environment
```bash
python -m venv .venv
```

Windows:
```bash
.venv\Scripts\activate
```

macOS/Linux:
```bash
source .venv/bin/activate
```

### 2. Install dependencies
```bash
pip install -r requirements.txt
```

### 3. Run the Python analysis
```bash
python src/analysis.py
```

This creates an enriched CSV and four PNG charts.

### 4. Run the notebook
```bash
jupyter notebook notebooks/Project1_Global_Economic_Indicators.ipynb
```

### 5. Run the SQL
The SQL is SQLite-compatible. Example using the SQLite CLI:

```bash
sqlite3 project1.db
.mode csv
.headers on
.import data/global_economic_indicators.csv economic_indicators
.read sql/project1_analysis.sql
```

## Core analytical questions
1. Which countries have the largest GDP?
2. Which countries experienced the fastest GDP growth?
3. How did inflation change around 2020–2022?
4. Which economies had the lowest unemployment in 2024?
5. Is higher trade openness associated with higher GDP per capita?
6. Which country experienced the largest inflation spike?
7. Which country-years show GDP contraction?

## Portfolio talking points
- SQL handles reproducible analytical queries and ranking.
- Python handles validation, feature engineering and visualization.
- Window functions make time-series comparisons concise.
- The project can be upgraded to a live World Bank ingestion pipeline without changing the analytical layer.

## Data source note
World Bank WDI is the recommended live-data source for the production version. The official documentation states that the API provides programmatic access to thousands of indicators and supports JSON, CSV downloads, country filters and date ranges.
