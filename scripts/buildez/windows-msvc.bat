@echo off
setlocal enabledelayedexpansion

echo === BLauncher: Windows MSVC build ===

set "PROJECT_ROOT=%~dp0..\.."
set "BUILD_DIR=%PROJECT_ROOT%\build"
set "INSTALL_DIR=%PROJECT_ROOT%\install"
set "BUILD_TYPE=%~1"
if "%BUILD_TYPE%"=="" set "BUILD_TYPE=Release"

echo Project: %PROJECT_ROOT%
echo Build type: %BUILD_TYPE%
echo.

REM Check for Visual Studio
where cl >nul 2>&1
if errorlevel 1 (
    echo ERROR: cl.exe not found. Run this from "Developer Command Prompt for VS 2022"
    echo Or run: "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"
    exit /b 1
)

REM Check for vcpkg
if "%VCPKG_ROOT%"=="" (
    echo ERROR: VCPKG_ROOT is not set.
    echo Install vcpkg: https://vcpkg.io/en/getting-started
    exit /b 1
)

REM Init submodules
cd /d "%PROJECT_ROOT%"
git submodule update --init --recursive

REM Clean
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%INSTALL_DIR%" rmdir /s /q "%INSTALL_DIR%"

REM Configure
echo.
echo === Configuring ===
cmake --preset windows_msvc
if errorlevel 1 (
    echo Configuration failed!
    exit /b 1
)

REM Build
echo.
echo === Building (%BUILD_TYPE%) ===
cmake --build "%BUILD_DIR%" --config %BUILD_TYPE%
if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

REM Install
echo.
echo === Installing ===
cmake --install "%BUILD_DIR%" --config %BUILD_TYPE%

REM Portable
echo.
echo === Creating portable build ===
set "PORTABLE_DIR=%PROJECT_ROOT%\install-portable"
if exist "%PORTABLE_DIR%" rmdir /s /q "%PORTABLE_DIR%"
xcopy /e /i /q "%INSTALL_DIR%" "%PORTABLE_DIR%"
cmake --install "%BUILD_DIR%" --config %BUILD_TYPE% --prefix "%PORTABLE_DIR%" --component portable

REM Installer
echo.
echo === Building NSIS installer ===
where makensis >nul 2>&1
if errorlevel 1 (
    echo NOTE: makensis not found, skipping installer.
    echo Download NSIS from: https://nsis.sourceforge.io/
) else (
    cd /d "%INSTALL_DIR%"
    makensis -NOCD "%BUILD_DIR%\program_info\win_install.nsi"
)

echo.
echo === Done ===
echo Install dir:  %INSTALL_DIR%
echo Portable dir: %PORTABLE_DIR%

endlocal
