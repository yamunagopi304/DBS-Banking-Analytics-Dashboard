# Debit & Credit Queries
# 1. Total Credit Amount:
SELECT CONCAT(ROUND(SUM(COALESCE(Amount,0)) / 1000000, 2), 'M') AS Total_Credit_Amount
FROM debit_credit_data
WHERE TRIM(UPPER(`Transaction Type`)) = 'CREDIT';

# 2. Total Debit Amount:
SELECT CONCAT(ROUND(SUM(COALESCE(Amount,0)) / 1000000, 2), 'M') AS Total_Debit_Amount
FROM debit_credit_data
WHERE TRIM(UPPER(`Transaction Type`)) = 'DEBIT';

# 3. Credit to Debit Ratio:
SELECT SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount END) / SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount END)
AS Credit_to_Debit_Ratio
FROM debit_credit_data;

# 4. Net Transaction Amount:
SELECT ROUND(
        SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) -
        SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END),
    2) AS Net_Transaction_Amount
FROM debit_credit_data;

# 5. Account Activity Ratio:
SELECT ROUND(COUNT(*) * 1.0 / SUM(Amount), 2) AS Account_Activity_Ratio
FROM debit_credit_data
WHERE Amount IS NOT NULL;

# 6. Transactions per Day/Week/Month:
SELECT 
    YEAR(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) AS Year,
    MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) AS Month,
    COUNT(*) AS Transactions_Per_Month
FROM debit_credit_data
GROUP BY 
    YEAR(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')),
    MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d'))
ORDER BY Year, Month;

# 7. Total Transaction Amount by Branch:
SELECT Branch, CONCAT(FORMAT(SUM(COALESCE(Amount, 0)) / 1000000, 2), ' M') AS Total_Amount_By_Branch
FROM debit_credit_data
GROUP BY Branch
ORDER BY SUM(COALESCE(Amount, 0)) DESC;

# 8. Transaction Volume by Bank:
SELECT `Bank Name`, CONCAT(ROUND(SUM(Amount) / 1000000, 2), ' M') AS Transaction_Amount_By_Bank
FROM debit_credit_data
GROUP BY `Bank Name`
ORDER BY SUM(Amount) DESC;

# 9. Transaction Method Distribution:
SELECT `Transaction Method`, CONCAT(ROUND(SUM(Amount) / 1000000, 2), ' M') AS Transaction_Method
FROM debit_credit_data
GROUP BY `Transaction Method`
ORDER BY SUM(Amount) DESC;

# 10. Branch Transaction Growth:
SELECT Branch, ROUND((SUM(CASE WHEN MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) = 12 THEN Amount ELSE 0 END) - 
SUM(CASE WHEN MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) = 1 THEN Amount ELSE 0 END)) /
SUM(CASE WHEN MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) = 1 THEN Amount ELSE 0 END) * 100, 2) AS Growth_Percentage
FROM debit_credit_data
WHERE YEAR(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) = 2024
GROUP BY Branch;

# 11. High-Risk Transaction Flag:
SELECT `Customer ID`, Amount, `Transaction Date`, `Transaction Type`, `Transaction Method`, 
CASE WHEN (`Transaction Type` = 'Debit' AND Amount > 4000) OR (`Transaction Type` = 'Credit' AND Amount > 4500)
THEN 'High-Risk' ELSE 'Normal' END AS `High Risk Flag`
FROM debit_credit_data;

# 12. Suspicious Transaction Frequency:
SELECT `Customer ID`, COUNT(*) AS high_risk_count
FROM debit_credit_data
WHERE (`Transaction Type` = 'Debit' AND Amount > 4000) OR (`Transaction Type` = 'Credit' AND Amount > 4500)
GROUP BY `Customer ID`
ORDER BY high_risk_count DESC;



























