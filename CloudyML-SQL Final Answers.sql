use task_1
select * from task_1.account
select * from task_1.card
select * from task_1.client
select * from task_1.disp
select * from task_1.district
select * from task_1.loan
select * from task_1.orders
select * from task_1.trans
---------------------------------------------------------------------------------------
***one by one will check the columns quality table wise and do further steps accordingly***
----------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
select * from task_1.account
ALTER TABLE account  
CHANGE COLUMN `date` `dates` DATE   "date: yymmdd to yy-mm-dd"
select distinct(account_id) from account 'no null or blank value in column'
select distinct(district_id) from account
select distinct(frequency) from account 
---------------------------------------------------------------------------
select * from task_1.card
select distinct(card_id) from card
select distinct(disp_id) from card
select distinct(type) from card
select distinct(issued) from card
-------------------------                              -------------------------------
UPDATE card
SET issued = DATE_FORMAT(STR_TO_DATE(SUBSTRING(issued, 1, 6), '%y%m%d'), '%y-%m-%d');
ALTER TABLE card MODIFY issued DATE;
"from datetime(text) we have changed in the date format for issued column"
--------------------------------------------------------------------------------------
select * from task_1.client;
select distinct(client_id) from client
select distinct(birth_number) from client
select distinct(district_id) from client
--------------------------------------------------------------------------------------
select * from disp;
select distinct(disp_id) from disp;
select distinct(client_id) from disp;
select distinct(account_id) from disp;
select distinct(type) from disp;
---------------------------------------------------------------------------------------
select * from district
select distinct(A1) from district;
select distinct(A2) from district;
select distinct(A3) from district;
select distinct(A4) from district;
select distinct(A5) from district;
select distinct(A6) from district;
select distinct(A7) from district;
select distinct(A8) from district;
select distinct(A9) from district;
select distinct(A10) from district;
select distinct(A11) from district;
select distinct(A12) from district;
select distinct(A13) from district;
select distinct(A14) from district;
select distinct(A15) from district;
select distinct(A16) from district;
select distinct(A1) from district;
select distinct(A1) from district;
select distinct(A1) from district;
-------------#deleting all the unnessesary columns-------------------------------------
SELECT * FROM task_1.district;
ALTER TABLE task_1.district
DROP COLUMN A4,
DROP COLUMN A5,
DROP COLUMN A6,
DROP COLUMN A7,
DROP COLUMN A8,
DROP COLUMN A9,
DROP COLUMN A10,
DROP COLUMN A11,
DROP COLUMN A12,
DROP COLUMN A13,
DROP COLUMN A14,
DROP COLUMN A15,
DROP COLUMN A16;

---------------------------------------------------------------------------------------
select * from loan;
select distinct(loan_id) from loan;
select distinct(account_id) from loan;
select distinct(date) from loan; "changed"
select distinct(duration) from loan;
select distinct(payments) from loan;
select distinct(status) from loan;
--------------------------------                         -----------------------------
SET date = STR_TO_DATE(date, '%y%m%d');
ALTER TABLE loan
MODIFY COLUMN date DATE;
--------------------------------------------------------------------------------------
RENAME TABLE task_1.order TO task_1.orders;
select * from orders
select distinct(account_id) from orders;
select distinct(bank_to) from orders;
select distinct(account_to) from orders;
select distinct(amount) from orders;
select distinct(k_symbol) from orders; #"replaced all null values with 0"

"blank_counts from k_symbol columns"
SELECT COUNT(*) AS blank_count
FROM orders
WHERE k_symbol = ' ';
select count(k_symbol) from orders;

#"will replace the null value with zero"
update orders
set k_symbol=0
where k_symbol =' ';
---------------------------------------------------------------------------------------
select * from trans;
select distinct(trans_id) from trans;
select distinct(account_id) from trans;
select distinct(date) from trans; "changed"
select distinct(type) from trans;
select distinct(operation) from trans;
select distinct(amount) from trans;
select distinct(balance) from trans;
select distinct(k_symbol) from trans;
select distinct(bank) from trans;
select distinct(account) from trans;

