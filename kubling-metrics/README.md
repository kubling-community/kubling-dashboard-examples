# Kubling Metrics

## How Does It Work?

Kubling exposes telemetry metrics through an HTTP endpoint and as a `SYSTEM` table. However, Kubling does not store 
historical metric values internally, as it is not designed for that purpose.

Operational dashboards often rely on both current metric snapshots and time-based trendlines. 
This sample demonstrates how to achieve that by integrating Kubling with TimescaleDB and Superset.

### Workflow:
1. **Metrics Collection**:  
   Kubling metrics are captured and inserted into TimescaleDB, which serves as the time-series storage.

2. **Data Transfer**:  
   TimescaleDB is configured as a data source in Kubling. A scheduled script in Kubling performs an `INSERT INTO` operation to copy current metric values into TimescaleDB.

3. **Data Visualization**:  
   Superset is connected to Kubling (not directly to TimescaleDB). All the time-series data and other information are queried through Kubling, making it the single interface for data consumption.

## Run it
This sample requires `docker compose` installed on your machine. For more information please visit the [official documentation](https://docs.docker.com/compose/install/).

In the console, just run the following command:
```bash
sh run-compose.sh
```

Please note that the script contains a `SECRET_KEY` environment variable, needed to load the superset's database included with this sample.