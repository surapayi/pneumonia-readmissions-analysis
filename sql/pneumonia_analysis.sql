-- Pneumonia readmissions analysis (Phase 2: SQL)
-- Source table: encounters (imported from diabetic_data.csv)

-- Step 1: Destination lookup table (one row per discharge ID)
CREATE TABLE dest_lookup (
    discharge_disposition_id INTEGER,
    destination_group TEXT,
    include_flag INTEGER
);

INSERT INTO dest_lookup VALUES
(1, 'Home', 1),
(6, 'Home with health service', 1),
(8, 'Home with health service', 1),
(3, 'Skilled nursing/rehab/facility', 1),
(4,'Skilled nursing/rehab/facility',1),
(15,'Skilled nursing/rehab/facility',1),
(22,'Skilled nursing/rehab/facility',1),
(23,'Skilled nursing/rehab/facility',1),
(24,'Skilled nursing/rehab/facility',1),
(2,'Other',1),(5,'Other',1),(7,'Other',1),(9,'Other',1),(10,'Other',1),
(12,'Other',1),(16,'Other',1),(17,'Other',1),(27,'Other',1),(28,'Other',1),
(11,'Exclude: expired or hospice',0),(13,'Exclude: expired or hospice',0),
(14,'Exclude: expired or hospice',0),(19,'Exclude: expired or hospice',0),
(20,'Exclude: expired or hospice',0),(21,'Exclude: expired or hospice',0),
(18,'Exclude: unknown',0),(25,'Exclude: unknown',0),(26,'Exclude: unknown',0);


-- Step 1.1: Join tables:encouters and dest_lookup
SELECT 
	d.destination_group,
	COUNT(*) AS stays,
	SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) as readmissions
FROM encounters e
JOIN dest_lookup d
	ON CAST(e.discharge_disposition_id AS INTEGER) = d.discharge_disposition_id
WHERE CAST(diag_1 AS REAL) BETWEEN 480 AND 486.99
GROUP BY d.destination_group;


-- Step 2: Cleaned pneumonia view (filters, LOS bands, readmission flag)
CREATE VIEW pneumonia_clean AS
SELECT
    d.destination_group,                      -- 1. which destination group
    CASE                                      -- 2. which LOS band
        WHEN CAST(e.time_in_hospital AS INTEGER) <= 3 THEN '1-3 days'
        WHEN CAST(e.time_in_hospital AS INTEGER) <= 6 THEN '4-6 days'
        ELSE '7+ days'
    END AS los_band,
    CASE WHEN e.readmitted = '<30' THEN 1 ELSE 0 END AS readmit_flag   -- 3. the 0/1 flag
FROM encounters e
JOIN dest_lookup d                            -- 4. match each stay to its destination group
    ON CAST(e.discharge_disposition_id AS INTEGER) = d.discharge_disposition_id
WHERE CAST(e.diag_1 AS REAL) BETWEEN 480 AND 486.99   -- only pneumonia
  AND d.include_flag = 1;                              -- drop excluded destinations

 -- Check: should match Excel (3,699 stays, 354 readmissions) 
SELECT COUNT(*) AS stays, SUM(readmit_flag) AS readmissions
FROM pneumonia_clean;


-- Step 3: Rate by destination and LOS
SELECT
	destination_group,
	los_band,
	COUNT(*) AS stays,
	SUM(readmit_flag) AS readmissions,
	ROUND(SUM(readmit_flag) * 100.0/ COUNT(*), 1) AS rate_pct
FROM pneumonia_clean
GROUP BY destination_group, los_band
ORDER BY destination_group, los_band;

--Step 3.1: Add 95% margin of error and flags
SELECT
    destination_group,
    los_band,
    stays,
    readmissions,
    ROUND(100 * p, 1) AS rate_pct,
    ROUND(100 * (p - 1.96 * SQRT(p * (1 - p) / stays)), 1) AS lower_pct,
    ROUND(100 * (p + 1.96 * SQRT(p * (1 - p) / stays)), 1) AS upper_pct,
    CASE
        WHEN stays < 30 THEN 'Too small'
        WHEN p - 1.96 * SQRT(p * (1 - p) / stays) > overall_p THEN 'Above'
        WHEN p + 1.96 * SQRT(p * (1 - p) / stays) < overall_p THEN 'Below'
        ELSE 'Not clear'
    END AS vs_overall
FROM (
    SELECT
        destination_group,
        los_band,
        COUNT(*) AS stays,
        SUM(readmit_flag) AS readmissions,
        1.0 * SUM(readmit_flag) / COUNT(*) AS p,
        (SELECT 1.0 * SUM(readmit_flag) / COUNT(*) FROM pneumonia_clean) AS overall_p
    FROM pneumonia_clean
    GROUP BY destination_group, los_band
)
ORDER BY destination_group, los_band;