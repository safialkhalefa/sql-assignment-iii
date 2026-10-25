-- =============================================================================
-- ASSIGNMENT III: SQL TABLE MANIPULATION
-- Institution: Kigali Independent University (ULK)
-- Instructor: Eric Maniraguha
-- Business Idea: Pharmacy Management System
-- Selected DBMS: PostgreSQL
-- =============================================================================

-- =============================================================================
-- 1. DATABASE CREATION
-- =============================================================================
-- Note: Replace with your actual database name if different
-- CREATE DATABASE yourname_studentid_pharmacy_system;

-- =============================================================================
-- 2. TABLE CREATION AND CONSTRAINTS
-- =============================================================================

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS categories;

-- Parent Table 1: categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Child Table 1 / Parent Table 2: medicines
CREATE TABLE medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(150) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    category_id INT NOT NULL,
    CONSTRAINT fk_medicines_categories FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Child Table 2: sales
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    medicine_id INT NOT NULL,
    customer_name VARCHAR(120) NOT NULL,
    quantity_sold INT NOT NULL CHECK (quantity_sold > 0),
    sale_date DATE NOT NULL,
    CONSTRAINT fk_sales_medicines FOREIGN KEY (medicine_id) 
        REFERENCES medicines(medicine_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =============================================================================
-- 3. INITIAL DATA INSERTION (At least 5 records per table)
-- =============================================================================

INSERT INTO categories (category_name, description) VALUES
('Antibiotics', 'Medicines that inhibit the growth of or destroy microorganisms'),
('Painkillers', 'Analgesic drugs used to achieve relief from pain'),
('Vitamins', 'Nutritional supplements that support human growth and health'),
('Antihistamines', 'Medications used to treat allergy symptoms'),
('Antacids', 'Agents that neutralize stomach acidity to relieve heartburn');

INSERT INTO medicines (medicine_name, unit_price, stock_quantity, category_id) VALUES
('Amoxicillin 500mg', 12.50, 80, 1),
('Paracetamol 500mg', 3.00, 200, 2),
('Ibuprofen 400mg', 5.50, 150, 2),
('Vitamin C 1000mg', 8.00, 95, 3),
('Cetirizine 10mg', 4.50, 40, 4);

INSERT INTO sales (medicine_id, customer_name, quantity_sold, sale_date) VALUES
(1, 'Jean Paul Mugisha', 2, '2026-10-24'),
(2, 'Claire Ingabire', 4, '2026-10-24'),
(2, 'David Habimana', 1, '2026-10-25'),
(3, 'Grace Uwera', 3, '2026-10-25'),
(4, 'Emmanuel Ndahiro', 2, '2026-10-25');

-- =============================================================================
-- 4. SELECT TASKS
-- =============================================================================

-- Q1.1: Basic Data Retrieval
SELECT medicine_name, unit_price, stock_quantity 
FROM medicines;

-- Q1.2: Conditional Data Retrieval
SELECT medicine_name, unit_price, stock_quantity 
FROM medicines 
WHERE unit_price > 5.00 AND stock_quantity < 100;

-- Q1.3: Sorted Data Retrieval
SELECT medicine_id, medicine_name, unit_price, stock_quantity 
FROM medicines 
ORDER BY unit_price DESC;

-- =============================================================================
-- 5. JOIN TASKS
-- =============================================================================

-- Q2.1: INNER JOIN
SELECT m.medicine_id, m.medicine_name, m.unit_price, c.category_name
FROM medicines m
INNER JOIN categories c ON m.category_id = c.category_id;

-- Q2.2: LEFT JOIN
SELECT c.category_name, m.medicine_name, m.unit_price
FROM categories c
LEFT JOIN medicines m ON c.category_id = m.category_id;

-- Q2.3: Multi-Table JOIN
SELECT 
    s.sale_id,
    s.sale_date,
    s.customer_name,
    m.medicine_name,
    c.category_name,
    s.quantity_sold,
    m.unit_price,
    (s.quantity_sold * m.unit_price) AS total_amount
FROM sales s
INNER JOIN medicines m ON s.medicine_id = m.medicine_id
INNER JOIN categories c ON m.category_id = c.category_id
ORDER BY s.sale_date ASC;

-- =============================================================================
-- 6. UPDATE TASKS AND VERIFICATION
-- =============================================================================

-- Q3.1: Update One Record
UPDATE medicines
SET unit_price = 3.50
WHERE medicine_id = 2;

-- Verification Q3.1:
SELECT medicine_id, medicine_name, unit_price 
FROM medicines 
WHERE medicine_id = 2;

-- Q3.2: Update Multiple Records
UPDATE medicines
SET stock_quantity = stock_quantity + 30
WHERE stock_quantity < 50;

-- Verification Q3.2:
SELECT medicine_id, medicine_name, stock_quantity 
FROM medicines;

-- Q3.3: Conditional Update (Business Rule)
UPDATE medicines
SET unit_price = ROUND(unit_price * 0.90, 2)
WHERE category_id = 2;

-- Verification Q3.3:
SELECT medicine_id, medicine_name, unit_price, category_id 
FROM medicines 
WHERE category_id = 2;

-- =============================================================================
-- 7. ALTER TABLE TASKS AND VERIFICATION
-- =============================================================================

-- Q4.1: Rename a Column
ALTER TABLE categories 
RENAME COLUMN description TO category_description;

-- Verification Q4.1:
SELECT category_id, category_name, category_description 
FROM categories 
LIMIT 3;

-- Q4.2: Change a Column's Data Type
ALTER TABLE sales 
ALTER COLUMN customer_name TYPE VARCHAR(180);

-- Verification Q4.2:
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'sales' AND column_name = 'customer_name';

-- Q4.3: Add a Column
ALTER TABLE medicines 
ADD COLUMN expiry_date DATE DEFAULT '2028-12-31';

-- Verification Q4.3:
SELECT medicine_id, medicine_name, expiry_date 
FROM medicines 
LIMIT 3;

-- =============================================================================
-- 8. ADDITIONAL INSERT TASKS AND VERIFICATION
-- =============================================================================

-- Q5.1: Insert a Single Record
INSERT INTO categories (category_name, category_description) 
VALUES ('Cardiovascular', 'Drugs used to treat conditions of the heart and blood vessels');

-- Verification Q5.1:
SELECT * FROM categories WHERE category_name = 'Cardiovascular';

-- Q5.2: Insert Multiple Records
INSERT INTO medicines (medicine_name, unit_price, stock_quantity, category_id, expiry_date) VALUES
('Amlodipine 5mg', 9.50, 60, 6, '2028-06-30'),
('Omeprazole 20mg', 6.00, 110, 5, '2027-11-15');

-- Verification Q5.2:
SELECT * FROM medicines WHERE medicine_name IN ('Amlodipine 5mg', 'Omeprazole 20mg');

-- Q5.3: Insert a Related Record
INSERT INTO sales (medicine_id, customer_name, quantity_sold, sale_date) 
VALUES (6, 'Patrick Kayitare', 1, '2026-10-26');

-- Verification Q5.3:
SELECT s.sale_id, s.customer_name, s.quantity_sold, m.medicine_name, s.sale_date
FROM sales s
INNER JOIN medicines m ON s.medicine_id = m.medicine_id
WHERE s.customer_name = 'Patrick Kayitare';