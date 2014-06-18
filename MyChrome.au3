#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon_1.ico
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=可自动更新的 Google Chrome 便携版
#AutoIt3Wrapper_Res_Description=Google Chrome 便携版
#AutoIt3Wrapper_Res_Fileversion=2.9.4.0
#AutoIt3Wrapper_Res_LegalCopyright=(C)甲壳虫<jdchenjian@gmail.com>
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_AU3Check_Parameters=-q
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------
	AutoIt Version: 3.3.10.2
	作者:        甲壳虫 < jdchenjian@gmail.com >
	网站:        http://code.google.com/p/my-chrome/
	脚本说明：   MyChrome - 可自动更新的 Google Chrome 便携版
#ce ----------------------------------------------------------------------------
#include <Date.au3>
#include <Constants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <WinAPIFiles.au3>
#include <APIFilesConstants.au3>
#include <WinAPI.au3>
#include <WinAPIProc.au3>
#include <WinAPIReg.au3>
#include <APIRegConstants.au3>
#include <WinAPIDiag.au3>
#include <Security.au3>
#include "WinHttp.au3" ; http://www.autoitscript.com/forum/topic/84133-winhttp-functions/
#include "SimpleMultiThreading.au3"

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 3) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayOnEventMode", 1)
Opt("GUIOnEventMode", 1)
Opt("WinTitleMatchMode", 4)

Global Const $AppVersion = "2.9.4" ; MyChrome version
Global $AppName, $inifile, $FirstRun = 0, $ChromePath, $ChromeDir, $ChromeExe, $UserDataDir, $Params
Global $CacheDir, $CacheSize, $PortableParam
Global $LastCheckUpdate, $UpdateInterval, $Channel, $IsUpdating = 0, $AskBeforeUpdateChrome, $x86 = 0
Global $EnableProxy, $ProxySever, $ProxyPort
Global $AutoUpdateApp, $LastCheckAppUpdate
Global $RunInBackground, $ExApp, $ExAppAutoExit, $ExApp2, $AppPID, $ExAppPID
Global $TaskBarDir = @AppDataDir & "\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
Global $TaskBarLastChange
Global $aExApp, $aExApp2, $aExAppPID[2]

Global $hSettings, $SettingsOK
Global $hSettingsOK, $hSettingsApply, $hStausbar
Global $hChromePath, $hGetChromePath, $hChromeSource, $hCheckUpdate
Global $hChannel, $hx86, $hUpdateInterval, $hLatestChromeVer, $hCurrentVer, $hUserDataDir, $hCopyData
Global $hAutoUpdateApp, $hCacheDir, $hSelectCacheDir, $hCacheSize
Global $hParams, $hDownloadThreads, $hEnableProxy, $hProxySever, $hProxyPort
Global $hAskBeforeUpdateChrome
Global $hRunInBackground, $hExApp, $hExAppAutoExit, $hExApp2

Global $ChromeFileVersion, $ChromeLastChange, $LatestChromeVer, $LatestChromeUrl
Global $DefaultChromeDir, $DefaultChromeVer, $DefaultUserDataDir
Global $TrayTipProgress = 0
Global $iThreadPid, $DownloadThreads
Global $aDlInfo[6]
;~ 0 - Latest Chrome Version / Bytes read so far
;~ 1 - Latest Chrome url / The size of the download (this may not always be present)
;~ 2 - Set to True if the download is complete, False if the download is still ongoing.
;~ 3 - True if the download was successful. If this is False then the next data member will be non-zero.
;~ 4 - The error value for the download. The value itself is arbitrary. Testing that the value is non-zero is sufficient for determining if an error occurred.
;~ 5 - The extended value for the download. The value is arbitrary and is primarily only useful to the AutoIt developers.
Global $hEvent, $ClientKey, $Progid
Global $aREG[6][3] = [[$HKEY_CURRENT_USER, 'Software\Clients\StartMenuInternet'], _
		[$HKEY_LOCAL_MACHINE, 'Software\Clients\StartMenuInternet'], _
		[$HKEY_CLASSES_ROOT, 'ftp'], _
		[$HKEY_CLASSES_ROOT, 'http'], _
		[$HKEY_CLASSES_ROOT, 'https'], _
		[$HKEY_CLASSES_ROOT, '']] ; ChromeHTML.XXX
Global $aFileAsso[6] = [".htm", ".html", ".shtml", ".webp", ".xht", ".xhtml"]
Global $aUrlAsso[13] = ["ftp", "http", "https", "irc", "mailto", "mms", "news", "nntp", "sms", "smsto", "tel", "urn", "webcal"]

FileChangeDir(@ScriptDir)
$AppName = StringRegExpReplace(@ScriptName, "\.[^.]*$", "")
$inifile = @ScriptDir & "\" & $AppName & ".ini"
If Not FileExists($inifile) Then
	$FirstRun = 1
	IniWrite($inifile, "Settings", "AppVersion", $AppVersion)
	IniWrite($inifile, "Settings", "ChromePath", ".\Chrome\chrome.exe")
	IniWrite($inifile, "Settings", "UserDataDir", ".\User Data")
	IniWrite($inifile, "Settings", "CacheDir", "")
	IniWrite($inifile, "Settings", "CacheSize", 0)
	IniWrite($inifile, "Settings", "Channel", "Stable")
	IniWrite($inifile, "Settings", "x86", 1)
	IniWrite($inifile, "Settings", "LastCheckUpdate", "2014/05/01 00:00:00")
	IniWrite($inifile, "Settings", "UpdateInterval", 24)
	IniWrite($inifile, "Settings", "AskBeforeUpdateChrome", 1) ; 1 - 更新前询问
	IniWrite($inifile, "Settings", "EnableUpdateProxy", 0)
	IniWrite($inifile, "Settings", "UpdateProxy", "")
	IniWrite($inifile, "Settings", "UpdatePort", "")
	IniWrite($inifile, "Settings", "DownloadThreads", 3)
	IniWrite($inifile, "Settings", "Params", "")
	IniWrite($inifile, "Settings", "RunInBackground", 1)
	IniWrite($inifile, "Settings", "AutoUpdateApp", 1) ; 0 - 什么也不做，1 - 通知我，2 - 自动更新（无提示）
	IniWrite($inifile, "Settings", "LastCheckAppUpdate", "2014/01/01 00:00:00")
	IniWrite($inifile, "Settings", "CheckDefaultBrowser", 1)
	IniWrite($inifile, "Settings", "ExApp", "")
	IniWrite($inifile, "Settings", "ExAppAutoExit", 1)
	IniWrite($inifile, "Settings", "ExApp2", "")
EndIf
;~ 从配置文件读取参数
$ChromePath = IniRead($inifile, "Settings", "ChromePath", ".\Chrome\chrome.exe")
$UserDataDir = IniRead($inifile, "Settings", "UserDataDir", ".\User Data")
$CacheDir = IniRead($inifile, "Settings", "CacheDir", "")
$CacheSize = IniRead($inifile, "Settings", "CacheSize", 0) * 1
$Channel = IniRead($inifile, "Settings", "Channel", "Stable")
$x86 = IniRead($inifile, "Settings", "x86", 1) * 1
$LastCheckUpdate = IniRead($inifile, "Settings", "LastCheckUpdate", "2014/01/01 00:00:00")
$UpdateInterval = IniRead($inifile, "Settings", "UpdateInterval", 24)
$AskBeforeUpdateChrome = IniRead($inifile, "Settings", "AskBeforeUpdateChrome", 1) * 1
$EnableProxy = IniRead($inifile, "Settings", "EnableUpdateProxy", 0) * 1
$ProxySever = IniRead($inifile, "Settings", "UpdateProxy", "")
$ProxyPort = IniRead($inifile, "Settings", "UpdatePort", "")
$DownloadThreads = IniRead($inifile, "Settings", "DownloadThreads", 3) * 1
$Params = IniRead($inifile, "Settings", "Params", "")
$RunInBackground = IniRead($inifile, "Settings", "RunInBackground", 1) * 1
$AutoUpdateApp = IniRead($inifile, "Settings", "AutoUpdateApp", 1) * 1
$LastCheckAppUpdate = IniRead($inifile, "Settings", "LastCheckAppUpdate", "2014/01/01 00:00:00")
$CheckDefaultBrowser = IniRead($inifile, "Settings", "CheckDefaultBrowser", 1) * 1
$ExApp = IniRead($inifile, "Settings", "ExApp", "")
$ExAppAutoExit = IniRead($inifile, "Settings", "ExAppAutoExit", 1) * 1
$ExApp2 = IniRead($inifile, "Settings", "ExApp2", "")

#Region ========= 兼容旧版 MyChrome =========
If $AppVersion <> IniRead($inifile, "Settings", "AppVersion", "") Then
	$FirstRun = 1
	IniWrite($inifile, "Settings", "AppVersion", $AppVersion)
	If FileExists($AppName & "设置.vbs") Then FileDelete($AppName & "设置.vbs")
	If StringRight($Channel, 4) = "-x86" Then
		$Channel = StringTrimRight($Channel, 4)
		$x86 = 1
		IniWrite($inifile, "Settings", "Channel", $Channel)
		IniWrite($inifile, "Settings", "x86", $x86)
	ElseIf StringRight($Channel, 4) = "-x64" Then
		$Channel = StringTrimRight($Channel, 4)
		IniWrite($inifile, "Settings", "Channel", $Channel)
	EndIf
EndIf
#EndRegion ========= 兼容旧版 MyChrome =========

