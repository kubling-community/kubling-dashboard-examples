DBEngine.executeUpdatePrivileged(
    contextVars.vdb_name,
    "SELECT CURRENT_TIMESTAMP, m.name, m.val " +
    `INTO \"${contextVars.timescale_metrics_schema}.historical\" ` +
    "FROM SYSMETRICS.METRICS m " +
    "WHERE m.name LIKE 'kubling%'"
);
