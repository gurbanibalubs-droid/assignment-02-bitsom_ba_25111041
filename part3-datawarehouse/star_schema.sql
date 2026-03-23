-- ============================================================
-- Part 3 — Data Warehouse Star Schema
-- Source: retail_transactions.csv
-- Design: Star Schema with fact_sales + 3 dimension tables
-- ============================================================

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- ============================================================
-- Dimension Table: dim_date
-- Pre-populated date dimension for fast time-based aggregation.
-- Extracts year, month, quarter, weekday from the date key.
-- ============================================================
CREATE TABLE dim_date (
    date_key     INT          NOT NULL,   -- surrogate key: YYYYMMDD
    full_date    DATE         NOT NULL,
    day          INT          NOT NULL,
    month        INT          NOT NULL,
    month_name   VARCHAR(20)  NOT NULL,
    quarter      INT          NOT NULL,
    year         INT          NOT NULL,
    weekday_name VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

INSERT INTO dim_date (date_key, full_date, day, month, month_name, quarter, year, weekday_name) VALUES
(20230115, '2023-01-15', 15, 1,  'January',   1, 2023, 'Sunday'),
(20230220, '2023-02-20', 20, 2,  'February',  1, 2023, 'Monday'),
(20230331, '2023-03-31', 31, 3,  'March',     1, 2023, 'Friday'),
(20230428, '2023-04-28', 28, 4,  'April',     2, 2023, 'Friday'),
(20230521, '2023-05-21', 21, 5,  'May',       2, 2023, 'Sunday'),
(20230612, '2023-06-12', 12, 6,  'June',      2, 2023, 'Monday'),
(20230715, '2023-07-15', 15, 7,  'July',      3, 2023, 'Saturday'),
(20230812, '2023-08-12', 12, 8,  'August',    3, 2023, 'Saturday'),
(20230829, '2023-08-29', 29, 8,  'August',    3, 2023, 'Tuesday'),
(20230908, '2023-09-08',  8, 9,  'September', 3, 2023, 'Friday'),
(20231020, '2023-10-20', 20, 10, 'October',   4, 2023, 'Friday'),
(20231118, '2023-11-18', 18, 11, 'November',  4, 2023, 'Saturday'),
(20231212, '2023-12-12', 12, 12, 'December',  4, 2023, 'Tuesday');

-- ============================================================
-- Dimension Table: dim_store
-- One row per store branch. Eliminates store info redundancy.
-- ============================================================
CREATE TABLE dim_store (
    store_key    INT          NOT NULL,   -- surrogate key
    store_name   VARCHAR(100) NOT NULL,
    store_city   VARCHAR(100) NOT NULL,
    store_region VARCHAR(100) NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

INSERT INTO dim_store (store_key, store_name, store_city, store_region) VALUES
(1, 'Chennai Anna',    'Chennai',   'South'),
(2, 'Delhi South',     'Delhi',     'North'),
(3, 'Bangalore MG',    'Bangalore', 'South'),
(4, 'Pune FC Road',    'Pune',      'West'),
(5, 'Mumbai Central',  'Mumbai',    'West');

-- ============================================================
-- Dimension Table: dim_product
-- One row per product. Cleaned & standardized category casing.
-- ============================================================
CREATE TABLE dim_product (
    product_key  INT          NOT NULL,   -- surrogate key
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(100) NOT NULL,   -- standardized: Electronics / Clothing / Groceries
    unit_price   DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

INSERT INTO dim_product (product_key, product_name, category, unit_price) VALUES
(1,  'Smartwatch',   'Electronics', 58851.01),
(2,  'Tablet',       'Electronics', 23226.12),
(3,  'Phone',        'Electronics', 48703.39),
(4,  'Speaker',      'Electronics', 49262.78),
(5,  'Laptop',       'Electronics', 42343.15),
(6,  'Headphones',   'Electronics', 15999.00),
(7,  'Jeans',        'Clothing',     2317.47),
(8,  'Jacket',       'Clothing',    30187.24),
(9,  'Saree',        'Clothing',     5499.00),
(10, 'T-Shirt',      'Clothing',     1499.00),
(11, 'Atta 10kg',    'Groceries',   52464.00),
(12, 'Biscuits',     'Groceries',   27469.99),
(13, 'Milk 1L',      'Groceries',   43374.39),
(14, 'Rice 5kg',     'Groceries',   36000.00),
(15, 'Oil 1L',       'Groceries',   18500.00),
(16, 'Pulses 1kg',   'Groceries',   12000.00);

-- ============================================================
-- Fact Table: fact_sales
-- Central table with numeric measures and FK references.
-- Grain: one row per retail transaction.
-- ============================================================
CREATE TABLE fact_sales (
    sale_id        VARCHAR(20)    NOT NULL,
    date_key       INT            NOT NULL,
    store_key      INT            NOT NULL,
    product_key    INT            NOT NULL,
    customer_id    VARCHAR(20)    NOT NULL,
    units_sold     INT            NOT NULL,
    unit_price     DECIMAL(10,2)  NOT NULL,
    total_revenue  DECIMAL(12,2)  NOT NULL,   -- derived: units_sold * unit_price
    CONSTRAINT pk_fact_sales    PRIMARY KEY (sale_id),
    CONSTRAINT fk_fact_date     FOREIGN KEY (date_key)    REFERENCES dim_date    (date_key),
    CONSTRAINT fk_fact_store    FOREIGN KEY (store_key)   REFERENCES dim_store   (store_key),
    CONSTRAINT fk_fact_product  FOREIGN KEY (product_key) REFERENCES dim_product (product_key),
    CONSTRAINT chk_units        CHECK (units_sold > 0),
    CONSTRAINT chk_revenue      CHECK (total_revenue > 0)
);

-- 12 cleaned fact rows (date formats standardized, categories normalized, NULL cities imputed)
INSERT INTO fact_sales (sale_id, date_key, store_key, product_key, customer_id, units_sold, unit_price, total_revenue) VALUES
('TXN5000', 20230829, 1, 4,  'CUST045', 3,  49262.78, 147788.34),
('TXN5001', 20231212, 1, 2,  'CUST021', 11, 23226.12, 255487.32),
('TXN5002', 20230521, 1, 3,  'CUST019', 20, 48703.39, 974067.80),
('TXN5003', 20230220, 2, 2,  'CUST007', 14, 23226.12, 325165.68),
('TXN5004', 20230115, 1, 1,  'CUST004', 10, 58851.01, 588510.10),
('TXN5005', 20230908, 3, 11, 'CUST027', 12, 52464.00, 629568.00),
('TXN5006', 20230331, 4, 1,  'CUST025', 6,  58851.01, 353106.06),
('TXN5007', 20231020, 4, 7,  'CUST041', 16,  2317.47,  37079.52),
('TXN5008', 20230812, 3, 12, 'CUST030', 9,  27469.99, 247229.91),
('TXN5009', 20230812, 3, 1,  'CUST020', 3,  58851.01, 176553.03),
('TXN5010', 20230428, 1, 8,  'CUST031', 15, 30187.24, 452808.60),
('TXN5011', 20231020, 5, 7,  'CUST045', 13,  2317.47,  30127.11),
('TXN5012', 20230521, 3, 5,  'CUST044', 13, 42343.15, 550460.95),
('TXN5013', 20230428, 5, 13, 'CUST015', 10, 43374.39, 433743.90),
('TXN5014', 20231118, 2, 8,  'CUST042', 5,  30187.24, 150936.20);
