```markdown
# Assignment III: SQL Table Manipulation

## Section 1: Project Overview
* **Project Title:** Pharmacy Inventory and Sales Management System
* **Student Name:** Safi Alkhalefa
* **Student ID:** [Your Student ID]
* **Chosen Business Idea:** Pharmacy Management System
* **Selected DBMS:** PostgreSQL
* **Instructor:** Eric Maniraguha
* **Institution:** Kigali Independent University (ULK)

---

## Section 2: Database and Table Design

### 2.1 Database Name
`safialkhalefa_[your_student_id]_pharmacy_system`

### 2.2 Table Descriptions and Purposes
1. **`categories` (Parent Table):** Stores distinct pharmaceutical drug classifications (e.g., Antibiotics, Painkillers, Vitamins).
2. **`medicines` (Child of `categories`, Parent of `sales`):** Catalogs individual pharmaceutical products, pricing, stock levels, and references the category it belongs to.
3. **`sales` (Child of `medicines`):** Records patient/customer transactions, referencing the medicine sold, quantity, and date.

### 2.3 Primary and Foreign Key Relationships
* **`categories.category_id` (PK):** Auto-generated unique identifier for each category.
* **`medicines.medicine_id` (PK):** Auto-generated unique identifier for each medication.
* **`medicines.category_id` (FK):** References `categories(category_id)` to maintain category classification (`ON DELETE RESTRICT ON UPDATE CASCADE`).
* **`sales.sale_id` (PK):** Auto-generated unique identifier for each transaction.
* **`sales.medicine_id` (FK):** References `medicines(medicine_id)` ensuring sales records point to valid stock items (`ON DELETE RESTRICT ON UPDATE CASCADE`).

### 2.4 Entity-Relationship Diagram (ERD)
The ERD was generated directly from pgAdmin 4 prior to running `ALTER TABLE` modifications:

![ERD](erd.png)

---

## Section 3: Database and Table Creation

### 3.1 Database Creation Statement
```sql
CREATE DATABASE safialkhalefa_pharmacy_system;
```

### 3.2 Table Creation Statements
```sql
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(150) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    category_id INT NOT NULL,
    CONSTRAINT fk_medicines_categories FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    medicine_id INT NOT NULL,
    customer_name VARCHAR(120) NOT NULL,
    quantity_sold INT NOT NULL CHECK (quantity_sold > 0),
    sale_date DATE NOT NULL,
    CONSTRAINT fk_sales_medicines FOREIGN KEY (medicine_id) 
        REFERENCES medicines(medicine_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);
```

---

## Section 4: Initial Data Insertion

Five initial records were inserted into each table in parent-to-child sequence:

```sql
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
```

---

## Section 5: SQL Practical Tasks

### 5.1 SELECT — Data Retrieval

#### Q1.1: Basic Data Retrieval
* **Objective:** Retrieve `medicine_name`, `unit_price`, and `stock_quantity` from the `medicines` table.
* **SQL Statement:**
  ```sql
  SELECT medicine_name, unit_price, stock_quantity 
  FROM medicines;
  ```
* **Execution Evidence:**
  ![Q1.1 Result](screenshots/q1_1.png)
* **Explanation:** Displays current inventory pricing and stock availability without internal database keys.

---

#### Q1.2: Conditional Data Retrieval
* **Objective:** Retrieve medicines costing more than 5.00 with available stock below 100 units.
* **SQL Statement:**
  ```sql
  SELECT medicine_name, unit_price, stock_quantity 
  FROM medicines 
  WHERE unit_price > 5.00 AND stock_quantity < 100;
  ```
* **Execution Evidence:**
  ![Q1.2 Result](screenshots/q1_2.png)
* **Explanation:** Uses `WHERE` with `AND` to filter for high-value items requiring reordering.

---

#### Q1.3: Sorted Data Retrieval
* **Objective:** Retrieve all medicines ordered by `unit_price` in descending order.
* **SQL Statement:**
  ```sql
  SELECT medicine_id, medicine_name, unit_price, stock_quantity 
  FROM medicines 
  ORDER BY unit_price DESC;
  ```
* **Execution Evidence:**
  ![Q1.3 Result](screenshots/q1_3.png)
* **Explanation:** Arranges products from highest to lowest price using `ORDER BY ... DESC`.

---

### 5.2 JOIN — Retrieving Related Data

#### Q2.1: INNER JOIN
* **Objective:** Retrieve medicines along with their parent category name.
* **SQL Statement:**
  ```sql
  SELECT m.medicine_id, m.medicine_name, m.unit_price, c.category_name
  FROM medicines m
  INNER JOIN categories c ON m.category_id = c.category_id;
  ```
* **Execution Evidence:**
  ![Q2.1 Result](screenshots/q2_1.png)
* **Explanation:** Matches records across both tables, linking each product with its category.

---

#### Q2.2: LEFT JOIN
* **Objective:** Display all categories and associated medicines, preserving categories with zero products.
* **SQL Statement:**
  ```sql
  SELECT c.category_name, m.medicine_name, m.unit_price
  FROM categories c
  LEFT JOIN medicines m ON c.category_id = m.category_id;
  ```
* **Execution Evidence:**
  ![Q2.2 Result](screenshots/q2_2.png)
* **Explanation:** Preserves all records from `categories`; categories with no assigned products display `NULL` for medicine columns.

---

#### Q2.3: Multi-Table JOIN
* **Objective:** Combine `sales`, `medicines`, and `categories` into a comprehensive transaction report.
* **SQL Statement:**
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
  INNER JOIN medicines m ON s.medicine_id = m.medicine_id
  INNER JOIN categories c ON m.category_id = c.category_id
  ORDER BY s.sale_date ASC;
  ```
