@echo off
setlocal enabledelayedexpansion

:: Ruta del archivo de texto que contiene los nombres de usuarios
set "file=usuarios.txt"

:: Verifica si el archivo existe
if not exist %file% (
    echo El archivo %file% no existe.
    exit /b 1
)

:: Obtén la fecha actual en el formato YYYY_MM_DD
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set year=!datetime:~0,4!
set month=!datetime:~4,2!
set day=!datetime:~6,2!
set date=!year!_!month!_!day!

:: Nombre del archivo de resultados
set "output_file=resultado_%date%.txt"

:: Limpia el archivo de resultados si ya existe
if exist %output_file% del %output_file%

:: Recorre cada línea del archivo
for /f "tokens=*" %%A in (%file%) do (
    set "user=%%A"
    
    echo Ejecutando net user /do !user!
    net user /do !user! > temp.txt
    
    :: Bandera para saber si se encontró "Cuenta activa"
    set "found=0"
    
    :: Filtra la línea que contiene "Cuenta activa"
    for /f "tokens=*" %%B in ('findstr /c:"Cuenta activa" temp.txt') do (
        echo Usuario: !user!
        echo %%B
        echo !user!, Cuenta activa %%B >> %output_file%
        set "found=1"
    )

    :: Si no se encontró "Cuenta activa", agregar "Cuenta no encontrada"
    if !found! equ 0 (
        echo !user!, Cuenta no encontrada >> %output_file%
    )
)

:: Elimina el archivo temporal
del temp.txt

endlocal
pause
