CREATE OR REPLACE TEMP VIEW date_dimension_table AS
    WITH
       dates AS (
           SELECT
               '2000-01-01' AS start_date,
               CAST(ADD_MONTHS(LAST_DAY(CURRENT_DATE()), 12) AS DATE) AS end_date
       ),
       start_date_with_days_count AS (
           SELECT
               start_date,
               EXPLODE(SEQUENCE(0, DATEDIFF(end_date, start_date) - 1, 1)) AS days_shift
           FROM dates
       ),
       date_sequence AS (
           SELECT
               days_shift AS id,
               DATE_ADD(start_date, days_shift) AS full_date
           FROM start_date_with_days_count
       ),
       date_dimension AS (
          SELECT 
           full_date AS Date,
           DAY(full_date) AS DayNumber,
           DAY(full_date) AS Day,
           DATE_FORMAT(full_date, 'MMMM') AS Month,
           DATE_FORMAT(full_date, 'MMM') AS ShortMonth,
           MONTH(full_date) AS CalendarMonthNumber,
           CONCAT('CY', YEAR(full_date), '-', DATE_FORMAT(full_date, 'MMM')) AS CalendarMonthLabel,
           YEAR(full_date) AS CalendarYear,
           CONCAT('CY', YEAR(full_date)) AS CalendarYearLabel,
           CASE WHEN MONTH(full_date) IN (11, 12)
                   THEN MONTH(full_date) - 10
                   ELSE MONTH(full_date) + 2
                 END AS FiscalMonthNumber,
           CONCAT('FY', cast(CASE WHEN MONTH(full_date) IN (11, 12)
                                     THEN YEAR(full_date) + 1
                                     ELSE YEAR(full_date)
                                END AS string), '-', DATE_FORMAT(full_date, 'MMM')) AS FiscalMonthLabel,
          CASE WHEN MONTH(full_date) IN (11, 12)
                   THEN YEAR(full_date) + 1
                   ELSE YEAR(full_date)
              END AS FiscalYear,
           CONCAT('FY', cast(CASE WHEN MONTH(full_date) IN (11, 12)
                                     THEN YEAR(full_date) + 1
                                     ELSE YEAR(full_date)
                                END AS string)) AS FiscalYearLabel,
           date_part('WEEK', full_date) AS ISOWeekNumber          
           FROM date_sequence
       )
       
       SELECT * FROM date_dimension
