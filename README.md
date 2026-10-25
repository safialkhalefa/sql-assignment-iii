
```markdown
# 🏥 Assignment III: SQL Table Manipulation
> **Course Work Report** — Relational Database Management Systems with PostgreSQL

---

## 📋 Metadata & Student Profile

| Field | Details |
| :--- | :--- |
| **Project Title** | Pharmacy Inventory and Sales Management System |
| **Student Name** | Safi Alkhalefa |
| **Student ID** | `[Your Student ID]` |
| **Business Domain**| Pharmaceutical & Retail Inventory |
| **Database Engine** | PostgreSQL 15+ |
| **Target Database** | `safialkhalefa_[your_student_id]_pharmacy_system` |
| **Instructor** | Eric Maniraguha |
| **Institution** | Kigali Independent University (ULK) |

---

## 📑 Table of Contents
1. [System Architecture & Schema Design](#1-system-architecture--schema-design)
   - [Database Entities](#11-database-entities)
   - [Keys & Referential Integrity](#12-keys--referential-integrity)
   - [Entity-Relationship Diagram (ERD)](#13-entity-relationship-diagram-erd)
2. [DDL: Database & Table Creation](#2-ddl-database--table-creation)
3. [DML: Seed Data Insertion](#3-dml-seed-data-insertion)
4. [Practical SQL Tasks](#4-practical-sql-tasks)
   - [Task 1: SELECT Queries (Retrieval & Filtering)](#task-1-select-queries-retrieval--filtering)
   - [Task 2: JOIN Operations (Relational Analysis)](#task-2-join-operations-relational-analysis)
   - [Task 3: UPDATE Operations (Data Maintenance)](#task-3-update-operations-data-maintenance)
   - [Task 4: ALTER TABLE (Schema Evolution)](#task-4-alter-table-schema-evolution)
   - [Task 5: INSERT Operations (Lifecycle Integration)](#task-5-insert-operations-lifecycle-integration)
5. [Conclusion & Key Takeaways](#5-conclusion--key-takeaways)

---

## 1. System Architecture & Schema Design

### 1.1 Database Entities

| Table | Role | Description |
| :--- | :---: | :--- |
| `categories` | **Parent** | Catalogs drug classifications (e.g., Antibiotics, Analgesics, Vitamins). |
| `medicines` | **Parent / Child** | Core inventory catalog containing pricing, stock units, and category links. |
| `sales` | **Child** | Transaction logs mapping customer sales to inventory records. |

### 1.2 Keys & Referential Integrity

```
```
[ categories ] (1) <--- (N) [ medicines ] (1) <--- (N) [ sales ]


* **`categories.category_id`** `[PK]`: Auto-incrementing unique identifier.
* **`medicines.medicine_id`** `[PK]`: Auto-incrementing unique inventory item ID.
* **`medicines.category_id`** `[FK]`: References `categories(category_id)`
  * *Policy:* `ON DELETE RESTRICT ON UPDATE CASCADE`
* **`sales.sale_id`** `[PK]`: Auto-incrementing transaction invoice number.
* **`sales.medicine_id`** `[FK]`: References `medicines(medicine_id)`
  * *Policy:* `ON DELETE RESTRICT ON UPDATE CASCADE`
```
```
### 1.3 Entity-Relationship Diagram (ERD)
> Generated via pgAdmin 4 prior to structural schema modifications.


+------------------+         +--------------------+         +--------------------+
|    categories    |         |     medicines      |         |       sales        |
+------------------+         +--------------------+         +--------------------+
| PK category_id   |<---+    | PK medicine_id     |<---+    | PK sale_id         |
|    category_name |    +---o| FK category_id     |    +---o| FK medicine_id     |
|    description   |         |    medicine_name   |         |    customer_name   |
+------------------+         |    unit_price      |         |    quantity_sold   |
                             |    stock_quantity  |         |    sale_date       |
                             +--------------------+         +--------------------+


![ERD](erd.png)

---

## 2. DDL: Database & Table Creation

### 2.1 Database Initialization
```sql
CREATE DATABASE safialkhalefa_pharmacy_system;


