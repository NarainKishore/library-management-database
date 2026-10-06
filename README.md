# 📚 Enterprise Library Management Database System (`library_db`)

[![MySQL Version](https://img.shields.io/badge/MySQL-8.0%2B-blue.svg)](https://www.mysql.com/)
[![Database Architecture](https://img.shields.io/badge/Architecture-3NF%20Normalized-brightgreen.svg)](#database-normalization--architecture)
[![Integrity](https://img.shields.io/badge/Referential%20Integrity-Cascading%20Deletes-orange.svg)](#constraint--integrity-matrix)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-grade relational database project built from scratch using MySQL. This repository demonstrates end-to-end relational data engineering: designing normalized schema structures up to 3rd Normal Form (3NF), enforcing strict domain and integrity constraints, seeding large-scale test datasets, and executing operational data retrieval spanning temporal calculations, string transformations, dynamic record modifications, and automated referential cascade handling.

> **Note:** All table definitions (DDL), sample seed fixtures (DML), and operational milestone queries are maintained in the companion file [`library_db.sql`](./library_db.sql).

---

## 📑 Table of Contents
1. [Project Overview](#-project-overview)
2. [Database Normalization & Architecture](#-database-normalization--architecture)
3. [Entity-Relationship Structure](#-entity-relationship-structure)
4. [Constraint & Integrity Matrix](#-constraint--integrity-matrix)
5. [Data Dictionary & Schema Breakdown](#-data-dictionary--schema-breakdown)
6. [Milestone Tasks & Business Analysis](#-milestone-tasks--business-analysis)
   - [Task 1: Inventory Stock & Temporal Filtering](#task-1-inventory-stock--temporal-filtering)
   - [Task 2: Active Borrowing Audit (Three-Valued Logic)](#task-2-active-borrowing-audit-three-valued-logic)
   - [Task 3: Loan Duration & Temporal Differences](#task-3-loan-duration--temporal-differences)
   - [Task 4: Patron Data Normalization & String Masking](#task-4-patron-data-normalization--string-masking)
   - [Task 5: Statutory Return Deadline Projections](#task-5-statutory-return-deadline-projections)
   - [Task 6: Dynamic Transaction State Modifications](#task-6-dynamic-transaction-state-modifications)
   - [Task 7: Cascade Deletion Verification Protocol](#task-7-cascade-deletion-verification-protocol)
7. [Repository File Structure](#-repository-file-structure)
8. [Local Installation & Verification Guide](#-local-installation--verification-guide)
9. [Key SQL Concepts Mastered](#-key-sql-concepts-mastered)

---

## 🎯 Project Overview

In production library systems, databases must handle high-concurrency transaction logging, enforce strict inventory tracking, ensure zero orphan records when catalog items or authors are expunged, and maintain patron communication records without data duplication.

This project implements **`library_db`**, an ACID-compliant transactional model providing:
- Complete mitigation of anomalies (Insertion, Deletion, Update).
- Zero unallocated child records through bidirectional cascading foreign keys.
- Automated boundary protection preventing negative inventory levels.
- Fine-grained temporal tracking computing loan longevity, return statuses, and dynamic due dates.

---

## 📐 Database Normalization & Architecture

The database architecture is designed according to relational normalization principles to minimize duplication and guarantee deterministic data consistency:

- **First Normal Form (1NF):**
  - All attributes hold strictly atomic (indivisible) scalar values (no multi-valued comma-separated lists or nested tables).
  - Column types are strictly enforced (e.g., standard ISO `DATE` formats, discrete numeric integers).
  - Every table features an explicit surrogate primary key (`*_id`).

- **Second Normal Form (2NF):**
  - Meets all 1NF conditions.
  - Completely eliminates partial dependencies: all non-key attributes are fully functionally dependent on the entire primary key, not an arbitrary subset.

- **Third Normal Form (3NF):**
  - Meets all 2NF conditions.
  - Transitive dependencies have been eliminated: no non-key attribute relies upon another non-key attribute (e.g., author nationality is decoupled from book records, patron metadata is decoupled from checkout logs).

---

## 🏛️ Entity-Relationship Structure

The relational architecture maintains clean cardinality boundaries across all four tables:

* **`authors` to `books` (1 : M):** An author can publish multiple books. Each catalog item maps back to one parent author (`authors.author_id`).
* **`books` to `loans` (1 : M):** A book title can be checked out across multiple loan events over time (`books.book_id`).
* **`members` to `loans` (1 : M):** A library patron can initiate multiple distinct loan transactions (`members.member_id`).
* **`books` and `members` (M : M Junction):** The `loans` table serves as a relational transaction bridge tracking which member borrowed which book and when.

---

## 🛡️ Constraint & Integrity Matrix

| Table | Column | Constraint Type | Business Rule / Enforced Logic |
| :--- | :--- | :--- | :--- |
| `authors` | `author_id` | `PRIMARY KEY`, `AUTO_INCREMENT` | Generates system-wide unique surrogate keys for authors. |
| `authors` | `author_name` | `NOT NULL` | Prevents catalog entry of unnamed or blank author fields. |
| `books` | `book_id` | `PRIMARY KEY`, `AUTO_INCREMENT` | Unique identifier for physical book titles. |
| `books` | `title` | `NOT NULL` | Books must possess an official catalog title. |
| `books` | `author_id` | `FOREIGN KEY` (`CASCADE`) | Links title to parent author; automatically purges books if an author is removed. |
| `books` | `available_copies` | `DEFAULT 1`, `CHECK (>= 0)` | Disallows negative inventory counts under all checkout conditions. |
| `members` | `member_id` | `PRIMARY KEY`, `AUTO_INCREMENT` | Unique patron identification number. |
| `members` | `email` | `UNIQUE`, `NOT NULL` | Guarantees single account registration per patron email address. |
| `members` | `join_date` | `NOT NULL` | Requires strict registration timestamp logging. |
| `loans` | `loan_id` | `PRIMARY KEY`, `AUTO_INCREMENT` | Transaction ledger identifier for every loan occurrence. |
| `loans` | `book_id` | `FOREIGN KEY` (`CASCADE`) | Prevents loans of nonexistent titles; purges transactions if a book is deleted. |
| `loans` | `member_id` | `FOREIGN KEY` (`CASCADE`) | Prevents loans to unregistered patrons; purges loan logs if a member is deleted. |
| `loans` | `return_date` | `NULLABLE` | Supports dynamic state: holds `NULL` while active, updated upon return. |

---

## 🗂️ Data Dictionary & Schema Breakdown

### 1. `authors` Table
Master directory containing author identities and nationality origins (15 records).
* `author_id` (`INT`, Auto Increment): Unique primary key.
* `author_name` (`VARCHAR(100)`): Author's full pen or legal name.
* `country` (`VARCHAR(50)`): Country of author nationality or publication origin.

### 2. `books` Table
Physical inventory registry managing title data and shelf availability (20 records).
* `book_id` (`INT`, Auto Increment): Unique catalog accession number.
* `title` (`VARCHAR(150)`): Full published title.
* `author_id` (`INT`): Foreign key referencing `authors.author_id`.
* `published_year` (`INT`): 4-digit Gregorian publication year.
* `available_copies` (`INT`): Current shelf count (guaranteed $\ge 0$).

### 3. `members` Table
Patron directory tracking contact info and enrollment timestamps (15 records).
* `member_id` (`INT`, Auto Increment): Library barcode identifier.
* `full_name` (`VARCHAR(100)`): Patron's full name.
* `email` (`VARCHAR(100)`): Unique contact email address.
* `join_date` (`DATE`): Enrollment date formatted as `YYYY-MM-DD`.

### 4. `loans` Table
Circulation ledger tracking physical check-out and check-in cycles (15 records).
* `loan_id` (`INT`, Auto Increment): Circulation receipt transaction number.
* `book_id` (`INT`): Foreign key referencing borrowed `books.book_id`.
* `member_id` (`INT`): Foreign key referencing borrowing `members.member_id`.
* `loan_date` (`DATE`): Date item was released from inventory.
* `return_date` (`DATE`): Date item was checked back in (`NULL` while currently out).

---

## 🔍 Milestone Tasks & Business Analysis

### Task 1: Inventory Stock & Temporal Filtering
* **Business Objective:** Retrieve all historical catalog entries published prior to `1950` with physical shelf stock ($\ge 1$), sorted from newest to oldest.
* **Demonstrated Output:**

| title | published_year | available_copies |
| :--- | :--- | :--- |
| 1984 | 1949 | 4 |
| Animal Farm | 1945 | 2 |
| And Then There Were None | 1939 | 4 |
| The Metamorphosis | 1915 | 2 |
| Adventures of Huckleberry Finn | 1884 | 3 |
| The Adventures of Tom Sawyer | 1876 | 1 |
| War and Peace | 1869 | 1 |
| Pride and Prejudice | 1813 | 5 |
| Sense and Sensibility | 1811 | 2 |

---

### Task 2: Active Borrowing Audit (Three-Valued Logic)
* **Business Objective:** Identify all items currently out on loan where no check-in date has been recorded using SQL `IS NULL`.
* **Demonstrated Output:**

| loan_id | book_id | member_id | loan_date |
| :--- | :--- | :--- | :--- |
| 2 | 3 | 2 | 2026-03-05 |
| 4 | 8 | 4 | 2026-03-10 |
| 6 | 12 | 6 | 2026-03-15 |
| 8 | 4 | 8 | 2026-03-20 |
| 10 | 14 | 10 | 2026-03-25 |
| 11 | 16 | 11 | 2026-03-28 |
| 13 | 20 | 13 | 2026-04-01 |
| 14 | 7 | 14 | 2026-04-02 |
| 15 | 9 | 15 | 2026-04-03 |

---

### Task 3: Loan Duration & Temporal Differences
* **Business Objective:** Calculate the exact elapsed days a book was kept for all completed transactions using `DATEDIFF()` against `IS NOT NULL` records.
* **Demonstrated Output:**

| loan_id | loan_date | return_date | days_kept |
| :--- | :--- | :--- | :--- |
| 1 | 2026-03-01 | 2026-03-15 | 14 |
| 3 | 2026-03-08 | 2026-03-22 | 14 |
| 5 | 2026-03-12 | 2026-03-26 | 14 |
| 7 | 2026-03-18 | 2026-03-30 | 12 |
| 9 | 2026-03-22 | 2026-04-02 | 11 |
| 12 | 2026-03-29 | 2026-04-03 | 5 |

---

### Task 4: Patron Data Normalization & String Masking
* **Business Objective:** Standardize patron names to uppercase and swap legacy `@mail.com` email domains to institutional `@library.org` domains using `UPPER()` and `REPLACE()`.
* **Demonstrated Output (Sample Excerpt):**

| member_id | member_name_upper | domain_check |
| :--- | :--- | :--- |
| 1 | ALICE JOHNSON | alice.johnson@library.org |
| 2 | BOB SMITH | bob.smith@inbox.org |
| 3 | CHARLIE BROWN | charlie.brown@reader.net |
| 4 | DIANA PRINCE | diana.prince@library.org |
| 5 | ETHAN HUNT | ethan.hunt@inbox.org |

---

### Task 5: Statutory Return Deadline Projections
* **Business Objective:** Compute dynamic 14-day statutory return deadlines from the checkout date using `DATE_ADD(..., INTERVAL 14 DAY)`.
* **Demonstrated Output (Sample Excerpt):**

| loan_id | loan_date | due_date |
| :--- | :--- | :--- |
| 1 | 2026-03-01 | 2026-03-15 |
| 2 | 2026-03-05 | 2026-03-19 |
| 3 | 2026-03-08 | 2026-03-22 |
| 4 | 2026-03-10 | 2026-03-24 |

---

### Task 6: Dynamic Transaction State Modifications
* **Business Objective:** Close an active loan transaction by updating `return_date` dynamically to the current system date (`CURDATE()`) targeting primary key `loan_id = 2`.
* **Execution Verification:** Row matched: 1, Changed: 1, Warnings: 0.

---

### Task 7: Cascade Deletion Verification Protocol
* **Business Objective:** Expunge Author 1 (`George Orwell`) and confirm that relational cascade propagation automatically removes child rows from `books`.
* **Execution Verification:**
  - `DELETE FROM authors WHERE author_id = 1;` executes successfully.
  - `SELECT author_id FROM books WHERE author_id = 1;` returns `Empty set (0.00 sec)`.
  - **Outcome:** Proves `ON DELETE CASCADE` functioned properly by automatically removing *1984* and *Animal Farm* without orphan records or foreign key violations.

---

## 📁 Repository File Structure

```text
library-management-database/
├── library_db.sql       # Full schema DDL, seed data, and analytical queries
└── README.md            # Comprehensive system documentation and output reports