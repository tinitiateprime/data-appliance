-- Full refresh is intentional for these small reporting marts. For large
-- production marts, drive the same MERGEs from Silver table_changes().

INSERT OVERWRITE banking_demo.gold.dim_customer
WITH latest_score AS (
  SELECT customer_id, score,
         row_number() OVER (PARTITION BY customer_id ORDER BY score_date DESC, source_updated_at DESC) rn
  FROM banking_demo.silver.credit_scores WHERE NOT is_deleted
)
SELECT c.customer_id, concat_ws(' ',c.first_name,c.last_name),
       CASE WHEN floor(months_between(current_date(),c.date_of_birth)/12)<25 THEN '18-24'
            WHEN floor(months_between(current_date(),c.date_of_birth)/12)<40 THEN '25-39'
            WHEN floor(months_between(current_date(),c.date_of_birth)/12)<60 THEN '40-59' ELSE '60+' END,
       a.city, a.state, c.kyc_status, c.risk_rating, s.score,
       CASE WHEN s.score>=800 THEN 'EXCEPTIONAL' WHEN s.score>=740 THEN 'VERY_GOOD'
            WHEN s.score>=670 THEN 'GOOD' WHEN s.score>=580 THEN 'FAIR' ELSE 'POOR' END,
       c.customer_since, current_timestamp()
FROM banking_demo.silver.customers c
LEFT JOIN banking_demo.silver.customer_addresses a
  ON c.customer_id=a.customer_id AND a.is_primary AND NOT a.is_deleted
LEFT JOIN latest_score s ON c.customer_id=s.customer_id AND s.rn=1
WHERE NOT c.is_deleted;

INSERT OVERWRITE banking_demo.gold.dim_product
SELECT product_id, product_code, product_name, product_category,
       base_interest_rate, default_term_months, is_secured, current_timestamp()
FROM banking_demo.silver.products WHERE NOT is_deleted;

INSERT OVERWRITE banking_demo.gold.dim_branch
SELECT b.branch_id,b.branch_name,b.city,b.state,
       count_if(e.status='ACTIVE' AND NOT e.is_deleted),current_timestamp()
FROM banking_demo.silver.branches b
LEFT JOIN banking_demo.silver.employees e ON b.branch_id=e.branch_id
WHERE NOT b.is_deleted
GROUP BY ALL;

INSERT OVERWRITE banking_demo.gold.fact_daily_deposit_activity
SELECT t.posted_date,a.branch_id,a.product_id,count(*),count(DISTINCT t.account_id),
       sum(CASE WHEN t.transaction_type IN ('DEPOSIT','TRANSFER_IN') THEN t.amount ELSE 0 END),
       abs(sum(CASE WHEN t.transaction_type IN ('WITHDRAWAL','TRANSFER_OUT') THEN t.amount ELSE 0 END)),
       abs(sum(CASE WHEN t.transaction_type='FEE' THEN t.amount ELSE 0 END)),
       sum(t.amount),current_timestamp()
FROM banking_demo.silver.deposit_transactions t
JOIN banking_demo.silver.accounts a ON t.account_id=a.account_id AND NOT a.is_deleted
WHERE NOT t.is_deleted AND t.status='POSTED'
GROUP BY t.posted_date,a.branch_id,a.product_id;

INSERT OVERWRITE banking_demo.gold.fact_daily_card_spend
SELECT t.transaction_date,a.branch_id,c.card_type,m.merchant_category,count(*),
       count_if(t.authorization_status='APPROVED'),count_if(t.authorization_status='DECLINED'),
       sum(CASE WHEN t.authorization_status='APPROVED' THEN t.amount ELSE 0 END),
       count_if(t.fraud_flag),sum(CASE WHEN t.fraud_flag THEN t.amount ELSE 0 END),
       current_timestamp()
FROM banking_demo.silver.card_transactions t
JOIN banking_demo.silver.cards c ON t.card_id=c.card_id AND NOT c.is_deleted
JOIN banking_demo.silver.accounts a ON c.account_id=a.account_id AND NOT a.is_deleted
LEFT JOIN banking_demo.silver.merchants m ON t.merchant_id=m.merchant_id AND NOT m.is_deleted
WHERE NOT t.is_deleted
GROUP BY t.transaction_date,a.branch_id,c.card_type,m.merchant_category;

