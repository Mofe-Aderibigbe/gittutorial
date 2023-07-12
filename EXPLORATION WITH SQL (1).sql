



----Total salaries of each division and their percentage of overall salary
  WITH C AS (
    SELECT 
      division, 
      total_salary_by_division, 
      SUM(total_salary_by_division) OVER() AS overall_total_salary 
    FROM 
      (
        SELECT 
          division, 
          SUM(salary) total_salary_by_division 
        FROM 
          employees e NATURAL 
          JOIN DEPARTMENTS 
        GROUP BY 
          division
      ) X
  ) 
SELECT 
  *, 
  ROUND(
    (
      total_salary_by_division / overall_total_salary
    ) * 100, 
    2
  ) SalaryPercentage_by_division 
FROM 
  C 
ORDER BY 
  division, 
  SalaryPercentage_by_division desc 

----Details of Employees who earn more than the average salary in their respective department and are from United states or Canada.
SELECT 
  first_name, 
  last_name, 
  email, 
  gender, 
  department, 
  country, 
  salary, 
  (
    SELECT 
      ROUND(
        AVG(salary), 
        2
      ) 
    FROM 
      employees e1 
    WHERE 
      e1.department = e.department
  ) average_salary_by_dept 
FROM 
  employees e NATURAL 
  JOIN regions 
WHERE 
  salary > (
    SELECT 
      AVG(salary) 
    FROM 
      employees e1 
    WHERE 
      e1.department = e.department
  ) 
  AND country in ('Canada', 'United States') 
ORDER BY 
  department, 
  salary desc 

----Overall Average of salary WITHOUT the Outliers
SELECT 
  ROUND(
    AVG(salary), 
    2
  ) overall_Average_Salary 
FROM 
  employees 
WHERE 
  employee_id NOT IN(
    SELECT 
      employee_id 
    FROM 
      employees 
    WHERE 
      salary =(
        SELECT 
          MAX(salary) 
        FROM 
          employees
      ) 
      OR salary = (
        SELECT 
          MIN(salary) 
        FROM 
          employees
      )
  ) 
 
 ----Categorizing employees into Junior, Senior and Executive staffs
SELECT 
  first_name, 
  salary, 
  department, 
  CASE WHEN salary < 100000 THEN 'Junior_staff' WHEN salary > 100000 
  AND salary < 160000 THEN 'Senior_staff' WHEN salary > 160000 THEN 'Executive' ELSE 'Clerk' END AS Category 
FROM 
  employees 
ORDER BY 
  department, 
  salary desc 
  
  ----Count of Employees in each Category
SELECT 
  category, 
  COUNT(category) Number 
FROM 
  (
    SELECT 
      first_name, 
      salary, 
      department, 
      CASE WHEN salary < 100000 THEN 'Junior_staff' WHEN salary > 100000 
      AND salary < 160000 THEN 'Senior_staff' WHEN salary > 160000 THEN 'Executive' ELSE 'unpaid' END AS Category 
    FROM 
      employees
  ) P 
GROUP BY 
  category 
  
----Using case statement to return Employees in the United states region
SELECT 
  first_name, 
  CASE WHEN region_id = 1 THEN (
    SELECT 
      country 
    FROM 
      regions 
    WHERE 
      region_id = 1
  ) ELSE '-' END "Region 1", 
  CASE WHEN region_id = 2 THEN (
    SELECT 
      country 
    FROM 
      regions 
    WHERE 
      region_id = 2
  ) ELSE '-' END "Region 2" 
FROM 
  employees 

----Using case statement to count the total number of Employees in each department and Transposing the result
SELECT 
  COUNT(a.region_1) + COUNT(a.region_2) + COUNT(a.region_3) AS United_States, 
  COUNT(a.region_4) + COUNT(a.region_5) AS Asia, 
  COUNT(a.region_6) + COUNT(a.region_7) AS Canada 