### 2.2 Table Schemas & Constraints
```sql
-- 1. Parent Table: Drug Categories
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT
);

-- 2. Child Table: Medicines Inventory
CREATE TABLE medicines (
    medicine_id    SERIAL PRIMARY KEY,
    medicine_name  VARCHAR(150) NOT NULL,
    unit_price     NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    category_id    INT NOT NULL,
    CONSTRAINT fk_medicines_categories 
        FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

-- 3. Grandchild Table: Sales Ledger
CREATE TABLE sales (
    sale_id       SERIAL PRIMARY KEY,
    medicine_id   INT NOT NULL,
    customer_name VARCHAR(120) NOT NULL,
    quantity_sold INT NOT NULL CHECK (quantity_sold > 0),
    sale_date     DATE NOT NULL,
    CONSTRAINT fk_sales_medicines 
        FOREIGN KEY (medicine_id) 
        REFERENCES medicines(medicine_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);




## 3. DML: Seed Data Insertion

> Records are seeded strictly in **parent-to-child** order to respect foreign key dependencies.

```sql
-- Step 1: Categories
INSERT INTO categories (category_name, description) VALUES
('Antibiotics',    'Medicines that inhibit the growth of or destroy microorganisms'),
('Painkillers',    'Analgesic drugs used to achieve relief from pain'),
('Vitamins',       'Nutritional supplements that support human growth and health'),
('Antihistamines', 'Medications used to treat allergy symptoms'),
('Antacids',       'Agents that neutralize stomach acidity to relieve heartburn');

-- Step 2: Medicines
INSERT INTO medicines (medicine_name, unit_price, stock_quantity, category_id) VALUES
('Amoxicillin 500mg', 12.50,  80, 1),
('Paracetamol 500mg',  3.00, 200, 2),
('Ibuprofen 400mg',    5.50, 150, 2),
('Vitamin C 1000mg',   8.00,  95, 3),
('Cetirizine 10mg',    4.50,  40, 4);

-- Step 3: Sales
INSERT INTO sales (medicine_id, customer_name, quantity_sold, sale_date) VALUES
(1, 'Jean Paul Mugisha', 2, '2026-10-24'),
(2, 'Claire Ingabire',   4, '2026-10-24'),
(2, 'David Habimana',    1, '2026-10-25'),
(3, 'Grace Uwera',       3, '2026-10-25'),
(4, 'Emmanuel Ndahiro',  2, '2026-10-25');


---

## 4. Practical SQL Tasks

### Task 1: SELECT Queries (Retrieval & Filtering)

#### 🔹 Q1.1 · Basic Data Retrieval
* **Goal:** Extract product names, pricing, and current stock counts.
* **SQL:**
  ```sql
  SELECT medicine_name, unit_price, stock_quantity 
  FROM medicines;
  
* **Output Evidence:**  
  ![Q1.1 Result](screenshots/q1_1.png)
* **Technical Note:** Selects only customer-facing attributes without exposing internal surrogate keys.

---

#### 🔹 Q1.2 · Conditional Filtering (`WHERE` + `AND`)
* **Goal:** Identify low-stock items (`< 100`) priced above `$5.00` for restocking priority.
* **SQL:**
  ```sql
  SELECT medicine_name, unit_price, stock_quantity 
  FROM medicines 
  WHERE unit_price > 5.00 
    AND stock_quantity < 100;
  
* **Output Evidence:**  
  ![Q1.2 Result](screenshots/q1_2.png)
* **Technical Note:** Combines comparison operators to isolate high-value items requiring immediate reorder.

---

#### 🔹 Q1.3 · Result Set Sorting (`ORDER BY DESC`)
* **Goal:** Sort the entire inventory catalog from highest unit price to lowest.
* **SQL:**
  ```sql
  SELECT medicine_id, medicine_name, unit_price, stock_quantity 
  FROM medicines 
  ORDER BY unit_price DESC;
  
* **Output Evidence:**  
  ![Q1.3 Result](screenshots/q1_3.png)
* **Technical Note:** Orders rows descending based on numeric valuation.

---

### Task 2: JOIN Operations (Relational Analysis)

#### 🔹 Q2.1 · Two-Table `INNER JOIN`
* **Goal:** Match each medicine with its parent classification name.
* **SQL:**
  ```sql
  SELECT 
      m.medicine_id, 
      m.medicine_name, 
      m.unit_price, 
      c.category_name
  FROM medicines m
  INNER JOIN categories c 
      ON m.category_id = c.category_id;
  