* **Execution Evidence:**
  ![Q2.3 Result](screenshots/q2_3.png)
* **Explanation:** Connects three tables through primary and foreign keys and calculates total amount per transaction.

---

### 5.3 UPDATE — Modifying Existing Data

#### Q3.1: Update One Record
* **Objective:** Update the unit price of Paracetamol 500mg (`medicine_id = 2`) to 3.50.
* **SQL Statement:**
  ```sql
  UPDATE medicines
  SET unit_price = 3.50
  WHERE medicine_id = 2;
  ```
* **Verification Query:**
  ```sql
  SELECT medicine_id, medicine_name, unit_price 
  FROM medicines 
  WHERE medicine_id = 2;
  ```
* **Execution Evidence:**
  ![Q3.1 Result](screenshots/q3_1.png)
* **Explanation:** Targets a single record using its primary key, updating the price safely to 3.50.

---

#### Q3.2: Update Multiple Records
* **Objective:** Restock low-inventory items by adding 30 units to any medicine with stock below 50.
* **SQL Statement:**
  ```sql
  UPDATE medicines
  SET stock_quantity = stock_quantity + 30
  WHERE stock_quantity < 50;
  ```
* **Verification Query:**
  ```sql
  SELECT medicine_id, medicine_name, stock_quantity 
  FROM medicines;
  ```
* **Execution Evidence:**
  ![Q3.2 Result](screenshots/q3_2.png)
* **Explanation:** Updates all records matching `stock_quantity < 50` simultaneously.

---

#### Q3.3: Conditional Update (Business Rule)
* **Objective:** Apply a 10% promotional discount to all Painkillers (`category_id = 2`).
* **SQL Statement:**
  ```sql
  UPDATE medicines
  SET unit_price = ROUND(unit_price * 0.90, 2)
  WHERE category_id = 2;
  ```
* **Verification Query:**
  ```sql
  SELECT medicine_id, medicine_name, unit_price, category_id 
  FROM medicines 
  WHERE category_id = 2;
  ```
* **Execution Evidence:**
  ![Q3.3 Result](screenshots/q3_3.png)
* **Explanation:** Applies a category-wide promotional discount policy to all Painkiller products.

---

### 5.4 ALTER TABLE — Modifying Table Structure

#### Q4.1: Rename a Column
* **Objective:** Rename column `description` in `categories` to `category_description`.
* **SQL Statement:**
  ```sql
  ALTER TABLE categories 
  RENAME COLUMN description TO category_description;
  ```
* **Verification Query:**
  ```sql
  SELECT category_id, category_name, category_description 
  FROM categories 
  LIMIT 3;
  ```
* **Execution Evidence:**
  ![Q4.1 Result](screenshots/q4_1.png)
