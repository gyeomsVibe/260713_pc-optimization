@echo off
echo ========================================
echo System Fixer
echo ========================================
echo.
FOR /F "skip=2 tokens=2,*" %%A IN ('reg query HKCU\Environment /v PATH 2^>nul') DO SET "USER_PATH=%%B"
if not defined USER_PATH (
    setx PATH "C:\Windows\System32\WindowsPowerShell\v1.0\"
) else (
    echo %USER_PATH% | findstr /i /c:"WindowsPowerShell" >nul
    if errorlevel 1 (
        setx PATH "%USER_PATH%;C:\Windows\System32\WindowsPowerShell\v1.0\"
    ) else (
        echo PowerShell path already exists.
    )
)
echo.
echo ========================================
echo FIX COMPLETE!
echo Close this window and RESTART Antigravity IDE.
echo ========================================
pause