* **Output Evidence:**  
  ![Q2.1 Result](screenshots/q2_1.png)
* **Technical Note:** Returns only records with matches in both tables, omitting unlinked records.

---

#### 🔹 Q2.2 · Outer Relational Lookup (`LEFT JOIN`)
* **Goal:** Display every category regardless of whether it currently contains listed medications.
* **SQL:**
  ```sql
  SELECT 
      c.category_name, 
      m.medicine_name, 
      m.unit_price
  FROM categories c
  LEFT JOIN medicines m 
      ON c.category_id = m.category_id;
  
* **Output Evidence:**  
  ![Q2.2 Result](screenshots/q2_2.png)
* **Technical Note:** Preserves categories such as *Antacids* by returning `NULL` for missing medicine fields.

---

#### 🔹 Q2.3 · Multi-Table Join & Calculated Fields
* **Goal:** Build an itemized sales audit log combining transaction, product, and category details.
* **SQL:**
  ```sql
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
  INNER JOIN medicines m  ON s.medicine_id = m.medicine_id
  INNER JOIN categories c ON m.category_id = c.category_id
  ORDER BY s.sale_date ASC;
  
* **Output Evidence:**  
  ![Q2.3 Result](screenshots/q2_3.png)
* **Technical Note:** Demonstrates 3-table traversal with runtime dynamic computation (`total_amount`).

---

### Task 3: UPDATE Operations (Data Maintenance)

#### 🔹 Q3.1 · Targeted Single-Row Mutation
* **Goal:** Adjust unit price of *Paracetamol 500mg* (`ID: 2`) from `3.00` to `3.50`.
* **Execution:**
  ```sql
  UPDATE medicines
  SET unit_price = 3.50
  WHERE medicine_id = 2;
  
* **Verification:**
  ```sql
  SELECT medicine_id, medicine_name, unit_price 
  FROM medicines 
  WHERE medicine_id = 2;
  
* **Output Evidence:**  
  ![Q3.1 Result](screenshots/q3_1.png)

---

#### 🔹 Q3.2 · Bulk Batch Update
* **Goal:** Increment inventory by `+30 units` for any product falling below `50` units.
* **Execution:**
  ```sql
  UPDATE medicines
  SET stock_quantity = stock_quantity + 30
  WHERE stock_quantity < 50;
  
* **Verification:**
  ```sql
  SELECT medicine_id, medicine_name, stock_quantity 
  FROM medicines;
  
* **Output Evidence:**  
  ![Q3.2 Result](screenshots/q3_2.png)

---

#### 🔹 Q3.3 · Business Logic Update with Calculations
* **Goal:** Apply a promotional 10% price markdown across all *Painkillers* (`category_id = 2`).
* **Execution:**
  ```sql
  UPDATE medicines
  SET unit_price = ROUND(unit_price * 0.90, 2)
  WHERE category_id = 2;
  
* **Verification:**
  ```sql
  SELECT medicine_id, medicine_name, unit_price, category_id 
  FROM medicines 
  WHERE category_id = 2;
  
* **Output Evidence:**  
  ![Q3.3 Result](screenshots/q3_3.png)

---

### Task 4: ALTER TABLE (Schema Evolution)

#### 🔹 Q4.1 · Rename Column
* **Goal:** Improve column naming semantics by updating `description` to `category_description`.
* **Execution:**
  ```sql
  ALTER TABLE categories 
  RENAME COLUMN description TO category_description;
  
* **Verification:**
  ```sql
  SELECT category_id, category_name, category_description 
  FROM categories 
  LIMIT 3;
  
* **Output Evidence:**  
  ![Q4.1 Result](screenshots/q4_1.png)

---

