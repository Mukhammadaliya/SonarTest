@echo off
cd web/biruni && sass main.scss main.css --no-source-map -s compressed && cd ../.. && sbt build && pause
