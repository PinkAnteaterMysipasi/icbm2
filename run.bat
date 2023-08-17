@echo off
set /p pbport= "Port pro pocketbase: " 
set /p webport= "Port pro webserver: " 
start ./pb/pocketbase serve --http localhost:%pbport%
start "" "./bin/icbm2" %webport%