* **Explanation:** Updates column naming clarity while keeping all underlying descriptions intact.

---

#### Q4.2: Change a Column's Data Type
* **Objective:** Safely widen `customer_name` in `sales` from `VARCHAR(120)` to `VARCHAR(180)`.
* **SQL Statement:**
  ```sql
  ALTER TABLE sales 
  ALTER COLUMN customer_name TYPE VARCHAR(180);
  ```
* **Verification Query:**
  ```sql
  SELECT column_name, data_type, character_maximum_length 
  FROM information_schema.columns 
  WHERE table_name = 'sales' AND column_name = 'customer_name';
  ```
* **Execution Evidence:**
  ![Q4.2 Result](screenshots/q4_2.png)
* **Explanation:** Expands the maximum allowed length of customer names without affecting existing records.

---

#### Q4.3: Add a Column
* **Objective:** Add an `expiry_date` column with a default value of `'2028-12-31'` to `medicines`.
* **SQL Statement:**
  ```sql
  ALTER TABLE medicines 
  ADD COLUMN expiry_date DATE DEFAULT '2028-12-31';
  ```
* **Verification Query:**
  ```sql
  SELECT medicine_id, medicine_name, expiry_date 
  FROM medicines 
  LIMIT 3;
  ```
* **Execution Evidence:**
  ![Q4.3 Result](screenshots/q4_3.png)
* **Explanation:** Adds an essential column to track medication shelf-life across inventory.

---

### 5.5 INSERT — Adding New Records

#### Q5.1: Insert a Single Record
* **Objective:** Insert one new category into the parent table `categories`.
* **SQL Statement:**
  ```sql
  INSERT INTO categories (category_name, category_description) 
  VALUES ('Cardiovascular', 'Drugs used to treat conditions of the heart and blood vessels');
  ```
* **Verification Query:**
  ```sql
  SELECT * FROM categories WHERE category_name = 'Cardiovascular';
  ```
* **Execution Evidence:**
  ![Q5.1 Result](screenshots/q5_1.png)
* **Explanation:** Inserts a single record into the parent table while letting the primary key auto-increment.

---

#### Q5.2: Insert Multiple Records
* **Objective:** Insert multiple new medicines in a single statement.
* **SQL Statement:**
  ```sql
  INSERT INTO medicines (medicine_name, unit_price, stock_quantity, category_id, expiry_date) VALUES
  ('Amlodipine 5mg', 9.50, 60, 6, '2028-06-30'),
  ('Omeprazole 20mg', 6.00, 110, 5, '2027-11-15');
  ```
* **Verification Query:**
  ```sql
  SELECT * FROM medicines WHERE medicine_name IN ('Amlodipine 5mg', 'Omeprazole 20mg');
  ```
* **Execution Evidence:**
  ![Q5.2 Result](screenshots/q5_2.png)
* **Explanation:** Populates multiple rows in one operation, referencing valid category foreign keys.

---

#### Q5.3: Insert a Related Record
* **Objective:** Insert a transaction referencing the newly added medicine (`medicine_id = 6`).
* **SQL Statement:**
  ```sql
  INSERT INTO sales (medicine_id, customer_name, quantity_sold, sale_date) 
  VALUES (6, 'Patrick Kayitare', 1, '2026-10-26');
  ```
* **Verification Query:**
  ```sql
  SELECT s.sale_id, s.customer_name, s.quantity_sold, m.medicine_name, s.sale_date
  FROM sales s
  INNER JOIN medicines m ON s.medicine_id = m.medicine_id
  WHERE s.customer_name = 'Patrick Kayitare';
  ```
* **Execution Evidence:**
  ![Q5.3 Result](screenshots/q5_3.png)
* **Explanation:** Inserts a record referencing a valid parent foreign key, demonstrating referential integrity.

---

## Section 6: Conclusion
In this assignment, I designed and implemented a relational database for a Pharmacy Management System using PostgreSQL. I gained hands-on experience enforcing referential integrity with primary and foreign key constraints, creating parent and child tables in proper sequence, retrieving and joining data using `INNER JOIN` and `LEFT JOIN`, safely executing conditional updates, and altering table structures with `ALTER TABLE`.
```