ALTER TABLE task_1.trans
CHANGE COLUMN date dates DATE;

UPDATE trans
SET k_symbol = 0
WHERE k_symbol IS NULL OR k_symbol = ' ';

select * from trans
update trans
set bank =0
where bank =' ' or bank is null;
select distinct(bank) from trans;
select * from trans
select * from client
update trans
set account=0
where account=' ' or account is null;
#"we have replaced the blank with 0 ""in k_symbol,bank,account"

---------------------------Cleaning Part Done---------------------------------------------

FINAL ANSWER
---------------------
QUE_1 ANSWER>
What is the demographic profile of the banks clients and how does it vary across districts?


SELECT
d.a1 AS district_id,
d.a2 AS district_name,
COUNT(l.loan_id) AS loan_count,
AVG(l.amount) AS average_loan_amount,
AVG(t.amount) AS average_transaction_amount
FROM
loan l
JOIN
account a ON l.account_id = a.account_id
JOIN
district d ON a.district_id = d.a1
LEFT JOIN
trans t ON a.account_id = t.account_id
GROUP BY
d.a1, d.a2
LIMIT 0, 400;



---------------------------------------------------------------------------------------------------


QUE_2 ANSWER>
How the banks have performed over the years. Give their detailed analysis year & month-wise.?



SELECT
year,
account_count,
transaction_count,
IFNULL(ROUND((account_count - lag_account_count) / lag_account_count * 100, 2), 0) AS account_count_increase_percentage,
IFNULL(ROUND((transaction_count - lag_transaction_count) / lag_transaction_count * 100, 2), 0) AS transaction_count_increase_percentage
FROM (
SELECT
YEAR(t.dates) AS year,
COUNT(DISTINCT a.account_id) AS account_count,
COUNT(DISTINCT t.trans_id) AS transaction_count,
LAG(COUNT(DISTINCT a.account_id)) OVER (ORDER BY YEAR(t.dates)) AS lag_account_count,
LAG(COUNT(DISTINCT t.trans_id)) OVER (ORDER BY YEAR(t.dates)) AS lag_transaction_count
FROM
trans t
LEFT JOIN
account a ON t.account_id = a.account_id
GROUP BY
year
) AS subquery
ORDER BY
year;




SELECT
month,
account_count,
transaction_count,
IFNULL(ROUND((account_count - lag_account_count) / lag_account_count * 100, 2), 0) AS account_count_increase_percentage,
IFNULL(ROUND((transaction_count - lag_transaction_count) / lag_transaction_count * 100, 2), 0) AS transaction_count_increase_percentage
FROM (
SELECT
MONTH(t.dates) AS month,
COUNT(DISTINCT a.account_id) AS account_count,
COUNT(DISTINCT t.trans_id) AS transaction_count,
LAG(COUNT(DISTINCT a.account_id)) OVER (ORDER BY MONTH(t.dates)) AS lag_account_count,
LAG(COUNT(DISTINCT t.trans_id)) OVER (ORDER BY MONTH(t.dates)) AS lag_transaction_count
FROM
trans t
LEFT JOIN
account a ON t.account_id = a.account_id
GROUP BY
month
) AS subquery
ORDER BY
month;
---------------------------------------------------------------------------------------------------





QUE_3_ANSWER>
What are the most common types of accounts and how do they differ in terms of usage and profitability?


SELECT
t.type AS transaction_type,
COUNT(DISTINCT t.account_id) AS account_count,
COUNT(DISTINCT l.loan_id) AS loan_holder_count,
COUNT(t.trans_id) AS transaction_count,
AVG(l.amount) AS average_loan_amount
FROM
trans t
LEFT JOIN
loan l ON t.account_id = l.account_id
GROUP BY
t.type
ORDER BY
transaction_count DESC;



---------------------------------------------------------------------------------------------------

QUE_4_ANSWER>
#Which types of cards are most frequently used by the bank's clients and what is the overall profitability of the credit card business?

