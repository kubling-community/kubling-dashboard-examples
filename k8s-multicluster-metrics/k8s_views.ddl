CREATE VIEW CURRENT_POD_CPU_REQ_TOTAL AS
    SELECT
        SUM(
            CASE
                WHEN jsonPathAsString(pc.resources__requests, '$.cpu') IS NULL THEN
                    CAST(0 AS double)
                WHEN jsonPathAsString(pc.resources__requests, '$.cpu') LIKE '%m' THEN
                    CAST(REPLACE(jsonPathAsString(pc.resources__requests, '$.cpu'), 'm', '') AS double) / 1000
                ELSE
                    CAST(jsonPathAsString(pc.resources__requests, '$.cpu') AS double)
            END
        ) AS total_cpu_cores
    FROM {{ schema.name }}.POD_CONTAINER pc

CREATE VIEW CURRENT_POD_MEM_REQ_TOTAL AS
    SELECT 
        (SUM(
            CASE
    	        WHEN jsonPathAsString(pc.resources__requests, '$.memory') IS NULL THEN 
    	        	CAST(0 AS double)
                WHEN jsonPathAsString(pc.resources__requests, '$.memory') LIKE '%Mi' THEN 
                    CAST(REPLACE(jsonPathAsString(pc.resources__requests, '$.memory'), 'Mi', '') AS double) * 1048576
                WHEN jsonPathAsString(pc.resources__requests, '$.memory') LIKE '%Gi' THEN 
                    CAST(REPLACE(jsonPathAsString(pc.resources__requests, '$.memory'), 'Gi', '') AS double) * 1073741824
                WHEN jsonPathAsString(pc.resources__requests, '$.memory') LIKE '%MB' THEN 
                    CAST(REPLACE(jsonPathAsString(pc.resources__requests, '$.memory'), 'MB', '') AS double) * 1000000
                WHEN jsonPathAsString(pc.resources__requests, '$.memory') LIKE '%M' THEN 
                    CAST(REPLACE(jsonPathAsString(pc.resources__requests, '$.memory'), 'M', '') AS double) * 1000000
                WHEN jsonPathAsString(pc.resources__requests, '$.memory') LIKE '%GB' THEN 
                    CAST(REPLACE(jsonPathAsString(pc.resources__requests, '$.memory'), 'GB', '') AS double) * 1000000000
                ELSE CAST(jsonPathAsString(pc.resources__requests, '$.memory') AS double)
            END
        ) / 1073741824) AS total_memory_gb
    FROM {{ schema.name }}.POD_CONTAINER pc;