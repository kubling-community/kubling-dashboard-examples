// CPU
DBEngine.executeUpdate(
    contextVars.vdb_name,
    `
        SELECT CURRENT_TIMESTAMP, 'k8s.cpu',
        	(SELECT SUM(total_cpu_cores) FROM k8s.CURRENT_POD_CPU_REQ_TOTAL)
        INTO tsdb_metrics."kbl_metrics.historical"
    `
);

// Memory
DBEngine.executeUpdate(
    contextVars.vdb_name,
    `
        SELECT CURRENT_TIMESTAMP, 'k8s.mem',
            (SELECT SUM(total_memory_gb) FROM k8s.CURRENT_POD_MEM_REQ_TOTAL)
        INTO tsdb_metrics."kbl_metrics.historical"
    `
);