SELECT
c.type AS card_type,
COUNT(t.trans_id) AS transaction_count,
AVG(t.amount) AS average_amount
FROM
trans t
LEFT JOIN
disp d ON t.account_id = d.account_id
LEFT JOIN
card c ON d.disp_id = c.disp_id
LEFT JOIN
client cl ON d.client_id = cl.client_id
GROUP BY
c.type
ORDER BY
transaction_count DESC;
---------------------------------------------------------------------------------------------------

QUE_5_ANSWER>
#What are the major expenses of the bank and how can they be reduced to improve profitability?

WITH ExpenseSummary AS (
SELECT
CASE
WHEN k_symbol = 'DUCHOD' THEN 'Pension'
WHEN k_symbol = 'UROK' THEN 'Interest'
WHEN k_symbol = 'SIPO' THEN 'Household'
WHEN k_symbol = 'SLUZBY' THEN 'Services'
WHEN k_symbol = '0' THEN '0'
WHEN k_symbol = 'POJISTNE' THEN 'Insurance'
WHEN k_symbol = 'SANKC. UROK' THEN 'Penalty Interest'
WHEN k_symbol = 'UVER' THEN 'Loan'
END AS expense_category,
SUM(amount) AS total_amount,
SUM(amount) / SUM(SUM(amount)) OVER () * 100 AS expense_percentage,
ROW_NUMBER() OVER (ORDER BY SUM(amount) DESC) AS expense_rank
FROM
trans
WHERE
k_symbol IN ('DUCHOD', 'UROK', 'SIPO', 'SLUZBY', '0', 'POJISTNE', 'SANKC. UROK', 'UVER')
GROUP BY
expense_category
)
SELECT
expense_category,
total_amount,
expense_percentage
FROM
ExpenseSummary;

---------------------------------------------------------------------------------------------------

QUE_6_ANSWER>
What is the banks loan portfolio and how does it vary across different purposes and client segments?


SELECT
loan.loan_id,
loan.account_id,
loan.date AS loan_date,
loan.amount AS loan_amount,
loan.duration AS loan_duration,
loan.payments AS loan_payments,
loan.status AS loan_status,
orders.bank_to,
orders.amount AS order_amount,
orders.k_symbol,
client.client_id,
client.birth_number,
client.district_id AS client_district_id,
district.a2 AS client_district_name,
district.a3 AS client_region,
disp.type AS client_type,
disp.account_id AS client_account_id,
account.frequency AS account_frequency
FROM
loan
JOIN
orders ON loan.account_id = orders.account_id
JOIN
client ON loan.account_id = client.client_id
JOIN
district ON client.district_id = district.a1
JOIN
disp ON loan.account_id = disp.account_id
JOIN
account ON loan.account_id = account.account_id;

---------------------------------------------------------------------------------------------------

QUE_7_ANSWER>
How can the bank improve its customer service and satisfaction levels?


SELECT
account.account_id,
account.frequency,
district.a2 AS district_name,
district.a1 AS district_id,
AVG(trans.amount) AS average_transaction_amount
FROM
account
JOIN
district ON account.district_id = district.a1
LEFT JOIN
trans ON account.account_id = trans.account_id
GROUP BY
account.district_id,
account.account_id,
account.frequency,
district.a2,
district.a1;




QUE_8_ANSWER>
Can the bank introduce new financial products or services to attract more customers and increase profitability?

By introducing innovative financial products and services tailored to customer needs, leveraging digital transformation, and fostering strategic partnerships, the bank can attract more customers and increase profitability
----------------------------------------------------------------------------------------------------------

Důchod - Pension or Income
Pojistné - Insurance
Sankční úrok - Penalty Interest
SIPO - Combined Household Payments (System for Consolidated Payments in the Czech Republic, covering utilities, TV license, etc.)
Služby - Services
Úrok - Interest
Úvěr - Loan

SIPO - Combined Household Payments (System for Consolidated Payments in the Czech Republic, covering utilities, TV license, etc.)
Pojistné - Insurance
Úvěr - Loan
Služby - Services
Sankční úrok - Penalty Interest

Příjem - Income
Výběr - Withdrawal
Výdaj - Expense

Poplatek měsíčně - Monthly fee
Poplatek po obratu - Fee per transaction
Poplatek týdně - Weekly fee











