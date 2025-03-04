$CurrentDir = Get-Location
docker run --rm -v "${CurrentDir}:/base" kubling/kubling-cli:latest bundle genmod /base/descriptor -o /base/dashboard-descriptor-bundle.zip --parse