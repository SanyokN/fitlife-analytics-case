-- DDL for Database Schema & Indexes (PostgreSQL)

-- 1. Table Definitions

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    source VARCHAR(50),
    registration_date DATE,
    device VARCHAR(20),
    country_code VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS activity (
    session_id UUID PRIMARY KEY,
    user_id INT REFERENCES users(id),
    event_name VARCHAR(50),
    event_date DATE
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id UUID PRIMARY KEY,
    user_id INT REFERENCES users(id),
    amount NUMERIC(10, 2),
    payment_date DATE,
    payment_status VARCHAR(20)
);

-- 2. Performance Indexes

-- Indexes for users table (Geography & Cohorts)
CREATE INDEX IF NOT EXISTS idx_users_country 
ON users(country_code);

CREATE INDEX IF NOT EXISTS idx_users_country_reg_date 
ON users(country_code, registration_date);

-- Composite Index for activity funnel filtering and user aggregation
CREATE INDEX IF NOT EXISTS idx_activity_name_user_date 
ON activity(event_name, user_id, event_date);

-- Composite Index for user activity cohorts and date truncations
CREATE INDEX IF NOT EXISTS idx_activity_user_date 
ON activity(user_id, event_date);

-- Index for transactions table
CREATE INDEX IF NOT EXISTS idx_transactions_user_date 
ON transactions(user_id, payment_date);