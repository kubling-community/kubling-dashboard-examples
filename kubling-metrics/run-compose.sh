#!/bin/bash
sh gen-bundles.sh
unzip -o ./superset_home/superset.zip superset.db -d ./superset_home
SECRET_KEY="WMq6YJfpeYEytXEs8P2NN8sX/awDASKfx6wGBDUi+YRbIfQqhYaQM5lD" docker compose up