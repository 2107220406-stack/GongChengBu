@echo off
chcp 65001 >nul

set "SERVICE=MySQL97"

:: 先检查服务是否存在
sc query "%SERVICE%" >nul 2>&1
if errorlevel 1 (
    echo 未找到服务 "%SERVICE%"，请确认服务名是否正确。
    pause
    exit /b 1
)

:: 查询服务是否正在运行
sc query "%SERVICE%" | findstr /R /C:"STATE.*RUNNING" >nul

if not errorlevel 1 (
    echo 检测到 "%SERVICE%" 正在运行，正在停止...
    net stop "%SERVICE%"
    if errorlevel 1 echo 停止失败：请以管理员身份运行，或检查权限/依赖服务。
) else (
    echo 检测到 "%SERVICE%" 未运行，正在启动...
    net start "%SERVICE%"
    if errorlevel 1 echo 启动失败：请以管理员身份运行，或检查服务是否被禁用/依赖服务。
)

echo.
pause
exit /b