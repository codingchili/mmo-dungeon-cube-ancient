color 0a
title Relauncher
cls
:TO
REBOOT
rmdir /S /Q conf
start PatcherProj.exe
pause
taskkill /f /im Lobby.exe
GOTO TO