FROM 
  (
    select 
      first_name, 
      (
        case when region_id = 1 then 'United States' else null end
      ) Region_1, 
      (
        case when region_id = 2 then 'United States' else null end
      ) Region_2, 
      (
        case when region_id = 3 then 'United States' else null end
      ) Region_3, 
      (
        case when region_id = 4 then 'Asia' else null end
      ) Region_4, 
      (
        case when region_id = 5 then 'Asia' else null end
      ) Region_5, 
      (
        case when region_id = 6 then 'Canada' else null end
      ) Region_6, 
      (
        case when region_id = 7 then 'Canada' else null end
      ) Region_7 
    from 
      employees
  ) a 
  
----Using subquery to return departments with either 50 or lesser employees and the maximum salary in those department
SELECT 
  department, 
  MAX(salary) Maximum_salary 
FROM 
  employees e1 
WHERE 
  50 <= (
    SELECT 
      COUNT(*) 
    FROM 
      employees e2 
    WHERE 
      e2.department = e1.department
  ) 
GROUP BY 
  e1.department 
ORDER BY 
  Maximum_salary DESC 

----Checking for Departments in the Employees table which are not yet in Departments table
SELECT 
  DISTINCT department 
FROM 
  employees e 
WHERE 
  department NOT IN(
    SELECT 
      department 
    FROM 
      departments
  ) 
  
----Using case statement and correlated subquery to return the maximum and minimum salary in each department
SELECT 
  First_name, 
  department, 
  salary, 
  CASE WHEN salary = (
    SELECT 
      MAX(salary) 
    FROM 
      employees e1 
    WHERE 
      e1.department = e.department
  ) THEN 'HI' ELSE 'LOW' END 
FROM 
  employees e 
WHERE 
  salary = (
    SELECT 
      MAX(salary) 
    FROM 
      employees e1 
    where 
      e1.department = e.department
  ) 
  OR salary = (
    SELECT 
      MIN(salary) 
    from 
      employees e1 
    WHERE 
      e1.department = e.department
  ) 
ORDER BY 
  department, 
  salary DESC 
SELECT 
  department, 
  (
    SELECT 
      department 
    FROM 
      departments d 
    WHERE 
      d.department = e.department
  ) 
FROM 
  employees e 
  
----Spending pattern of the company 30 days before an employee was hired including the day they were hired
SELECT 
  first_name, 
  department, 
  hire_date, 
  salary, 
  (
    SELECT 
      SUM(salary) 
    FROM 
      employees e2 
    WHERE 
      e2.hire_date BETWEEN e.hire_date - 30 
      AND e.hire_date
  ) AS spending_pattern 
FROM 
  employees e 
ORDER BY 
  hire_date, 
  department 
  
----Salary pattern from 2003 to 2016
SELECT 
  years, 
  SUM(Salary) 
FROM 
  (
    SELECT 
      first_name, 
      department, 
      hire_date, 
      EXTRACT(
        YEAR 
        FROM 
          hire_date
      ) years, 
      EXTRACT(
        MONTH 
        FROM 
          hire_date
      ) months, 
      salary 
    FROM 
      employees 
    ORDER BY 
      years, 
      months, 
      department
  ) p 
GROUP BY 
  years 
  
----Salary pattern for each year from 2003 to 2016 
SELECT 
  years, 
  months, 
  SUM(Salary) 
FROM 
  (
    SELECT 
      first_name, 
      department, 
      hire_date, 
      EXTRACT(
        YEAR 
        FROM 
          hire_date
      ) years, 
      EXTRACT(
        MONTH 
        FROM 
          hire_date
      ) months, 
      salary 
    FROM 
      employees 
    ORDER BY 
      years, 
      months, 
      department
  ) p 
GROUP BY 
  years, 
  months 
  
----Salary increase pattern in each department as Employees are being hired
SELECT 
  first_name, 
  salary, 
  department, 
  hire_date, 
  SUM(salary) OVER(
    PARTITION department 
    ORDER BY 
      hire_date
  ) AS SALARY_CHANGE 
FROM 
  EMPLOYEES ORDER department, 
  hire_date 
  
