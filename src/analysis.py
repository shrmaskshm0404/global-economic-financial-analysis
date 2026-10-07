from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "global_economic_indicators.csv"
CHARTS = ROOT / "charts"
CHARTS.mkdir(exist_ok=True)

df = pd.read_csv(DATA)

# Basic validation
required = {
    "country", "iso3", "year", "gdp_current_usd_bn",
    "gdp_per_capita_usd", "inflation_pct", "unemployment_pct",
    "trade_pct_gdp", "real_interest_rate_pct"
}
missing = required - set(df.columns)
if missing:
    raise ValueError(f"Missing columns: {sorted(missing)}")

assert df[["country", "year"]].duplicated().sum() == 0

# Derived metrics
df = df.sort_values(["country", "year"])
df["gdp_yoy_pct"] = df.groupby("country")["gdp_current_usd_bn"].pct_change() * 100
df["inflation_3yr_avg"] = (
    df.groupby("country")["inflation_pct"]
      .transform(lambda s: s.rolling(3, min_periods=1).mean())
)

latest = df[df["year"] == df["year"].max()].sort_values(
    "gdp_current_usd_bn", ascending=False
)

print("\nLatest snapshot:")
print(latest[[
    "country", "gdp_current_usd_bn", "inflation_pct",
    "unemployment_pct", "trade_pct_gdp"
]].to_string(index=False))

# Chart 1: GDP trend
plt.figure(figsize=(10, 6))
for country, group in df.groupby("country"):
    plt.plot(group["year"], group["gdp_current_usd_bn"], label=country)
plt.title("GDP Trend by Country")
plt.xlabel("Year")
plt.ylabel("GDP (USD billions)")
plt.legend(ncol=2, fontsize=8)
plt.tight_layout()
plt.savefig(CHARTS / "gdp_trend.png", dpi=160)
plt.close()

# Chart 2: Inflation trend
plt.figure(figsize=(10, 6))
for country, group in df.groupby("country"):
    plt.plot(group["year"], group["inflation_pct"], label=country)
plt.title("Inflation Trend by Country")
plt.xlabel("Year")
plt.ylabel("Inflation (%)")
plt.legend(ncol=2, fontsize=8)
plt.tight_layout()
plt.savefig(CHARTS / "inflation_trend.png", dpi=160)
plt.close()

# Chart 3: Unemployment 2024
latest_sorted = latest.sort_values("unemployment_pct")
plt.figure(figsize=(9, 5))
plt.barh(latest_sorted["country"], latest_sorted["unemployment_pct"])
plt.title("Unemployment Rate — 2024")
plt.xlabel("Unemployment (%)")
plt.tight_layout()
plt.savefig(CHARTS / "unemployment_2024.png", dpi=160)
plt.close()

# Chart 4: Inflation vs unemployment
plt.figure(figsize=(8, 6))
plt.scatter(latest["inflation_pct"], latest["unemployment_pct"])
for _, r in latest.iterrows():
    plt.annotate(r["country"], (r["inflation_pct"], r["unemployment_pct"]),
                 xytext=(5, 5), textcoords="offset points", fontsize=8)
plt.title("Inflation vs Unemployment — 2024")
plt.xlabel("Inflation (%)")
plt.ylabel("Unemployment (%)")
plt.tight_layout()
plt.savefig(CHARTS / "inflation_vs_unemployment.png", dpi=160)
plt.close()

# Export derived analysis
df.to_csv(ROOT / "data" / "economic_indicators_enriched.csv", index=False)
print(f"\nCharts written to: {CHARTS}")
