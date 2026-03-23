-- ============================================================
-- Part 1 — RDBMS Schema Design (3NF)
-- Normalized from orders_flat.csv
-- ============================================================

-- Drop tables in reverse dependency order (if re-running)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sales_reps;

-- ============================================================
-- Table: sales_reps
-- Stores sales representative details independently of orders.
-- Eliminates update anomaly: office_address stored once per rep.
-- ============================================================
CREATE TABLE sales_reps (
    sales_rep_id   VARCHAR(10)  NOT NULL,
    sales_rep_name VARCHAR(100) NOT NULL,
    sales_rep_email VARCHAR(150) NOT NULL,
    office_address VARCHAR(255) NOT NULL,
    CONSTRAINT pk_sales_reps PRIMARY KEY (sales_rep_id)
);

INSERT INTO sales_reps (sales_rep_id, sales_rep_name, sales_rep_email, office_address) VALUES
('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001'),
('SR04', 'Meena Pillai', 'meena@corp.com',  'South Zone, Anna Salai, Chennai - 600002'),
('SR05', 'Suresh Rao',   'suresh@corp.com', 'East Zone, Park Street, Kolkata - 700016');

-- ============================================================
-- Table: customers
-- Stores customer information independently of orders.
-- Eliminates delete anomaly: customers survive order deletion.
-- Eliminates insert anomaly: customers can be added without orders.
-- ============================================================
CREATE TABLE customers (
    customer_id    VARCHAR(10)  NOT NULL,
    customer_name  VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    customer_city  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

INSERT INTO customers (customer_id, customer_name, customer_email, customer_city) VALUES
('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');

-- ============================================================
-- Table: products
-- Stores product catalogue independently of orders.
-- Eliminates insert anomaly: products can be added without orders.
-- ============================================================
CREATE TABLE products (
    product_id   VARCHAR(10)  NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(100) NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0)
);

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
('P001', 'Laptop',        'Electronics', 55000.00),
('P002', 'Mouse',         'Electronics',   800.00),
('P003', 'Desk Chair',    'Furniture',    8500.00),
('P004', 'Notebook',      'Stationery',    120.00),
('P005', 'Headphones',    'Electronics',  3200.00),
('P006', 'Standing Desk', 'Furniture',   22000.00),
('P007', 'Pen Set',       'Stationery',    250.00),
('P008', 'Webcam',        'Electronics',  2100.00);

-- ============================================================
-- Table: orders
-- Stores order header information.
-- order_id is PK; customer_id and sales_rep_id are FKs.
-- ============================================================
CREATE TABLE orders (
    order_id     VARCHAR(10) NOT NULL,
    customer_id  VARCHAR(10) NOT NULL,
    sales_rep_id VARCHAR(10) NOT NULL,
    order_date   DATE        NOT NULL,
    CONSTRAINT pk_orders     PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer  FOREIGN KEY (customer_id)  REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_sales_rep FOREIGN KEY (sales_rep_id) REFERENCES sales_reps (sales_rep_id)
);

INSERT INTO orders (order_id, customer_id, sales_rep_id, order_date) VALUES
('ORD1001', 'C001', 'SR01', '2023-01-05'),
('ORD1002', 'C002', 'SR02', '2023-01-17'),
('ORD1003', 'C003', 'SR01', '2023-01-22'),
('ORD1004', 'C004', 'SR01', '2023-02-10'),
('ORD1005', 'C005', 'SR03', '2023-02-20'),
('ORD1006', 'C006', 'SR01', '2023-03-01'),
('ORD1007', 'C001', 'SR01', '2023-03-15'),
('ORD1008', 'C007', 'SR03', '2023-04-02'),
('ORD1009', 'C008', 'SR02', '2023-04-18'),
('ORD1010', 'C002', 'SR01', '2023-05-07');

-- ============================================================
-- Table: order_items
-- Stores individual line items per order.
-- Composite PK of (order_id, product_id).
-- quantity is stored here; unit_price is a FK to products
-- (price at time of order could optionally be denormalized here
--  for historical accuracy — kept as FK for simplicity).
-- ============================================================
CREATE TABLE order_items (
    order_id   VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    quantity   INT         NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_order_items  PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders   (order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT chk_quantity     CHECK (quantity > 0),
    CONSTRAINT chk_item_price   CHECK (unit_price > 0)
);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
('ORD1001', 'P001', 2, 55000.00),
('ORD1001', 'P002', 3,   800.00),
('ORD1002', 'P005', 1,  3200.00),
('ORD1003', 'P007', 5,   250.00),
('ORD1004', 'P003', 2,  8500.00),
('ORD1005', 'P004', 4,   120.00),
('ORD1006', 'P002', 2,   800.00),
('ORD1007', 'P006', 1, 22000.00),
('ORD1008', 'P001', 1, 55000.00),
('ORD1009', 'P008', 3,  2100.00),
('ORD1010', 'P004', 5,   120.00),
('ORD1010', 'P007', 2,   250.00);
