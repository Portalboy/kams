docker stop starmud-dev
docker rm starmud-dev
# Prod
# docker run --name kams -v /ssd-pny/docker/mud/kams-data/storage:/storage -p 25579:8888 -d kams:latest

# Dev
docker run --name starmud-dev -v "C:\SykkenData\Dev\gitprojects\kams\app\storage:/storage" -v "C:\SykkenData\Dev\gitprojects\kams\app\conf:/conf" -p 25581:8888 -d -e "INIT_PAUSE=$true" starmud:latest