INSERT OVERWRITE banking_demo.gold.fact_loan_portfolio
WITH collateral AS (
  SELECT loan_id,sum(appraised_value) collateral_value
  FROM banking_demo.silver.loan_collateral WHERE NOT is_deleted GROUP BY loan_id
), payments AS (
  SELECT loan_id,sum(principal_amount) principal_paid,sum(interest_amount) interest_paid
  FROM banking_demo.silver.loan_payments WHERE NOT is_deleted AND payment_status='POSTED' GROUP BY loan_id
)
SELECT current_date(),a.branch_id,a.product_id,count(*),sum(l.original_principal),
       sum(l.outstanding_principal),
       sum(l.outstanding_principal*l.interest_rate)/nullif(sum(l.outstanding_principal),0),
       count_if(l.delinquency_days>0),sum(CASE WHEN l.delinquency_days>0 THEN l.outstanding_principal ELSE 0 END),
       sum(coalesce(c.collateral_value,0)),sum(coalesce(p.principal_paid,0)),
       sum(coalesce(p.interest_paid,0)),current_timestamp()
FROM banking_demo.silver.loans l
JOIN banking_demo.silver.accounts a ON l.account_id=a.account_id AND NOT a.is_deleted
LEFT JOIN collateral c ON l.loan_id=c.loan_id
LEFT JOIN payments p ON l.loan_id=p.loan_id
WHERE NOT l.is_deleted
GROUP BY a.branch_id,a.product_id;

INSERT OVERWRITE banking_demo.gold.customer_360
WITH account_rollup AS (
  SELECT h.customer_id,
    count_if(p.product_code IN ('CHECKING','SAVINGS')) deposit_account_count,
    sum(CASE WHEN p.product_code='CHECKING' THEN a.current_balance ELSE 0 END) checking_balance,
    sum(CASE WHEN p.product_code='SAVINGS' THEN a.current_balance ELSE 0 END) savings_balance,
    count_if(p.product_code='CREDIT_CARD') credit_card_count,
    sum(CASE WHEN p.product_code='CREDIT_CARD' THEN coalesce(a.credit_limit,0) ELSE 0 END) credit_limit,
    abs(sum(CASE WHEN p.product_code='CREDIT_CARD' THEN least(a.current_balance,0) ELSE 0 END)) card_outstanding,
    sum(CASE WHEN p.product_code='PERSONAL_LOAN' THEN coalesce(l.outstanding_principal,0) ELSE 0 END) personal_loan_balance,
    sum(CASE WHEN p.product_code='AUTO_LOAN' THEN coalesce(l.outstanding_principal,0) ELSE 0 END) auto_loan_balance,
    sum(CASE WHEN p.product_code='HOUSING_LOAN' THEN coalesce(l.outstanding_principal,0) ELSE 0 END) housing_loan_balance
  FROM banking_demo.silver.account_holders h
  JOIN banking_demo.silver.accounts a ON h.account_id=a.account_id AND NOT a.is_deleted
  JOIN banking_demo.silver.products p ON a.product_id=p.product_id AND NOT p.is_deleted
  LEFT JOIN banking_demo.silver.loans l ON a.account_id=l.account_id AND NOT l.is_deleted
  WHERE NOT h.is_deleted
  GROUP BY h.customer_id
)
SELECT c.customer_id,concat_ws(' ',c.first_name,c.last_name),c.home_branch_id,
       coalesce(r.deposit_account_count,0),coalesce(r.checking_balance,0),coalesce(r.savings_balance,0),
       coalesce(r.credit_card_count,0),coalesce(r.credit_limit,0),coalesce(r.card_outstanding,0),
       coalesce(r.personal_loan_balance,0),coalesce(r.auto_loan_balance,0),coalesce(r.housing_loan_balance,0),
       coalesce(r.checking_balance,0)+coalesce(r.savings_balance,0)-coalesce(r.card_outstanding,0)
         -coalesce(r.personal_loan_balance,0)-coalesce(r.auto_loan_balance,0)-coalesce(r.housing_loan_balance,0),
       d.latest_credit_score,c.risk_rating,current_timestamp()
FROM banking_demo.silver.customers c
LEFT JOIN account_rollup r ON c.customer_id=r.customer_id
LEFT JOIN banking_demo.gold.dim_customer d ON c.customer_id=d.customer_id
WHERE NOT c.is_deleted;
