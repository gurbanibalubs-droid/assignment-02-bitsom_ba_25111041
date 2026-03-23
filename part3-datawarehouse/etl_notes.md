## ETL Decisions

### Decision 1 — Inconsistent Date Formats

Problem: The `date` column in `retail_transactions.csv` contains three different formats mixed throughout the 300 rows: ISO format (`2023-02-05`), slash-delimited day-first (`29/08/2023`), and dash-delimited day-first (`20-02-2023`). Because Python's default date parser treats ambiguous formats like `2023-02-05` as year-month-day but `29/08/2023` as day/month/year, naively applying a single parser produces silently incorrect dates (e.g., `2023-02-05` being misread as 5th February instead of 2nd May when the separator changes). Incorrect dates in a date dimension would cause month and quarter groupings in analytical queries to return wrong results.

Resolution: Applied Python's `dateutil.parser.parse()` with `dayfirst=True` for all non-ISO strings, and then explicitly re-parsed ISO-format strings (`YYYY-MM-DD`) with `dayfirst=False`. All dates were normalized to `YYYY-MM-DD` before generating `date_key` integers in the format `YYYYMMDD` for the `dim_date` dimension table.

---

### Decision 2 — Inconsistent Category Casing

Problem: The `category` column contained five distinct values due to inconsistent casing and naming: `electronics`, `Electronics`, `Grocery`, `Clothing`, and `Groceries`. This means queries grouping by category would return separate rows for `electronics` and `Electronics`, effectively splitting one logical group into two. The inconsistency between `Grocery` and `Groceries` further fragments the data, making aggregations (e.g., total Groceries revenue by month) incorrect.

Resolution: Applied `.str.strip().str.title()` to normalize all values to title case, then applied a manual mapping to reconcile `Grocery` → `Groceries`, resulting in exactly three canonical category values: `Electronics`, `Clothing`, and `Groceries`. These standardized values are stored in the `dim_product` table, ensuring all fact rows reference a single consistent category label.

---

### Decision 3 — NULL Values in store_city Column

Problem: 19 out of 300 rows (approximately 6.3%) had `NULL` values in the `store_city` column. In the raw flat file, `store_city` is a free-text field populated separately from `store_name`, and some rows were simply not filled in. Leaving these NULLs in the warehouse would cause city-level and region-level queries to exclude affected transactions entirely (since NULL comparisons always return false), silently understating revenue figures for those stores.

Resolution: Since `store_name` was always present and unambiguous (it deterministically identifies the branch), a lookup dictionary was constructed mapping each `store_name` to its canonical `store_city`: `Chennai Anna` → `Chennai`, `Delhi South` → `Delhi`, `Bangalore MG` → `Bangalore`, `Pune FC Road` → `Pune`, `Mumbai Central` → `Mumbai`. All NULL `store_city` values were imputed using this mapping before loading into `dim_store`. This is a safe resolution because the functional dependency `store_name → store_city` holds without exception across the entire dataset.
