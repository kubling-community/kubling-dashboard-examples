if (Test-Path ".\gen-bundles.ps1") {
    & .\gen-bundles.ps1
} else {
    Write-Host "gen-bundles.ps1 not found. Ensure you are in the correct directory." -ForegroundColor Red
    exit 1
}

if (Test-Path "./superset_home/superset.zip") {
    Expand-Archive -Path "./superset_home/superset.zip" -DestinationPath "./superset_home" -Force
} else {
    Write-Host "Error: ./superset_home/superset.zip not found." -ForegroundColor Red
    exit 1
}

$env:SECRET_KEY = "WMq6YJfpeYEytXEs8P2NN8sX/awDASKfx6wGBDUi+YRbIfQqhYaQM5lD"
docker compose up
