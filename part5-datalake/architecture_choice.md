## Architecture Recommendation

For a fast-growing food delivery startup collecting GPS location logs, customer text reviews, payment transactions, and restaurant menu images, I would recommend a **Data Lakehouse** architecture.

A pure Data Warehouse is designed for structured, schema-on-write data and excels at SQL analytics. However, it cannot natively store or process GPS logs (semi-structured time-series), text reviews (unstructured NLP input), or restaurant images (binary files). Forcing these into a relational warehouse would require lossy preprocessing and would block the machine learning use cases that make a food delivery platform competitive (e.g., ETA prediction, sentiment analysis, recommendation engines). A pure Data Lake, on the other hand, can store all formats cheaply but lacks transactional guarantees, indexing, and the ACID properties needed for payment records and operational reporting.

A Data Lakehouse — implemented with technologies like Apache Delta Lake, Apache Iceberg, or Databricks Lakehouse Platform — gives the startup the best of both architectures.

**Reason 1 — Multi-format storage in a single system.** The lakehouse stores GPS logs as Parquet files, text reviews as JSON or Delta tables, payment transactions as ACID-compliant Delta tables, and menu images as raw binary objects in object storage (S3/GCS). No format is excluded and no separate ETL pipeline is needed to move data between a lake and a warehouse.

**Reason 2 — ACID transactions for payment data.** Payment records require the same consistency guarantees as a relational database. Delta Lake's ACID transaction support means concurrent writes from thousands of delivery agents and customers are handled safely, and time-travel versioning provides an audit trail — a compliance necessity for financial data.

**Reason 3 — Unified platform for both BI and ML.** Business analysts can run SQL queries directly on Delta tables for operational dashboards (revenue by city, average delivery time). Data scientists can simultaneously read the same data in Python using Spark or Pandas for model training — training an ETA prediction model on GPS logs, or a review sentiment classifier on text data. A traditional warehouse would force separate pipelines for these two workloads.
