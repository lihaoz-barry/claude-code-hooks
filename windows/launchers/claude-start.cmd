@echo off
REM Claude Code Starter - Global Command
REM This batch file allows you to run "claude-start" from anywhere

powershell -ExecutionPolicy Bypass -File "%~dp0claude-start-with-window-recording.ps1" %*
