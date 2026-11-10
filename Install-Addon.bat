@echo off
chcp 65001 >nul
title Instalador ToyFinder - World of Warcraft

echo ======================================================================
echo             ToyFinder (Midnight & Retail) - Instalador Automático
echo ======================================================================
echo.

set "SOURCE_DIR=%~dp0ToyFinder"

if not exist "%SOURCE_DIR%\ToyFinder.toc" (
    echo [ERRO] A pasta 'ToyFinder' não foi encontrada neste diretório!
    echo Certifique-se de executar o ficheiro no mesmo local onde está a pasta do addon.
    echo.
    pause
    exit /b 1
)

echo A procurar a instalação do World of Warcraft no seu computador...
echo.

set "TARGET_DIR="

:: Locais comuns de instalação
if exist "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
) else if exist "C:\Program Files\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=C:\Program Files\World of Warcraft\_retail_\Interface\AddOns"
) else if exist "D:\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=D:\World of Warcraft\_retail_\Interface\AddOns"
) else if exist "E:\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=E:\World of Warcraft\_retail_\Interface\AddOns"
) else if exist "D:\Games\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=D:\Games\World of Warcraft\_retail_\Interface\AddOns"
) else if exist "E:\Games\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=E:\Games\World of Warcraft\_retail_\Interface\AddOns"
) else if exist "C:\Games\World of Warcraft\_retail_\Interface\AddOns" (
    set "TARGET_DIR=C:\Games\World of Warcraft\_retail_\Interface\AddOns"
)

if defined TARGET_DIR (
    echo [ENCONTRADO] World of Warcraft detetado em:
    echo "%TARGET_DIR%"
    echo.
    goto :INSTALL
)

:PROMPT_USER
echo Não foi possível detetar o caminho padrão do WoW automaticamente.
echo Por favor, cole ou digite o caminho da sua pasta de AddOns.
echo Exemplo: C:\World of Warcraft\_retail_\Interface\AddOns
echo.
set /p "TARGET_DIR=Caminho dos AddOns: "

if "%TARGET_DIR%"=="" (
    echo Instalação cancelada pelo utilizador.
    pause
    exit /b 0
)

:: Remover aspas se o utilizador colou com aspas
set TARGET_DIR=%TARGET_DIR:"=%

if not exist "%TARGET_DIR%" (
    echo.
    echo [AVISO] O caminho inserido não existe. Deseja criá-lo? (S/N)
    set /p "CONFIRM=Escolha: "
    if /i "%CONFIRM%"=="S" (
        mkdir "%TARGET_DIR%" 2>nul
    ) else (
        goto :PROMPT_USER
    )
)

:INSTALL
echo.
echo A instalar ToyFinder...
xcopy "%SOURCE_DIR%" "%TARGET_DIR%\ToyFinder" /E /I /Y /Q >nul

if %ERRORLEVEL% EQU 0 (
    echo ======================================================================
    echo [SUCESSO] ToyFinder instalado com sucesso!
    echo Local: "%TARGET_DIR%\ToyFinder"
    echo ======================================================================
    echo.
    echo Já pode iniciar o World of Warcraft!
    echo Dentro do jogo, use o comando /tf ou clique no botão do minimapa.
    echo.
) else (
    echo [ERRO] Ocorreu um erro ao copiar os ficheiros.
    echo Tente executar este ficheiro como Administrador ou copie manualmente
    echo a pasta 'ToyFinder' para a pasta 'Interface\AddOns' do seu jogo.
    echo.
)

pause
exit /b 0