----Bucketing or categorizing employees based on their Salaries in their respective department 
SELECT 
  first_name, 
  department, 
  salary, 
  NTILE(5) OVER(
    PARTITION BY department 
    ORDER BY 
      salary DESC
  ) third_highest_salary 
FROM 
  employees 
ORDER BY 
  department 
----Using window function to return employees with the third highest salaries in each department
SELECT 
  first_name, 
  department, 
  salary, 
  NTH_VALUE(salary, 3) OVER(
    PARTITION BY department 
    ORDER BY 
      salary DESC
  ) rank_salary 
FROM 
  employees 
  
----Using window function to return the difference between employees salaries and the immediate higher salary in their respective department
SELECT 
  first_name, 
  department, 
  salary, 
  higher_salary - salary AS salary_difference 
FROM 
  (
    SELECT 
      first_name, 
      department, 
      salary, 
      LAG(salary) OVER(
        PARTITION BY department 
        ORDER BY 
          salary DESC
      ) higher_salary 
    FROM 
      employees
  ) P 
  
----Using window function to find the salary range in every department
SELECT 
  first_name, 
  department, 
  salary, 
  (highest_salary - lowest_salary) Range 
from 
  (
    SELECT 
      first_name, 
      department, 
      salary, 
      FIRST_VALUE(salary) OVER W AS Highest_salary, 
      LAST_VALUE(salary) OVER W AS lowest_salary 
    FROM 
      employees WINDOW W AS (
        PARTITION BY department 
        ORDER BY 
          salary DESC RANGE BETWEEN UNBOUNDED PRECEDING 
          AND UNBOUNDED FOLLOWING
      )
  ) P 
  
----Using the cume_dist function to return the first 50% of employees in each department based on their salaries 
SELECT 
  first_name, 
  department, 
  salary, 
  rankk || '%' AS rank 
from 
  (
    SELECT 
      first_name, 
      department, 
      salary, 
      ROUND(
        (
          CUME_DIST() OVER(
            PARTITION BY department 
            ORDER BY 
              salary DESC
          )
        ):: NUMERIC * 100, 
        2
      ) rankK 
    FROM 
      employees
  ) P 
WHERE 
  rankk <= 50 
  
----Using percent_rank to know how high or low an employee's salary compared to others       
SELECT 
  first_name, 
  department, 
  salary, 
  ROUND(
    (
      PERCENT_RANK() OVER(
        PARTITION BY department 
        ORDER BY 
          salary ASC
      )
    ):: NUMERIC * 100, 
    2
  ) Percentage_rank 
FROM 
  employees 
  
----Creating view for salaries paid to each division
  CREATE VIEW Division_Salaries AS WITH C AS (
    SELECT 
      division, 
      total_salary_by_division, 
      SUM(total_salary_by_division) OVER() AS overall_total_salary 
    FROM 
      (
        SELECT 
          division, 
          SUM(salary) total_salary_by_division 
        FROM 
          employees e NATURAL 
          JOIN DEPARTMENTS 
        GROUP BY 
          division
      ) X
  ) 
SELECT 
  *, 
  ROUND(
    (
      total_salary_by_division / overall_total_salary
    ) * 100, 
    2
  )|| '%' SalaryPercentage_by_division 
FROM 
  C 
ORDER BY 
  division, 
  SalaryPercentage_by_division desc 
  
----Creating a temp table for high and low salaries in each department
  CREATE TEMPORARY TABLE high_low_salary AS 
SELECT 
  First_name, 
  department, 
  salary, 
  CASE WHEN salary = (
    SELECT 
      MAX(salary) 
    FROM 
      employees e1 
    WHERE 
      e1.department = e.department
  ) THEN 'HI' ELSE 'LOW' END 
FROM 
  employees e 
WHERE 
  salary = (
    SELECT 
      MAX(salary) 
    FROM 
      employees e1 
    where 
      e1.department = e.department
  ) 
  OR salary = (
    SELECT 
      MIN(salary) 
    from 
      employees e1 
    WHERE 
      e1.department = e.department
  ) 
ORDER BY 
  department, 
  salary DESC
