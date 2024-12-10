const sanitize = (value) => value.replace(/'/g, "''");

export function logIt(user, success, result) {
    const tableName = `tsdb_audit."${contextVars.timescale_audit_schema}.log_events"`;

    const query = `
        INSERT INTO ${tableName} ("_time", "_user", "_result", "_success")
        VALUES (CURRENT_TIMESTAMP, '${sanitize(user)}', '${sanitize(result)}', ${success});
    `;

    DBEngine.executeUpdate(contextVars.vdb_name, query);
}