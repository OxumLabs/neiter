#!/bin/bash
app_path="$1"
wine reg add "HKEY_CURRENT_USER\Software\Wine\Wine" /v RunAsAdmin /t REG_DWORD /d 1 /f
wine "$app_path"
wine reg delete "HKEY_CURRENT_USER\Software\Wine\Wine" /v RunAsAdmin /f
