:: Created by npm, please don't edit manually.
@IF EXIST "%~dp0\node.exe" (
  "%~dp0\node.exe"  "%~dp0\..\coffee-script\bin\cake" %*
) ELSE (
  node  "%~dp0\..\coffee-script\bin\cake" %*
)