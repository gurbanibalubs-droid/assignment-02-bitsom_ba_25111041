## Storage Systems

The hospital network has four distinct goals, each with different data characteristics, consistency requirements, and access patterns. The architecture uses a purpose-built storage system for each goal.

**Goal 1 — Predict patient readmission risk** uses a combination of a **relational database (PostgreSQL)** for storing structured historical treatment records (diagnoses, procedures, medications, lab results) and a **feature store (Feast or Tecton)** that materializes engineered features for model training and serving. Historical data is periodically extracted to an **object store (S3/GCS)** where it feeds an ML training pipeline. PostgreSQL is chosen here because patient treatment records have a well-defined relational structure (patients → admissions → diagnoses → treatments), require referential integrity, and benefit from ACID guarantees to prevent incomplete records from corrupting model training data.

**Goal 2 — Plain-English querying of patient history** uses a **Vector Database (Pinecone or Weaviate)** alongside a large language model. Clinical notes and discharge summaries are chunked, embedded using a medical-domain sentence transformer, and stored as vectors. When a doctor asks "Has this patient had a cardiac event before?", the query is embedded and a nearest-neighbour search retrieves the most semantically relevant records, which are then passed to an LLM for answer generation. A traditional keyword search would miss synonyms ("myocardial infarction" vs "heart attack"), making a vector DB essential.

**Goal 3 — Monthly management reports** uses an **OLAP Data Warehouse (Amazon Redshift or Google BigQuery)**. Operational data from PostgreSQL is loaded nightly via an ETL pipeline into a star schema optimized for aggregation queries (bed occupancy by department, cost per admission, revenue by payer). Columnar storage and MPP query engines in these warehouses deliver fast GROUP BY and window function performance on millions of rows.

**Goal 4 — Real-time ICU vitals streaming** uses **Apache Kafka** for ingestion (handles high-throughput write bursts from hundreds of monitoring devices) feeding into a **time-series database (InfluxDB or TimescaleDB)**. Time-series databases are purpose-built for sensor data: they compress time-ordered readings efficiently, support downsampling and retention policies, and enable fast range queries like "show heart rate every 5 seconds for the last 2 hours".

---

## OLTP vs OLAP Boundary

The transactional (OLTP) system ends at the PostgreSQL layer. All day-to-day clinical operations — registering admissions, recording diagnoses, updating medications, billing — are writes to PostgreSQL. This database is optimized for low-latency, high-concurrency row-level operations and must maintain ACID integrity at all times.

The analytical (OLAP) system begins at the Data Warehouse (Redshift/BigQuery). A nightly ETL job extracts changed records from PostgreSQL, applies transformations (standardizing ICD codes, aggregating admission costs), and loads them into the warehouse's star schema. Analysts and managers query only the warehouse, never the production PostgreSQL instance. This separation ensures that heavy analytical queries (full table scans, multi-table joins across millions of rows) never compete with clinical staff entering patient data, protecting response time and consistency in the operational system.

---

## Trade-offs

**Trade-off: Data Freshness vs. Operational Isolation**

The nightly ETL batch load into the data warehouse means management reports are always 12–24 hours stale. A CFO running a bed-occupancy report at 9 AM is seeing yesterday's numbers. For some decisions this is acceptable; for operational decisions like emergency staffing, it is not.

**Mitigation:** Introduce a **Lambda Architecture** layer: in addition to the nightly batch load, implement a real-time streaming pipeline (Kafka → Apache Flink → a materialized view layer in the warehouse) that continuously refreshes a subset of high-priority metrics — current bed occupancy, today's admissions, ICU capacity — with a latency of under 5 minutes. The batch pipeline remains the source of truth for historical reports and billing; the streaming layer serves operational dashboards. This dual-path approach adds engineering complexity but eliminates the staleness problem for the metrics that matter most to real-time hospital operations.
