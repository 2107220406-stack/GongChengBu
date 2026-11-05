@echo off
chcp 65001 >nul
:: 查询 MySQL97 服务状态
sc query "MySQL97" | find "RUNNING" > nul

:: 根据上一条命令的返回值判断
if %errorlevel%==0 (
    echo 检测到 MySQL97 服务正在运行，正在停止...
    net stop "MySQL97"
) else (
    echo 检测到 MySQL97 服务已停止，正在启动...
    net start "MySQL97"
)

echo.
echo 操作完成，按任意键退出...
exit