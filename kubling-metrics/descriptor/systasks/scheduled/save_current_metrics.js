DBEngine.executeUpdate(
    contextVars.vdb_name,
    "SELECT CURRENT_TIMESTAMP, m.name, m.val " +
    "INTO tsdb_metrics.\"kbl_metrics.historical\" " +
    "FROM SYSMETRICS.METRICS m " +
    "WHERE m.name LIKE 'kubling%'"
);