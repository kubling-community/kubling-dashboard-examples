const podRequests = `
    SELECT
        p.clusterName,
        COALESCE(CAST(jsonJqAsString(p.spec__containers, 'def cpu: if endswith("n") then (rtrimstr("n") | tonumber) / 1000000000 elif endswith("u") then (rtrimstr("u") | tonumber) / 1000000 elif endswith("m") then (rtrimstr("m") | tonumber) / 1000 elif endswith("k") then (rtrimstr("k") | tonumber) * 1000 elif endswith("M") then (rtrimstr("M") | tonumber) * 1000000 elif endswith("G") then (rtrimstr("G") | tonumber) * 1000000000 elif endswith("T") then (rtrimstr("T") | tonumber) * 1000000000000 elif endswith("P") then (rtrimstr("P") | tonumber) * 1000000000000000 elif endswith("E") then (rtrimstr("E") | tonumber) * 1000000000000000000 else tonumber end; (. // []) | map((.resources.requests.cpu // "0") | cpu) | add // 0') AS double), 0) AS app_cpu,
        COALESCE(CAST(jsonJqAsString(p.spec__initContainers, 'def cpu: if endswith("n") then (rtrimstr("n") | tonumber) / 1000000000 elif endswith("u") then (rtrimstr("u") | tonumber) / 1000000 elif endswith("m") then (rtrimstr("m") | tonumber) / 1000 elif endswith("k") then (rtrimstr("k") | tonumber) * 1000 elif endswith("M") then (rtrimstr("M") | tonumber) * 1000000 elif endswith("G") then (rtrimstr("G") | tonumber) * 1000000000 elif endswith("T") then (rtrimstr("T") | tonumber) * 1000000000000 elif endswith("P") then (rtrimstr("P") | tonumber) * 1000000000000000 elif endswith("E") then (rtrimstr("E") | tonumber) * 1000000000000000000 else tonumber end; (. // []) | map((.resources.requests.cpu // "0") | cpu) | max // 0') AS double), 0) AS init_cpu,
        COALESCE(CAST(jsonJqAsString(p.spec__overhead, 'def cpu: if endswith("n") then (rtrimstr("n") | tonumber) / 1000000000 elif endswith("u") then (rtrimstr("u") | tonumber) / 1000000 elif endswith("m") then (rtrimstr("m") | tonumber) / 1000 elif endswith("k") then (rtrimstr("k") | tonumber) * 1000 elif endswith("M") then (rtrimstr("M") | tonumber) * 1000000 elif endswith("G") then (rtrimstr("G") | tonumber) * 1000000000 elif endswith("T") then (rtrimstr("T") | tonumber) * 1000000000000 elif endswith("P") then (rtrimstr("P") | tonumber) * 1000000000000000 elif endswith("E") then (rtrimstr("E") | tonumber) * 1000000000000000000 else tonumber end; (. // {}) | (.cpu // "0") | cpu') AS double), 0) AS overhead_cpu,
        COALESCE(CAST(jsonJqAsString(p.spec__containers, 'def bytes: if endswith("Ki") then (rtrimstr("Ki") | tonumber) * 1024 elif endswith("Mi") then (rtrimstr("Mi") | tonumber) * 1048576 elif endswith("Gi") then (rtrimstr("Gi") | tonumber) * 1073741824 elif endswith("Ti") then (rtrimstr("Ti") | tonumber) * 1099511627776 elif endswith("Pi") then (rtrimstr("Pi") | tonumber) * 1125899906842624 elif endswith("Ei") then (rtrimstr("Ei") | tonumber) * 1152921504606846976 elif endswith("m") then (rtrimstr("m") | tonumber) / 1000 elif endswith("k") then (rtrimstr("k") | tonumber) * 1000 elif endswith("M") then (rtrimstr("M") | tonumber) * 1000000 elif endswith("G") then (rtrimstr("G") | tonumber) * 1000000000 elif endswith("T") then (rtrimstr("T") | tonumber) * 1000000000000 elif endswith("P") then (rtrimstr("P") | tonumber) * 1000000000000000 elif endswith("E") then (rtrimstr("E") | tonumber) * 1000000000000000000 else tonumber end; (. // []) | map((.resources.requests.memory // "0") | bytes) | add // 0') AS double), 0) AS app_memory,
        COALESCE(CAST(jsonJqAsString(p.spec__initContainers, 'def bytes: if endswith("Ki") then (rtrimstr("Ki") | tonumber) * 1024 elif endswith("Mi") then (rtrimstr("Mi") | tonumber) * 1048576 elif endswith("Gi") then (rtrimstr("Gi") | tonumber) * 1073741824 elif endswith("Ti") then (rtrimstr("Ti") | tonumber) * 1099511627776 elif endswith("Pi") then (rtrimstr("Pi") | tonumber) * 1125899906842624 elif endswith("Ei") then (rtrimstr("Ei") | tonumber) * 1152921504606846976 elif endswith("m") then (rtrimstr("m") | tonumber) / 1000 elif endswith("k") then (rtrimstr("k") | tonumber) * 1000 elif endswith("M") then (rtrimstr("M") | tonumber) * 1000000 elif endswith("G") then (rtrimstr("G") | tonumber) * 1000000000 elif endswith("T") then (rtrimstr("T") | tonumber) * 1000000000000 elif endswith("P") then (rtrimstr("P") | tonumber) * 1000000000000000 elif endswith("E") then (rtrimstr("E") | tonumber) * 1000000000000000000 else tonumber end; (. // []) | map((.resources.requests.memory // "0") | bytes) | max // 0') AS double), 0) AS init_memory,
        COALESCE(CAST(jsonJqAsString(p.spec__overhead, 'def bytes: if endswith("Ki") then (rtrimstr("Ki") | tonumber) * 1024 elif endswith("Mi") then (rtrimstr("Mi") | tonumber) * 1048576 elif endswith("Gi") then (rtrimstr("Gi") | tonumber) * 1073741824 elif endswith("Ti") then (rtrimstr("Ti") | tonumber) * 1099511627776 elif endswith("Pi") then (rtrimstr("Pi") | tonumber) * 1125899906842624 elif endswith("Ei") then (rtrimstr("Ei") | tonumber) * 1152921504606846976 elif endswith("m") then (rtrimstr("m") | tonumber) / 1000 elif endswith("k") then (rtrimstr("k") | tonumber) * 1000 elif endswith("M") then (rtrimstr("M") | tonumber) * 1000000 elif endswith("G") then (rtrimstr("G") | tonumber) * 1000000000 elif endswith("T") then (rtrimstr("T") | tonumber) * 1000000000000 elif endswith("P") then (rtrimstr("P") | tonumber) * 1000000000000000 elif endswith("E") then (rtrimstr("E") | tonumber) * 1000000000000000000 else tonumber end; (. // {}) | (.memory // "0") | bytes') AS double), 0) AS overhead_memory
    FROM k8s.POD p
    WHERE COALESCE(p.status__phase, '') NOT IN ('Succeeded', 'Failed')
`;

DBEngine.executeUpdatePrivileged(
    contextVars.vdb_name,
    `
        SELECT
            CURRENT_TIMESTAMP,
            'k8s.cpu',
            requests.clusterName,
            COALESCE(SUM(
                CASE WHEN requests.app_cpu >= requests.init_cpu
                     THEN requests.app_cpu ELSE requests.init_cpu END
                + requests.overhead_cpu
            ), 0)
        INTO "${contextVars.timescale_metrics_schema}.historical"
        FROM (${podRequests}) requests
        GROUP BY requests.clusterName
    `
);

DBEngine.executeUpdatePrivileged(
    contextVars.vdb_name,
    `
        SELECT
            CURRENT_TIMESTAMP,
            'k8s.mem',
            requests.clusterName,
            COALESCE(SUM(
                CASE WHEN requests.app_memory >= requests.init_memory
                     THEN requests.app_memory ELSE requests.init_memory END
                + requests.overhead_memory
            ), 0) / 1073741824
        INTO "${contextVars.timescale_metrics_schema}.historical"
        FROM (${podRequests}) requests
        GROUP BY requests.clusterName
    `
);
