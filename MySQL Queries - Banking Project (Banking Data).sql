# Banking Data - Queries
# 1. Total Clients:
SELECT COUNT(*) AS Total_Clients
FROM dim_client;

# 2. Active Clients:
SELECT COUNT(`Client id`) AS Active_Clients
FROM fact_loan
WHERE `Loan Status` = 'Active';

# 3. New Clients:
SELECT COUNT(DISTINCT `Client Id`) AS New_Clients
FROM fact_loan
WHERE DATE(`Disbursement Date`) BETWEEN '2015-01-01 00:00:00' AND '2023-01-31 00:00:00';

# 4. Client Retention Rate:
WITH clients_by_month AS (SELECT DISTINCT `Client Id`, DATE_FORMAT(`Disbursement Date`, '%Y-%m') AS period
FROM fact_loan),
previous_clients AS (SELECT period, COUNT(DISTINCT `Client Id`) AS prev_clients
FROM clients_by_month
GROUP BY period),
returning_clients AS (SELECT c1.period AS current_period, COUNT(DISTINCT c1.`Client Id`) AS returning_clients
FROM clients_by_month c1
JOIN clients_by_month c2
ON c1.`Client Id` = c2.`Client Id`
AND PERIOD_ADD(REPLACE(c2.period, '-', ''), 1) = REPLACE(c1.period, '-', '')
GROUP BY c1.period)
SELECT r.current_period, CONCAT(ROUND(r.returning_clients * 100.0 / p.prev_clients, 2), '%') AS Client_Retention_Rate
FROM returning_clients r
JOIN previous_clients p
ON PERIOD_ADD(REPLACE(p.period, '-', ''), 1) = REPLACE(r.current_period, '-', '')
ORDER BY r.current_period;

# 5. Total Loan Amount Disbursed:
SELECT CONCAT(ROUND(SUM(`Loan Amount`)/1000000,3), ' M') AS Total_Loan_Disbursement
FROM fact_loan;

# 6. Total Funded Amount:
SELECT CONCAT(ROUND(SUM(`Funded Amount`)/1000000,3), ' M') AS Total_Funded_Amount
FROM fact_loan;

# 7. Average Loan Size:
SELECT ROUND(AVG(`Loan Amount`), 2) AS Avg_Loan_Size
FROM fact_loan;

# 8. Loan Growth %:
WITH loans_by_month AS (SELECT DATE_FORMAT(`Disbursement Date`, '%Y-%m') AS period, SUM(`Loan Amount`) AS total_loans
FROM fact_loan
GROUP BY DATE_FORMAT(`Disbursement Date`, '%Y-%m')),
growth AS (SELECT l1.period AS current_period, l1.total_loans AS current_loans, l2.total_loans AS prev_loans,
ROUND(((l1.total_loans - l2.total_loans) / l2.total_loans) * 100, 2) AS loan_growth_pct
FROM loans_by_month l1
JOIN loans_by_month l2
ON PERIOD_ADD(REPLACE(l2.period, '-', ''), 1) = REPLACE(l1.period, '-', ''))
SELECT current_period, current_loans, prev_loans, CONCAT(loan_growth_pct, '%') AS Loan_Growth_Percent
FROM growth
ORDER BY current_period;

# 9. Total Repayments Collected:
SELECT CONCAT(ROUND(SUM(`Total Pymnt`)/1000000,3), ' M') AS Total_Repayments
FROM fact_repayment;

# 10. Principal Recovery Rate:
SELECT ROUND(SUM(`Total Rec Prncp`)/SUM(`Loan Amount`)*100,2) AS Principal_Recovery_Rate
FROM fact_repayment r
JOIN fact_loan l ON r.`Account Id` = l.`Account Id`;

# 11. Interest Income:
SELECT CONCAT(ROUND(SUM(`Total Rrec int`)/1000000,1), ' M') AS Interest_Income
FROM fact_repayment;

# 12. Default Rate:
SELECT ROUND(SUM(CASE WHEN `Is Default Loan`='Y' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS Default_Rate
FROM fact_repayment;

# 13. Delinquency Rate:
SELECT ROUND(SUM(CASE WHEN `Is Delinquent Loan`='Y' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS Delinquency_Rate
FROM fact_repayment;

# 14. On-Time Repayment %:
SELECT ROUND(SUM(CASE WHEN `Repayment Behavior`='On-Time' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS On_Time_Repayment_Percent
FROM fact_repayment;

# 15. Loan Distribution by Branch:
SELECT `Branch Name`, CONCAT(ROUND(SUM(`Loan Amount`) / 1000000, 2), ' M') AS Total_Loan_Amount
FROM fact_loan
GROUP BY `Branch Name`
ORDER BY SUM(`Loan Amount`) DESC;

# 16. Branch Performance Category Split:
SELECT `Branch Performance Category`, COUNT(*) AS Branch_Count
FROM dim_branch
GROUP BY `Branch Performance Category`;

# 17. Product-wise Loan Volume:
SELECT p.`Product Id`, CONCAT(ROUND(SUM(l.`Loan Amount`) / 1000000, 2), ' M') AS Loan_Volume
FROM fact_loan l
JOIN dim_product p ON l.`Product Id` = p.`Product Id`
GROUP BY p.`Product Id`
ORDER BY Loan_Volume DESC;

# 18. Product Profitability:
SELECT p.`Product Id`, SUM(r.`Total Rrec int`) AS Interest_Income
FROM fact_loan l
JOIN dim_product p ON l.`Product Id` = p.`Product Id`
JOIN fact_repayment r ON l.`Account Id` = r.`Account Id`
GROUP BY p.`Product Id`
ORDER BY Interest_Income DESC;