Opt("ExpandEnvStrings", 1)
EnvSet("APP", @ScriptDir)
;~ 第一个启动参数为“-set”，或第一次运行，Chrome.exe、用户数据文件夹不存在，则显示设置窗口
If ($cmdline[0] = 1 And $cmdline[1] = "-set") Or $FirstRun Or Not FileExists($ChromePath) Or Not FileExists($UserDataDir) Then
	CreateSettingsShortcut(@ScriptDir & "\" & $AppName & ".vbs")
	Settings()
EndIf

$ChromePath = FullPath($ChromePath)
SplitPath($ChromePath, $ChromeDir, $ChromeExe)
$UserDataDir = FullPath($UserDataDir)

If IsAdmin() And $cmdline[0] = 1 And $cmdline[1] = "-SetDefaultGlobal" Then
	CheckDefaultBrowser($ChromePath)
	Exit
EndIf

;~ write file First Run to prevent chrome from generate shortcut on desktop
If Not FileExists($ChromeDir & "\First Run") Then FileWrite($ChromeDir & "\First Run", "")

; 给带空格的外部参数加上引号。
For $i = 1 To $cmdline[0]
	If StringInStr($cmdline[$i], " ") Then
		$Params &= ' "' & $cmdline[$i] & '"'
	Else
		$Params &= ' ' & $cmdline[$i]
	EndIf
Next
;~ $PortableParam = '--no-default-browser-check'
$PortableParam = '--user-data-dir="' & $UserDataDir & '"'
If $CacheDir <> "" Then
	$CacheDir = FullPath($CacheDir)
	$PortableParam &= ' --disk-cache-dir="' & $CacheDir & '"'
EndIf
If $CacheSize <> 0 Then
	$PortableParam &= ' --disk-cache-size=' & $CacheSize
EndIf

Local $ChromeIsRunning = AppIsRunning($ChromePath)
If Not $ChromeIsRunning And FileExists($ChromeDir & "\~updated") Then
	ApplyUpdate()
EndIf

; start chrome
$AppPID = Run('"' & $ChromePath & '" ' & $PortableParam & ' ' & $Params, $ChromeDir)

FileChangeDir(@ScriptDir)
CreateSettingsShortcut(@ScriptDir & "\" & $AppName & ".vbs")

If $ChromeIsRunning Then
	; check if another instance of mychrome is running
	$list = ProcessList(StringRegExpReplace(@AutoItExe, ".*\\", ""))
	For $i = 1 To $list[0][0]
		If $list[$i][1] <> @AutoItPID And GetProcPath($list[$i][1]) = @AutoItExe Then
			Exit ;exit if another instance of mychrome/chrome is running
		EndIf
	Next
EndIf


; Start external apps
If $ExApp <> "" Then
	$aExApp = StringSplit($ExApp, "||", 1)
	ReDim $aExAppPID[$aExApp[0] + 1]
	$aExAppPID[0] = $aExApp[0]
	For $i = 1 To $aExApp[0]
		$match = StringRegExp($aExApp[$i], '^"(.*?)" *(.*)', 1)
		If @error Then
			$file = $aExApp[$i]
			$args = ""
		Else
			$file = $match[0]
			$args = $match[1]
		EndIf
		$file = FullPath($file)
		$aExAppPID[$i] = ProcessExists(StringRegExpReplace($file, '.*\\', ''))
		If Not $aExAppPID[$i] And FileExists($file) Then
			$aExAppPID[$i] = ShellExecute($file, $args, StringRegExpReplace($file, '\\[^\\]+$', ''))
		EndIf
	Next
EndIf

If $CheckDefaultBrowser Then
	CheckDefaultBrowser($ChromePath)
EndIf

If FileExists($TaskBarDir) Then
	CheckPinnedPrograms($ChromePath)
EndIf

Global $FirstUpdateCheck = 1
If Not $RunInBackground Then
	UpdateCheck()
	Exit
EndIf
; ========================= app ended if not run in background ================================


If $CheckDefaultBrowser Then ; register REG for notification
	$hEvent = _WinAPI_CreateEvent()
	For $i = 0 To UBound($aREG) - 1
		If $aREG[$i][1] Then
			$aREG[$i][2] = _WinAPI_RegOpenKey($aREG[$i][0], $aREG[$i][1], $KEY_NOTIFY)
			If $aREG[$i][2] Then
				_WinAPI_RegNotifyChangeKeyValue($aREG[$i][2], $REG_NOTIFY_CHANGE_LAST_SET, 1, 1, $hEvent)
			EndIf
		EndIf
	Next
EndIf
OnAutoItExitRegister("OnExit")
AdlibRegister("UpdateCheck", 10000)

Local $hWnd
WinWait("[REGEXPCLASS:(?i)Chrome]", "", 15)
$list = WinList("[REGEXPCLASS:(?i)Chrome]")
For $i = 1 To $list[0][0]
	If $AppPID = WinGetProcess($list[$i][1]) Then
		$hWnd = $list[$i][1]
		ExitLoop
	EndIf
Next
ReduceMemory()

; wait for chrome exit
While 1
	Sleep(500)

	If $hWnd Then
		If Not WinExists($hWnd) Then ExitLoop
	Else ; ProcessExists() is resource consuming than WinExists()
		If Not ProcessExists($AppPID) Then ExitLoop
	EndIf

	If $TaskBarLastChange Then
		CheckPinnedPrograms($ChromePath)
	EndIf

	If $hEvent And Not _WinAPI_WaitForSingleObject($hEvent, 0) Then
		; MsgBox(0, "", "Reg changed!")
		Sleep(50)
		CheckDefaultBrowser($ChromePath)
		For $i = 0 To UBound($aREG) - 1
			If $aREG[$i][2] Then
				_WinAPI_RegNotifyChangeKeyValue($aREG[$i][2], $REG_NOTIFY_CHANGE_LAST_SET, 1, 1, $hEvent)
			EndIf
		Next
	EndIf
WEnd

If $ExAppAutoExit And $ExApp <> "" Then
	For $i = 1 To $aExAppPID[0]
		If Not $aExAppPID[$i] Then ContinueLoop
		$aChildren = _ProcessGetChildren($aExAppPID[$i])
		ProcessClose($aExAppPID[$i])
		If IsArray($aChildren) Then
			For $j = 1 To $aChildren[0][0]
				ProcessClose($aChildren[$j][0])
			Next
		EndIf
	Next
EndIf

; Start external apps
If $ExApp2 <> "" Then
	$aExApp2 = StringSplit($ExApp2, "||", 1)
	For $i = 1 To $aExApp2[0]
		$match = StringRegExp($aExApp2[$i], '^"(.*?)" *(.*)', 1)
		If @error Then
			$file = $aExApp2[$i]
			$args = ""
		Else
			$file = $match[0]
			$args = $match[1]
		EndIf
		$file = FullPath($file)
		If Not ProcessExists(StringRegExpReplace($file, '.*\\', '')) Then
			If FileExists($file) Then
				ShellExecute($file, $args, StringRegExpReplace($file, '\\[^\\]+$', ''))
			EndIf
		EndIf
	Next
EndIf

If 0 Then ; ========= Lines below will never be executed =========
	; put functions here to prevent these functions from being stripped
	GetLatestVersion("")
	DownloadChrome("", "")
EndIf ; ============= Lines above will never be executed =========
Exit
; ==================== 以上为自动执行部分 ========================




Func OnExit()
	If $hEvent Then
		_WinAPI_CloseHandle($hEvent)
		For $i = 0 To UBound($aREG) - 1
			_WinAPI_RegCloseKey($aREG[$i][2])
		Next
	EndIf
EndFunc   ;==>OnExit

Func UpdateCheck()
	Local $updated, $var
	; Check mychrome update
	If $AutoUpdateApp <> 0 And _DateDiff("h", $LastCheckAppUpdate, _NowCalc()) >= 24 Then
		CheckAppUpdate()
	EndIf
	; check chrome update
	If $UpdateInterval >= 0 Then
		If $UpdateInterval = 0 Then
			If $FirstUpdateCheck Then
				$updated = UpdateChrome($ChromePath, $Channel)
			EndIf
		Else
			Local $var = _DateDiff("h", $LastCheckUpdate, _NowCalc())
			If $var >= $UpdateInterval Then
				$updated = UpdateChrome($ChromePath, $Channel)
			EndIf
		EndIf
		If $updated And Not AppIsRunning($ChromePath) Then ; restart app/chrome
			If @Compiled Then
				Run('"' & @AutoItExe & '" --restore-last-session')
			Else
				Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" --restore-last-session')
			EndIf
			Exit
		EndIf
	EndIf

	If $RunInBackground Then
		If $FirstUpdateCheck Then
			AdlibRegister("UpdateCheck", 300000)
		EndIf
		ReduceMemory()
	EndIf
	$FirstUpdateCheck = 0
EndFunc   ;==>UpdateCheck

;~ for win7/vista or newer
Func CheckPinnedPrograms($path)
	If Not FileExists($TaskBarDir) Then
		Return
	EndIf
	Local $ftime = FileGetTime($TaskBarDir, 0, 1)
	If $ftime = $TaskBarLastChange Then
		Return
	EndIf

	$TaskBarLastChange = $ftime
	Local $search = FileFindFirstFile($TaskBarDir & "\*.lnk")
	If $search = -1 Then Return
	Local $file, $ShellObj, $objShortcut
	$ShellObj = ObjCreate("WScript.Shell")
	If Not @error Then
		While 1
			$file = $TaskBarDir & "\" & FileFindNextFile($search)
			If @error Then ExitLoop
			$objShortcut = $ShellObj.CreateShortCut($file)
			If $path = $objShortcut.TargetPath Then
				$objShortcut.TargetPath = @ScriptFullPath
				$objShortcut.IconLocation = $path & ",0"
				$objShortcut.Save
				$TaskBarLastChange = FileGetTime($TaskBarDir, 0, 1)
				ExitLoop
			EndIf
		WEnd
		$objShortcut = ""
	EndIf
	FileClose($search)
EndFunc   ;==>CheckPinnedPrograms


;~ 设置批处理
Func CreateSettingsShortcut($fname)
	Local $var = FileRead($fname)
	If $var <> 'CreateObject("shell.application").ShellExecute "' & @ScriptName & '", "-set"' Then
		FileDelete($fname)
		FileWrite($fname, 'CreateObject("shell.application").ShellExecute "' & @ScriptName & '", "-set"')
	EndIf
EndFunc   ;==>CreateSettingsShortcut


Func CheckDefaultBrowser($BrowserPath)
	Local $InternetClient, $key, $i, $j, $var, $RegWriteError = 0

	; 在 StartMenuInternet 中注册后，Win XP 中点击开始菜单的“Internet”项才会启动chrome便携版
	; Win vista / 7 “默认程序” 设置中才会出现Chrome浏览器
	If Not $ClientKey Then
		Local $aRoot[3] = ["HKCU", "HKLM64", "HKLM"]
		For $i = 0 To 2 ; search chrome in internetclient
			$j = 1
			While 1
				$InternetClient = RegEnumKey($aRoot[$i] & "\Software\Clients\StartMenuInternet", $j)
				If @error <> 0 Then ExitLoop
				$key = $aRoot[$i] & '\SOFTWARE\Clients\StartMenuInternet\' & $InternetClient
				$var = RegRead($key & '\DefaultIcon', '')
				If StringInStr($var, $BrowserPath) Then
					$ClientKey = $key
					$Progid = RegRead($ClientKey & '\Capabilities\URLAssociations', 'http')
					ExitLoop 2
				EndIf
				$j += 1
			WEnd
		Next
	EndIf
	If $ClientKey Then
		$var = RegRead($ClientKey & '\shell\open\command', '')
		If Not StringInStr($var, @ScriptFullPath) Then
			$RegWriteError += Not RegWrite($ClientKey & '\shell\open\command', _
					'', 'REG_SZ', '"' & @ScriptFullPath & '"')
		EndIf
	EndIf

	If Not $Progid Then
		$Progid = FindChromeProgid($BrowserPath)
	EndIf

	If $Progid Then
		$var = RegRead('HKCR\' & $Progid & '\shell\open\command', '')
		If Not StringInStr($var, @ScriptFullPath) Then
			RegDelete('HKCR\' & $Progid & '\shell\open\ddeexec', '')
			RegDelete('HKCR\' & $Progid & '\shell\open\command', 'DelegateExecute') ; 解决 Win8“未注册类”错误
			$RegWriteError += Not RegWrite('HKCR\' & $Progid & '\shell\open\command', _
					'', 'REG_SZ', '"' & @ScriptFullPath & '" -- "%1"')
		EndIf
		If Not $aREG[5][1] Then
			$aREG[5][1] = $Progid ; for reg notification
			$aREG[5][2] = _WinAPI_RegOpenKey($aREG[5][0], $aREG[5][1], $KEY_NOTIFY)
		EndIf
	EndIf

	Local $aAsso[3] = ['ftp', 'http', 'https']
	For $i = 0 To 2
		$var = RegRead('HKCR\' & $aAsso[$i] & '\DefaultIcon', '')
		If StringInStr($var, $BrowserPath) Then
			$var = RegRead('HKCR\' & $aAsso[$i] & '\shell\open\command', '')
			If Not StringInStr($var, @ScriptFullPath) Then
				RegDelete('HKCR\' & $aAsso[$i] & '\shell\open\ddeexec', '')
				RegDelete('HKCR\' & $aAsso[$i] & '\shell\open\command', 'DelegateExecute')
				$RegWriteError += Not RegWrite('HKCR\' & $aAsso[$i] & '\shell\open\command', _
						'', 'REG_SZ', '"' & @ScriptFullPath & '" -- "%1"')
			EndIf
		EndIf
	Next

	If IsAdmin() Then
		RegRead('HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', '')
		If Not @error Then
			RegWrite('HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', '', 'REG_SZ', @ScriptFullPath)
			RegWrite('HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', 'Path', 'REG_SZ', @ScriptDir)
		EndIf
	EndIf

	If $RegWriteError And Not _IsUACAdmin() And @extended Then
		If @Compiled Then
			ShellExecute(@ScriptName, "-SetDefaultGlobal", @ScriptDir, "runas")
		Else
			ShellExecute(@AutoItExe, '"' & @ScriptFullPath & '" -SetDefaultGlobal', @ScriptDir, "runas")
		EndIf
	EndIf
EndFunc   ;==>CheckDefaultBrowser
Func FindChromeProgid($BrowserPath)
	Local $i, $id, $var
	RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts', '')
	If @error <> 1 Then
		For $i = 0 To UBound($aFileAsso) - 1
			$id = RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' & $aFileAsso[$i] & '\UserChoice', 'Progid')
			If $id Then
				$var = RegRead('HKCR\' & $id & '\DefaultIcon', '')
				If StringInStr($var, $BrowserPath) Then
					Return $id
				EndIf
			EndIf
		Next
	EndIf

	For $i = 0 To UBound($aFileAsso) - 1
		$id = RegRead('HKCR\' & $aFileAsso[$i], '')
		$var = RegRead('HKCR\' & $id & '\DefaultIcon', '')
		If StringInStr($var, $BrowserPath) Then
			Return $id
		EndIf
	Next

	RegRead('HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations', '')
	If @error <> 1 Then
		For $i = 0 To UBound($aUrlAsso) - 1
			$id = RegRead('HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\' & $aUrlAsso[$i] & '\UserChoice', 'Progid')
			If $id Then
				$var = RegRead('HKCR\' & $id & '\DefaultIcon', '')
				If StringInStr($var, $BrowserPath) Then
					Return $id
				EndIf
			EndIf
		Next
	EndIf
	Return ""
EndFunc   ;==>FindChromeProgid


;~ check MyChrome update
Func CheckAppUpdate()
	Local $var, $match, $LatestAppVer, $msg, $update, $url
	Local $slatest = "latest", $surl = "url", $supdate = "update"
	If @AutoItX64 Then
		$slatest &= "_x64"
		$surl &= "_x64"
		$supdate &= "_x64"
	EndIf
	$LastCheckAppUpdate = _NowCalc()
	IniWrite($inifile, "Settings", "LastCheckAppUpdate", $LastCheckAppUpdate)
	If $EnableProxy Then
		HttpSetProxy(2, $ProxySever & ":" & $ProxyPort)
	Else
		HttpSetProxy(0)
	EndIf
	$var = BinaryToString(InetRead("http://my-chrome.googlecode.com/svn/Update.txt", 27), 4)
	$var = StringStripWS($var, 3) ; 去掉开头、结尾的空字符
	$match = StringRegExp($var, '(?im)^' & $slatest & '=(\S+)', 1)
	If @error Then Return
	$LatestAppVer = $match[0]
	If Not VersionCompare($LatestAppVer, $AppVersion) Then Return
	$match = StringRegExp($var, '(?im)^' & $surl & '=(\S+)', 1)
	If @error Then Return
	$url = $match[0]
	$match = StringRegExp($var, '(?im)' & $supdate & '=(.+)', 1)
	If @error Then Return
	$update = StringReplace($match[0], "\n", @CRLF)

	If $AutoUpdateApp = 1 Then
		$msg = MsgBox(68, 'MyChrome', "MyChrome " & $LatestAppVer & " 已发布，更新内容：" & _
				@CRLF & @CRLF & $update & @CRLF & @CRLF & "是否更新？")
		If $msg <> 6 Then Return
	EndIf
	Local $temp = @ScriptDir & "\MyChrome_temp"
	$file = $temp & "\MyChrome.zip"
	If Not FileExists($temp) Then DirCreate($temp)

	TraySetState(1)
	TraySetClick(0) ; Tray menu will never be shown through a mouseclick
	TraySetToolTip("MyChrome")
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "")
	TrayTip("MyChrome更新", "正在下载 MyChrome ...", 5, 1)

	InetGet($url, $file, 19)
	FileSetAttrib($file, "+A")
	FileInstall("7z.exe", $temp & "\7z.exe", 1) ; http://www.7-zip.org/download.html
	FileInstall("7z.dll", $temp & "\7z.dll", 1)
	RunWait($temp & '\7z.exe x "' & $file & '" -y', $temp, @SW_HIDE)
	If FileExists($temp & "\MyChrome.exe") Then
		FileMove(@ScriptFullPath, @ScriptDir & "\" & @ScriptName & ".bak", 9)
		FileMove($temp & "\MyChrome.exe", @ScriptFullPath, 9)
		FileDelete($temp & "\7z.exe")
		FileDelete($temp & "\7z.dll")
		FileDelete($file)
		FileMove($temp & "\*.*", @ScriptDir & "\", 9)
		MsgBox(64, "MyChrome", "MyChrome 已更新至 " & $LatestAppVer & " ！" & @CRLF & "原 App 已备份为 " & @ScriptName & ".bak。")
	Else
		$msg = MsgBox(20, "MyChrome", "MyChrome 自动更新失败！" & @CRLF & @CRLF & "是否去软件发布页手动下载更新？")
		If $msg = 6 Then ; Yes
			OpenWebsite()
		EndIf
	EndIf
	DirRemove($temp, 1)
	TraySetState(2)
EndFunc   ;==>CheckAppUpdate

;~ 显示设置窗口
Func Settings()
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Switch $UpdateInterval
		Case -1
			$UpdateInterval = "从不"
		Case 168
			$UpdateInterval = "每周"
		Case 24
			$UpdateInterval = "每天"
		Case 1
			$UpdateInterval = "每小时"
		Case Else
			$UpdateInterval = "每次启动时"
	EndSwitch
	$ChromeFileVersion = FileGetVersion($ChromeDir & "\chrome.dll", "FileVersion")
	$ChromeLastChange = FileGetVersion($ChromeDir & "\chrome.dll", "LastChange")

	Opt("ExpandEnvStrings", 0)
	$hSettings = GUICreate("MyChrome - 打造自己的 Google Chrome 便携版", 500, 520)
	GUISetOnEvent($GUI_EVENT_CLOSE, "ExitApp")
	GUICtrlCreateLabel("MyChrome " & $AppVersion & " by 甲壳虫 <jdchenjian@gmail.com>", 5, 10, 490, -1, $SS_CENTER)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetTip(-1, "点击打开 MyChrome 主页")
	GUICtrlSetOnEvent(-1, "OpenWebsite")

	;常规
	GUICtrlCreateTab(5, 35, 492, 410)
	GUICtrlCreateTabItem("常规")

	GUICtrlCreateGroup("Google Chrome 程序文件", 10, 80, 480, 180)
	GUICtrlCreateLabel("chrome 路径：", 20, 110, 120, 20)
	$hChromePath = GUICtrlCreateEdit($ChromePath, 130, 106, 290, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "浏览器主程序路径")
	$hGetChromePath = GUICtrlCreateButton("浏览", 430, 106, 50, 20)
	GUICtrlSetTip(-1, "选择便携版浏览器" & @CRLF & "主程序（chrome.exe）")
	GUICtrlSetOnEvent(-1, "GetChromePath")

	GUICtrlCreateLabel("获取 Google Chrome 浏览器程序文件：", 20, 144, 250, 20)
	$hChromeSource = GUICtrlCreateCombo("", 280, 140, 130, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "----  请选择  ----|从系统中提取|从网络下载|从离线安装文件提取", "----  请选择  ----")
	GUICtrlSetTip(-1, "获取便携版浏览器程序文件")
	GUICtrlSetOnEvent(-1, "GetChrome")

	GUICtrlCreateLabel("分支：", 20, 174, 80, 20)
	$hChannel = GUICtrlCreateCombo("", 100, 170, 150, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "Stable|Beta|Dev|Canary|Chromium-Continuous|Chromium-Snapshots", $Channel)
	GUICtrlSetTip(-1, "Stable - 稳定版(正式版)" & @CRLF & "Beta - 测试版" & @CRLF & "Dev - 开发版" & @CRLF & _
			"Canary - 金丝雀版" & @CRLF & "Chromium - 更新快但不稳定")
	GUICtrlSetOnEvent(-1, "CheckChrome")

	GUICtrlCreateLabel("检查浏览器更新：", 20, 204, 110, 20)
	$hUpdateInterval = GUICtrlCreateCombo("", 130, 200, 120, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "每次启动时|每小时|每天|每周|从不", $UpdateInterval)

	$hx86 = GUICtrlCreateCheckbox(" 32-bit (x86)", 280, 174, -1, 20)
	GUICtrlSetTip(-1, "勾选此项下载 32-bit 浏览器。")
	GUICtrlSetOnEvent(-1, "Change_Browser_Bit")
	If $x86 Then GUICtrlSetState(-1, $GUI_CHECKED)

	$hCheckUpdate = GUICtrlCreateButton("立即更新", 400, 170, 80, 25)
	GUICtrlSetTip(-1, "检查浏览器更新" & @CRLF & "下载最新版至 chrome 程序文件夹")
	GUICtrlSetOnEvent(-1, "Start_End_ChromeUpdate")

	GUICtrlCreateLabel("最新版本：", 280, 204, 70, 20)
	$hLatestChromeVer = GUICtrlCreateLabel("", 350, 204, 140, 20)
	GUICtrlSetTip(-1, "复制下载地址到剪贴板")
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetOnEvent(-1, "ShowUrl")

	GUICtrlCreateLabel("当前版本：", 280, 235, 70, 20)
	$hCurrentVer = GUICtrlCreateLabel("", 350, 235, 140, 20)
	GUICtrlSetData(-1, $ChromeFileVersion & "  " & $ChromeLastChange)

	GUICtrlCreateLabel("发现新版本时", 20, 235, 110, 20)
	$hAskBeforeUpdateChrome = GUICtrlCreateCombo("", 130, 230, 120, 20, $CBS_DROPDOWNLIST)
	Local $sAskBeforeUpdateChrome
	If $AskBeforeUpdateChrome = 1 Then
		$sAskBeforeUpdateChrome = "通知我"
	Else
		$sAskBeforeUpdateChrome = "自动更新"
	EndIf
	GUICtrlSetData(-1, "通知我|自动更新", $sAskBeforeUpdateChrome)

	GUICtrlCreateGroup("Google Chrome 用户数据文件", 10, 280, 480, 80)
	GUICtrlCreateLabel("用户数据文件夹：", 20, 310, 110, 20)
	$hUserDataDir = GUICtrlCreateEdit($UserDataDir, 130, 305, 290, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "浏览器用户数据文件夹")
	GUICtrlCreateButton("浏览", 430, 305, 50, 20)
	GUICtrlSetTip(-1, "选择用户数据文件夹")
	GUICtrlSetOnEvent(-1, "GetUserDataDir")
	$hCopyData = GUICtrlCreateCheckbox("从系统中提取用户数据文件", 20, 330, -1, 20)

	GUICtrlCreateLabel("MyChrome 发布新版时", 20, 380, 130, 20)
	$hAutoUpdateApp = GUICtrlCreateCombo("", 150, 375, 120, 20, $CBS_DROPDOWNLIST)
	Local $sAutoUpdateApp

	If $AutoUpdateApp = 0 Then
		$sAutoUpdateApp = "什么也不做"
	ElseIf $AutoUpdateApp = 1 Then
		$sAutoUpdateApp = "通知我"
	Else
		$sAutoUpdateApp = "自动更新"
	EndIf
	GUICtrlSetData(-1, "通知我|自动更新|什么也不做", $sAutoUpdateApp)
	$hRunInBackground = GUICtrlCreateCheckbox("MyChrome 在后台运行直至浏览器退出", 20, 410, 400, 20)
	GUICtrlSetOnEvent(-1, "RunInBackground")
	If $RunInBackground Then
		GUICtrlSetState($hRunInBackground, $GUI_CHECKED)
	EndIf

	; 高级
	GUICtrlCreateTabItem("高级")
	GUICtrlCreateGroup("Google Chrome 缓存", 10, 80, 480, 90)
	GUICtrlCreateLabel("缓存位置：", 20, 110, 100, 20)
	$hCacheDir = GUICtrlCreateEdit($CacheDir, 120, 106, 300, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "浏览器缓存位置" & @CRLF & "空白 = 默认路径" & @CRLF & "支持%TEMP%等环境变量")
	$hSelectCacheDir = GUICtrlCreateButton("浏览", 430, 106, 50, 20)
	GUICtrlSetTip(-1, "选择缓存位置")
	GUICtrlSetOnEvent(-1, "SelectCacheDir")
	GUICtrlCreateLabel("缓存大小：", 20, 140, 100, 20)
	$hCacheSize = GUICtrlCreateEdit(Round($CacheSize / 1024 / 1024), 120, 136, 80, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "缓存大小" & @CRLF & "0 = 无限制")
	GUICtrlCreateLabel(" MB", 200, 140, 40, 20)

	; 启动参数
	GUICtrlCreateLabel("Google Chrome 启动参数", 20, 190)
	Local $lparams = StringReplace($Params, " --", Chr(13) & Chr(10) & "--") ; 空格换成换行符，便于显示
	$hParams = GUICtrlCreateEdit($lparams, 20, 210, 460, 60, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	GUICtrlSetTip(-1, "Chrome 启动参数，每行写一个参数。" & @CRLF & "支持%TEMP%等环境变量，" & @CRLF & "特别地，%APP%代表 MyChrome 所在目录。")

	; 线程数
	GUICtrlCreateGroup("Chrome 更新网络设置", 10, 290, 480, 90)
	GUICtrlCreateLabel("下载线程数(1-10)：", 20, 320, 130, 20)
	$hDownloadThreads = GUICtrlCreateInput($DownloadThreads, 150, 316, 60, 20, $ES_NUMBER)
	GUICtrlSetTip(-1, "增减线程数可调节下载速度" & @CRLF & "仅适用于下载 chrome 更新")
	GUICtrlSetOnEvent(-1, "ThreadsLimit")
	GUICtrlCreateUpdown($hDownloadThreads)
	GUICtrlSetLimit(-1, 10, 1)
	; 代理
	$hEnableProxy = GUICtrlCreateCheckbox("代理服务器：", 20, 346, 130, 20)
	GUICtrlSetTip(-1, "如果检查、下载更新出错，" & @CRLF & "可尝试通过代理服务器下载。")
	GUICtrlSetOnEvent(-1, "SetProxy")
	$hProxySever = GUICtrlCreateCombo($ProxySever, 150, 346, 110, 20)
	GUICtrlSetData(-1, "127.0.0.1")
	GUICtrlSetTip(-1, "代理服务器IP地址" & @CRLF & "仅适用于下载 chrome 更新")
	GUICtrlCreateLabel("端口：", 290, 350, 80, 20)
	$hProxyPort = GUICtrlCreateCombo($ProxyPort, 370, 346, 80, 20)
	GUICtrlSetData(-1, "8087")
	GUICtrlSetTip(-1, "代理服务器端口" & @CRLF & "仅适用于下载 chrome 更新")
	If $EnableProxy Then
		GUICtrlSetState($hEnableProxy, $GUI_CHECKED)
	Else
		GUICtrlSetState($hProxySever, $GUI_DISABLE)
		GUICtrlSetState($hProxyPort, $GUI_DISABLE)
	EndIf
;~ 	SetProxy()

	; 外部程序
	GUICtrlCreateTabItem("外部程序")
	GUICtrlCreateLabel("浏览器启动时运行", 20, 80, -1, 20)
	$hExAppAutoExit = GUICtrlCreateCheckbox(" #浏览器退出后自动关闭", 240, 75, -1, 20)
	If $ExAppAutoExit = 1 Then
		GUICtrlSetState($hExAppAutoExit, $GUI_CHECKED)
	EndIf
	$hExApp = GUICtrlCreateEdit("", 20, 100, 410, 50, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	If $ExApp <> "" Then
		GUICtrlSetData(-1, StringReplace($ExApp, "||", @CRLF) & @CRLF)
	EndIf
	GUICtrlSetTip(-1, "浏览器启动时运行的外部程序，支持批处理、vbs文件等" & @CRLF & "如需启动参数，可添加在程序路径之后")
	GUICtrlCreateButton("添加", 440, 100, 40, 20)
	GUICtrlSetTip(-1, "选择外部程序")
	GUICtrlSetOnEvent(-1, "AddExApp")

	GUICtrlCreateLabel("#浏览器退出后运行", 20, 180, -1, 20)
	$hExApp2 = GUICtrlCreateEdit("", 20, 200, 410, 50, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	If $ExApp2 <> "" Then
		GUICtrlSetData(-1, StringReplace($ExApp2, "||", @CRLF) & @CRLF)
	EndIf
	GUICtrlSetTip(-1, "浏览器退出后运行的外部程序，支持批处理、vbs文件等" & @CRLF & "如需启动参数，可添加在程序路径之后")
	GUICtrlCreateButton("添加", 440, 200, 40, 20)
	GUICtrlSetTip(-1, "选择外部程序")
	GUICtrlSetOnEvent(-1, "AddExApp2")


	GUICtrlCreateTabItem("")
	$hSettingsOK = GUICtrlCreateButton("确定", 260, 470, 70, 20)
	GUICtrlSetTip(-1, "应用设置并启动浏览器")
	GUICtrlSetOnEvent(-1, "SettingsOK")
	GUICtrlSetState(-1, $GUI_FOCUS)
	GUICtrlCreateButton("取消", 340, 470, 70, 20)
	GUICtrlSetTip(-1, "取消")
	GUICtrlSetOnEvent(-1, "ExitApp")
	$hSettingsApply = GUICtrlCreateButton("应用", 420, 470, 70, 20)
	GUICtrlSetTip(-1, "应用")
	GUICtrlSetOnEvent(-1, "SettingsApply")
	$hStausbar = _GUICtrlStatusBar_Create($hSettings, -1, '双击软件目录下的 "' & $AppName & '.vbs" 文件可调出此窗口')
	Opt("ExpandEnvStrings", 1)

	Local $ChromeExists = CheckChromeInSystem($Channel) ; 检查系统中是否有 Channel 对应的 Chrome 程序文件
	FileChangeDir(@ScriptDir)
	If $FirstRun And Not FileExists($ChromePath) Then
		If $ChromeExists Then
			_GUICtrlComboBox_SelectString($hChromeSource, "从系统中提取")
		Else
			_GUICtrlComboBox_SelectString($hChromeSource, "从网络下载")
		EndIf
	EndIf

	; 复制用户数据文件选项
	If Not FileExists(FullPath($UserDataDir) & "\Local State") And FileExists($DefaultUserDataDir & "\Local State") Then ; 文件夹中无数据文件且系统中有，则勾选复制
		GUICtrlSetState($hCopyData, $GUI_CHECKED)
	EndIf

	GUISetState(@SW_SHOW)
	AdlibRegister("ShowLatestChromeVer", 10) ; Channel 对应的 Chrome 程序文件及对应的最新版本号

	While Not $SettingsOK
		Sleep(100)
	WEnd
	GUIDelete($hSettings)
	$hSettings = "" ; free the handle
EndFunc   ;==>Settings

Func Change_Browser_Bit()
	If GUICtrlRead($hx86) = $GUI_CHECKED Then
		$x86 = 1
	Else
		$x86 = 0
	EndIf
	If $IsUpdating Then Return
	If ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf
	AdlibRegister("ShowLatestChromeVer", 10)
EndFunc   ;==>Change_Browser_Bit

Func AddExApp()
	Local $path
	$path = FileOpenDialog("选择浏览器启动时需运行的外部程序", @ScriptDir, _
			"所有文件 (*.*)", 1 + 2, "", $hSettings)
	If $path = "" Then Return
	$path = RelativePath($path)
	$ExApp = GUICtrlRead($hExApp) & '"' & $path & '"' & @CRLF
	GUICtrlSetData($hExApp, $ExApp)
EndFunc   ;==>AddExApp
Func AddExApp2()
	Local $path
	$path = FileOpenDialog("选择浏览器启动时需运行的外部程序", @ScriptDir, _
			"所有文件 (*.*)", 1 + 2, "", $hSettings)
	If $path = "" Then Return
	$path = RelativePath($path)
	$ExApp2 = GUICtrlRead($hExApp2) & '"' & $path & '"' & @CRLF
	GUICtrlSetData($hExApp2, $ExApp2)
EndFunc   ;==>AddExApp2


Func RunInBackground()
	If GUICtrlRead($hRunInBackground) = $GUI_CHECKED Then
		Return
	EndIf
	$msg = MsgBox(36 + 256, "MyChrome", '允许 MyChrome 在后台运行可以带来更好的用户体验。若取消此选项，请注意以下几点：' & @CRLF & @CRLF & _
			'1. 将浏览器锁定到任务栏或设为默认浏览器后，需再运行一次 MyChrome 才能生效；' & @CRLF & _
			'2. MyChrome 设置界面中带“#”符号的功能/选项将不会执行，包括浏览器退出后关闭外部程序、运行外部程序等。' & @CRLF & @CRLF & _
			'确定要取消此选项吗？', 0, $hSettings)
	If $msg <> 6 Then
		GUICtrlSetState($hRunInBackground, $GUI_CHECKED)
	EndIf
EndFunc   ;==>RunInBackground

;~ chrome.exe路径
Func GetChromePath()
	Local $sChromePath
	$sChromePath = FileOpenDialog("选择 Chrome 浏览器主程序（chrome.exe）", @ScriptDir, _
			"可执行文件(*.exe)|所有文件(*.*)", 2, "chrome.exe", $hSettings)
	If $sChromePath = "" Then Return
	If FileExists($sChromePath) Then
		_GUICtrlComboBox_SelectString($hChromeSource, "----  请选择  ----")
	EndIf
	Local $chromedll = StringRegExpReplace($sChromePath, "[^\\]+$", "chrome.dll")
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = FileGetVersion($chromedll, "LastChange")
	GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	$ChromePath = RelativePath($sChromePath) ; 绝对路径转成相对路径（如果可以）
	GUICtrlSetData($hChromePath, $ChromePath)
EndFunc   ;==>GetChromePath

; 指定用户数据文件夹
Func GetUserDataDir()
	Local $sUserDataDir = FileSelectFolder("选择一个文件夹用来保存用户数据文件", "", 1 + 4, _
			@ScriptDir & "\User Data", $hSettings)
	If $sUserDataDir <> "" Then
		$UserDataDir = RelativePath($sUserDataDir) ; 绝对路径转成相对路径（如果可以）
		GUICtrlSetData($hUserDataDir, $UserDataDir)
	EndIf
EndFunc   ;==>GetUserDataDir


;~ 从系统中复制chrome程序文件
Func CopyChromeFromSystem()
	$ChromePath = GUICtrlRead($hChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	$ChromeIsRunning = ChromeIsRunning($ChromePath, "请关闭 Google Chrome 浏览器，以便更新浏览器程序文件。")
	If $ChromeIsRunning Then Return
	_GUICtrlStatusBar_SetText($hStausbar, "从系统中提取 Google Chrome 程序文件...")
	SplashTextOn("MyChrome", "正在提取 Chrome 程序文件...", 300, 100)
	FileCopy($DefaultChromeDir & "\*.*", $ChromeDir & "\", 1 + 8)
	DirCopy($DefaultChromeDir & "\" & $DefaultChromeVer, $ChromeDir, 1)
	SplashOff()
	; 如果设定的chrome程序文件路径不以chrome.exe结尾，则认为使用者将其改名，将chrome.exe重命名为设定的文件名
	If StringRegExpReplace($ChromePath, ".*\\", "") <> "chrome.exe" Then
		FileMove($ChromeDir & "\chrome.exe", $ChromePath, 1)
	EndIf
	Local $chromedll = StringRegExpReplace($ChromePath, "[^\\]+$", "chrome.dll")
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = FileGetVersion($chromedll, "LastChange")
	GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	_GUICtrlStatusBar_SetText($hStausbar, '提取 Google Chrome 程序文件成功！')
EndFunc   ;==>CopyChromeFromSystem

;~ press "OK" in settings
Func SettingsOK()
	SettingsApply()
	If @error Or $IsUpdating Then Return
	If ProcessExists($iThreadPid) Then
		ProcessClose($iThreadPid)
	EndIf
	$SettingsOK = 1
EndFunc   ;==>SettingsOK

;~ press "Apply" in settings
Func SettingsApply()
	Local $msg, $var
	FileChangeDir(@ScriptDir)
	Opt("ExpandEnvStrings", 0)
	$ChromePath = RelativePath(GUICtrlRead($hChromePath))
	Switch GUICtrlRead($hUpdateInterval)
		Case "从不"
			$UpdateInterval = -1
		Case "每周"
			$UpdateInterval = 168
		Case "每天"
			$UpdateInterval = 24
		Case "每小时"
			$UpdateInterval = 1
		Case Else
			$UpdateInterval = 0
	EndSwitch
	$Channel = GUICtrlRead($hChannel)
	If GUICtrlRead($hx86) = $GUI_CHECKED Then
		$x86 = 1
	Else
		$x86 = 0
	EndIf
	$UserDataDir = RelativePath(GUICtrlRead($hUserDataDir))
	Local $CopyData = GUICtrlRead($hCopyData)
	Switch GUICtrlRead($hAutoUpdateApp)
		Case "什么也不做"
			$AutoUpdateApp = 0
		Case "通知我"
			$AutoUpdateApp = 1
		Case Else
			$AutoUpdateApp = 2
	EndSwitch

	If GUICtrlRead($hAskBeforeUpdateChrome) = "通知我" Then
		$AskBeforeUpdateChrome = 1
	Else
		$AskBeforeUpdateChrome = 0
	EndIf
	If GUICtrlRead($hRunInBackground) = $GUI_CHECKED Then
		$RunInBackground = 1
	Else
		$RunInBackground = 0
	EndIf

	$CacheDir = GUICtrlRead($hCacheDir)
	If $CacheDir <> "" Then
		$CacheDir = RelativePath($CacheDir)
	EndIf
	$CacheSize = GUICtrlRead($hCacheSize) * 1024 * 1024
	$var = GUICtrlRead($hParams)
	$var = StringStripWS($var, 3)
	$Params = StringReplace($var, Chr(13) & Chr(10), " ") ; 换行符换成空格

	$var = GUICtrlRead($hExApp)
	$var = StringStripWS($var, 3)
	$var = StringReplace($var, @CRLF, "||")
	$var = StringRegExpReplace($var, "\|+\s*\|+", "\|\|")
	$ExApp = $var
	If GUICtrlRead($hExAppAutoExit) = $GUI_CHECKED Then
		$ExAppAutoExit = 1
	Else
		$ExAppAutoExit = 0
	EndIf
	$var = GUICtrlRead($hExApp2)
	$var = StringStripWS($var, 3)
	$var = StringReplace($var, @CRLF, "||")
	$var = StringRegExpReplace($var, "\|+\s*\|+", "\|\|")
	$ExApp2 = $var

	SetProxy()
	$DownloadThreads = GUICtrlRead($hDownloadThreads)
	IniWrite($inifile, "Settings", "AskBeforeUpdateChrome", $AskBeforeUpdateChrome)
	IniWrite($inifile, "Settings", "UserDataDir", $UserDataDir)
	IniWrite($inifile, "Settings", "Params", $Params)
	IniWrite($inifile, "Settings", "UpdateInterval", $UpdateInterval)
	IniWrite($inifile, "Settings", "Channel", $Channel)
	IniWrite($inifile, "Settings", "x86", $x86)
	IniWrite($inifile, "Settings", "CacheDir", $CacheDir)
	IniWrite($inifile, "Settings", "CacheSize", $CacheSize)
	IniWrite($inifile, "Settings", "RunInBackground", $RunInBackground)
	IniWrite($inifile, "Settings", "AutoUpdateApp", $AutoUpdateApp)
	IniWrite($inifile, "Settings", "EnableUpdateProxy", $EnableProxy)
	IniWrite($inifile, "Settings", "UpdateProxy", $ProxySever)
	IniWrite($inifile, "Settings", "UpdatePort", $ProxyPort)
	IniWrite($inifile, "Settings", "DownloadThreads", $DownloadThreads)
	$var = $ExApp
	If StringRegExp($var, '^".*"$') Then $var = '"' & $var & '"'
	IniWrite($inifile, "Settings", "ExApp", $var)
	IniWrite($inifile, "Settings", "ExAppAutoExit", $ExAppAutoExit)
	$var = $ExApp2
	If StringRegExp($var, '^".*"$') Then $var = '"' & $var & '"'
	IniWrite($inifile, "Settings", "ExApp2", $var)


	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Opt("ExpandEnvStrings", 1)
	Local $ChromeSource = GUICtrlRead($hChromeSource)
	If $ChromeSource <> "从网络下载" And Not FileExists($ChromePath) Then ; Chrome 路径
		Local $msg = MsgBox(36, "MyChrome", "浏览器程序文件不存在或者路径错误：" & @CRLF & $ChromePath & @CRLF & @CRLF & _
				"请重新设置 chrome 浏览器路径，或者选择从网络下载。" & @CRLF & @CRLF & _
				"需要从网络下载 Google Chrome 的最新版本吗？", 0, $hSettings)
		If $msg = 6 Then
			GUICtrlSetData($hChromeSource, "")
			GUICtrlSetData($hChromeSource, "----  请选择  ----|从系统中提取|从网络下载|从离线安装文件提取", "从网络下载")
		Else
			GUICtrlSetState($hChromePath, $GUI_FOCUS)
			Return SetError(1)
		EndIf
	EndIf
	Opt("ExpandEnvStrings", 0)
	IniWrite($inifile, "Settings", "ChromePath", $ChromePath)
	Opt("ExpandEnvStrings", 1)

	; user data dir
	If Not FileExists($UserDataDir) Then
		DirCreate($UserDataDir)
	EndIf
	If $CopyData = $GUI_CHECKED Then
		Local $lockfile = $UserDataDir & "\lockfile"
		While 1
			If FileExists($lockfile) And FileDelete($lockfile) = 0 Then
				$msg = MsgBox(17, "MyChrome", "浏览器正在运行，无法提取用户数据文件！" & @CRLF & "请关闭 Chrome 浏览器后继续。")
				If $msg <> 1 Then ExitLoop
			Else
				_GUICtrlStatusBar_SetText($hStausbar, "复制 Google Chrome 用户数据文件...")
				SplashTextOn("MyChrome", "正在复制 Chrome 用户数据文件...", 300, 100)
				DirCopy($DefaultUserDataDir, $UserDataDir, 1) ; copy user data
				SplashOff()
				_GUICtrlStatusBar_SetText($hStausbar, '双击软件目录下的 "' & $AppName & '.vbs" 文件可调出此窗口')
				ExitLoop
			EndIf
		WEnd
		GUICtrlSetState($hCopyData, $GUI_UNCHECKED)
	EndIf

	$ChromeSource = GUICtrlRead($hChromeSource)
	If $ChromeSource = "从网络下载" Then
		MsgBox(64, "MyChrome", "即将从网络下载 Google Chrome 的最新版本！", 0, $hSettings)
		_GUICtrlComboBox_SelectString($hChromeSource, "----  请选择  ----")
		Start_End_ChromeUpdate()
	EndIf
EndFunc   ;==>SettingsApply

;~ 检查系统中是否有 Channel 对应的 chrome 程序文件及对应最新版本号
Func CheckChrome()
	Global $Channel = GUICtrlRead($hChannel)
	CheckChromeInSystem($Channel)
	If $IsUpdating Then Return
	If ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf
	AdlibRegister("ShowLatestChromeVer", 10)
EndFunc   ;==>CheckChrome

;~ 检查系统中是否存在chrome
Func CheckChromeInSystem($Channel)
	Local $dir, $Subkey
	If StringInStr($Channel, "Chromium") Then
		$DefaultUserDataDir = @LocalAppDataDir & "\Chromium\User Data"
		$dir = "Chromium\Application"
		$Subkey = "Software\Chromium"
	ElseIf StringInStr($Channel, "Canary") Then
		$DefaultUserDataDir = @LocalAppDataDir & "\Google\Chrome SxS\User Data"
		$dir = "Google\Chrome SxS\Application"
		$Subkey = "Software\Google\Update\Clients\{4ea16ac7-fd5a-47c3-875b-dbf4a2008c20}"
	Else ; chrome stable / beta / dev
		$DefaultUserDataDir = @LocalAppDataDir & "\Google\Chrome\User Data"
		$dir = "Google\Chrome\Application"
		$Subkey = "Software\Google\Update\Clients\{8A69D345-D564-463c-AFF1-A69D9E530F96}"
	EndIf

;~ 复制用户数据文件选项
	If FileExists($DefaultUserDataDir & "\Local State") Then
		GUICtrlSetState($hCopyData, $GUI_ENABLE)
		GUICtrlSetTip($hCopyData, "复制 Google Chrome 用户数据文件：" & @CRLF & $DefaultUserDataDir)
	Else
		GUICtrlSetState($hCopyData, $GUI_UNCHECKED)
		GUICtrlSetState($hCopyData, $GUI_DISABLE)
	EndIf

	; 以管理员身份在线安装在 @ProgramFilesDir
	$DefaultChromeDir = @ProgramFilesDir & "\" & $dir
	$DefaultChromeVer = RegRead("HKLM64\" & $Subkey, "pv")
	If FileExists($DefaultChromeDir & "\chrome.exe") And FileExists($DefaultChromeDir & "\" & $DefaultChromeVer & "\chrome.dll") Then
		Return 1
	EndIf

	; 离线安装在 @LocalAppDataDir
	$DefaultChromeDir = @LocalAppDataDir & "\" & $dir
	$DefaultChromeVer = RegRead("HKCU\" & $Subkey, "pv")
	If FileExists($DefaultChromeDir & "\chrome.exe") And FileExists($DefaultChromeDir & "\" & $DefaultChromeVer & "\chrome.dll") Then
		Return 1
	EndIf
EndFunc   ;==>CheckChromeInSystem


Func ShowLatestChromeVer()
	AdlibUnRegister("ShowLatestChromeVer")
	Dim $aDlInfo[6]
	Local $ResponseTimer

	SetProxy()
	$LatestChromeVer = ""
	$LatestChromeUrl = ""
	GUICtrlSetData($hLatestChromeVer, "")

	_SetVar("DLInfo", "|||||")
	_SetVar("ResponseTimer", TimerInit())

	If $EnableProxy = 1 Then
		$iThreadPid = _StartThread("GetLatestVersion", $Channel, $x86, $ProxySever, $ProxyPort)
	Else
		$iThreadPid = _StartThread("GetLatestVersion", $Channel, $x86)
	EndIf

	While 1
		$ResponseTimer = _GetVar("ResponseTimer")
		$aDlInfo = StringSplit(_GetVar("DLInfo"), "|", 2)
		If UBound($aDlInfo) >= 6 Then
			_GUICtrlStatusBar_SetText($hStausbar, $aDlInfo[5])
			If $aDlInfo[2] Then ExitLoop
		EndIf
		If Not ProcessExists($iThreadPid) Or TimerDiff($ResponseTimer) > 60000 Then
			ExitLoop ; 子进程结束或无响应
		EndIf
		Sleep(100)
	WEnd
	_KillThread($iThreadPid)
	If Not $aDlInfo[2] Then
		_GUICtrlStatusBar_SetText($hStausbar, "获取 Google Chrome 更新信息失败")
	ElseIf $aDlInfo[3] Then
		$LatestChromeVer = $aDlInfo[0]
		$LatestChromeUrl = $aDlInfo[1]
	EndIf
	GUICtrlSetData($hLatestChromeVer, $LatestChromeVer)
EndFunc   ;==>ShowLatestChromeVer

; 打开网站
Func OpenWebsite()
;~ 	ShellExecute("http://hi.baidu.com/jdchenjian/item/e04f06df3975724eddf9bedc")
	ShellExecute("http://code.google.com/p/my-chrome/")
EndFunc   ;==>OpenWebsite

;~ 显示下载地址
Func ShowUrl()
	If $LatestChromeUrl Then
		ClipPut($LatestChromeUrl)
		MsgBox(64, "MyChrome", "下载地址已复制到剪贴板!" & @CRLF & @CRLF & $LatestChromeUrl, 0, $hSettings)
	EndIf
EndFunc   ;==>ShowUrl

Func GetChrome()
	Local $source = GUICtrlRead($hChromeSource)
	If $source = "从系统中提取" Then
		If CheckChromeInSystem($Channel) Then
			CopyChromeFromSystem()
		Else
			MsgBox(64, "MyChrome", "在您的系统中未找到 Google Chrome（" & $Channel & "）程序文件!", 0, $hSettings)
		EndIf
		_GUICtrlComboBox_SelectString($hChromeSource, "----  请选择  ----")
	ElseIf $source = "从离线安装文件提取" Then
		Local $installer = FileOpenDialog("选择离线安装文件（chrome_installer.exe）", @ScriptDir, _
				"可执行文件(*.exe)", 1 + 2, "chrome_installer.exe", $hSettings)
		If $installer <> "" Then
			$ChromePath = GUICtrlRead($hChromePath)
			$ChromePath = FullPath($ChromePath)
			InstallChrome($installer)
			EndUpdate()
		EndIf
		_GUICtrlComboBox_SelectString($hChromeSource, "----  请选择  ----")
	EndIf
EndFunc   ;==>GetChrome

;~ 线程数限定在 1~10
Func ThreadsLimit()
	Local $Threads = GUICtrlRead($hDownloadThreads)
	If $Threads > 10 Then
		GUICtrlSetData($hDownloadThreads, 10)
	ElseIf $Threads < 1 Then
		GUICtrlSetData($hDownloadThreads, 1)
	EndIf
EndFunc   ;==>ThreadsLimit

;~ 启动 / 停止更新
Func Start_End_ChromeUpdate()
	If Not $IsUpdating Then
		$IsUpdating = 1
		_KillThread($iThreadPid)
		AdlibRegister("CheckChromeUpdate", 10) ; 通过 timer 启动更新，尽快返回，避免 GUI 无响应
	ElseIf MsgBox(292, "MyChrome", "确定要取消浏览器更新吗？", 0, $hSettings) = 6 Then
		$IsUpdating = 0
	EndIf
EndFunc   ;==>Start_End_ChromeUpdate

;~ 下载更新代理服务器选项
Func SetProxy()
	If GUICtrlRead($hEnableProxy) = $GUI_CHECKED Then
		$EnableProxy = 1
		GUICtrlSetState($hProxySever, $GUI_ENABLE)
		GUICtrlSetState($hProxyPort, $GUI_ENABLE)
		$ProxySever = GUICtrlRead($hProxySever)
		$ProxyPort = GUICtrlRead($hProxyPort)
	Else
		$EnableProxy = 0
		GUICtrlSetState($hProxySever, $GUI_DISABLE)
		GUICtrlSetState($hProxyPort, $GUI_DISABLE)
	EndIf
EndFunc   ;==>SetProxy

;~ 选择缓存目录
Func SelectCacheDir()
	Local $sCacheDir = FileSelectFolder("选择一个文件夹用来保存浏览器缓存文件", "", 1 + 4, _
			FullPath($UserDataDir) & "\Default", $hSettings)
	If $sCacheDir <> "" Then
		$CacheDir = RelativePath($sCacheDir) ; 绝对路径转成相对路径（如果可以）
		GUICtrlSetData($hCacheDir, $CacheDir)
	EndIf
EndFunc   ;==>SelectCacheDir

;~ 更新google chrome
Func CheckChromeUpdate()
	AdlibUnRegister("CheckChromeUpdate")
	$ChromePath = GUICtrlRead($hChromePath)
	$Channel = GUICtrlRead($hChannel)
	$DownloadThreads = GUICtrlRead($hDownloadThreads)
	SetProxy() ; 设置代理
	GUICtrlSetData($hCheckUpdate, "取消更新")
	GUICtrlSetTip($hCheckUpdate, "取消更新")
	GUICtrlSetState($hSettingsOK, $GUI_DISABLE)
	GUICtrlSetState($hSettingsApply, $GUI_DISABLE)

	UpdateChrome($ChromePath, $Channel)

	If GUICtrlRead($hChromeSource) = "从网络下载" Then
		_GUICtrlComboBox_SelectString($hChromeSource, "----  请选择  ----")
	EndIf
EndFunc   ;==>CheckChromeUpdate

;~ 更新浏览器
Func UpdateChrome($ChromePath, $Channel)
	$ChromePath = FullPath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	If ChromeIsUpdating($ChromeDir) Then
		If IsHWnd($hSettings) Then
			MsgBox(64, "MyChrome", "Google Chrome 浏览器上次更新仍在进行中！", 0, $hSettings)
		EndIf
		EndUpdate()
		Return
	EndIf

	$IsUpdating = 1
	Local $msg, $ResponseTimer
	If Not $LatestChromeVer Then ; 获取更新信息
		Do
			$LatestChromeVer = ""
			$LatestChromeUrl = ""
			_SetVar("DLInfo", "|||||")
			If $EnableProxy = 1 Then
				$iThreadPid = _StartThread("GetLatestVersion", $Channel, $x86, $ProxySever, $ProxyPort)
			Else
				$iThreadPid = _StartThread("GetLatestVersion", $Channel, $x86)
			EndIf
			$ResponseTimer = TimerInit()
			_SetVar("ResponseTimer", $ResponseTimer)

			While 1
				$ResponseTimer = _GetVar("ResponseTimer")
				$aDlInfo = StringSplit(_GetVar("DLInfo"), "|", 2)
				If UBound($aDlInfo) >= 6 Then
					_GUICtrlStatusBar_SetText($hStausbar, $aDlInfo[5])
					If $aDlInfo[2] Then ExitLoop ; 任务完成
				EndIf

				If Not ProcessExists($iThreadPid) Or TimerDiff($ResponseTimer) > 60000 Then
					ExitLoop ; 子进程结束或无响应
				EndIf
				If Not $IsUpdating Then
					ExitLoop 2 ; 手动停止更新
				EndIf
				Sleep(100)
			WEnd
			_KillThread($iThreadPid)
			If Not $aDlInfo[2] Then
				_GUICtrlStatusBar_SetText($hStausbar, "获取 Google Chrome 更新信息失败")
			ElseIf $aDlInfo[3] Then
				$LatestChromeVer = $aDlInfo[0]
				$LatestChromeUrl = $aDlInfo[1]
			EndIf
			If Not $LatestChromeVer Then
				If Not IsHWnd($hSettings) Then ExitLoop
				$msg = MsgBox(16 + 5, "更新错误-MyChrome", "获取 Google Chrome (" & $Channel & ") 更新信息失败！" & @CRLF & _
						"请检查网络连接和设置，稍后再试。", 0, $hSettings)
			EndIf
		Until $LatestChromeVer Or $msg = 2 ; Cancel
	EndIf

	If Not $LatestChromeVer Then
		EndUpdate()
		Return
	EndIf

	$LastCheckUpdate = _NowCalc()
	IniWrite($inifile, "Settings", "LastCheckUpdate", $LastCheckUpdate)
	$ChromeFileVersion = FileGetVersion($ChromeDir & "\chrome.dll", "FileVersion")
	$ChromeLastChange = FileGetVersion($ChromeDir & "\chrome.dll", "LastChange")
	If $LatestChromeVer = $ChromeLastChange Or $LatestChromeVer = $ChromeFileVersion Then
		If IsHWnd($hSettings) Then
			MsgBox(64, "MyChrome", "您的 Google Chrome (" & $Channel & ") 已经是最新版!", 0, $hSettings)
		EndIf
		EndUpdate()
		Return
	EndIf

	Local $info = "Google Chrome (" & $Channel & ") 可以更新，是否立即下载？" & @CRLF & @CRLF _
			 & "最新版本：" & $LatestChromeVer & @CRLF _
			 & "您的版本：" & $ChromeFileVersion & "  " & $ChromeLastChange
	$msg = 6
	If Not IsHWnd($hSettings) And $AskBeforeUpdateChrome = 1 Then
		$msg = MsgBox(68, 'MyChrome', $info)
	EndIf

	Local $restart = 1, $error, $errormsg, $updated
	If $msg = 6 Then ; Yes
		$IsUpdating = $LatestChromeUrl
		Local $localfile = $ChromeDir & "\~update\chrome_installer.exe"
		If IsHWnd($hSettings) Then
			_GUICtrlStatusBar_SetText($hStausbar, "下载 Google Chrome ...")
		ElseIf Not @TrayIconVisible Then
			TraySetState(1)
			TraySetClick(8)
			TraySetToolTip("MyChrome")
			TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "TrayTipProgress")
			TrayCreateItem("取消更新 ...")
			TrayItemSetOnEvent(-1, "CancelUpdate")
			TrayTip("开始下载 Google Chrome", "点击图标可查看下载进度", 10, 1)
		EndIf

		Local $ResumeDownload = 0, $aDlInfo, $error, $errormsg
		While 1
			If Not $IsUpdating Then
				ExitLoop ; 手动停止
			EndIf

			_SetVar("DLInfo", "|||||")
			_SetVar("ResponseTimer", TimerInit())
			If $ResumeDownload Then
				_SetVar("ResumeDownload", 1)
			Else
				If $EnableProxy = 1 Then
					$iThreadPid = _StartThread("DownloadChrome", $LatestChromeUrl, $localfile, $LatestChromeVer, $DownloadThreads, $ProxySever, $ProxyPort)
				Else
					$iThreadPid = _StartThread("DownloadChrome", $LatestChromeUrl, $localfile, $LatestChromeVer, $DownloadThreads)
				EndIf
			EndIf

			While 1 ; 等待下载结束
				$aDlInfo = StringSplit(_GetVar("DLInfo"), "|", 2)
				If IsHWnd($hSettings) Then
					_GUICtrlStatusBar_SetText($hStausbar, $aDlInfo[5])
				ElseIf $TrayTipProgress Or TrayTipExists("下载 Google Chrome") Then
					$aDlInfo[5] = StringReplace($aDlInfo[5], ": ", @CRLF)
					TrayTip("", $aDlInfo[5], 10, 1)
					$TrayTipProgress = 0
				EndIf
				If $aDlInfo[2] Then ExitLoop ; 任务完成
				If Not ProcessExists($iThreadPid) Or TimerDiff(_GetVar("ResponseTimer")) > 60000 Then
					ExitLoop ; 子进程结束或无响应
				EndIf

				If Not $IsUpdating Then ; 手动停止
					ExitLoop 2
				EndIf
				Sleep(100)
			WEnd

			If $aDlInfo[2] And $aDlInfo[3] Then ; 下载成功
				$updated = InstallChrome() ; 安装更新
				ExitLoop
			EndIf

			$error = $aDlInfo[4]
			If $error = 2 Then
				$errormsg = "下载中断，文件未下载完整。"
				$ResumeDownload = 1 ; 下载出错未完成，可续传
			Else
				$ResumeDownload = 0 ; 下载出错，不能续传
				_KillThread($iThreadPid)
				If $error = 1 Then
					$errormsg = "无法连接更新服务器。"
				ElseIf $error = 3 Then
					$errormsg = "已下载的文件大小不正确。"
				EndIf
			EndIf
			If Not IsHWnd($hSettings) And Not $AskBeforeUpdateChrome Then ExitLoop
			$msg = MsgBox(16 + 5, "更新错误-MyChrome", "下载 Google Chrome 出错！" & @CRLF & $errormsg, 0, $hSettings)
			If $msg <> 4 Then ExitLoop
			Dim $aDlInfo[6]
		WEnd
	EndIf

	If @TrayIconVisible Then
		TraySetState(2)
	EndIf
	EndUpdate()
	Return $updated
EndFunc   ;==>UpdateChrome

Func CancelUpdate()
	Local $msg = MsgBox(292, "MyChrome", "浏览器正在更新，确定要取消吗？")
	If $msg = 6 Then
		$IsUpdating = 0
	EndIf
EndFunc   ;==>CancelUpdate

#Region 获取 Chrome 更新信息（最新版本号，下载地址）
;~ $aDlInfo[6]
;~ 0 - Latest Chrome Version
;~ 1 - Latest Chrome url
;~ 2 - Set to True if the download is complete, False if the download is still ongoing.
;~ 3 - True if the download was successful. If this is False then the next data member will be non-zero.
;~ 4 - The error value for the download. The value itself is arbitrary. Testing that the value is non-zero is sufficient for determining if an error occurred.
;~ 5 - The extended value for the download. The value is arbitrary and is primarily only useful to the AutoIt developers.
;~ 从网络获取 chrome 最新版本号
Func GetLatestVersion($Channel, $x86 = 0, $ProxySever = "", $ProxyPort = "")
	Local $urlbase, $var, $LatestVer, $LatestUrl, $i
	Local $WinVer = WinVer()
	Local $OSArch = StringLower(@OSArch)
	$x86 = $x86 * 1
	AdlibRegister("ResetTimer", 1000) ; 定时向父进程发送时间信息（响应信息）

;~ 	for test only
;~ 	If Not $x86 Then
;~ 		$OSArch = "x64"
;~ 	EndIf
;~ 	for test only

	Local $hHTTPOpen, $hConnect, $version, $name, $a, $hRequest, $sHeader, $error
	If $ProxySever <> "" And $ProxyPort <> "" Then
		$hHTTPOpen = _WinHttpOpen(Default, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxySever & ":" & $ProxyPort, "localhost")
	Else
		$hHTTPOpen = _WinHttpOpen() ; 无代理
	EndIf
	_WinHttpSetTimeouts($hHTTPOpen, 0, 7000, 7000, 7000) ; 设置超时

	; get latest Chromium developer build
	; https://storage.googleapis.com/chromium-browser-continuous/index.html?path=Win/
	; https://storage.googleapis.com/chromium-browser-continuous/index.html?path=Win_x64/
	If StringInStr($Channel, "Chromium") Then
		Local $arr[4] = ["https://storage.googleapis.com", "https://storage.googleapis.com", _
				"https://storage.googleapis.com", "https://storage.googleapis.com"]
		If $Channel = "Chromium-Continuous" Then
			If $x86 Or $OSArch = "x86" Then
				$urlbase = "chromium-browser-continuous/Win"
			Else
				$urlbase = "chromium-browser-continuous/Win_x64"
			EndIf
		Else
			$urlbase = "chromium-browser-snapshots/Win"
		EndIf
		For $i = 0 To UBound($arr) - 1
			_SetVar("DLInfo", "|||||从服务器获取 Chromium 更新信息... 第 " & $i + 1 & " 次尝试")
			$hConnect = _WinHttpConnect($hHTTPOpen, $arr[$i])
			$var = _WinHttpSimpleSSLRequest($hConnect, "GET", $urlbase & "/LAST_CHANGE")
			_WinHttpCloseHandle($hConnect)
			If StringIsDigit($var) And $var > 0 Then
				$LatestVer = $var
				$LatestUrl = $arr[$i] & "/" & $urlbase & "/" & $var & "/mini_installer.exe"
				ExitLoop
			EndIf
			Sleep(200)
		Next
		_WinHttpCloseHandle($hHTTPOpen)
		If $LatestVer Then
			_SetVar("DLInfo", $LatestVer & "|" & $LatestUrl & "|1|1||已成功获取 Chromium 更新信息")
		Else
			_SetVar("DLInfo", "||1||1|获取 Chromium 更新信息失败，请检查网络连接，稍后再试。")
		EndIf
		Return
	EndIf

	; 利用 Google Update API 获取 stable/beta/dev/canary 最新版本号 http://code.google.com/p/omaha/wiki/ServerProtocol
	Local $appid, $id, $ap, $data, $match
	Switch $Channel
		Case "Stable"
			$appid = "4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D" ; protocol v3
			$id = "8A69D345-D564-463C-AFF1-A69D9E530F96" ; ; protocol v2
			If $x86 Or $OSArch = "x86" Or $WinVer < 6.1 Then
				$ap = "-multi-chrome"
				$OSArch = "x86"
			Else
				$ap = "x64-multi-chrome"
			EndIf
		Case "Beta"
			$appid = "4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D"
			$id = "8A69D345-D564-463C-AFF1-A69D9E530F96"
			If $x86 Or $OSArch = "x86" Or $WinVer < 6.1 Then
				$ap = "1.1-beta"
				$OSArch = "x86"
			Else
				$ap = "1.1-beta-x64-beta-multi-chrome"
			EndIf
		Case "Dev"
			$appid = "4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D"
			$id = "8A69D345-D564-463C-AFF1-A69D9E530F96"
			If $x86 Or $OSArch = "x86" Or $WinVer < 6.1 Then
				$ap = "2.0-dev"
				$OSArch = "x86"
			Else
				$ap = "x64-dev-multi-chrome"
			EndIf
		Case "Canary"
			$appid = "4EA16AC7-FD5A-47C3-875B-DBF4A2008C20"
			$id = "4ea16ac7-fd5a-47c3-875b-dbf4a2008c20"
			If $x86 Or $OSArch = "x86" Or $WinVer < 6.1 Then
				$ap = ""
				$OSArch = "x86"
			Else
				$ap = "x64-canary"
			EndIf
	EndSwitch

	; omaha protocol v3
	$data = '<?xml version="1.0" encoding="UTF-8"?><request protocol="3.0" version="1.3.23.9" shell_version="1.3.21.103" ismachine="0" ' & _
			'sessionid="{3597644B-2952-4F92-AE55-D315F45F80A5}" installsource="ondemandcheckforupdate" ' & _
			'requestid="{CD7523AD-A40D-49F4-AEEF-8C114B804658}" dedup="cr"><os platform="win" version="' & $WinVer & '" ' & _
			'sp="' & @OSServicePack & '" arch="' & $OSArch & '"/><app appid="{' & $appid & '}" version="" nextversion="" ' & _
			'ap="' & $ap & '" lang="" brand="GGLS" client=""><updatecheck/></app></request>'

	Local $arr[3] = ["https://tools.google.com", "https://tools.google.com", "https://clients2.google.com"]
	For $i = 0 To UBound($arr) - 1
		_SetVar("DLInfo", "|||||从服务器获取 Chrome 更新信息... 第 " & $i + 1 & " 次尝试")
		$hConnect = _WinHttpConnect($hHTTPOpen, $arr[$i])
		$var = _WinHttpSimpleSSLRequest($hConnect, "POST", "service/update2", Default, $data, "User-Agent: Google Update/1.3.23.9;winhttp")
		_WinHttpCloseHandle($hConnect)
		$match = StringRegExp($var, '(?i)<manifest +version="(.+?)".* name="(.+?)"', 1)
		$error = @error
		If Not $error Then ExitLoop
		Sleep(200)
	Next
	If Not $error Then
		$version = $match[0]
		$name = $match[1]
		$match = StringRegExp($var, '(?i)<url +codebase="(.+?)"', 3)
		If Not @error Then
			For $i = 0 To UBound($match) - 1
				_SetVar("DLInfo", "|||||尝试连接 " & $match[$i] & $name)
				$a = HttpParseUrl($match[$i] & $name)
				$hConnect = _WinHttpConnect($hHTTPOpen, $a[0], $a[2])
				$hRequest = _WinHttpOpenRequest($hConnect, Default, $a[1])
				_WinHttpSendRequest($hRequest)
				_WinHttpReceiveResponse($hRequest)
				$sHeader = _WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_STATUS_CODE)
				_WinHttpCloseHandle($hRequest)
				_WinHttpCloseHandle($hConnect)
				If $sHeader = 200 Then
					$LatestVer = $version
					$LatestUrl = $match[$i] & $name
					ExitLoop
				EndIf
			Next
		EndIf
	EndIf

	; omaha protocol v2
	If Not $LatestVer And ($x86 Or $OSArch = "x86" Or $WinVer < 6.1) Then
		Local $arr[2] = ["https://clients2.google.com", "https://clients2.google.com"]
		For $i = 0 To UBound($arr) - 1
			_SetVar("DLInfo", "|||||从服务器获取 Chrome 更新信息... 第 " & $i + 4 & " 次尝试")
			$hConnect = _WinHttpConnect($hHTTPOpen, $arr[$i])
			$var = _WinHttpSimpleSSLRequest($hConnect, "GET", "service/update2/crx?x=id%3D{" & $id & "}%26uc&ap=" & $ap)
			_WinHttpCloseHandle($hConnect)
			$match = StringRegExp($var, '(?i)<updatecheck +Version="(.+?)".* codebase="(.+?)"', 1)
			If Not @error Then
				$LatestVer = $match[0]
				$LatestUrl = $match[1]
				ExitLoop
			EndIf
			Sleep(200)
		Next
	EndIf

	_WinHttpCloseHandle($hHTTPOpen)
	If $LatestVer Then
		_SetVar("DLInfo", $LatestVer & "|" & $LatestUrl & "|1|1||已成功获取 Chrome 更新信息")
	Else
		_SetVar("DLInfo", "||1||1|获取 Chrome 更新信息失败，请检查网络连接，稍后再试。")
	EndIf
EndFunc   ;==>GetLatestVersion
Func ResetTimer() ; 定时向父进程发送时间信息，告诉父进程：我还活着！
	_SetVar("ResponseTimer", TimerInit())
EndFunc   ;==>ResetTimer
#EndRegion 获取 Chrome 更新信息（最新版本号，下载地址）

#Region DownloadChrome
; #FUNCTION# ;===============================================================================
; Name...........: DownloadChrome
; Description ...: 下载 chrome
; Syntax.........: DownloadChrome($url, $localfile, $version = "", $DownloadThreads = 3, $ProxySever = "", $ProxyPort = "")
; Parameters ....: $url - 网址，如："http://dl.google.com/chrome/install/912.12/chrome_installer.exe"
;                  $localfile - 本地文件名
;                  $version - chrome 最新版本号
;                  $DownloadThreads - 下载线程数
;                  $ProxySever - 代理服务器
;                  $ProxyPort - 代理服务器端口
;                  _SetVar("ResumeDownload", 1) - 0 - 重新下载，1 - 断点续传
; Return values .: Success - @error = 0, @extended = ""
;                  Failure - @error = 1: 连接服务器失败，不能续传
;                            @error = 2:下载出错，可以续传
;                            @error = 3:下载的文件不正确，不能续传
;============================================================================================
Func DownloadChrome($url, $localfile, $version = "", $DownloadThreads = 3, $ProxySever = "", $ProxyPort = "")
	Local $DownLoadInfo
	; Dim $DownLoadInfo[1][5]
;~ [n, 0] - bytes from
;~ [n, 1] - current pos(pointer)
;~ [n, 2] - bytes to
;~ [n, 3] - $hHttpRequest, special falg: 0 - error, -1 - complete
;~ [n, 4] - $hHttpConnect

	Local $TempDir = StringMid($localfile, 1, StringInStr($localfile, "\", 0, -1) - 1)
	If Not FileExists($TempDir) Then DirCreate($TempDir)
	If FileExists($localfile) Then FileDelete($localfile)
	Local $hDlFile = FileOpen($localfile, 25)

	_SetVar("DLInfo", "|||||准备下载 Google Chrome ...")
	AdlibRegister("ResetTimer", 1000) ; 定时向父进程发送时间信息（响应信息）

	Local $hHTTPOpen, $ret, $error
	If $ProxySever <> "" And $ProxyPort <> "" Then
		$hHTTPOpen = _WinHttpOpen(Default, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxySever & ":" & $ProxyPort, "localhost")
	Else
		$hHTTPOpen = _WinHttpOpen() ; 无代理
	EndIf
	_WinHttpSetTimeouts($hHTTPOpen, 0, 10000, 10000, 10000) ; 设置超时
	While 1
		$ret = __DownloadChrome($url, $localfile, $hDlFile, $version, $DownloadThreads, $hHTTPOpen, $DownLoadInfo)
		$error = @error
		_SetVar("DLInfo", $ret)

		For $i = 0 To UBound($DownLoadInfo) - 1
			If Not $DownLoadInfo[$i][3] Or $DownLoadInfo[$i][3] = -1 Then ContinueLoop
			_WinHttpCloseHandle($DownLoadInfo[$i][3])
			_WinHttpCloseHandle($DownLoadInfo[$i][4])
		Next

		If $error <> 2 Then ExitLoop
		While 1
			Sleep(100)
			; ToolTip(_GetVar("ResumeDownload"))
			If _GetVar("ResumeDownload") = 1 Then
				_SetVar("ResumeDownload", 0)
				ExitLoop 1
			EndIf
			If Not WinExists($__hwnd_vars) Then ExitLoop 2
		WEnd
	WEnd

	_WinHttpCloseHandle($hHTTPOpen)
	FileClose($hDlFile)
	If Not WinExists($__hwnd_vars) Then
		DirRemove($TempDir, 1) ; 没有父进程则删除文件
	EndIf
EndFunc   ;==>DownloadChrome
Func __DownloadChrome($url, $localfile, $hDlFile, $version, $DownloadThreads, $hHTTPOpen, ByRef $DownLoadInfo)
	Local $i, $header, $remotesize, $aThread, $match
	Local $TempDir = StringMid($localfile, 1, StringInStr($localfile, "\", 0, -1) - 1)
	Local $resume = IsArray($DownLoadInfo)

	If Not $resume Then
		IniWrite($TempDir & "\Update.ini", "general", "pid", @AutoItPID) ; 执行更新的程序pid,用来验证是否已有MyChrome进程在更新chrome
		IniWrite($TempDir & "\Update.ini", "general", "exe", StringRegExpReplace(@AutoItExe, ".*\\", "")) ; 正在执行更新的程序名
		If $version Then IniWrite($TempDir & "\Update.ini", "general", "latest", $version) ; 最新版本号
		IniWrite($TempDir & "\Update.ini", "general", "url", $url) ; 下载地址

		; 测试服务器是否支持断点续传、获取远程文件大小，分块
		_SetVar("DLInfo", "|||||正在连接 Google Chrome 服务器...")
		For $i = 1 To 3
			$aThread = CreateThread($url, $hHTTPOpen, "10-20")
			$header = _WinHttpQueryHeaders($aThread[0])
			_WinHttpCloseHandle($aThread[0])
			_WinHttpCloseHandle($aThread[1])
			If StringRegExp($header, '(?i)(?s)^HTTP/[\d\.]+ +2') Then ExitLoop
			Sleep(500)
			If Not WinExists($__hwnd_vars) Then ExitLoop
		Next

		If Not $aThread[0] Or $header = "" Then
			Return SetError(1, 0, "||1||1|连接 Google Chrome 更新服务器失败") ; 无法连接服务器
		EndIf
		If StringRegExp($header, '(?i)(?s)^HTTP/[\d\.]+ +200 ') Then ; 不支持断点续传
			Dim $DownLoadInfo[1][5] = [[0, 0, 0]]
			$match = StringRegExp($header, '(?i)(?m)Content-Length: *(\d+)', 1)
			If Not @error Then
				$remotesize = $match[0]
				$DownLoadInfo[0][2] = $remotesize - 1
			EndIf
		Else
			Dim $DownLoadInfo[$DownloadThreads][5]
			$match = StringRegExp($header, '(?i)(?m)^Content-Range: *bytes +10-20/(\d+)', 1)
			If Not @error Then ; 多线程分段下载
				$remotesize = $match[0]
				Local $chunks = UBound($DownLoadInfo)
				Local $chunksize = Ceiling($remotesize / $chunks)
				Local $pointer = 0
				$DownLoadInfo[$chunks - 1][2] = $remotesize - 1
				For $i = 0 To $chunks - 1
					$DownLoadInfo[$i][0] = $pointer
					$DownLoadInfo[$i][1] = $pointer
					$pointer += $chunksize
					If $i <> $chunks - 1 Then $DownLoadInfo[$i][2] = $pointer
					$pointer += 1
				Next
			EndIf
		EndIf

		If Not $remotesize Then ; 如果远程文件大小未知，则改单线程下载
			Dim $DownLoadInfo[1][5] = [[0, 0, 0]]
		EndIf
		IniWrite($TempDir & "\Update.ini", "general", "size", $remotesize)
	EndIf

	_SetVar("DLInfo", "|||||下载 Google Chrome ...")
	Local $range, $j
	For $i = 0 To UBound($DownLoadInfo) - 1 ; 发送请求
		If Not WinExists($__hwnd_vars) Then ExitLoop
		If $DownLoadInfo[$i][2] Then
			If $DownLoadInfo[$i][1] > $DownLoadInfo[$i][2] Then ContinueLoop
			$range = $DownLoadInfo[$i][1] & "-" & $DownLoadInfo[$i][2]
		EndIf
		For $j = 1 To 2
			If Not WinExists($__hwnd_vars) Then ExitLoop
			$aThread = CreateThread($url, $hHTTPOpen, $range)
			If Not @error Then ExitLoop
			Sleep(200)
		Next
		If $i = 0 And _WinHttpQueryHeaders($aThread[0], $WINHTTP_QUERY_STATUS_CODE) = 200 Then ; 不支持断点续传
			$DownLoadInfo[$i][0] = 0
			$DownLoadInfo[$i][1] = 0
		EndIf
		$DownLoadInfo[$i][3] = $aThread[0] ; $hHttpRequest
		$DownLoadInfo[$i][4] = $aThread[1] ; $hHttpConnect
	Next

	Local $n, $data, $RecvError, $RecvLen, $msg, $bytes
	Local $Threads = UBound($DownLoadInfo)
	Local $t = TimerInit()
	Local $timediff, $timeinit = $t
	Local $speed, $progress
	Local $ErrorThreads, $LiveThreads, $FileError
	Local $size = 0, $a
	Local $S[50] ; Stack for download speed calculation
	$remotesize = $DownLoadInfo[$Threads - 1][2] + 1
	If $resume Then
		For $i = 0 To $Threads - 1
			$size += $DownLoadInfo[$i][1] - $DownLoadInfo[$i][0]
		Next
	EndIf
	For $i = 0 To UBound($S) - 1
		$S[$i] = "0:" & $size
	Next

	Do
		If Not WinExists($__hwnd_vars) Then ExitLoop
		For $i = 0 To $Threads - 1
			If Not WinExists($__hwnd_vars) Then ExitLoop 2
			If Not $DownLoadInfo[$i][3] Or $DownLoadInfo[$i][3] = -1 Then
				ContinueLoop
			EndIf

			If _WinHttpQueryDataAvailable($DownLoadInfo[$i][3]) Then
				$bytes = @extended
			Else
				$bytes = Default
			EndIf

			$data = _WinHttpReadData($DownLoadInfo[$i][3], 2, $bytes) ; read binary
			$RecvError = @error
			$RecvLen = @extended
			If $RecvError = -1 Then ; 当前线程下载完成
				_WinHttpCloseHandle($DownLoadInfo[$i][3])
				_WinHttpCloseHandle($DownLoadInfo[$i][4])
				$DownLoadInfo[$i][3] = -1
				$DownLoadInfo[$i][4] = -1

				; 判断是否有出错暂停的线程
				$n = 0
				For $j = 0 To $Threads - 1
					If Not $DownLoadInfo[$j][3] Then
						$n = $j
						ExitLoop
					EndIf
				Next
				; 尝试重新启动出错的线程
				If $n Then
					For $j = 1 To 3 ; 重试3次
						Sleep(200)
						$aThread = CreateThread($url, $hHTTPOpen, $DownLoadInfo[$n][1] & "-" & $DownLoadInfo[$n][2])
						If Not @error Then
							$DownLoadInfo[$n][3] = $aThread[0] ; $hHttpRequest
							$DownLoadInfo[$n][4] = $aThread[1] ; $hHttpConnect
							ExitLoop
						EndIf
					Next
				EndIf
			ElseIf $RecvError Then ; 出错，重试，断点续传
				_WinHttpCloseHandle($DownLoadInfo[$i][3])
				_WinHttpCloseHandle($DownLoadInfo[$i][4])
				$DownLoadInfo[$i][3] = 0 ; 出错标志
				$DownLoadInfo[$i][4] = 0 ; 出错标志
				For $j = 1 To 3 ; 重试3次
					Sleep(200)
					$aThread = CreateThread($url, $hHTTPOpen, $DownLoadInfo[$i][1] & "-" & $DownLoadInfo[$i][2])
					If Not @error Then
						$DownLoadInfo[$i][3] = $aThread[0] ; $hHttpRequest
						$DownLoadInfo[$i][4] = $aThread[1] ; $hHttpConnect
						ExitLoop
					EndIf
				Next
			ElseIf $RecvLen Then
				FileSetPos($hDlFile, $DownLoadInfo[$i][1], 0)
				If Not FileWrite($hDlFile, $data) Then
					$FileError = 1
					ExitLoop
				Else
					$DownLoadInfo[$i][1] += $RecvLen
				EndIf
			EndIf
		Next

		; 检查下载是否结束，是否出错
		$size = 0
		$ErrorThreads = 0
		$LiveThreads = 0
		For $i = 0 To $Threads - 1
			$size += $DownLoadInfo[$i][1] - $DownLoadInfo[$i][0]
			If $DownLoadInfo[$i][3] = 0 Then
				$ErrorThreads += 1
			ElseIf $DownLoadInfo[$i][3] <> -1 Then
				$LiveThreads += 1
			EndIf
		Next

		If $FileError Or (Not $LiveThreads And $ErrorThreads) Then
			Return SetError(2, 0, $size & "|" & $remotesize & "|1||2|下载 Google Chrome 出错") ; 文件写入出错或下载出错
		EndIf

		If TimerDiff($t) > 200 Then
			$speed = 0
			$t = TimerInit()
			$timediff = TimerDiff($timeinit)
			_ArrayPush($S, $timediff & ":" & $size)
			$a = StringSplit($S[0], ":")
			If $a[0] >= 2 Then
				$speed = ($size - $a[2]) / ($timediff - $a[1]) / 1.024
				$speed = StringFormat('%.1f', $speed)
			EndIf
			$progress = Round($size / 1024) & " KB / " & Round($remotesize / 1024) & " KB  -  " & $speed & " KB/s"
			_SetVar("DLInfo", $size & "|" & $remotesize & "||||下载 Google Chrome: " & $progress)
		EndIf
	Until Not $LiveThreads

	FileClose($hDlFile)
	FileSetAttrib($localfile, "+A") ; Win8中没这行会出错
	If $remotesize And $remotesize <> FileGetSize($localfile) Then ; 文件大小不对，下载出错
		Return SetError(3, 0, $size & "|" & $remotesize & "|1||3|已下载的 Google Chrome 文件大小不正确") ; 已下载的文件大小不正确
	Else
		Return SetError(0, 0, $size & "|" & $remotesize & "|1|1||Google Chrome 下载完成")
	EndIf
EndFunc   ;==>__DownloadChrome
#EndRegion DownloadChrome

; #FUNCTION# ;===============================================================================
; Name...........: CreateThread
; Description ...: 创建线程
; Syntax.........: CreateThread($url, $hHttpOpen, $range = "")
; Parameters ....: $url - 网址，如："http://dl.google.com/chrome/install/912.12/chrome_installer.exe"
;                  $hHttpOpen -
;                  $range - 请求的范围, 如 "0-10000"
; Return values .: array
;                  Success: [$hHttpRequest, $hHttpConnect]
;                  failure: [0, 0] and set @error
;============================================================================================
Func CreateThread($url, $hHTTPOpen, $range = "")
	Local $hHttpConnect, $hHttpRequest, $aHandle

	Local $aUrl = HttpParseUrl($url) ; $aUrl[0] - host, $aUrl[1] - page, $aUrl[2] - port
	$hHttpConnect = _WinHttpConnect($hHTTPOpen, $aUrl[0], $aUrl[2])

	If $aUrl[2] = 443 Then
		$hHttpRequest = _WinHttpOpenRequest($hHttpConnect, "GET", $aUrl[1], Default, Default, Default, _
				BitOR($WINHTTP_FLAG_SECURE, $WINHTTP_FLAG_ESCAPE_DISABLE))
	Else
		$hHttpRequest = _WinHttpOpenRequest($hHttpConnect, "GET", $aUrl[1])
	EndIf
	If $range Then
		_WinHttpSendRequest($hHttpRequest, "Range: bytes=" & $range & @CRLF)
	Else
		_WinHttpSendRequest($hHttpRequest)
	EndIf
	_WinHttpReceiveResponse($hHttpRequest)
	Local $header = _WinHttpQueryHeaders($hHttpRequest, $WINHTTP_QUERY_STATUS_CODE)
	If StringLeft($header, 1) <> "2" Or Not _WinHttpQueryDataAvailable($hHttpRequest) Then
		_WinHttpCloseHandle($hHttpRequest)
		_WinHttpCloseHandle($hHttpConnect)
		Dim $aHandle[2] = [0, 0]
		Return SetError(1, 0, $aHandle)
	EndIf
	Dim $aHandle[2] = [$hHttpRequest, $hHttpRequest]
	Return SetError(0, 0, $aHandle)
EndFunc   ;==>CreateThread

Func InstallChrome($ChromeInstaller = "")
	$ChromePath = FullPath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Local $TempDir = $ChromeDir & "\~update"
	If Not FileExists($TempDir) Then DirCreate($TempDir)
	If $ChromeInstaller = "" Then $ChromeInstaller = $TempDir & "\chrome_installer.exe"

	If IsHWnd($hSettings) Then
		_GUICtrlStatusBar_SetText($hStausbar, "正在提取 Google Chrome 程序文件...")
	Else
		TraySetState(1)
		TraySetClick(0)
		TraySetToolTip("MyChrome")
		TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "")
		TrayTip("Google Chrome 更新", "正在提取 Google Chrome 程序文件...", 5, 1)
	EndIf

	; 解压
	FileInstall("7z.exe", $TempDir & "\7z.exe", 1) ; http://www.7-zip.org/download.html
	FileInstall("7z.dll", $TempDir & "\7z.dll", 1)
	RunWait($TempDir & '\7z.exe x "' & $ChromeInstaller & '" -y', $TempDir, @SW_HIDE)
	RunWait($TempDir & '\7z.exe x "' & $TempDir & '\chrome.7z" -y', $TempDir, @SW_HIDE)

	; 检查主要文件是否存在
	Local $latest = IniRead($TempDir & "\Update.ini", "general", "latest", "")
	If Not StringInStr($latest, ".") Then ; 版本号中必须有 .
		$latest = FileGetVersion($TempDir & "\Chrome-bin\chrome.exe")
		If Not $latest Then ; 不带版本号
			Local $file
			Local $search = FileFindFirstFile("*.*")
			While 1
				$file = FileFindNextFile($search)
				If @error Then ExitLoop
				If StringRegExp($file, "^[\d\.]+\.[\d\.]+$") Then
					$latest = $file
					ExitLoop
				EndIf
			WEnd
			FileClose($search)
		EndIf
	EndIf

	If Not FileExists($TempDir & "\Chrome-bin\chrome.exe") Or Not FileExists($TempDir & "\Chrome-bin\" & $latest & "\chrome.dll") Then
		MsgBox(64, "更新错误-MyChrome", "提取 Google Chrome 程序文件失败！", 0, $hSettings)
		Return SetError(1, 0, 0) ; 解压错误
	EndIf

	FileMove($TempDir & "\Chrome-bin\*.*", $TempDir & "\Chrome-bin\" & $latest & "\", 9)
	DirRemove($ChromeDir & "\~updated", 1)
	DirMove($TempDir & "\Chrome-bin\" & $latest, $ChromeDir & "\~updated", 1)

	; 复制程序文件
	$ChromeIsRunning = ChromeIsRunning($ChromePath, '请关闭 Chrome 浏览器以便完成更新，或者点击“取消”推迟到下次启动时应用更新。')
	If $ChromeIsRunning Then Return
	Return ApplyUpdate() ; 返回版本号
EndFunc   ;==>InstallChrome


Func ApplyUpdate()
	If IsHWnd($hSettings) Then
		_GUICtrlStatusBar_SetText($hStausbar, "正在应用浏览器更新...")
	ElseIf @TrayIconVisible Then
		TrayTip("Google Chrome 更新", "正在应用浏览器更新...", 5, 1)
	EndIf
	FileMove($ChromeDir & "\~updated\*.*", $ChromeDir, 9)
	DirCopy($ChromeDir & "\~updated", $ChromeDir, 1)
	; 如果设定的chrome程序文件路径不以chrome.exe结尾，则认为使用者将其改名，将chrome.exe重命名为设定的文件名
	If StringRegExpReplace($ChromePath, ".*\\", "") <> "chrome.exe" Then
		FileMove($ChromeDir & "\chrome.exe", $ChromePath, 1)
	EndIf
	Local $chromedll = $ChromeDir & "\chrome.dll"
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = FileGetVersion($chromedll, "LastChange")
	If IsHWnd($hSettings) Then
		GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	EndIf
	MsgBox(64, "MyChrome", "Google Chrome 浏览器已更新至 " & $ChromeFileVersion & " (" & $ChromeLastChange & ") !", 0, $hSettings)
	DirRemove($ChromeDir & "\~updated", 1)
	Return $ChromeFileVersion ; 返回版本号
EndFunc   ;==>ApplyUpdate

;~ 显示托盘气泡提示
Func TrayTipProgress()
	$TrayTipProgress = 1
EndFunc   ;==>TrayTipProgress

;~ 退出更新，清理临时文件，恢复状态
Func EndUpdate()
	If ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf

	; 检查是否有另一个 MyChrome 进程正在更新 Chrome，
	If Not ChromeIsUpdating($ChromeDir) Then
		Local $TempDir = $ChromeDir & "\~update"
		If FileExists($TempDir) Then
			DirRemove($TempDir, 1) ; 如果此文件夹中没有其它文件则删除
		EndIf
	EndIf

	If IsHWnd($hSettings) Then
		GUICtrlSetData($hCheckUpdate, "立即更新")
		GUICtrlSetTip($hCheckUpdate, "检查浏览器更新" & @CRLF & "下载最新版至 chrome 程序文件夹")
		GUICtrlSetState($hSettingsOK, $GUI_ENABLE)
		GUICtrlSetState($hSettingsApply, $GUI_ENABLE)
		_GUICtrlStatusBar_SetText($hStausbar, '双击软件目录下的 "' & $AppName & '.vbs" 文件可调出此窗口')
	EndIf
	$IsUpdating = 0
EndFunc   ;==>EndUpdate

; 退出前检查是否在更新
Func ExitApp()
	If $IsUpdating Then
		Local $msg = MsgBox(292, "MyChrome", "浏览器正在更新，确定要取消更新并退出吗？", 0, $hSettings)
		If $msg = 7 Then Return
		EndUpdate()
	ElseIf ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf
	Exit
EndFunc   ;==>ExitApp

; #FUNCTION# ;===============================================================================
; Name...........: SplitPath
; Description ...: 路径分割
; Syntax.........: SplitPath($path, ByRef $dir, ByRef $file)
;                  $path - 路径
;                  $dir - 目录
;                  $file - 文件名
; Return values .: Success -
;                  Failure -
; Author ........: 甲壳虫
;============================================================================================
Func SplitPath($path, ByRef $dir, ByRef $file)
	Local $pos = StringInStr($path, "\", 0, -1)
	If $pos = 0 Then
		$dir = "."
		$file = $path
	Else
		$dir = StringLeft($path, $pos - 1)
		$file = StringMid($path, $pos + 1)
	EndIf
EndFunc   ;==>SplitPath

;~ 绝对路径转成相对于脚本目录的相对路径，
;~ 如 .\dir1\dir2 或 ..\dir2
Func RelativePath($path)
	If $path = "" Then Return $path
	If StringLeft($path, 1) = "%" Then Return $path
	If Not StringInStr($path, ":") And StringLeft($path, 2) <> "\\" Then Return $path
	If StringLeft(@ScriptDir, 3) <> StringLeft($path, 3) Then Return $path ; different driver
	If StringRight($path, 1) <> "\" Then $path &= "\"
	Local $r = '.\'
	Local $pos, $dir = @ScriptDir & "\"
	While 1
		$path = StringReplace($path, $dir, $r)
		If @extended Then ExitLoop
		$pos = StringInStr($dir, "\", 0, -2)
		If $pos = 0 Then ExitLoop
		$dir = StringLeft($dir, $pos)
		If StringLeft($r, 2) = '.\' Then
			$r = '..\'
		Else
			$r = '..\' & $r
		EndIf
	WEnd
	If StringRight($path, 1) = "\" Then $path = StringTrimRight($path, 1)
	Return $path
EndFunc   ;==>RelativePath

;~ 相对于脚本目录的相对路径转换成绝对路径，输出结果结尾没有 “\”。
Func FullPath($path)
	If $path = "" Then Return $path
	If StringLeft($path, 1) = "%" Then Return $path
	If StringInStr($path, ":\") Or StringLeft($path, 2) = "\\" Then Return $path
	If StringRight($path, 1) <> "\" Then $path &= "\"
	Local $dir = @ScriptDir
	If StringLeft($path, 2) = ".\" Then
		$path = StringReplace($path, '.', $dir, 1)
	ElseIf StringLeft($path, 3) <> "..\" Then
		$path = $dir & "\" & $path
	Else
		Local $i, $n, $pos
		$path = StringReplace($path, "..\", "")
		$n = @extended
		For $i = 1 To $n
			$pos = StringInStr($dir, "\", 0, -1)
			If $pos = 0 Then ExitLoop
			$dir = StringLeft($dir, $pos - 1)
		Next
		$path = $dir & "\" & $path
	EndIf
	If StringRight($path, 1) = "\" Then $path = StringTrimRight($path, 1)
	Return $path
EndFunc   ;==>FullPath

;~ 判断是否有另一个 MyChrome 进程正在更新当前的 chrome
;~ 本程序是否正在更新 chrome 由 $IsUpdating 判断
Func ChromeIsUpdating($dir)
	Local $UpdateIni = $dir & "\~update\Update.ini"
	If Not FileExists($UpdateIni) Then Return

	Local $pid = IniRead($UpdateIni, "general", "pid", "")
	Local $exe = IniRead($UpdateIni, "general", "exe", "")
	If $pid <> $iThreadPid And ProcessExists($pid) And ProcessExists($exe) Then
		Return 1
	EndIf
EndFunc   ;==>ChromeIsUpdating

Func AppIsRunning($AppPath)
	Local $exe = StringRegExpReplace($AppPath, '.*\\', '')
	Local $list = ProcessList($exe)
	For $i = 1 To $list[0][0]
		If StringInStr(GetProcPath($list[$i][1]), $AppPath) Then
			Return $list[$i][1]
		EndIf
	Next
	Return 0
EndFunc   ;==>AppIsRunning

;~ 等待 chrome 浏览器关闭
Func ChromeIsRunning($AppPath = "chrome.exe", $msg = "请关闭 Google Chrome 浏览器后继续！")
	If Not AppIsRunning($AppPath) Then Return 0
	Dim $hSettings
	$var = MsgBoxE(52, 'MyChrome', $msg, 0, $hSettings, '强制关闭', '取消')
	If $var <> 6 Then Return 1

	$exe = StringRegExpReplace($AppPath, '.*\\', '')
	For $j = 1 To 20
		; close chrome
		$list = WinList("[REGEXPCLASS:(?i)Chrome]")
		For $i = 1 To $list[0][0]
			$pid = WinGetProcess($list[$i][1])
			If StringInStr(GetProcPath($pid), $AppPath) Then
				WinClose($list[$i][1])
				WinWaitClose($list[$i][1], "", 2)
			EndIf
		Next
		; kill chrome processes
		Sleep(1000)
		$list = ProcessList($exe)
		For $i = 1 To $list[0][0]
			If StringInStr(GetProcPath($list[$i][1]), $AppPath) Then
				ProcessClose($list[$i][1])
			EndIf
		Next
		If Not AppIsRunning($AppPath) Then Return 0
	Next
	Return 1
EndFunc   ;==>ChromeIsRunning


; #FUNCTION# ;===============================================================================
; Name...........: HttpParseUrl
; Description ...: 解析 http 网址
; Syntax.........: HttpParseUrl($url)
; Parameters ....: $url - 网址，如：http://dl.google.com/chrome/install/912.12/chrome_installer.exe
; Return values .: Success - $Array[0] - host, 如：dl.google.com
;                            $Array[1] - page, 如：/chrome/install/912.12/chrome_installer.exe
;                            $Array[2] - port, 如：80
;                  Failure - Returns empty sets @error
; Author ........: 甲壳虫
;============================================================================================
Func HttpParseUrl($url)
	Local $host, $page, $port, $aResults[3]
	Local $match = StringRegExp($url, '(?i)^https?://([^/]+)(/?.*)', 1)
	If @error Then Return SetError(1, 0, $aResults)
	$aResults[0] = $match[0] ; host
	$aResults[1] = $match[1] ; page
	If $aResults[1] = "" Then $aResults[1] = "/"
	If StringLeft($url, 5) = "https" Then
		$aResults[2] = 443
	Else
		$aResults[2] = 80
	EndIf
	Return SetError(0, 0, $aResults)
EndFunc   ;==>HttpParseUrl

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBox_SelectString
; Description ...: Searches the ListBox of a ComboBox for an item that begins with the characters in a specified string
; Syntax.........: _GUICtrlComboBox_SelectString($hWnd, $sText[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String that contains the characters for which to search
;                  $iIndex      - Specifies the zero-based index of the item preceding the first item to be searched
; Return values .: Success      - The index of the selected item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When the search reaches the bottom of the list, it continues from the top of the list back to the
;                  item specified by the wParam parameter.
;+
;                  If $iIndex is ?, the entire list is searched from the beginning.
;                  A string is selected only if the characters from the starting point match the characters in the
;                  prefix string
;+
;                  If a matching item is found, it is selected and copied to the edit control
; Related .......: _GUICtrlComboBox_FindString, _GUICtrlComboBox_FindStringExact, _GUICtrlComboBoxEx_FindStringExact
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBox_SelectString($hWnd, $sText, $iIndex = -1)
;~ 	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $CB_SELECTSTRING, $iIndex, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlComboBox_SelectString


;===============================================================================
;~ 参考： http://www.autoitx.com/viewthread.php?tid=13550&extra=&page=3
;~ 函数: MsgBoxE()
;~ 描述: 修改 MsgBox() 的位置或按钮文字
;~ 参数:
;~ $flag = MsgBox() 的 flag
;~ $title = MsgBox() 标题
;~ $text = MsgBox() 的信息内容
;~ $timeout = MsgBox() 超时
;~ $hwnd = MsgBox() 的 hwnd
;~ $Button1 = 第一个按钮要显示的文字
;~ $Button2 = 第二个按钮要显示的文字
;~ $Button3 = 第三个按钮要显示的文字
;~ $x = MsgBox() 的 x 坐标
;~ $y = MsgBox() 的 y 坐标
;~ 返回值: 同 MsgBox() 的返回值
;~ 例:
;~ $msg = MsgBoxE(3, '_MsgBoxE()示例', _
;~ 		'本例对 MsgBox(3, "", "...") 的按钮和位置进行修改：' & @CRLF & @CRLF & _
;~ 		'第一个按钮“是”改成“按钮1”' & @CRLF & _
;~ 		'第二个按钮“否”改成“修改设置”' & @CRLF & _
;~ 		'第三个按钮“取消”不修改' & @CRLF & _
;~ 		'x 座标不变，y 座标改成 100', 0, '', '按钮1', '修改设置', '', '', 100)
;~ MsgBox(0, 'MsgBoxE()', '返回：' & $msg)
;===============================================================================
Func MsgBoxE($flag, $title, $text, $timeout = 0, $hWnd = '', $Button1 = '', $Button2 = '', $Button3 = '', $x = '', $y = '')

	; 参数加在 title 后面传递给 MB__CallBack，避免使用全局变量
	$title &= @CRLF & 'B1=' & $Button1 & @CRLF & 'B2=' & $Button2 & @CRLF & 'B3=' & $Button3 & @CRLF & 'x=' & $x & @CRLF & 'y=' & $y

	Local $hGUI = GUICreate("")
	Local $sFuncName = "GetWindowLongW"
	If @AutoItX64 Then $sFuncName = "GetWindowLongPtrW"
	Local $aResult = DllCall("user32.dll", "long_ptr", $sFuncName, "hwnd", $hGUI, "int", -6)
	Local $hInst = $aResult[0]

	$aResult = DllCall("kernel32.dll", "dword", "GetCurrentThreadId")
	Local $iThreadId = $aResult[0]

	Local $hCallBack = DllCallbackRegister("MB__CallBack", "int", "int;hWnd;ptr")
	Local $pCallBack = DllCallbackGetPtr($hCallBack)

	$aResult = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", 5, "ptr", $pCallBack, "handle", $hInst, "dword", $iThreadId)
	Local $hHook = $aResult[0]

	Local $msg = MsgBox($flag, $title, $text, $timeout, $hWnd)

	GUIDelete($hGUI)
	DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $hHook)
	DllCallbackFree($hCallBack)
	Return $msg
EndFunc   ;==>MsgBoxE
Func MB__CallBack($iCode, $wParam, $lParam)
;~ 	ConsoleWrite('$iCode=' & $iCode & ', $wParam=' & $wParam & ', $lParam=' & $lParam & @CRLF)

	If $iCode = 5 Then

		Local $title = WinGetTitle($wParam)
		If Not StringInStr($title, @CRLF & 'B1=') Then Return

		Local $match = StringRegExp($title, '(?i)\r\nB1=(.*)\r\nB2=(.*)\r\nB3=(.*)\r\nx=(.*)\r\ny=(.*)', 1)
		If @error Then Return

		; 改回 title
		$title = StringRegExpReplace($title, '(?i)(?s)\r\nB1=.*', '')
		WinSetTitle($wParam, '', $title)

		; 移动 MsgBox 位置
		If $match[3] <> '' Or $match[4] <> '' Then
			If $match[3] = '' Then $match[3] = Default
			If $match[4] = '' Then $match[4] = Default
			WinMove($wParam, '', $match[3], $match[4])
		EndIf

		; 修改按钮文字
		If $match[0] <> '' Then ControlSetText($wParam, '', 'Button1', $match[0])
		If $match[1] <> '' Then ControlSetText($wParam, '', 'Button2', $match[1])
		If $match[2] <> '' Then ControlSetText($wParam, '', 'Button3', $match[2])
	EndIf
EndFunc   ;==>MB__CallBack


; Windows 内部版本号
;~ MsgBox(0, "", "Windows 内部版本号：" & WinVer())
Func WinVer()
	Local $tOSVI, $ret
	$tOSVI = DllStructCreate('dword Size;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128]')
	DllStructSetData($tOSVI, 'Size', DllStructGetSize($tOSVI))
	$ret = DllCall('kernel32.dll', 'int', 'GetVersionExW', 'ptr', DllStructGetPtr($tOSVI))
	If (@error) Or (Not $ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return DllStructGetData($tOSVI, 'MajorVersion') & "." & DllStructGetData($tOSVI, 'MinorVersion')
EndFunc   ;==>WinVer


;===============================================================================
;~ 函数: TrayTipExists()
;~ 描述: 检测托盘提示是否存在
;~ 参数:
;~ $TrayText = TrayTip text 中包含的文字
;~ $MatchMode = TrayTip text 匹配模式
;~                  0 - 用 StringInStr 匹配部分文字 (default)
;~                  1 - StringRegExp 正则式匹配
;~ 返回值: TrayTip() 的 handle
;~ 例:
;~ TrayTip("下载 Google Chrome", "10000 KB / 21000 KB - 100 KB/s", 20)
;~ $hTrayTip = TrayTipExists("(?i) KB / .* KB .* KB/s", 1)
;~ If Not $hTrayTip Then
;~ 	MsgBox(0, "", "未检测到托盘提示！")
;~ Else
;~ 	Do
;~ 		Sleep(100)
;~ 	Until Not TrayTipExists("(?i) KB / .* KB .* KB/s", 1)
;~ 	MsgBox(0, "TrayTipExists()", "托盘提示因点击或超时关闭！")
;~ EndIf
;===============================================================================
Func TrayTipExists($TrayText, $MatchMode = 0)
	Local $aWindows = WinList('[CLASS:tooltips_class32]')
	Local $i, $hWnd, $class, $text
	For $i = 1 To $aWindows[0][0]
		If Not BitAND(WinGetState($aWindows[$i][1]), 2) Then ContinueLoop ; 忽略不可见窗口

		$hWnd = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $aWindows[$i][1])
		If @error Then Return SetError(@error, @extended, 0)
		$class = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd[0], "wstr", "", "int", 1024);根据句柄得到类
		If @error Then Return SetError(@error, @extended, 0)
		If $class[2] <> "Shell_TrayWnd" Then ContinueLoop ; 忽略非托盘提示

		$text = WinGetTitle($aWindows[$i][1]) ; 实际取得的是 TrayTip() 的 text
		If $MatchMode = 1 Then
			If StringRegExp($text, $TrayText) Then Return $aWindows[$i][1]
		Else
			If StringInStr($text, $TrayText) Then Return $aWindows[$i][1]
		EndIf
	Next
EndFunc   ;==>TrayTipExists

;~ 函数。整理内存
;~ http://www.autoitscript.com/forum/index.php?showtopic=13399&hl=GetCurrentProcessId&st=20
; Original version : w_Outer
; modified by Rajesh V R to include process ID
Func ReduceMemory($ProcID = @AutoItPID)
	Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $ProcID)
	Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
	DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
	Return $ai_Return[0]
EndFunc   ;==>ReduceMemory

; http://www.autoitscript.com/forum/topic/78445-solved-parent-process-child-process/
Func _ProcessGetChildren($i_pid) ; First level children processes only
	Local Const $TH32CS_SNAPPROCESS = 0x00000002
	Local $a_tool_help = DllCall("Kernel32.dll", "long", "CreateToolhelp32Snapshot", "int", $TH32CS_SNAPPROCESS, "int", 0)
	If IsArray($a_tool_help) = 0 Or $a_tool_help[0] = -1 Then Return SetError(1, 0, $i_pid)
	Local $tagPROCESSENTRY32 = _
			DllStructCreate _
			( _
			"dword dwsize;" & _
			"dword cntUsage;" & _
			"dword th32ProcessID;" & _
			"uint th32DefaultHeapID;" & _
			"dword th32ModuleID;" & _
			"dword cntThreads;" & _
			"dword th32ParentProcessID;" & _
			"long pcPriClassBase;" & _
			"dword dwFlags;" & _
			"char szExeFile[260]" _
			)
	DllStructSetData($tagPROCESSENTRY32, 1, DllStructGetSize($tagPROCESSENTRY32))
	Local $p_PROCESSENTRY32 = DllStructGetPtr($tagPROCESSENTRY32)
	Local $a_pfirst = DllCall("Kernel32.dll", "int", "Process32First", "long", $a_tool_help[0], "ptr", $p_PROCESSENTRY32)
	If IsArray($a_pfirst) = 0 Then Return SetError(2, 0, $i_pid)
	Local $a_pnext, $a_children[11][2] = [[10]], $i_child_pid, $i_parent_pid, $i_add = 0
	$i_child_pid = DllStructGetData($tagPROCESSENTRY32, "th32ProcessID")
	If $i_child_pid <> $i_pid Then
		$i_parent_pid = DllStructGetData($tagPROCESSENTRY32, "th32ParentProcessID")
		If $i_parent_pid = $i_pid Then
			$i_add += 1
			$a_children[$i_add][0] = $i_child_pid
			$a_children[$i_add][1] = DllStructGetData($tagPROCESSENTRY32, "szExeFile")
		EndIf
	EndIf
	While 1
		$a_pnext = DllCall("Kernel32.dll", "int", "Process32Next", "long", $a_tool_help[0], "ptr", $p_PROCESSENTRY32)
		If IsArray($a_pnext) And $a_pnext[0] = 0 Then ExitLoop
		$i_child_pid = DllStructGetData($tagPROCESSENTRY32, "th32ProcessID")
		If $i_child_pid <> $i_pid Then
			$i_parent_pid = DllStructGetData($tagPROCESSENTRY32, "th32ParentProcessID")
			If $i_parent_pid = $i_pid Then
				If $i_add = $a_children[0][0] Then
					ReDim $a_children[$a_children[0][0] + 11][2]
					$a_children[0][0] = $a_children[0][0] + 10
				EndIf
				$i_add += 1
				$a_children[$i_add][0] = $i_child_pid
				$a_children[$i_add][1] = DllStructGetData($tagPROCESSENTRY32, "szExeFile")
			EndIf
		EndIf
	WEnd
	If $i_add <> 0 Then
		ReDim $a_children[$i_add + 1][2]
		$a_children[0][0] = $i_add
	EndIf
	DllCall("Kernel32.dll", "int", "CloseHandle", "long", $a_tool_help[0])
	If $i_add Then Return $a_children
	Return SetError(3, 0, 0)
EndFunc   ;==>_ProcessGetChildren


; #FUNCTION# ;===============================================================================
; 参考 http://www.autoitscript.com/forum/topic/63947-read-full-exe-path-of-a-known-windowprogram/
; Name...........: GetProcPath
; Description ...: 取得进程路径
; Syntax.........: GetProcPath($Process_PID)
; Parameters ....: $Process_PID - 进程的 pid
; Return values .: Success - 完整路径
;                  Failure - set @error
;============================================================================================
Func GetProcPath($pid = @AutoItPID)
	If @OSArch <> "X86" And Not @AutoItX64 And Not _WinAPI_IsWow64Process($pid) Then ; much slow than dllcall method
		Local $colItems = ""
		Local $objWMIService = ObjGet("winmgmts:\\localhost\root\CIMV2")
		$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE ProcessId = " & $pid, "WQL", _
				0x10 + 0x20)
		If IsObj($colItems) Then
			For $objItem In $colItems
				If $objItem.ExecutablePath Then Return $objItem.ExecutablePath
			Next
		EndIf
		Return ""
	Else
		Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', BitOR(0x0400, 0x0010), 'int', 0, 'dword', $pid)
		If (@error) Or (Not $hProcess[0]) Then Return SetError(1, 0, '')
		Local $ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetModuleFileNameExW', 'ptr', $hProcess[0], 'ptr', 0, 'wstr', '', 'int', 1024)
		If (@error) Or (Not $ret[0]) Then Return SetError(1, 0, '')
		Return $ret[3]
	EndIf
EndFunc   ;==>GetProcPath

; #FUNCTION# ====================================================================================================================
; Name ..........: _IsUACAdmin
; Description ...: Determines if process has Admin privileges and whether running under UAC.
; Syntax ........: _IsUACAdmin()
; Parameters ....: None
; Return values .: Success          - 1 - User has full Admin rights (Elevated Admin w/ UAC)
;                  Failure          - 0 - User is not an Admin, sets @extended:
;                                   | 0 - User cannot elevate
;                                   | 1 - User can elevate
; Author ........: Erik Pilsits
; Modified ......:
; Remarks .......: THE GOOD STUFF: returns 0 w/ @extended = 1 > UAC Protected Admin
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _IsUACAdmin()
	If StringRegExp(@OSVersion, "_(XP|2003)") Or RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA") <> 1 Then
		Return SetExtended(0, IsAdmin())
	EndIf

	Local $hToken = _Security__OpenProcessToken(_WinAPI_GetCurrentProcess(), $TOKEN_QUERY)
	Local $tTI = _Security__GetTokenInformation($hToken, $TOKENGROUPS)
	_WinAPI_CloseHandle($hToken)

	Local $pTI = DllStructGetPtr($tTI)
	Local $cbSIDATTR = DllStructGetSize(DllStructCreate("ptr;dword"))
	Local $count = DllStructGetData(DllStructCreate("dword", $pTI), 1)
	Local $pGROUP1 = DllStructGetPtr(DllStructCreate("dword;STRUCT;ptr;dword;ENDSTRUCT", $pTI), 2)
	Local $tGROUP, $sGROUP = ""

	; S-1-5-32-544 > BUILTINAdministrators > $SID_ADMINISTRATORS
	; S-1-16-8192  > Mandatory LabelMedium Mandatory Level (Protected Admin) > $SID_MEDIUM_MANDATORY_LEVEL
	; S-1-16-12288 > Mandatory LabelHigh Mandatory Level (Elevated Admin) > $SID_HIGH_MANDATORY_LEVEL
	; SE_GROUP_USE_FOR_DENY_ONLY = 0x10

	Local $inAdminGrp = False, $denyAdmin = False, $elevatedAdmin = False, $sSID
	For $i = 0 To $count - 1
		$tGROUP = DllStructCreate("ptr;dword", $pGROUP1 + ($cbSIDATTR * $i))
		$sSID = _Security__SidToStringSid(DllStructGetData($tGROUP, 1))
		If StringInStr($sSID, "S-1-5-32-544") Then ; member of Administrators group
			$inAdminGrp = True
			; check for deny attribute
			If (BitAND(DllStructGetData($tGROUP, 2), 0x10) = 0x10) Then $denyAdmin = True
		ElseIf StringInStr($sSID, "S-1-16-12288") Then
			$elevatedAdmin = True
		EndIf
	Next

	If $inAdminGrp Then
		; check elevated
		If $elevatedAdmin Then
			; check deny status
			If $denyAdmin Then
				; protected Admin CANNOT elevate
				Return SetExtended(0, 0)
			Else
				; elevated Admin
				Return SetExtended(1, 1)
			EndIf
		Else
			; protected Admin
			Return SetExtended(1, 0)
		EndIf
	Else
		; not an Admin
		Return SetExtended(0, 0)
	EndIf
EndFunc   ;==>_IsUACAdmin

Func VersionCompare($v1, $v2)
	Local $i, $c1, $c2, $a1, $a2
	StringReplace($v1, ".", ".")
	$c1 = @extended
	StringReplace($v2, ".", ".")
	$c2 = @extended
	If $c1 > $c2 Then
		For $i = 1 To $c1 - $c2
			$v2 &= ".0"
		Next
	Else
		For $i = 1 To $c2 - $c1
			$v1 &= ".0"
		Next
	EndIf
	$a1 = StringSplit($v1, ".")
	$a2 = StringSplit($v2, ".")
	For $i = 1 To $a1[0]
		If $a1[$i] * 1 <> $a2[$i] * 1 Then
			Return $a1[$i] - $a2[$i] > 0
		EndIf
	Next
	Return False
EndFunc   ;==>VersionCompare
