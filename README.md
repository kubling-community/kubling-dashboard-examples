# Kubling Dashboard Examples

[![Kubling license](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE)

This collection provides **ready-to-use resources** to help you get started with Kubling and explore powerful dashboards 
tailored for various use cases. Each example includes Kubling Modules, predefined dashboards, and all necessary configurations 
to streamline your setup.

## Repository Structure

Each directory in this repository represents a distinct use case or integration. Inside each folder, you will find:
- **Kubling Resources**: Preconfigured descriptor and data sources modules, app configuration and properties.
- **Predefined Dashboards**: Dashboards tailored to visualize specific data sources or use cases.
- **Docker Compose Configurations**: Scripts to quickly spin up the required services and Kubling environment.
- **Documentation**: Instructions to guide you through the setup process.

### Important Directories
- `descriptor`: contains the main Kubling descriptor module.
- `db-init-scripts`: contains the TimescaleDB initialization script.
- `superset_home`: contains the Superset's preconfigured Database that contains data sources, datasets and dashboards.

## Examples Included

| Example Name             | Description                                                                  |
|--------------------------|------------------------------------------------------------------------------|
| **`kubling-metrics`**    | Visualize data from GitHub repositories, including commits and contributors. |
| **`k8s-monitoring`**     | Dashboards for Kubernetes cluster metrics and resource management.           |

## Components

All examples use the following components:
- **Kubling**: As the main database.
- **TimescaleDB**: As the time-series database.
- **Superset**: For building and visualizing the dashboard.

## Getting Started

### Prerequisites
To use these examples, you will need:
- **Docker** and **Docker Compose** installed on your system.
- Basic knowledge of Kubling and dashboard configuration.
- Access to the relevant data sources for each example.

### Running an Example
1. Clone this repository:
   ```bash
   git clone https://github.com/your-organization/kubling-dashboard-examples.git
   cd kubling-dashboard-examples
   ```
2. Navigate to the desired example directory:
   ```bash
   cd kubling-metrics
   ```
3. Run the Docker Compose setup:
   ```bash
    sh run-compose.sh
   ```
4. Access Kubling and the dashboard in your browser:
  - Kubling Console: http://localhost:8282/console
  - Dashboard (Superset): http://localhost:8088

## Community Edition Limitations
This edition has certain limitations that may affect the behavior of your dashboards:
- Scripts defined in the Descriptor module are limited to **3**.
- Scripts defined in the Data Source module are limited to **1**.
- The Authentication Script Delegate is limited to **5 concurrent script contexts**.

These limitations should not impede the creation of dashboards or the setup of Kubling's development environments.

### Customizing Examples
Examples are just starting points you can use as a foundational idea for your own requirements and are not intended 
to be used in production environments.

## Contributing
We welcome contributions to expand this repository and cover as many use cases as possible!
If you have an idea for a new example or improvements to existing ones, feel free to:
- Fork the repository.
- Create a new branch.
- Submit a pull request.

