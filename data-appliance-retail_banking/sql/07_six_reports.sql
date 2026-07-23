-- REPORT 1: Deposit balances and customer/account counts by product and branch.
SELECT b.branch_name,p.product_name,
       count(DISTINCT a.account_id) account_count,
       count(DISTINCT h.customer_id) customer_count,
       sum(a.current_balance) total_balance,
       avg(a.current_balance) average_balance
FROM banking_demo.silver.accounts a
JOIN banking_demo.silver.products p ON a.product_id=p.product_id AND NOT p.is_deleted
JOIN banking_demo.silver.branches b ON a.branch_id=b.branch_id AND NOT b.is_deleted
LEFT JOIN banking_demo.silver.account_holders h ON a.account_id=h.account_id AND NOT h.is_deleted
WHERE NOT a.is_deleted AND p.product_code IN ('CHECKING','SAVINGS')
GROUP BY b.branch_name,p.product_name ORDER BY b.branch_name,p.product_name;

-- REPORT 2: Monthly credit/debit card spend, approval rate, and fraud rate.
SELECT date_trunc('MONTH',spend_date) month,card_type,
       sum(transaction_count) transaction_count,sum(approved_spend) approved_spend,
       round(100.0*sum(approved_count)/nullif(sum(transaction_count),0),2) approval_rate_pct,
       round(100.0*sum(fraud_transaction_count)/nullif(sum(transaction_count),0),2) fraud_rate_pct
FROM banking_demo.gold.fact_daily_card_spend
GROUP BY date_trunc('MONTH',spend_date),card_type ORDER BY month,card_type;

-- REPORT 3: Loan portfolio by personal, auto, and housing product.
SELECT p.product_name,sum(f.loan_count) loan_count,
       sum(f.original_principal) original_principal,
       sum(f.outstanding_principal) outstanding_principal,
       round(100*sum(f.weighted_interest_rate*f.outstanding_principal)
         /nullif(sum(f.outstanding_principal),0),3) weighted_rate_pct,
       sum(f.collateral_value) collateral_value,
       round(sum(f.outstanding_principal)/nullif(sum(f.collateral_value),0)*100,2) portfolio_ltv_pct
FROM banking_demo.gold.fact_loan_portfolio f
JOIN banking_demo.gold.dim_product p ON f.product_id=p.product_id
GROUP BY p.product_name
ORDER BY outstanding_principal DESC;

-- REPORT 4: Delinquency aging and exposure.
SELECT CASE WHEN delinquency_days=0 THEN 'CURRENT'
            WHEN delinquency_days<=30 THEN '1-30' WHEN delinquency_days<=60 THEN '31-60'
            WHEN delinquency_days<=90 THEN '61-90' ELSE '90+' END aging_bucket,
       count(*) loan_count,sum(outstanding_principal) exposure,
       sum(next_payment_amount) next_payments_due
FROM banking_demo.silver.loans
WHERE NOT is_deleted
GROUP BY 1 ORDER BY min(delinquency_days);

-- REPORT 5: Customer 360 / cross-sell opportunities.
SELECT customer_id,customer_name,deposit_account_count,credit_card_count,
       personal_loan_balance,auto_loan_balance,housing_loan_balance,latest_credit_score,
       CASE WHEN credit_card_count=0 AND latest_credit_score>=700 THEN 'OFFER_CREDIT_CARD'
            WHEN savings_balance=0 AND checking_balance>5000 THEN 'OFFER_SAVINGS'
            WHEN auto_loan_balance=0 AND latest_credit_score>=680 THEN 'OFFER_AUTO_LOAN'
            ELSE 'NO_CURRENT_OFFER' END next_best_offer
FROM banking_demo.gold.customer_360
ORDER BY total_relationship_balance DESC;

-- REPORT 6: Branch performance scorecard.
WITH deposits AS (
  SELECT branch_id,sum(deposit_amount) deposits,sum(withdrawal_amount) withdrawals,
         sum(fee_amount) fees,sum(net_flow) net_flow
  FROM banking_demo.gold.fact_daily_deposit_activity GROUP BY branch_id
), loans AS (
  SELECT branch_id,sum(outstanding_principal) loan_balance,
         sum(delinquent_balance) delinquent_balance FROM banking_demo.gold.fact_loan_portfolio GROUP BY branch_id
), cards AS (
  SELECT branch_id,sum(approved_spend) card_spend,sum(fraud_amount) fraud_amount
  FROM banking_demo.gold.fact_daily_card_spend GROUP BY branch_id
)
SELECT b.branch_name,b.state,b.active_employee_count,d.deposits,d.withdrawals,d.fees,d.net_flow,
       l.loan_balance,l.delinquent_balance,
       round(100*l.delinquent_balance/nullif(l.loan_balance,0),2) delinquency_rate_pct,
       c.card_spend,c.fraud_amount
FROM banking_demo.gold.dim_branch b
LEFT JOIN deposits d ON b.branch_id=d.branch_id
LEFT JOIN loans l ON b.branch_id=l.branch_id
LEFT JOIN cards c ON b.branch_id=c.branch_id
ORDER BY d.net_flow DESC;
