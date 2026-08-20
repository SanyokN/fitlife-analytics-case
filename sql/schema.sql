-- DDL for Database Indexes (PostgreSQL)

-- Composite Index for activity funnel filtering and user aggregation
CREATE INDEX IF NOT EXISTS idx_activity_name_user_date 
ON activity(event_name, user_id, event_date);

-- Composite Index for user activity cohorts and date truncations
CREATE INDEX IF NOT EXISTS idx_activity_user_date 
ON activity(user_id, event_date);

-- Index for transactions table (if queries join transactions by user and date)
CREATE INDEX IF NOT EXISTS idx_transactions_user_date 
ON transactions(user_id, transaction_date);