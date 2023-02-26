@echo on
setlocal enabledelayedexpansion

:: downlaod application

::	search application name	
::	winget search "<application name>"

:: list installed application
:: winget list

set list=AnyDeskSoftwareGmbH.AnyDesk
set list=%list%;voidtools.Everything
set list=%list%;GitHub.GitHubDesktop
set list=%list%;Git.Git
set list=%list%;Google.Chrome
set list=%list%;JetBrains.IntelliJIDEA.Community
set list=%list%;Microsoft.Edge
set list=%list%;Notepad++.Notepad++
set list=%list%;Microsoft.OneDrive
set list=%list%;Microsoft.Teams
set list=%list%;WhatsApp.WhatsApp
set list=%list%;Telegram.TelegramDesktop
set list=%list%;OpenJS.NodeJS.LTS
set list=%list%;Google.Drive
set list=%list%;Microsoft.Teams
set list=%list%;Microsoft.VisualStudioCode
set list=%list%;Oracle.VirtualBox
set list=%list%;Adobe.Acrobat.Reader.32-bit
set list=%list%;Microsoft.PowerToys
set list=%list%;Microsoft.DotNet.DesktopRuntime.6
set list=%list%;Microsoft.VCRedist.2015+.x64
set list=%list%;EclipseAdoptium.Temurin.17.JDK
set list=%list%;Microsoft.PowerShell


(for %%a in (%list%) do ( 
	winget list | findstr -i %%a
	if !ERRORLEVEL! == 0 (
		echo %%a already installed
	) else if !ERRORLEVEL! == 1 (
		winget install --id %%a --accept-package-agreements --accept-source-agreements 
		if !ERRORLEVEL! EQU 0 Echo %%a installed successfully.  	
	)else (
	   echo ErrorLevel is !ERRORLEVEL!
	)
))

pause