#### 🔹 Q4.2 · Widen Column Precision
* **Goal:** Expand `customer_name` capacity in `sales` from `VARCHAR(120)` to `VARCHAR(180)`.
* **Execution:**
  ```sql
  ALTER TABLE sales 
  ALTER COLUMN customer_name TYPE VARCHAR(180);
  
* **Verification (Schema Metadata):**
  ```sql
  SELECT column_name, data_type, character_maximum_length 
  FROM information_schema.columns 
  WHERE table_name = 'sales' AND column_name = 'customer_name';
  
* **Output Evidence:**  
  ![Q4.2 Result](screenshots/q4_2.png)

---

#### 🔹 Q4.3 · Add Column with Default
* **Goal:** Add trackable `expiry_date` column defaulting to `'2028-12-31'`.
* **Execution:**
  ```sql
  ALTER TABLE medicines 
  ADD COLUMN expiry_date DATE DEFAULT '2028-12-31';
  
* **Verification:**
  ```sql
  SELECT medicine_id, medicine_name, expiry_date 
  FROM medicines 
  LIMIT 3;
  
* **Output Evidence:**  
  ![Q4.3 Result](screenshots/q4_3.png)

---

### Task 5: INSERT Operations (Lifecycle Integration)

#### 🔹 Q5.1 · Single Parent Insert
* **Goal:** Add a new classification entry (`Cardiovascular`).
* **Execution:**
  ```sql
  INSERT INTO categories (category_name, category_description) 
  VALUES ('Cardiovascular', 'Drugs used to treat conditions of the heart and blood vessels');
  
* **Verification:**
  ```sql
  SELECT * FROM categories WHERE category_name = 'Cardiovascular';
  
* **Output Evidence:**  
  ![Q5.1 Result](screenshots/q5_1.png)

---

#### 🔹 Q5.2 · Multi-Row Child Insert
* **Goal:** Seed multiple new medicine records referencing both existing and newly added categories.
* **Execution:**
  ```sql
  INSERT INTO medicines (medicine_name, unit_price, stock_quantity, category_id, expiry_date) 
  VALUES
  ('Amlodipine 5mg',   9.50,  60, 6, '2028-06-30'),
  ('Omeprazole 20mg',  6.00, 110, 5, '2027-11-15');
  
* **Verification:**
  ```sql
  SELECT * FROM medicines 
  WHERE medicine_name IN ('Amlodipine 5mg', 'Omeprazole 20mg');
  
* **Output Evidence:**  
  ![Q5.2 Result](screenshots/q5_2.png)

---

#### 🔹 Q5.3 · Transactional Grandchild Insert
* **Goal:** Record a sales receipt pointing to newly registered inventory item (`medicine_id = 6`).
* **Execution:**
  ```sql
  INSERT INTO sales (medicine_id, customer_name, quantity_sold, sale_date) 
  VALUES (6, 'Patrick Kayitare', 1, '2026-10-26');
  
* **Verification:**
  ```sql
  SELECT 
      s.sale_id, 
      s.customer_name, 
      s.quantity_sold, 
      m.medicine_name, 
      s.sale_date
  FROM sales s
  INNER JOIN medicines m ON s.medicine_id = m.medicine_id
  WHERE s.customer_name = 'Patrick Kayitare';
  
* **Output Evidence:**  
  ![Q5.3 Result](screenshots/q5_3.png)

---

## 5. Conclusion & Key Takeaways

Through this assignment, a complete relational model for a **Pharmacy Inventory and Sales System** was established and manipulated using PostgreSQL:

1. **Relational Integrity:** Implemented explicit `PRIMARY KEY` and `FOREIGN KEY` constraints configured with `ON DELETE RESTRICT ON UPDATE CASCADE`, guaranteeing orphan records cannot be generated.
2. **Data Querying & Aggregation:** Utilized conditional filters (`WHERE`, `AND`), result sorting (`ORDER BY`), and both `INNER` and `LEFT` joins to answer operational business questions.
3. **Lifecycle Operations:** Performed safe single and batch updates, live schema alterations (`ALTER TABLE`), and verified end-to-end data insertion across all dependent entities.
```
