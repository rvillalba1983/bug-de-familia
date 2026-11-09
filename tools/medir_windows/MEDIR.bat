@echo off
rem Bug de Familia: medicion en la grafica real. Tarda unos 20 minutos.
rem Deja el portatil enchufado y no toques nada hasta que ponga TERMINADO.
cd /d "%~dp0"
if not exist BugDeFamilia_medir.exe (
  echo No encuentro el juego. Descomprime el zip entero en una carpeta y ejecuta MEDIR.bat desde alli.
  pause
  exit /b 1
)
if exist medicion.txt del medicion.txt

rem Rondas alternadas: si el portatil se calienta, afecta por igual a los dos modos.
for %%R in (1 2 3) do (
  for %%C in (ciudad caminando pelea pausa) do (
    call :medir %%C "" %%R opengl3
    call :medir %%C "" %%R opengl3_angle
  )
)

rem Lo que cuesta cada parte, con los dos modos.
for %%R in (1 2) do (
  for %%C in (ciudad caminando) do (
    for %%Q in (protagonista personajes paredes fachadas ambiente particulas) do (
      call :medir %%C %%Q p%%R opengl3
      call :medir %%C %%Q p%%R opengl3_angle
    )
  )
)

rem Personajes al tamano anterior, para ver cuanto aporta el 50 por ciento.
for %%R in (1 2 3) do (
  for %%C in (ciudad caminando) do (
    call :medir %%C "" t%%R opengl3 1.0
    call :medir %%C "" t%%R opengl3_angle 1.0
  )
)

echo.
echo TERMINADO. Enviame el archivo medicion.txt de esta carpeta.
pause
exit /b 0

:medir
echo Midiendo: %~1 quitar=%~2 ronda=%~3 driver=%~4
set CASO=%~1
set QUITAR=%~2
set RONDA=%~3
set ESCALA=%~5
start /wait "" BugDeFamilia_medir.exe --rendering-driver %~4
exit /b 0
