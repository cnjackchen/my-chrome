#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon_1.ico
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Google Chrome Portable
#AutoIt3Wrapper_Res_Fileversion=3.8.1.0
#AutoIt3Wrapper_Res_LegalCopyright=甲壳虫<jdchenjian@gmail.com>
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_AU3Check_Parameters=-q
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Date.au3>
#include <Constants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <GuiComboBox.au3>
#include <ComboConstants.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <WinAPIReg.au3>
#include <WinAPIMisc.au3>
#include <WinAPISys.au3>
#include <Misc.au3>
#include <InetConstants.au3>
#include "WinHttp.au3" ; http://www.autoitscript.com/forum/topic/84133-winhttp-functions/
#include "AppUserModelId.au3"
#include "AppMute.au3"

Global $WinVersion = _WinAPI_GetVersion()
Global Const $AppVersion = "3.8.1" ; MyChrome version
Global $AppName = StringRegExpReplace(@ScriptName, "\.[^.]*$", "")
Global $inifile = @ScriptDir & "\" & $AppName & ".ini"
Global $Language = IniRead($inifile, "Settings", "Language", "Auto")
Global $LangFile = LangCheck()
Global $ProxyType, $ProxySever, $ProxyPort
Global $UserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 Chrome/56.0.2924.87 Safari/537.36"

#include "SimpleMultiThreading.au3"
#include "IAccessible.au3"

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 3) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayOnEventMode", 1)
Opt("GUIOnEventMode", 1)
Opt("WinTitleMatchMode", 4)

Global $FirstRun = 0, $ChromePath, $ChromeDir, $ChromeExe, $UserDataDir, $Params
Global $CacheDir, $CacheSize, $PortableParam
Global $ChromeSource = "Google", $get_latest_chrome_ver = "get_latest_chrome_ver"
Global $LastCheckUpdate, $UpdateInterval, $Channel, $IsUpdating = 0, $x86 = 0
Global $AppUpdate, $AppUpdateLastCheck
Global $RunInBackground, $ExApp, $ExAppAutoExit, $ExApp2, $AppPID_Browser, $ExAppPID
Global $TaskBarDir = @AppDataDir & "\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
Global $TaskBarLastChange
Global $aExApp, $aExApp2, $aExAppPID[2]
Global $dicKeys, $Bosskey, $BosskeyM, $Hide2Tray
Global $KeepLastTab
Global $MouseClick2CloseTab ; LDClick|RClick + MClick
Global $Mouse2SwitchTab
Global $CancelAppUpdate

Global $hSettings, $SettingsOK
Global $hSettingsOK, $hSettingsApply, $hStausbar
Global $hChromePath, $hGetChromePath, $hChromeSource, $hCheckUpdate
Global $hChannel, $hx86, $hUpdateInterval, $hLatestChromeVer, $hCurrentVer, $hUserDataDir, $hCopyData, $hUrlList
Global $hAppUpdate, $hCacheDir, $hSelectCacheDir, $hCacheSize
Global $hParams, $hDownloadThreads, $hProxyType, $hProxySever, $hProxyPort
Global $hRunInBackground, $hLanguage, $hExApp, $hExAppAutoExit, $hExApp2
Global $hBosskey, $hBosskeyM, $hBosskeyM1, $hBosskeyM2, $hWndProc, $hHide2Tray
Global $hKeepLastTab, $hDoubleClick2CloseTab, $hRightClick2CloseTab, $hMouse2SwitchTab

Global $ChromeFileVersion, $ChromeLastChange, $LatestChromeVer, $LatestChromeUrls, $SelectedUrl
Global $DefaultChromeDir, $DefaultChromeVer, $DefaultUserDataDir
Global $TrayTipProgress = 0
Global $iThreadPid, $DownloadThreads

; Mouse events
Const $AU3_LCLICK = 0x0400 + 0x1A02
Const $AU3_LDCLICK = 0x0400 + 0x1A04
Const $AU3_LDROP = 0x0400 + 0x1A06
Const $AU3_RCLICK = 0x0400 + 0x1B02
Const $AU3_RDCLICK = 0x0400 + 0x1B04
Const $AU3_RDROP = 0x0400 + 0x1B06
Const $AU3_MCLICK = 0x0400 + 0x1C02
Const $AU3_MDCLICK = 0x0400 + 0x1C04
Const $AU3_MDROP = 0x0400 + 0x1C06
Const $AU3_XCLICK = 0x0400 + 0x1D02
Const $AU3_XDCLICK = 0x0400 + 0x1D04
Const $AU3_XDROP = 0x0400 + 0x1D06
Const $AU3_WHEELUP = 0x0400 + 0x1F02
Const $AU3_WHEELDOWN = 0x0400 + 0x1F04
;Const $WH_MOUSE = 7
Global $ChromeIsHidden
Global $hHookDll, $hHookLib, $hMouseHook

Global $hEvent_Reg, $ClientKey, $Progid
Global $aREG[6][3] = [[$HKEY_CURRENT_USER, 'Software\Clients\StartMenuInternet'], _
		[$HKEY_LOCAL_MACHINE, 'Software\Clients\StartMenuInternet'], _
		[$HKEY_CLASSES_ROOT, 'ftp'], _
		[$HKEY_CLASSES_ROOT, 'http'], _
		[$HKEY_CLASSES_ROOT, 'https'], _
		[$HKEY_CLASSES_ROOT, '']] ; ChromeHTML.XXX

; Global Const $KEY_WOW64_32KEY = 0x0200 ; Access a 32-bit key from either a 32-bit or 64-bit application
; Global Const $KEY_WOW64_64KEY = 0x0100 ; Access a 64-bit key from either a 32-bit or 64-bit application

If Not @AutoItX64 Then ; 32-bit Autoit
	$HKLM_Software_32 = "HKLM\SOFTWARE"
	$HKLM_Software_64 = "HKLM64\SOFTWARE"
Else ; 64-bit Autoit
	$HKLM_Software_32 = "HKLM\SOFTWARE\Wow6432Node"
	$HKLM_Software_64 = "HKLM64\SOFTWARE"
EndIf

Global $aFileAsso[6] = [".htm", ".html", ".shtml", ".webp", ".xht", ".xhtml"]
Global $aUrlAsso[13] = ["ftp", "http", "https", "irc", "mailto", "mms", "news", "nntp", "sms", "smsto", "tel", "urn", "webcal"]

FileChangeDir(@ScriptDir)

Global $EnvID = RegRead('HKLM64\SOFTWARE\Microsoft\Cryptography', 'MachineGuid')
$EnvID &= RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallDate")
$EnvID &= DriveGetSerial(@HomeDrive & "\")
$EnvID = StringTrimLeft(_WinAPI_HashString($EnvID, 0, 16), 2)

If Not FileExists($inifile) Then
	$FirstRun = 1
	IniWrite($inifile, "Settings", "AppVersion", $AppVersion)
	IniWrite($inifile, "Settings", "Language", "Auto")
	IniWrite($inifile, "Settings", "ChromePath", ".\Chrome\chrome.exe")
	IniWrite($inifile, "Settings", "UserDataDir", ".\User Data")
	IniWrite($inifile, "Settings", "CacheDir", "")
	IniWrite($inifile, "Settings", "CacheSize", 0)
	IniWrite($inifile, "Settings", "Channel", "Stable")
	IniWrite($inifile, "Settings", "x86", 0)
	IniWrite($inifile, "Settings", "ChromeSource", "Google")
	IniWrite($inifile, "Settings", "LastCheckUpdate", "2016/05/01 00:00:00")
	IniWrite($inifile, "Settings", "UpdateInterval", 24)

	IniWrite($inifile, "Settings", "ProxyType", "SYSTEM")
	IniWrite($inifile, "Settings", "UpdateProxy", "")
	IniWrite($inifile, "Settings", "UpdatePort", "")

	IniWrite($inifile, "Settings", "DownloadThreads", 3)
	IniWrite($inifile, "Settings", "Params", "")
	IniWrite($inifile, "Settings", "RunInBackground", 1)
	IniWrite($inifile, "Settings", "AppUpdate", 1)
	IniWrite($inifile, "Settings", "AppUpdateLastCheck", "2016/05/01 00:00:00")
	IniWrite($inifile, "Settings", "CheckDefaultBrowser", 1)
	IniWrite($inifile, "Settings", "ExApp", "")
	IniWrite($inifile, "Settings", "ExAppAutoExit", 1)
	IniWrite($inifile, "Settings", "ExApp2", "")
	IniWrite($inifile, "Settings", "Bosskey", "!x") ; Alt+x
	IniWrite($inifile, "Settings", "BosskeyM", $AU3_RDCLICK)
	IniWrite($inifile, "Settings", "Hide2Tray", 1)
	IniWrite($inifile, "Settings", "MouseClick2CloseTab", $AU3_LDCLICK)
	IniWrite($inifile, "Settings", "Mouse2SwitchTab", $AU3_WHEELDOWN & "|" & $AU3_WHEELUP)
	IniWrite($inifile, "Settings", "KeepLastTab", 0)
EndIf

; read ini info
$ChromePath = IniRead($inifile, "Settings", "ChromePath", ".\Chrome\chrome.exe")
$UserDataDir = IniRead($inifile, "Settings", "UserDataDir", ".\User Data")
$CacheDir = IniRead($inifile, "Settings", "CacheDir", "")
$CacheSize = IniRead($inifile, "Settings", "CacheSize", 0) * 1
$Channel = IniRead($inifile, "Settings", "Channel", "Stable")
$x86 = IniRead($inifile, "Settings", "x86", 0) * 1
$ChromeSource = IniRead($inifile, "Settings", "ChromeSource", "Google")
If $ChromeSource = "sina.com.cn" Then
	$get_latest_chrome_ver = "get_latest_chrome_ver_sina"
Else
	$get_latest_chrome_ver = "get_latest_chrome_ver"
EndIf
$LastCheckUpdate = IniRead($inifile, "Settings", "LastCheckUpdate", "2016/05/01 00:00:00")
$UpdateInterval = IniRead($inifile, "Settings", "UpdateInterval", 24) * 1
$ProxyType = IniRead($inifile, "Settings", "ProxyType", "SYSTEM")
$ProxySever = IniRead($inifile, "Settings", "UpdateProxy", "")
$ProxyPort = IniRead($inifile, "Settings", "UpdatePort", "")
$DownloadThreads = IniRead($inifile, "Settings", "DownloadThreads", 3) * 1
$Params = IniRead($inifile, "Settings", "Params", "")
$RunInBackground = IniRead($inifile, "Settings", "RunInBackground", 1) * 1
$AppUpdate = IniRead($inifile, "Settings", "AppUpdate", 1) * 1
$AppUpdateLastCheck = IniRead($inifile, "Settings", "AppUpdateLastCheck", "2016/05/01 00:00:00")
$CheckDefaultBrowser = IniRead($inifile, "Settings", "CheckDefaultBrowser", 1) * 1
$ExApp = IniRead($inifile, "Settings", "ExApp", "")
$ExAppAutoExit = IniRead($inifile, "Settings", "ExAppAutoExit", 1) * 1
$ExApp2 = IniRead($inifile, "Settings", "ExApp2", "")
$Bosskey = IniRead($inifile, "Settings", "Bosskey", "!x")
$BosskeyM = IniRead($inifile, "Settings", "BosskeyM", $AU3_RDCLICK)
$Hide2Tray = IniRead($inifile, "Settings", "Hide2Tray", 1) * 1
$MouseClick2CloseTab = IniRead($inifile, "Settings", "MouseClick2CloseTab", $AU3_LDCLICK)
$Mouse2SwitchTab = IniRead($inifile, "Settings", "Mouse2SwitchTab", $AU3_WHEELDOWN & "|" & $AU3_WHEELUP)
$KeepLastTab = IniRead($inifile, "Settings", "KeepLastTab", 0) * 1


#Region ========= Deal with old MyChrome =========
If $AppVersion <> IniRead($inifile, "Settings", "AppVersion", "") Then
	$FirstRun = 1
	IniWrite($inifile, "Settings", "AppVersion", $AppVersion)
EndIf
#EndRegion ========= Deal with old MyChrome =========

Opt("ExpandEnvStrings", 1)
EnvSet("APP", @ScriptDir)
; Show settings GUI if The first cmdline parameter is "-set"，
; or first run, Chrome.exe or userdata not exists
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

CheckEnv()

;~ write file "First Run" to prevent chrome from generating shortcut on desktop
If Not FileExists($ChromeDir & "\First Run") Then FileWrite($ChromeDir & "\First Run", "")

; quote external cmdline.
For $i = 1 To $cmdline[0]
	If StringInStr($cmdline[$i], " ") Then
		$Params &= ' "' & $cmdline[$i] & '"'
	Else
		$Params &= ' ' & $cmdline[$i]
	EndIf
Next

; $PortableParam = '--no-default-browser-check'
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
$AppPID_Browser = Run('"' & $ChromePath & '" ' & $PortableParam & ' ' & $Params, $ChromeDir)

FileChangeDir(@ScriptDir)
CreateSettingsShortcut(@ScriptDir & "\" & $AppName & ".vbs")

; check if another instance of mychrome is running
If @Compiled Then
	$list = ProcessList(StringRegExpReplace(@AutoItExe, ".*\\", ""))
	For $i = 1 To $list[0][0]
		If $list[$i][1] <> @AutoItPID And GetProcPath($list[$i][1]) = @AutoItExe Then
			Exit ;exit if another instance of mychrome is running
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

WinWait("[REGEXPCLASS:(?i)Chrome; REGEXPTITLE:\S+]", "", 10) ; wait fo Chrome / Chromium window
For $i = 1 To 5
	$hWnd_Browser = GethWndbyPID($AppPID_Browser, "Chrome", "\S+")
	If $hWnd_Browser Then ExitLoop
	Sleep(2000)
Next

Global $AppUserModelId
If FileExists($TaskBarDir) Then ; win 7+
	$AppUserModelId = _WindowAppId($hWnd_Browser)
	CheckPinnedPrograms($ChromePath)
EndIf

Global $FirstUpdateCheck = 1
If Not $RunInBackground Then
	UpdateCheck()
	Exit
EndIf
; ========================= app ended if not run in background ================================


If $CheckDefaultBrowser Then ; register REG for notification
	$hEvent_Reg = _WinAPI_CreateEvent()
	For $i = 0 To UBound($aREG) - 1
		If $aREG[$i][1] Then
			$aREG[$i][2] = _WinAPI_RegOpenKey($aREG[$i][0], $aREG[$i][1], $KEY_NOTIFY)
			If $aREG[$i][2] Then
				_WinAPI_RegNotifyChangeKeyValue($aREG[$i][2], $REG_NOTIFY_CHANGE_LAST_SET, 1, 1, $hEvent_Reg)
			EndIf
		EndIf
	Next
	OnAutoItExitRegister("CloseRegHandle")
EndIf

If $KeepLastTab Or $MouseClick2CloseTab Or $Mouse2SwitchTab Then
	AccessibleIni()
EndIf

If $Bosskey Then
	HotKeySet($Bosskey, "Bosskey")
EndIf
If $BosskeyM Or $KeepLastTab Or $MouseClick2CloseTab Or $Mouse2SwitchTab Then
	HookMouse()
EndIf
If $Bosskey Or $BosskeyM Then
	OnAutoItExitRegister("ResumeWindows")
EndIf

AdlibRegister("UpdateCheck", 10000)
ReduceMemory()

; wait for chrome exit
$AppIsRunning = 1
While 1
	Sleep(500)

	If $hWnd_Browser Then
		$AppIsRunning = WinExists($hWnd_Browser)
	Else ; ProcessExists() is resource consuming than WinExists()
		$AppIsRunning = ProcessExists($AppPID_Browser)
	EndIf

	If Not $AppIsRunning Then
		; check other chrome instance
		$AppPID_Browser = AppIsRunning($ChromePath)
		If Not $AppPID_Browser Then
			ExitLoop
		EndIf
		$AppIsRunning = 1
		$hWnd_Browser = GethWndbyPID($AppPID_Browser, "Chrome", "\S+")
	EndIf

	If $TaskBarLastChange Then
		CheckPinnedPrograms($ChromePath)
	EndIf

	If $hEvent_Reg And Not _WinAPI_WaitForSingleObject($hEvent_Reg, 0) Then
		; MsgBox(0, "", "Reg changed!")
		Sleep(50)
		CheckDefaultBrowser($ChromePath)
		For $i = 0 To UBound($aREG) - 1
			If $aREG[$i][2] Then
				_WinAPI_RegNotifyChangeKeyValue($aREG[$i][2], $REG_NOTIFY_CHANGE_LAST_SET, 1, 1, $hEvent_Reg)
			EndIf
		Next
	EndIf
WEnd

If $ExAppAutoExit And $ExApp <> "" Then
	$cmd = ''
	For $i = 1 To $aExAppPID[0]
		If Not $aExAppPID[$i] Then ContinueLoop
		$cmd &= ' /PID ' & $aExAppPID[$i]
	Next
	If $cmd Then
		$cmd = 'taskkill' & $cmd & ' /T /F'
		Run(@ComSpec & ' /c ' & $cmd, '', @SW_HIDE)
	EndIf
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

If 0 Then
	; put functions here to prevent these functions from being stripped
	get_latest_chrome_ver("Stable")
	get_latest_chrome_ver_sina("Stable")
	download_chrome("", "")
EndIf
Exit

; ==================== auto-exec codes ends ========================

; https://www.autoitscript.com/forum/topic/103362-monitoring-mouse-events/
Func Mouse_Event($hGUI, $MsgID, $wParam, $lParam)
	$x = BitAND($lParam, 0x0000FFFF) ;LoWord
	$y = BitShift($lParam, 16) ;HiWord
	$blocked = BitAND($MsgID, 0x00000001)
	$event = BitAND($MsgID, 0xFFFFFFFE)
	If WinGetProcess($wParam) <> $AppPID_Browser Then
		If $blocked Then
			PassMouseEvent($event)
		EndIf
		Return
	EndIf

	$tPoint = DllStructCreate($tagPOINT)
	$tPoint.X = $x
	$tPoint.Y = $y
	$hWnd = _WinAPI_WindowFromPoint($tPoint)
	$class = _WinAPI_GetClassName($hWnd)
	If $event = $AU3_RCLICK And _IsPressed("10") Then ; Shift + right click
		If $blocked Then
			PassMouseEvent($event)
		EndIf
		Return
	EndIf

	;$time = TimerInit()

	Local $blockEvent = 0
	If $class = "Chrome_RenderWidgetHostHWND" Then
		If $event = $BosskeyM Then
			If $blocked Then
				DllCall($hHookDll, "int", "IgnoreEvents", "int", 1)
				Switch $event
					Case $AU3_RDCLICK, $AU3_RDROP
						MouseUp("left") ; disable context menu

					Case $AU3_MDROP
						MouseUp("middle")
					Case $AU3_MDCLICK
						MouseDown("middle")
				EndSwitch
				Sleep(50)
				DllCall($hHookDll, "int", "IgnoreEvents", "int", 0)
				$blockEvent = 1
			EndIf
			Bosskey()
		EndIf
	ElseIf $class = "Chrome_WidgetWin_1" Then
		If ($KeepLastTab And ($event = $AU3_MCLICK Or $event = $AU3_LCLICK)) Or _
				StringInStr($MouseClick2CloseTab, $event) Or _
				StringInStr($Mouse2SwitchTab, $event) Then
			$blockEvent = TabProcess($hWnd, $event, $x, $y)
		EndIf
	EndIf

	;ConsoleWrite(Round(TimerDiff($time), 1) & " Event: " & $event & " on " & $class & ", block: " & $blocked & " --> " & $blockEvent & @LF)

	If $blocked And Not $blockEvent Then
		PassMouseEvent($event)
	EndIf
EndFunc   ;==>Mouse_Event

Func PassMouseEvent($event)
	DllCall($hHookDll, "int", "IgnoreEvents", "int", 1)

	Switch $event
		Case $AU3_LCLICK, $AU3_LDROP
			MouseUp("left")
		Case $AU3_LDCLICK
			MouseDown("left")

		Case $AU3_RCLICK, $AU3_RDCLICK, $AU3_RDROP
			MouseUp("right")

		Case $AU3_MCLICK, $AU3_MDROP
			MouseUp("middle")
		Case $AU3_MDCLICK
			MouseDown("middle")

		Case $AU3_XCLICK, $AU3_XDROP
			_WinAPI_Mouse_Event($MOUSEEVENTF_XUP)
		Case $AU3_XDCLICK
			_WinAPI_Mouse_Event($MOUSEEVENTF_XDOWN)
	EndSwitch

	Sleep(50)
	DllCall($hHookDll, "int", "IgnoreEvents", "int", 0)
EndFunc   ;==>PassMouseEvent

Func HookMouse()
	Local $hookdll, $iPID = 0
	If @AutoItX64 Then
		$hookdll = $ChromeDir & "\hook64.dll"
		FileInstall("hook64.dll", $hookdll, 1)
	Else
		$hookdll = $ChromeDir & "\hook.dll"
		FileInstall("hook.dll", $hookdll, 1)
	EndIf

	$hHookDll = DllOpen($hookdll)
	If $hHookDll = -1 Then Return

	OnAutoItExitRegister("UnhookMouse")
	$hHookLib = _WinAPI_LoadLibrary($hookdll)
	$mouseHOOKproc = _WinAPI_GetProcAddress($hHookLib, "MouseProc")
	If Not $mouseHOOKproc Then Return
	$iThread = _WinAPI_GetWindowThreadProcessId($hWnd_Browser, $iPID)
	;If Not $iThread Then Return
	$hMouseHook = _WinAPI_SetWindowsHookEx($WH_MOUSE, $mouseHOOKproc, $hHookLib, $iThread)

	Local $events = "|" & $BosskeyM & "|" & $MouseClick2CloseTab
	If $KeepLastTab Then
		$events &= "|" & $AU3_MCLICK
	EndIf
	$events &= "|" & $Mouse2SwitchTab
	;ConsoleWrite('Mouse events registered: ' & $events & @CRLF)

	Local $blockevents = $AU3_RCLICK & "|" & $AU3_RDCLICK & "|" & $AU3_RDROP & "|" & $AU3_MCLICK

	DllCall($hHookDll, "int", "SetValuesMouse", _
			"hwnd", $__hwnd_vars, "hwnd", $hMouseHook)

	DllCall($hHookDll, "int", "MouseEvents", "str", $events)
	DllCall($hHookDll, "int", "BlockEvents", "str", $blockevents)

	;GUIRegisterMsg($AU3_LCLICK, "Mouse_Event")
	;GUIRegisterMsg($AU3_LCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_LDCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_LDCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_LDROP, "Mouse_Event")
	GUIRegisterMsg($AU3_LDROP + 1, "Mouse_Event")

	GUIRegisterMsg($AU3_RCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_RCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_RDCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_RDCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_RDROP, "Mouse_Event")
	GUIRegisterMsg($AU3_RDROP + 1, "Mouse_Event")

	GUIRegisterMsg($AU3_MCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_MCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_MDCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_MDCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_MDROP, "Mouse_Event")
	GUIRegisterMsg($AU3_MDROP + 1, "Mouse_Event")

	GUIRegisterMsg($AU3_XCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_XCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_XDCLICK, "Mouse_Event")
	GUIRegisterMsg($AU3_XDCLICK + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_XDROP, "Mouse_Event")
	GUIRegisterMsg($AU3_XDROP + 1, "Mouse_Event")

	GUIRegisterMsg($AU3_WHEELUP, "Mouse_Event")
	GUIRegisterMsg($AU3_WHEELUP + 1, "Mouse_Event")
	GUIRegisterMsg($AU3_WHEELDOWN, "Mouse_Event")
	GUIRegisterMsg($AU3_WHEELDOWN + 1, "Mouse_Event")
EndFunc   ;==>HookMouse
Func UnhookMouse()
	_WinAPI_UnhookWindowsHookEx($hMouseHook)
	_WinAPI_FreeLibrary($hHookLib)
	DllClose($hHookDll)
EndFunc   ;==>UnhookMouse


Func TabProcess($hWnd, $action = $AU3_RCLICK, $mouseX = 0, $mouseY = 0)
	; Possible $action values: $AU3_LCLICK, $AU3_LDCLICK, $AU3_RCLICK, $AU3_MCLICK, $AU3_WHEELUP, $AU3_WHEELDOWN
	;ConsoleWrite($action & ", Mouse positon: $mouseX " & $mouseX & ", $mouseY " & $mouseY & @CRLF)

	Local $pAcc, $oAcc, $tVarChild
	AccessibleObjectFromPoint($mouseX, $mouseY, $pAcc, $tVarChild)
	If @error Then Return
	$oAcc = ObjCreateInterface($pAcc, $sIID_IAccessible, $dtagIAccessible)
	If Not IsObj($oAcc) Then Return

	Local $iRole, $aTab[2]
	$oAcc.get_accRole(0, $iRole)
	If $iRole = $ROLE_SYSTEM_PAGETAB Then
		Dim $aTab[2] = [$pAcc, $oAcc]
	ElseIf $iRole <> $ROLE_SYSTEM_STATICTEXT And $iRole <> $ROLE_SYSTEM_PUSHBUTTON Then
		Return
	EndIf

	If Not IsObj($aTab[1]) Then
		$aTab = AccessibleParent($oAcc, $ROLE_SYSTEM_PAGETAB, 1)
		If Not IsArray($aTab) Then
			;ConsoleWrite("Mouse is not on a page tab. Ignore and return..." & @CRLF)
			Return
		EndIf
	EndIf

	;ConsoleWrite("Mouse is on a page tab. " & @CRLF)

	If $action = $AU3_WHEELUP Then
		Send("^{PGUP}")
		Return
	ElseIf $action = $AU3_WHEELDOWN Then
		Send("^{PGDN}")
		Return
	EndIf

	Local $iTab = 0
	$aTabList = AccessibleParent($aTab[1], $ROLE_SYSTEM_PAGETABLIST, 1)
	If Not IsArray($aTabList) Or $aTabList[1].get_accChildCount($iTab) Or Not $iTab Then
		Return
	EndIf
	$iTab -= 1
	If $iTab > 1 Then ; more than one tab
		;ConsoleWrite("There are " & $iTab & " tabs within Chrome window. " & @CRLF)
		If $action = $AU3_LDCLICK Or $action = $AU3_RCLICK Then
			DllCall($hHookDll, "int", "IgnoreEvents", "int", 1)
			$pos = MouseGetPos()
			MouseMove($mouseX, $mouseY, 0)
			MouseClick("middle", $mouseX, $mouseY, 1, 0)
			MouseMove($pos[0], $pos[1], 0)
			Sleep(10)
			DllCall($hHookDll, "int", "IgnoreEvents", "int", 0)
			Return 1 ; block evnet

			;$aTabClose = AccessibleChildren($aTab[0], $aTab[1], $ROLE_SYSTEM_PUSHBUTTON, 0, 1)
			;If IsArray($aTabClose) Then
			;	$aTabClose[1].accDoDefaultAction(0)
			;	Return 1 ; block event
			;EndIf
		EndIf
		Return
	EndIf

	;ConsoleWrite("There is ONLY one tab within Chrome window. " & @CRLF)

	If $KeepLastTab Then
		Send("^t")
		Sleep(50)
	EndIf

	If $action = $AU3_LDCLICK Or $action = $AU3_RCLICK Then
		;ConsoleWrite("Close the old tab and return..." & @CRLF)

		DllCall($hHookDll, "int", "IgnoreEvents", "int", 1)
		$pos = MouseGetPos()
		MouseMove($mouseX, $mouseY, 0)
		MouseClick("middle", $mouseX, $mouseY, 1, 0)
		MouseMove($pos[0], $pos[1], 0)
		Sleep(10)
		DllCall($hHookDll, "int", "IgnoreEvents", "int", 0)

		;$aTabClose = AccessibleChildren($aTab[0], $aTab[1], $ROLE_SYSTEM_PUSHBUTTON, 0, 1)
		;If Not IsArray($aTabClose) Then Return
		;$aTabClose[1].accDoDefaultAction(0)
	EndIf

	If $action = $AU3_RCLICK Then
		Return 1 ; block event
	EndIf
EndFunc   ;==>TabProcess


Func Bosskey()
	Local $aList, $pid
	If $ChromeIsHidden Then
		ResumeWindows()
	Else
		$aList = WinList("[REGEXPCLASS:(?i)Chrome; REGEXPTITLE:\S+]")
		;_ArrayDisplay($aList)
		If $aList[0][0] < 1 Then Return
		For $i = 1 To $aList[0][0]
			If BitAND(WinGetState($aList[$i][1]), 2) Then ; ignore hidden windows
				$pid = WinGetProcess($aList[$i][1])
				If $pid = $AppPID_Browser Then
					WinSetState($aList[$i][1], "", @SW_HIDE)
					$ChromeIsHidden = 1
				EndIf
			EndIf
		Next

		If VersionCompare($WinVersion, "6.1") >= 0 Then ; Windows 7 or later
			Audio_SetAppMute($AppPID_Browser, 1)
		EndIf

		If $Hide2Tray Then
			TraySetIcon($ChromePath)
			TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "ResumeWindows")
			TraySetState(1)
			TraySetToolTip(StringFormat(lang("GUI", "UnhideChrome", 'Chrome已隐藏\n点击取消隐藏'), 0))
		EndIf
	EndIf
EndFunc   ;==>Bosskey

Func ResumeWindows()
	If $Hide2Tray Then
		TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "")
		TraySetToolTip()
		TraySetIcon()
		TraySetState(2)
	EndIf

	Local $aList, $pid
	$aList = WinList("[REGEXPCLASS:(?i)Chrome; REGEXPTITLE:\S+]")
	If $aList[0][0] < 1 Then Return
	For $i = 1 To $aList[0][0]
		If Not BitAND(WinGetState($aList[$i][1]), 2) Then ; hidden windows
			$pid = WinGetProcess($aList[$i][1])
			If $pid = $AppPID_Browser Or GetProcPath($pid) = $ChromePath Then
				WinSetState($aList[$i][1], "", @SW_SHOW)
			EndIf
		EndIf
	Next
	$ChromeIsHidden = 0

	If VersionCompare($WinVersion, "6.1") >= 0 Then
		Audio_SetAppMute($AppPID_Browser, 0)
	EndIf
EndFunc   ;==>ResumeWindows


Func LangCheck()
	If $Language = "Auto" And FileExists(@ScriptDir & "\lang\lang.ini") Then
		Return @ScriptDir & "\lang\lang.ini"
	EndIf

	Local $lngfile
	If $Language = "zh-CN" Then
		Return "" ; Chinese simplified (default)
	ElseIf $Language = "zh-TW" Then
		$lngfile = @ScriptDir & "\lang\zh-TW.ini"
	ElseIf $Language = "en-US" Then
		$lngfile = @ScriptDir & "\lang\en-US.ini"
	EndIf

	If Not $lngfile Then
		If @OSLang = "0004" Or @OSLang = "0804" Then
			Return "" ; Chinese simplified (default)
		ElseIf StringRight(@OSLang, 2) = "04" Then
			$lngfile = @ScriptDir & "\lang\zh-TW.ini"
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\lang") Then
		DirCreate(@ScriptDir & "\lang\")
	EndIf

	If Not $lngfile Then
		$lngfile = @ScriptDir & "\lang\en-US.ini"
	EndIf

	If $lngfile = @ScriptDir & "\lang\zh-TW.ini" Then
		If Not FileExists($lngfile) Or IniRead($lngfile, "Lang", "Version", "") <> $AppVersion Then
			FileInstall("zh-TW.ini", $lngfile, 1)
		EndIf
	Else ; $lngfile = @ScriptDir & "\en-US.ini"
		If Not FileExists($lngfile) Or IniRead($lngfile, "Lang", "Version", "") <> $AppVersion Then
			FileInstall("en-US.ini", $lngfile, 1)
		EndIf
	EndIf

	Return $lngfile
EndFunc   ;==>LangCheck

Func lang($Section, $Key, $DefaltStr)
	If Not $LangFile Then
		Return $DefaltStr
	Else
		Return IniRead($LangFile, $Section, $Key, $DefaltStr)
	EndIf
EndFunc   ;==>lang

;#include <WinAPI.au3>
Func GetIEProxy(ByRef $Sever, ByRef $Port)
	$Sever = ""
	$Port = ""
	Local $aIEproxy = _WinHttpGetIEProxyConfigForCurrentUser()
	If Not @error Then
		$sProxy = $aIEproxy[2]
		If Not $sProxy And $aIEproxy[1] Then
			; https://www.autoitscript.com/forum/topic/84133-winhttp-functions/?page=27
			$pacAddress = $aIEproxy[1]
			Local $WINHTTP_AUTOPROXY_OPTIONS = DllStructCreate("dword dwFlags;" & _
					"dword dwAutoDetectFlags;" & _
					"ptr lpszAutoConfigUrl;" & _
					"ptr lpvReserved;" & _
					"dword dwReserved;" & _
					"dword fAutoLogonIfChallenged;")
			Local $WINHTTP_PROXY_INFO = DllStructCreate("dword AccessType;ptr Proxy;ptr ProxyBypass")

			DllStructSetData($WINHTTP_AUTOPROXY_OPTIONS, "dwFlags", $WINHTTP_AUTOPROXY_CONFIG_URL)
			DllStructSetData($WINHTTP_AUTOPROXY_OPTIONS, "dwAutoDetectFlags", _
					BitOR($WINHTTP_AUTO_DETECT_TYPE_DHCP, $WINHTTP_AUTO_DETECT_TYPE_DNS_A))
			Local $tPacAddress = DllStructCreate("wchar[" & StringLen($pacAddress) + 1 & "]")
			DllStructSetData($tPacAddress, 1, $pacAddress)
			DllStructSetData($WINHTTP_AUTOPROXY_OPTIONS, "lpszAutoConfigUrl", DllStructGetPtr($tPacAddress))

			Local $hOpen = _WinHttpOpen()
			$url = "https://www.google.com"
			Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpGetProxyForUrl", _
					"handle", $hOpen, _
					"wstr", $url, _
					"struct*", DllStructGetPtr($WINHTTP_AUTOPROXY_OPTIONS), _
					"struct*", DllStructGetPtr($WINHTTP_PROXY_INFO))

			;ConsoleWrite("_WinAPI_GetLastError: " & _WinAPI_GetLastError() & @CRLF)
			_WinHttpCloseHandle($hOpen)
			Local $pProxy = DllStructGetData($WINHTTP_PROXY_INFO, "Proxy")
			$sProxy = DllStructGetData(DllStructCreate("wchar[" & _WinAPI_StringLenW($pProxy) & "]", $pProxy), 1)
		EndIf

		Local $match
		If StringInStr($sProxy, "https=") Then
			$match = StringRegExp($sProxy, '(?i)https=(\S+?:\d+)', 1)
			If Not @error Then $sProxy = $match[0]
		ElseIf StringInStr($sProxy, "http=") Then
			$match = StringRegExp($sProxy, '(?i)http=(\S+?:\d+)', 1)
			If Not @error Then $sProxy = $match[0]
		EndIf

		$pos = StringInStr($sProxy, ":")
		If $pos Then
			$Sever = StringLeft($sProxy, $pos - 1)
			$Port = StringMid($sProxy, $pos + 1)
		EndIf
	EndIf
EndFunc   ;==>GetIEProxy

Func GethWndbyPID($pid, $class = ".*", $title = ".*")
	$list = WinList("[REGEXPCLASS:(?i)" & $class & "; REGEXPTITLE:(?i)" & $title & "]")
	For $i = 1 To $list[0][0]
		If Not BitAND(WinGetState($list[$i][1]), 2) Then ContinueLoop ; ignore hidden windows
		If $pid = WinGetProcess($list[$i][1]) Then
			;ConsoleWrite("--> " & $list[$i][1] & "-" & $list[$i][0] & @CRLF)
			Return $list[$i][1]
		EndIf
	Next
EndFunc   ;==>GethWndbyPID

Func GetChromeLastChange($path)
	; chrome "LastChange"  changed from digits as 312162 to commit hashes
	; chrome release : 800fe26985bd6fd8626dd80f710fae8ac527bd6b-refs/branch-heads/2171@{#470}
	; chromium : 32cbfaa6478f66b93b6d383a58f606960e02441e-refs/heads/master@{#312162}
	Local $match = StringRegExp(FileGetVersion($path, "LastChange"), '(\d{6,})\D*$', 1)
	If Not @error Then Return $match[0]
	Return ""
EndFunc   ;==>GetChromeLastChange

Func CheckEnv()
	Local $oldstr, $var, $EnvString, $variations_seed, $variations_seed_signature
	$EnvString = FileRead($UserDataDir & "\EnvId")
	If $EnvString = $EnvID Then Return
	FileDelete($UserDataDir & "\EnvId")

	If FileExists($UserDataDir & "\Local State") Then
		$EnvString = FileWrite($UserDataDir & "\EnvId", $EnvID)
		FileInstall(".\Local State.MyChrome", $UserDataDir & "\Local State.MyChrome", 1)
		$var = FileRead($UserDataDir & "\Local State.MyChrome")
		FileDelete($UserDataDir & "\Local State.MyChrome")
		Local $match = StringRegExp($var, '(?i)("variations.*_seed": *"\S+?")', 1)
		If Not @error Then $variations_seed = $match[0]
		$match = StringRegExp($var, '(?i)("variations_seed_signature": *"\S+?")', 1)
		If Not @error Then $variations_seed_signature = $match[0]
		$oldstr = FileRead($UserDataDir & "\Local State")
		$var = StringRegExpReplace($oldstr, '(?i)"variations.*_seed": *"\S+?"', $variations_seed)
		If Not @error Then
			$var = StringRegExpReplace($var, '(?i)"variations_seed_signature": *"\S+?"', $variations_seed_signature)
			If $var <> $oldstr Then
				Local $file = FileOpen($UserDataDir & "\Local State", 2 + 256)
				FileWrite($file, $var)
				FileClose($file)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>CheckEnv

Func CloseRegHandle()
	If $hEvent_Reg Then
		_WinAPI_CloseHandle($hEvent_Reg)
		For $i = 0 To UBound($aREG) - 1
			_WinAPI_RegCloseKey($aREG[$i][2])
		Next
	EndIf
EndFunc   ;==>CloseRegHandle

Func UpdateCheck()
	Local $updated, $var

	; Check mychrome update
	If $AppUpdate <> 0 And _DateDiff("h", $AppUpdateLastCheck, _NowCalc()) >= 24 Then
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

; for win7+
Func CheckPinnedPrograms($browser_path)
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
	Local $file, $ShellObj, $objShortcut, $shortcut_appid
	$ShellObj = ObjCreate("WScript.Shell")
	If Not @error Then
		While 1
			$file = $TaskBarDir & "\" & FileFindNextFile($search)
			If @error Then ExitLoop
			$objShortcut = $ShellObj.CreateShortCut($file)
			$path = $objShortcut.TargetPath
			If $path == $browser_path Or $path == @ScriptFullPath Then
				If $path == $browser_path Then
					$objShortcut.TargetPath = @ScriptFullPath
					$objShortcut.Save
					$TaskBarLastChange = FileGetTime($TaskBarDir, 0, 1)
				EndIf
				$shortcut_appid = _ShortcutAppId($file)

				If Not $AppUserModelId Then
					If Not $hWnd_Browser Then
						Sleep(3000)
						$hWnd_Browser = GethWndbyPID($AppPID_Browser, "Chrome", "\S+")
					EndIf
					$AppUserModelId = _WindowAppId($hWnd_Browser)
					If Not $AppUserModelId Then
						If $shortcut_appid Then
							$AppUserModelId = $shortcut_appid
						Else ; if no window appid found,set an id for the window
							$AppUserModelId = "MyChrome." & StringTrimLeft(_WinAPI_HashString(@ScriptFullPath, 0, 16), 2)
						EndIf
						_WindowAppId($hWnd_Browser, $AppUserModelId)
					EndIf
				EndIf
				If $shortcut_appid <> $AppUserModelId Then
					_ShortcutAppId($file, $AppUserModelId)
					$TaskBarLastChange = FileGetTime($TaskBarDir, 0, 1)
				EndIf
				ExitLoop
			EndIf
		WEnd
		$objShortcut = ""
		$ShellObj = ""
	EndIf
	FileClose($search)
EndFunc   ;==>CheckPinnedPrograms

Func CreateSettingsShortcut($fname)
	Local $var = FileRead($fname)
	If $var <> 'CreateObject("shell.application").ShellExecute ".\' & @ScriptName & '", "-set"' Then
		FileDelete($fname)
		FileWrite($fname, 'CreateObject("shell.application").ShellExecute ".\' & @ScriptName & '", "-set"')
	EndIf
EndFunc   ;==>CreateSettingsShortcut


Func CheckDefaultBrowser($BrowserPath)
	Local $InternetClient, $Key, $i, $j, $var, $RegWriteError = 0

	If Not $ClientKey Then

		If @OSArch = "X86" Then
			Local $aRoot[2] = ["HKCU\SOFTWARE", $HKLM_Software_32]
		Else
			Local $aRoot[3] = ["HKCU\SOFTWARE", $HKLM_Software_32, $HKLM_Software_64]
		EndIf
		For $i = 0 To UBound($aRoot) - 1 ; search chrome in internetclient
			$j = 1
			While 1
				$InternetClient = RegEnumKey($aRoot[$i] & "\Clients\StartMenuInternet", $j)
				If @error <> 0 Then ExitLoop
				$Key = $aRoot[$i] & '\Clients\StartMenuInternet\' & $InternetClient
				$var = RegRead($Key & '\DefaultIcon', '')
				If StringInStr($var, $BrowserPath) Then
					$ClientKey = $Key
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
			RegWrite('HKCR\' & $Progid & '\shell\open\ddeexec', '', 'REG_SZ', '')
			RegDelete('HKCR\' & $Progid & '\shell\open\command', 'DelegateExecute') ; fix Unregistered class error
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
				RegWrite('HKCR\' & $aAsso[$i] & '\shell\open\ddeexec', '', 'REG_SZ', '')
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
	Local $UpdateInfo, $match, $LatestAppVer, $msg, $update, $url, $updated
	Local $flag_url = "url", $flag_update = "update"
	If @AutoItX64 Then
		$flag_url &= "_x64"
	EndIf

	If $LangFile Then
		If StringInStr($LangFile, "zh-TW.ini") Then
			$flag_update &= "_zh-TW"
		Else
			$flag_update &= "_en-US"
		EndIf
	EndIf

	$AppUpdateLastCheck = _NowCalc()
	IniWrite($inifile, "Settings", "AppUpdateLastCheck", $AppUpdateLastCheck)

	If $ProxyType = "SYSTEM" Then
		HttpSetProxy(0)
	ElseIf $ProxyType = "DIRECT" Or Not $ProxySever Then
		HttpSetProxy(1)
	Else
		HttpSetProxy(2, $ProxySever & ":" & $ProxyPort)
	EndIf
	$UpdateInfo = BinaryToString(InetRead("http://code.taobao.org/svn/mychrome/trunk/Update.txt", 27), 4)
	$UpdateInfo = StringStripWS($UpdateInfo, 3)

	$LangUpdateTips = lang("AppUpdate", "UpdateTips", _
			'%s 可以更新，是否立即下载？\n\n您的版本： %s，最新版本： %s\n\n%s')
	$LangUpdated = lang("AppUpdate", "Updated", '%s 已更新至 %s !')
	$LangUpdateFailed = lang("AppUpdate", "UpdateFailed", '%s 自动更新失败！\n\n是否去软件发布页手动下载？')

	$match = StringRegExp($UpdateInfo, '(?ism)^\W*latest=(\N+)$.*^\W*' & _
			$flag_url & '=(\N+)$.*^\W*' & _
			$flag_update & '=(\N*)$', 1)
	If Not @error Then
		$LatestAppVer = $match[0]
		$url = $match[1]
		$update = StringReplace($match[2], "\n", @CRLF)
		If VersionCompare($LatestAppVer, $AppVersion) > 0 Then
			If IsHWnd($hSettings) Then
				$msg = 6
			Else
				$msg = MsgBox(68, 'MyChrome', StringFormat($LangUpdateTips, 'MyChrome', $AppVersion, $LatestAppVer, $update))
			EndIf
			If $msg = 6 Then
				$updated = UpdateApp(@ScriptFullPath, $url)
				If $updated = 1 Then
					MsgBox(64, "MyChrome", StringFormat($LangUpdated, 'MyChrome', $LatestAppVer))
				ElseIf $updated = 0 Then
					$msg = MsgBox(20, "MyChrome", StringFormat($LangUpdateFailed, 'MyChrome'))
					If $msg = 6 Then ; Yes
						OpenWebsite()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	Return $updated
EndFunc   ;==>CheckAppUpdate
Func UpdateApp($exe = @ScriptFullPath, $url = "")
	Local $temp = @ScriptDir & "\MyChrome_temp"
	Local $file = $temp & "\MyChrome.7z"
	Local $iBytesSize, $updated = 0
	If Not FileExists($temp) Then DirCreate($temp)
	Local $hDownload = InetGet($url, $file, 19, 1)

	TraySetState(1)
	TraySetClick(8)
	TraySetToolTip("MyChrome")
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "TrayTipProgress")
	Local $iCancel = TrayCreateItem(lang("AppUpdate", "CancelUpdate", '取消更新') & ' ...')
	TrayItemSetOnEvent(-1, "CancelAppUpdate")
	$LangDownloading = lang("AppUpdate", "Downloading", '下载')
	$LangDownloadTips = lang("AppUpdate", "DownloadTips", '点击图标可查看下载进度')
	TrayTip("MyChrome", StringFormat("%s %s ...\n%s", $LangDownloading, "MyChrome", $LangDownloadTips), 10, 1)
	$CancelAppUpdate = False

	Do
		Sleep(250)
		If $CancelAppUpdate Then
			$updated = -1
			_GUICtrlStatusBar_SetText($hStausbar, "MyChrome " & lang("AppUpdate", "UpdateCanceled", '更新已取消'))
			ExitLoop
		EndIf
		$iBytesSize = InetGetInfo($hDownload, $INET_DOWNLOADREAD) / 1024
		If IsHWnd($hSettings) Then
			_GUICtrlStatusBar_SetText($hStausbar, StringFormat("%s %s ...  %.1fKB", $LangDownloading, "MyChrome", $iBytesSize))
		EndIf
		If $TrayTipProgress Or TrayTipExists(StringFormat("%s %s", $LangDownloading, "MyChrome")) Then
			TrayTip("MyChrome", StringFormat("%s %s ...  %.1fKB", $LangDownloading, "MyChrome", $iBytesSize), 10, 1)
			$TrayTipProgress = 0
		EndIf
	Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
	InetClose($hDownload)
	FileSetAttrib($file, "+A")
	If Not $CancelAppUpdate Then
		FileInstall("7zr.exe", $temp & "\7zr.exe", 1) ; http://www.7-zip.org/download.html
		RunWait($temp & '\7zr.exe x "' & $file & '" -y', $temp, @SW_HIDE)
		If FileExists($temp & "\MyChrome.exe") Then
			If FileExists($exe) Then
				FileMove($exe, $exe & ".bak", 9)
			EndIf
			FileMove($temp & "\MyChrome.exe", $exe, 9)
			FileDelete($temp & "\7zr.exe")
			FileDelete($file)
			DirCopy($temp, @ScriptDir, 1)
			$updated = 1
		EndIf
	EndIf

	TrayItemDelete($iCancel)
	TraySetState(2)
	$CancelAppUpdate = False
	DirRemove($temp, 1)
	Return $updated
EndFunc   ;==>UpdateApp
Func CancelAppUpdate()
	$CancelAppUpdate = True
EndFunc   ;==>CancelAppUpdate

;~ Show setting GUI
Func Settings()
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Local $LangIntvNever = lang("GUI", "IntvNever", '从不')
	Local $LangIntvEveryWeek = lang("GUI", "IntvEveryWeek", '每周')
	Local $LangIntvEveryDay = lang("GUI", "IntvEveryDay", '每天')
	Local $LangIntvEveryHour = lang("GUI", "IntvEveryHour", '每小时')
	Local $LangIntvOnStartup = lang("GUI", "IntvOnStartup", '每次启动时')
	Switch $UpdateInterval
		Case -1
			$UpdateInterval = $LangIntvNever
		Case 168
			$UpdateInterval = $LangIntvEveryWeek
		Case 24
			$UpdateInterval = $LangIntvEveryDay
		Case 1
			$UpdateInterval = $LangIntvEveryHour
		Case Else
			$UpdateInterval = $LangIntvOnStartup
	EndSwitch

	$ChromeFileVersion = FileGetVersion($ChromeDir & "\chrome.dll", "FileVersion")
	$ChromeLastChange = GetChromeLastChange($ChromeDir & "\chrome.dll")

	Opt("ExpandEnvStrings", 0)
	$hSettings = GUICreate(lang("GUI", "Title", 'MyChrome - 打造自己的 Google Chrome 便携版'), 500, 530)
	GUISetOnEvent($GUI_EVENT_CLOSE, "ExitApp")
	Local $LangCopyright = lang("GUI", "Copyright", 'MyChrome %s by 甲壳虫 <jdchenjian@gmail.com>')
	$LangCopyright = StringFormat($LangCopyright, $AppVersion)
	GUICtrlCreateLabel($LangCopyright, 5, 10, 490, -1, $SS_CENTER)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetTip(-1, lang("GUI", "CopyrightTips", '点击打开 MyChrome 主页'))
	GUICtrlSetOnEvent(-1, "OpenWebsite")

	;Tab General
	GUICtrlCreateTab(5, 35, 492, 430)
	GUICtrlCreateTabItem(lang("GUI", "TabGeneral", '常规'))

	GUICtrlCreateGroup(lang("GUI", "GroupChromeApp", 'Google Chrome 程序文件'), 10, 80, 480, 190)
	GUICtrlCreateLabel(lang("GUI", "ChromePath", 'Chrome 路径：'), 20, 110, 120, 20)
	$hChromePath = GUICtrlCreateEdit($ChromePath, 130, 106, 290, 20, $ES_AUTOHSCROLL)

	$hGetChromePath = GUICtrlCreateButton(lang("GUI", "Browse", '浏览'), 430, 106, 50, 20)
	GUICtrlSetOnEvent(-1, "GUI_GetChromePath")

	GUICtrlCreateLabel(lang("GUI", "ChromeSource", 'Chrome 浏览器程序文件来源：'), 20, 144, 250, 20)
	$hChromeSource = GUICtrlCreateCombo("", 280, 140, 200, 20, $CBS_DROPDOWNLIST)

	$LangChromeSourceSys = lang("GUI", "ChromeSourceSys", '从系统中提取')
	$LangChromeSourceInstaller = lang("GUI", "ChromeSourceInstaller", '从离线安装包提取')
	GUICtrlSetData(-1, "Google|sina.com.cn|" & $LangChromeSourceSys & "|" & $LangChromeSourceInstaller, $ChromeSource)
	GUICtrlSetOnEvent(-1, "GUI_EventChromeSource")

	GUICtrlCreateLabel(lang("GUI", "Channel", '分支：'), 20, 174, 80, 20)
	$hChannel = GUICtrlCreateCombo("", 130, 170, 130, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "Stable|Beta|Dev|Canary|Chromium", $Channel)
	GUICtrlSetOnEvent(-1, "GUI_CheckChrome")

	$hx86 = GUICtrlCreateCheckbox(lang("GUI", "Only32Bit", '只下载 32 位浏览器（x86）'), 20, 200, -1, 20)
	GUICtrlSetOnEvent(-1, "GUI_Eventx86")
	If $x86 Then GUICtrlSetState(-1, $GUI_CHECKED)

	GUICtrlCreateLabel(lang("GUI", "CheckBrowserUpdate", '检查浏览器更新：'), 20, 235, 110, 20)
	$hUpdateInterval = GUICtrlCreateCombo("", 130, 230, 130, 20, $CBS_DROPDOWNLIST)
	$var = StringFormat("%s|%s|%s|%s|%s", $LangIntvOnStartup, $LangIntvEveryHour, _
			$LangIntvEveryDay, $LangIntvEveryWeek, $LangIntvNever)
	GUICtrlSetData(-1, $var, $UpdateInterval)

	$hCheckUpdate = GUICtrlCreateButton(lang("GUI", "UpdateNow", '立即更新'), 360, 170, 120, 24)
	GUICtrlSetOnEvent(-1, "GUI_Start_End_ChromeUpdate")

	GUICtrlCreateLabel(lang("GUI", "LatestVersion", '最新版本：'), 280, 204, 100, 20)
	$hLatestChromeVer = GUICtrlCreateLabel("", 380, 204, 110, 40)
	GUICtrlSetTip(-1, lang("GUI", "ClickToViewUrl", '点击查看下载地址'))
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetOnEvent(-1, "GUI_ShowUrl")

	GUICtrlCreateLabel(lang("GUI", "CurrentVersion", '当前版本：'), 280, 235, 100, 20)
	$hCurrentVer = GUICtrlCreateLabel("", 380, 235, 110, 40)
	GUICtrlSetData(-1, $ChromeFileVersion & "  " & $ChromeLastChange)

	GUICtrlCreateGroup(lang("GUI", "ChromeUserData", 'Google Chrome 用户数据文件'), 10, 290, 480, 80)
	GUICtrlCreateLabel(lang("GUI", "UserDataDir", '用户数据文件夹：'), 20, 320, 110, 20)
	$hUserDataDir = GUICtrlCreateEdit($UserDataDir, 130, 315, 290, 20, $ES_AUTOHSCROLL)
	GUICtrlCreateButton(lang("GUI", "Browse", '浏览'), 430, 315, 50, 20)
	GUICtrlSetOnEvent(-1, "GUI_GetUserDataDir")
	$hCopyData = GUICtrlCreateCheckbox(lang("GUI", "CopyDataFromeSys", '从系统中提取用户数据文件'), 20, 340, -1, 20)

	If Not $LangFile Then
		$langstr = "显示语言："
	Else
		$langstr = "Language: "
	EndIf
	GUICtrlCreateLabel($langstr, 20, 390, 110, 20)
	$hLanguage = GUICtrlCreateCombo("", 130, 386, 130, 20, $CBS_DROPDOWNLIST)
	If $Language = "zh-CN" Then
		$sLang = "简体中文"
	ElseIf $Language = "zh-TW" Then
		$sLang = "繁體中文"
	ElseIf $Language = "en-US" Then
		$sLang = "English"
	Else
		$sLang = "Auto"
	EndIf
	GUICtrlSetData(-1, "Auto|简体中文|繁體中文|English", $sLang)
	GUICtrlSetOnEvent(-1, "GUI_LanguageEvent")

	GUICtrlCreateLabel(lang("GUI", "LangSupport", '语言支持：'), 280, 390, 110, 20)
	GUICtrlCreateLabel(IniRead($LangFile, "Lang", "LangSupport", ""), 390, 390, 100, 40)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetOnEvent(-1, "GUI_LangSupport")

	$hAppUpdate = GUICtrlCreateCheckbox(lang("GUI", "NotifyMyChromeUpdate", 'MyChrome 发布新版时通知我'), 20, 415, -1, 20)
	If $AppUpdate Then
		GUICtrlSetState($hAppUpdate, $GUI_CHECKED)
	EndIf
	$hRunInBackground = GUICtrlCreateCheckbox(lang("GUI", "MyChromeRunInBackground", 'MyChrome 在后台运行直至浏览器退出'), 20, 440, -1, 20)
	GUICtrlSetOnEvent(-1, "GUI_RunInBackground")
	If $RunInBackground Then
		GUICtrlSetState($hRunInBackground, $GUI_CHECKED)
	EndIf

	; Advanced
	GUICtrlCreateTabItem(lang("GUI", "TabAdvanced", '高级'))
	GUICtrlCreateGroup(lang("GUI", "ChromeCache", 'Google Chrome 缓存'), 10, 80, 480, 90)
	GUICtrlCreateLabel(lang("GUI", "CacheDir", '缓存位置：'), 20, 110, 100, 20)
	$hCacheDir = GUICtrlCreateEdit($CacheDir, 120, 106, 300, 20, $ES_AUTOHSCROLL)
	Local $LangCacheTips = lang("GUI", "ChromeCacheTips", '浏览器缓存位置\n空白 = 默认路径\n支持%TEMP%等环境变量')
	GUICtrlSetTip(-1, StringFormat($LangCacheTips, 0))
	$hSelectCacheDir = GUICtrlCreateButton(lang("GUI", "Browse", '浏览'), 430, 106, 50, 20)
	GUICtrlSetOnEvent(-1, "GUI_SelectCacheDir")
	GUICtrlCreateLabel(lang("GUI", "CacheSize", '缓存大小：'), 20, 140, 100, 20)
	$hCacheSize = GUICtrlCreateEdit(Round($CacheSize / 1024 / 1024), 120, 136, 80, 20, $ES_AUTOHSCROLL)
	Local $LangCacheSizeTips = lang("GUI", "ChromeCacheSizeTips", '缓存大小\n0 = 默认')
	GUICtrlSetTip(-1, StringFormat($LangCacheSizeTips, 0))
	GUICtrlCreateLabel(" MB", 200, 140, 40, 20)

	; Command line
	GUICtrlCreateLabel(lang("GUI", "CommandLine", 'Google Chrome 启动参数：'), 20, 190)
	Local $lparams = StringReplace($Params, " --", Chr(13) & Chr(10) & "--") ; replace white space with @crlf
	$hParams = GUICtrlCreateEdit($lparams, 20, 210, 460, 60, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	Local $LangCommandLineTips = lang("GUI", "CommandLineTips", 'Chrome 启动参数，每行写一个参数。\n支持%TEMP%等环境变量，\n特别地，%APP%代表 MyChrome 所在目录。')
	GUICtrlSetTip(-1, StringFormat($LangCommandLineTips, 0))

	; Download threads
	GUICtrlCreateGroup(lang("GUI", "NetworkSettings", '网络设置'), 10, 290, 480, 150)
	GUICtrlCreateLabel(lang("GUI", "ThreadsNum", '下载线程数(1-10)：'), 20, 320, 130, 20)
	$hDownloadThreads = GUICtrlCreateInput($DownloadThreads, 150, 316, 60, 20, $ES_NUMBER)
	Local $LangThreadsTips = lang("GUI", "ThreadsTips", '增减线程数可调节下载速度\n仅适用于下载chrome更新')
	GUICtrlSetTip(-1, StringFormat($LangThreadsTips, 0))
	GUICtrlSetOnEvent(-1, "GUI_CheckThreadsNum")
	GUICtrlCreateUpdown($hDownloadThreads)
	GUICtrlSetLimit(-1, 10, 1)

	; proxy
	GUICtrlCreateLabel(lang("GUI", "ProxyType", '代理类型：'), 20, 350, 130, 20)
	$hProxyType = GUICtrlCreateCombo("", 150, 346, 120, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetOnEvent(-1, "GUI_SetProxy")
	Local $LangProxyDirect = lang("GUI", "ProxyDirect", '直接连接')
	Local $LangProxyIE = lang("GUI", "ProxyIE", '跟随系统')
	If $ProxyType = "DIRECT" Then
		$sProxyType = $LangProxyDirect
	ElseIf $ProxyType = "SYSTEM" Then
		$sProxyType = $LangProxyIE
	Else
		$sProxyType = "HTTP"
	EndIf
	GUICtrlSetData(-1, $LangProxyDirect & "|" & $LangProxyIE & "|HTTP", $sProxyType)

	GUICtrlCreateLabel(lang("GUI", "ProxyServer", '代理服务器：'), 20, 380, 130, 20)
	$hProxySever = GUICtrlCreateCombo("", 150, 376, 120, 20)
	GUICtrlSetData(-1, "127.0.0.1")
	_GUICtrlComboBox_SetEditText($hProxySever, $ProxySever)
	GUICtrlCreateLabel(lang("GUI", "ProxyPort", '代理端口：'), 290, 380, 80, 20)
	$hProxyPort = GUICtrlCreateCombo("", 370, 376, 80, 20)
	GUICtrlSetData(-1, "1080|8787")
	_GUICtrlComboBox_SetEditText($hProxyPort, $ProxyPort)
	GUI_SetProxy()

	; More settings
	GUICtrlCreateTabItem(lang("GUI", "TabMore", '更多'))
	GUICtrlCreateLabel(lang("GUI", "StartWithChrome", '浏览器启动时运行：'), 20, 80, -1, 20)
	$hExAppAutoExit = GUICtrlCreateCheckbox(lang("GUI", "QuitOnChromeExit", ' 浏览器退出后自动关闭*'), 240, 75, -1, 20)
	If $ExAppAutoExit = 1 Then
		GUICtrlSetState($hExAppAutoExit, $GUI_CHECKED)
	EndIf
	$hExApp = GUICtrlCreateEdit("", 20, 100, 410, 50, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	If $ExApp <> "" Then
		GUICtrlSetData(-1, StringReplace($ExApp, "||", @CRLF) & @CRLF)
	EndIf
	Local $LangExAppsTips = lang("GUI", "ExAppsTips", '支持批处理、vbs文件等，\n如需启动参数，可添加在程序路径之后。')
	GUICtrlSetTip(-1, StringFormat($LangExAppsTips, 0))
	GUICtrlCreateButton(lang("GUI", "AddApp", '添加'), 440, 100, 40, 20)
	GUICtrlSetTip(-1, lang("GUI", "AddAppTips", '添加外部程序'))
	GUICtrlSetOnEvent(-1, "GUI_AddExApp")

	GUICtrlCreateLabel(lang("GUI", "RunOnChromeExit", '浏览器退出后运行*：'), 20, 170, -1, 20)
	$hExApp2 = GUICtrlCreateEdit("", 20, 190, 410, 50, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	If $ExApp2 <> "" Then
		GUICtrlSetData(-1, StringReplace($ExApp2, "||", @CRLF) & @CRLF)
	EndIf
	Local $LangExApps2Tips = lang("GUI", "ExApps2Tips", '支持批处理、vbs文件等，\n如需启动参数，可添加在程序路径之后。')
	GUICtrlSetTip(-1, StringFormat($LangExApps2Tips, 0))
	GUICtrlCreateButton(lang("GUI", "AddApp", '添加'), 440, 190, 40, 20)
	GUICtrlSetTip(-1, lang("GUI", "AddAppTips", '添加外部程序'))
	GUICtrlSetOnEvent(-1, "GUI_AddExApp2")

	GUICtrlCreateGroup(lang("GUI", "Bosskey", '老板键*'), 10, 260, 480, 90)
	GUICtrlCreateLabel(lang("GUI", "Hotkey", '键盘：'), 20, 290, 110, 20)
	$hBosskey = GUICtrlCreateInput("", 130, 286, 140, 20)

	Local $Key = StringRegExpReplace($Bosskey, '[!+#^]+', '')
	Local $key1
	If $Key Then
		If StringInStr($Bosskey, "+") Then
			$key1 &= " + Shift"
		EndIf
		If StringInStr($Bosskey, "^") Then
			$key1 &= " + Ctrl"
		EndIf
		If StringInStr($Bosskey, "!") Then
			$key1 &= " + Alt"
		EndIf
		If StringInStr($Bosskey, "#") Then
			$key1 &= " + Win"
		EndIf
		If Not $key1 Then
			$key1 = "Ctrl"
		Else
			$key1 = StringTrimLeft($key1, 3)
		EndIf
		$Key = $key1 & " + " & $Key
		GUICtrlSetData($hBosskey, $Key)
	EndIf

	Local $mButton = lang("GUI", "MiddleButton", '中键')
	Local $rButton = lang("GUI", "RightButton", '右键')
	Local $DBClick = lang("GUI", "DoubleClick", '双击')
	Local $DragDrop = lang("GUI", "DragDrop", '拖拽')
	$hBosskeyM = GUICtrlCreateCheckbox(lang("GUI", "MouseClick", '鼠标：'), 20, 316, 110, 20)
	GUICtrlSetOnEvent(-1, "Gui_EventMouseClick")
	$hBosskeyM1 = GUICtrlCreateCombo("", 130, 316, 140, 20, $CBS_DROPDOWNLIST)
	$hBosskeyM2 = GUICtrlCreateCombo("", 290, 316, 140, 20, $CBS_DROPDOWNLIST)

	Local $button, $act
	If $BosskeyM = $AU3_MDCLICK Or $BosskeyM = $AU3_MDROP Then
		$button = $mButton
	Else
		$button = $rButton
	EndIf
	If $BosskeyM = $AU3_RDROP Or $BosskeyM = $AU3_MDROP Then
		$act = $DragDrop
	Else
		$act = $DBClick
	EndIf

	GUICtrlSetData($hBosskeyM1, $mButton & "|" & $rButton, $button)
	GUICtrlSetData($hBosskeyM2, $DBClick & "|" & $DragDrop, $act)
	If $BosskeyM Then
		GUICtrlSetState($hBosskeyM, $GUI_CHECKED)
	Else
		GUICtrlSetState($hBosskeyM1, $GUI_DISABLE)
		GUICtrlSetState($hBosskeyM2, $GUI_DISABLE)
	EndIf

	$dicKeys = CreateKeysDic()
	$hFuncHotkey = DllCallbackRegister('GUI_EventHotkey', 'lresult', 'hwnd;uint;wparam;lparam')
	$hWndProc = _WinAPI_SetWindowLong(GUICtrlGetHandle($hBosskey), $GWL_WNDPROC, DllCallbackGetPtr($hFuncHotkey))

	$hHide2Tray = GUICtrlCreateCheckbox(lang("GUI", "Hide2Tray", ' 隐藏到系统托盘'), 290, 286, -1, 20)
	If $Hide2Tray Then
		GUICtrlSetState($hHide2Tray, $GUI_CHECKED)
	EndIf

	$hDoubleClick2CloseTab = GUICtrlCreateCheckbox(lang("GUI", "DoubleClick2CloseTab", '双击关闭标签页'), 20, 366, -1, 20)
	$hRightClick2CloseTab = GUICtrlCreateCheckbox(lang("GUI", "RightClick2CloseTab", '右键关闭标签页'), 20, 396, -1, 20)
	GUICtrlSetTip(-1, lang("GUI", "RightClick2CloseTabTips", 'Shift + 右键仍可显示菜单'))
	$hMouse2SwitchTab = GUICtrlCreateCheckbox(lang("GUI", "Mouse2SwitchTab", '滚轮切换标签页'), 240, 366, -1, 20)
	$hKeepLastTab = GUICtrlCreateCheckbox(lang("GUI", "KeepLastTab", '保留最后一个标签页'), 240, 396, -1, 20)
	If StringInStr($MouseClick2CloseTab, $AU3_LDCLICK) Then
		GUICtrlSetState($hDoubleClick2CloseTab, $GUI_CHECKED)
	EndIf
	If StringInStr($MouseClick2CloseTab, $AU3_RCLICK) Then
		GUICtrlSetState($hRightClick2CloseTab, $GUI_CHECKED)
	EndIf
	If StringInStr($Mouse2SwitchTab, $AU3_WHEELDOWN) Then
		GUICtrlSetState($hMouse2SwitchTab, $GUI_CHECKED)
	EndIf
	If $KeepLastTab Then
		GUICtrlSetState($hKeepLastTab, $GUI_CHECKED)
	EndIf

	GUICtrlCreateTabItem("")
	$hSettingsOK = GUICtrlCreateButton(lang("GUI", "OK", '确定'), 260, 480, 70, 20)
	GUICtrlSetOnEvent(-1, "GUI_SettingsOK")
	GUICtrlSetState(-1, $GUI_FOCUS)
	GUICtrlCreateButton(lang("GUI", "Cancel", '取消'), 340, 480, 70, 20)
	GUICtrlSetOnEvent(-1, "ExitApp")
	$hSettingsApply = GUICtrlCreateButton(lang("GUI", "Apply", '应用'), 420, 480, 70, 20)
	GUICtrlSetOnEvent(-1, "GUI_SettingsApply")
	$LangSettingsTips = StringFormat(lang("GUI", "SettingsTips", '双击软件目录下的 "%s.vbs" 文件可显示此窗口'), $AppName)
	$hStausbar = _GUICtrlStatusBar_Create($hSettings, -1, $LangSettingsTips)
	Opt("ExpandEnvStrings", 1)
	FileChangeDir(@ScriptDir)

	If Not FileExists(FullPath($UserDataDir) & "\Local State") And FileExists($DefaultUserDataDir & "\Local State") Then
		; check it if userdata dir is empty while userdata found in your system
		GUICtrlSetState($hCopyData, $GUI_CHECKED)
	EndIf

	GUISetState(@SW_SHOW)
	AdlibRegister("GUI_ShowLatestChromeVer", 10)

	While Not $SettingsOK
		Sleep(100)
	WEnd
	GUIDelete($hSettings)
	DllCallbackFree($hFuncHotkey)
	$dicKeys = ""
	$hSettings = "" ; free the handle
EndFunc   ;==>Settings

Func Gui_EventMouseClick()
	If GUICtrlRead($hBosskeyM) = $GUI_CHECKED Then
		GUICtrlSetState($hBosskeyM1, $GUI_ENABLE)
		GUICtrlSetState($hBosskeyM2, $GUI_ENABLE)
	Else
		GUICtrlSetState($hBosskeyM1, $GUI_DISABLE)
		GUICtrlSetState($hBosskeyM2, $GUI_DISABLE)
	EndIf
EndFunc   ;==>Gui_EventMouseClick

Func GUI_EventHotkey($hWnd, $iMsg, $iwParam, $ilParam)
	Switch $iMsg
		Case $WM_CHAR, $WM_SYSCHAR, $WM_KEYDOWN, $WM_SYSKEYDOWN
			If $iwParam <> 16 And $iwParam <> 17 And $iwParam <> 18 And $iwParam <> 91 And $iwParam <> 92 Then
				If $iwParam = 8 Or $iwParam = 46 Then ; 8 - {Backspace}, 46 - {Delete}
					$Key = ""
				Else
					$Key = _WinAPI_GetKeyNameText($ilParam)
					;ConsoleWrite($iwParam & " " & $Key & @CRLF)
					If StringLen($Key) <= 1 Then
						$Key = StringLower($Key)
					Else
						If StringInStr($Key, " ") Then
							If $dicKeys.Exists($Key) Then
								$Key = $dicKeys.Item($Key)
							Else
								$Key = StringReplace($Key, " ", "")
							EndIf
						EndIf
						$Key = "{" & $Key & "}"
					EndIf

					Local $k
					If _IsPressed("10") Then
						$k &= " + Shift"
					EndIf
					If _IsPressed("11") Then
						$k &= " + Ctrl"
					EndIf
					If _IsPressed("12") Then
						$k &= " + Alt"
					EndIf
					If _IsPressed("5B") Or _IsPressed("5C") Then
						$k &= " + Win"
					EndIf

					If Not $k Then
						$k = "Ctrl"
					Else
						$k = StringTrimLeft($k, 3)
					EndIf
					$Key = $k & " + " & $Key
				EndIf

				GUICtrlSetData($hBosskey, $Key)
			EndIf
			Return
	EndSwitch
	Return _WinAPI_CallWindowProc($hWndProc, $hWnd, $iMsg, $iwParam, $ilParam)
EndFunc   ;==>GUI_EventHotkey

Func CreateKeysDic()
	Local $oDic = ObjCreate("Scripting.Dictionary")
	$oDic.Add("Page Up", "PGUP")
	$oDic.Add("Page Down", "PGDN")
	$oDic.Add("Num Lock", "NUMLOCK")
	$oDic.Add("Caps Lock", "CAPSLOCK")
	$oDic.Add("Scroll Lock", "SCROLLLOCK")
	$oDic.Add("Num 0", "NUMPAD0")
	$oDic.Add("Num 1", "NUMPAD1")
	$oDic.Add("Num 2", "NUMPAD2")
	$oDic.Add("Num 3", "NUMPAD3")
	$oDic.Add("Num 4", "NUMPAD4")
	$oDic.Add("Num 5", "NUMPAD5")
	$oDic.Add("Num 6", "NUMPAD6")
	$oDic.Add("Num 7", "NUMPAD7")
	$oDic.Add("Num 8", "NUMPAD8")
	$oDic.Add("Num 9", "NUMPAD9")
	$oDic.Add("Num *", "NUMPADMULT")
	$oDic.Add("Num +", "NUMPADADD")
	$oDic.Add("Num -", "NUMPADSUB")
	$oDic.Add("Num /", "NUMPADDIV")
	Return $oDic
EndFunc   ;==>CreateKeysDic

Func GUI_LangSupport()
	Local $link = IniRead($LangFile, "Lang", "LangLink", "")
	If $link Then
		If StringLeft($link, 4) = "http" Then
			ShellExecute($link)
		Else
			MsgBox(64, "MyChrome", $link)
		EndIf
	EndIf
EndFunc   ;==>GUI_LangSupport

Func GUI_LanguageEvent()
	GUI_SaveLang()

	If $Language = "zh-CN" Then
		$langstr = "语言设置将在重启 MyChrome 后生效！"
	ElseIf $Language = "zh-TW" Then
		$langstr = "語言設置將在重啟 MyChrome 後生效！"
	Else
		$langstr = "MyChrome will restart to apply new language!"
	EndIf
	MsgBox(64, "MyChrome", $langstr)
	If $IsUpdating Then Return

	GUIDelete($hSettings)
	If @Compiled Then
		ShellExecute(@ScriptName, "-Set", @ScriptDir)
	Else
		ShellExecute(@AutoItExe, '"' & @ScriptFullPath & '" -Set', @ScriptDir)
	EndIf
	Exit
EndFunc   ;==>GUI_LanguageEvent

Func GUI_SaveLang()
	$sLang = GUICtrlRead($hLanguage)
	If $sLang = "简体中文" Then
		$Language = "zh-CN"
	ElseIf $sLang = "繁體中文" Then
		$Language = "zh-TW"
	ElseIf $sLang = "English" Then
		$Language = "en-US"
	Else
		$Language = "Auto"
	EndIf
	IniWrite($inifile, "Settings", "Language", $Language)
EndFunc   ;==>GUI_SaveLang

Func GUI_SetProxy()
	Local $LangProxyDirect = lang("GUI", "ProxyDirect", '直接连接')
	Local $LangProxyIE = lang("GUI", "ProxyIE", '跟随系统')
	Local $ptype = GUICtrlRead($hProxyType)
	If $ptype = $LangProxyDirect Then
		$ProxyType = "DIRECT"
	ElseIf $ptype = $LangProxyIE Then
		$ProxyType = "SYSTEM"
	Else
		$ProxyType = "HTTP"
	EndIf

	If $ProxyType = "HTTP" Then
		GUICtrlSetState($hProxySever, $GUI_ENABLE)
		GUICtrlSetState($hProxyPort, $GUI_ENABLE)
		$ProxySever = GUICtrlRead($hProxySever)
		$ProxyPort = GUICtrlRead($hProxyPort)
	Else ;If $ProxyType = "DIRECT" Or $ProxyType = "SYSTEM" Then
		GUICtrlSetState($hProxySever, $GUI_DISABLE)
		GUICtrlSetState($hProxyPort, $GUI_DISABLE)
		If $ProxyType = "SYSTEM" Then
			GetIEProxy($ProxySever, $ProxyPort)
			_GUICtrlComboBox_SetEditText($hProxySever, $ProxySever)
			_GUICtrlComboBox_SetEditText($hProxyPort, $ProxyPort)
		EndIf
	EndIf
EndFunc   ;==>GUI_SetProxy

Func GUI_Eventx86()
	If GUICtrlRead($hx86) = $GUI_CHECKED Then
		$x86 = 1
	Else
		$x86 = 0
	EndIf
	AdlibRegister("GUI_ShowLatestChromeVer", 10)
EndFunc   ;==>GUI_Eventx86

Func GUI_AddExApp()
	Local $path
	$path = FileOpenDialog(lang("GUI", "ChooseExApp", '选择外部程序'), @ScriptDir, _
			"All files (*.*)", 1 + 2, "", $hSettings)
	If $path = "" Then Return
	$path = RelativePath($path)
	$ExApp = GUICtrlRead($hExApp) & '"' & $path & '"' & @CRLF
	GUICtrlSetData($hExApp, $ExApp)
EndFunc   ;==>GUI_AddExApp
Func GUI_AddExApp2()
	Local $path
	$path = FileOpenDialog(lang("GUI", "ChooseExApp", '选择外部程序'), @ScriptDir, _
			"All files (*.*)", 1 + 2, "", $hSettings)
	If $path = "" Then Return
	$path = RelativePath($path)
	$ExApp2 = GUICtrlRead($hExApp2) & '"' & $path & '"' & @CRLF
	GUICtrlSetData($hExApp2, $ExApp2)
EndFunc   ;==>GUI_AddExApp2

Func GUI_RunInBackground()
	If GUICtrlRead($hRunInBackground) = $GUI_CHECKED Then
		Return
	EndIf
	$LangRunBackgroundTips = lang("GUI", "RunBackgroundTips", _
			'如果您不勾选该选项，请注意以下几点：\n\n1. 将浏览器锁定到任务栏或设为默认浏览器后，需再运行一次 MyChrome 才能生效；\n2. MyChrome 设置界面中带“*”符号的功能将无法实现。\n\n确定要取消此选项吗？')
	$msg = MsgBox(36 + 256, "MyChrome", StringFormat($LangRunBackgroundTips, 0), 0, $hSettings)
	If $msg <> 6 Then
		GUICtrlSetState($hRunInBackground, $GUI_CHECKED)
	EndIf
EndFunc   ;==>GUI_RunInBackground

Func GUI_GetChromePath()
	$sChromePath = FileOpenDialog(lang("GUI", "ChooseChromeExe", '选择 Chrome 浏览器主程序（chrome.exe）'), @ScriptDir, _
			"Executable files (*.exe)|All files (*.*)", 2, "chrome.exe", $hSettings)
	If $sChromePath = "" Then Return
	Local $chromedll = StringRegExpReplace($sChromePath, "[^\\]+$", "chrome.dll")
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = GetChromeLastChange($chromedll)
	GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	$ChromePath = RelativePath($sChromePath)
	GUICtrlSetData($hChromePath, $ChromePath)
EndFunc   ;==>GUI_GetChromePath

Func GUI_GetUserDataDir()
	Local $sUserDataDir = FileSelectFolder(lang("GUI", "ChooseDataDir", '选择一个文件夹用来保存用户数据文件'), "", 1 + 4, _
			@ScriptDir & "\User Data", $hSettings)
	If $sUserDataDir <> "" Then
		$UserDataDir = RelativePath($sUserDataDir)
		GUICtrlSetData($hUserDataDir, $UserDataDir)
	EndIf
EndFunc   ;==>GUI_GetUserDataDir


; copy chrome from system dir
Func GUI_CopyChromeFromSystem()
	$ChromePath = GUICtrlRead($hChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	$LangCloseChromeTips = lang("GUI", "CloseChromeTips", '请关闭 Google Chrome 浏览器以便完成更新。\n是否强制关闭？')
	$ChromeIsRunning = ChromeIsRunning($ChromePath, StringFormat($LangCloseChromeTips, 0))
	If $ChromeIsRunning Then Return
	$LangCopyChromeFromSys = lang("GUI", "CopyChromeFromSys", '正在复制 Chrome 程序文件...')
	_GUICtrlStatusBar_SetText($hStausbar, $LangCopyChromeFromSys)
	SplashTextOn("MyChrome", $LangCopyChromeFromSys, 300, 100)
	FileCopy($DefaultChromeDir & "\*.*", $ChromeDir & "\", 1 + 8)
	DirCopy($DefaultChromeDir & "\" & $DefaultChromeVer, $ChromeDir, 1)
	SplashOff()
	If StringRegExpReplace($ChromePath, ".*\\", "") <> "chrome.exe" Then
		FileMove($ChromeDir & "\chrome.exe", $ChromePath, 1)
	EndIf
	Local $chromedll = StringRegExpReplace($ChromePath, "[^\\]+$", "chrome.dll")
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = GetChromeLastChange($chromedll)
	GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	_GUICtrlStatusBar_SetText($hStausbar, lang("GUI", "CopyChromeSuccessful", '提取 Google Chrome 程序文件成功！'))
EndFunc   ;==>GUI_CopyChromeFromSystem

;~ press "OK" in settings
Func GUI_SettingsOK()
	GUI_SettingsApply()
	If @error Or $IsUpdating Then Return
	If ProcessExists($iThreadPid) Then
		ProcessClose($iThreadPid)
	EndIf
	$SettingsOK = 1
EndFunc   ;==>GUI_SettingsOK

;~ press "Apply" in settings
Func GUI_SettingsApply()
	Local $msg, $var
	FileChangeDir(@ScriptDir)
	Opt("ExpandEnvStrings", 0)
	$ChromePath = RelativePath(GUICtrlRead($hChromePath))

	Local $LangIntvNever = lang("GUI", "IntvNever", "从不")
	Local $LangIntvEveryWeek = lang("GUI", "IntvEveryWeek", '每周')
	Local $LangIntvEveryDay = lang("GUI", "IntvEveryDay", '每天')
	Local $LangIntvEveryHour = lang("GUI", "IntvEveryHour", '每小时')
	Local $LangIntvOnStartup = lang("GUI", "IntvOnStartup", '每次启动时')

	Switch GUICtrlRead($hUpdateInterval)
		Case $LangIntvNever
			$UpdateInterval = -1
		Case $LangIntvEveryWeek
			$UpdateInterval = 168
		Case $LangIntvEveryDay
			$UpdateInterval = 24
		Case $LangIntvEveryHour
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
	$ChromeSource = GUICtrlRead($hChromeSource)
	$UserDataDir = RelativePath(GUICtrlRead($hUserDataDir))
	Local $CopyData = GUICtrlRead($hCopyData)

	If GUICtrlRead($hAppUpdate) = $GUI_CHECKED Then
		$AppUpdate = 1
	Else
		$AppUpdate = 0
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
	$Params = StringReplace($var, Chr(13) & Chr(10), " ") ; replace @crlf with white space

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

	GUI_SetProxy()
	GUI_SaveLang()
	$DownloadThreads = GUICtrlRead($hDownloadThreads)
	IniWrite($inifile, "Settings", "UserDataDir", $UserDataDir)
	IniWrite($inifile, "Settings", "Params", $Params)
	IniWrite($inifile, "Settings", "UpdateInterval", $UpdateInterval)
	IniWrite($inifile, "Settings", "Channel", $Channel)
	IniWrite($inifile, "Settings", "x86", $x86)
	IniWrite($inifile, "Settings", "ChromeSource", $ChromeSource)
	IniWrite($inifile, "Settings", "CacheDir", $CacheDir)
	IniWrite($inifile, "Settings", "CacheSize", $CacheSize)
	IniWrite($inifile, "Settings", "RunInBackground", $RunInBackground)
	IniWrite($inifile, "Settings", "AppUpdate", $AppUpdate)
	IniWrite($inifile, "Settings", "ProxyType", $ProxyType)
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

	; boss key
	$Bosskey = ""
	$Key = GUICtrlRead($hBosskey)
	If $Key Then
		$Bosskey = StringStripWS($Key, 8) ;strip all spaces
		$Bosskey = StringReplace($Bosskey, "+", "")
		$Bosskey = StringReplace($Bosskey, "Shift", "+")
		$Bosskey = StringReplace($Bosskey, "Ctrl", "^")
		$Bosskey = StringReplace($Bosskey, "Alt", "!")
		$Bosskey = StringReplace($Bosskey, "Win", "#")
	EndIf
	If GUICtrlRead($hHide2Tray) = $GUI_CHECKED Then
		$Hide2Tray = 1
	Else
		$Hide2Tray = 0
	EndIf

	Local $mButton = lang("GUI", "MiddleButton", '中键')
	Local $DBClick = lang("GUI", "DoubleClick", '双击')
	If GUICtrlRead($hBosskeyM) <> $GUI_CHECKED Then
		$BosskeyM = ""
	Else
		If GUICtrlRead($hBosskeyM1) = $mButton Then
			If GUICtrlRead($hBosskeyM2) = $DBClick Then
				$BosskeyM = $AU3_MDCLICK
			Else
				$BosskeyM = $AU3_MDROP
			EndIf
		Else
			If GUICtrlRead($hBosskeyM2) = $DBClick Then
				$BosskeyM = $AU3_RDCLICK
			Else
				$BosskeyM = $AU3_RDROP
			EndIf
		EndIf
	EndIf

	$MouseClick2CloseTab = ""
	If GUICtrlRead($hDoubleClick2CloseTab) = $GUI_CHECKED Then
		$MouseClick2CloseTab &= "|" & $AU3_LDCLICK
	EndIf
	If GUICtrlRead($hRightClick2CloseTab) = $GUI_CHECKED Then
		$MouseClick2CloseTab &= "|" & $AU3_RCLICK
	EndIf
	$MouseClick2CloseTab = StringTrimLeft($MouseClick2CloseTab, 1)

	If GUICtrlRead($hMouse2SwitchTab) = $GUI_CHECKED Then
		$Mouse2SwitchTab = $AU3_WHEELDOWN & "|" & $AU3_WHEELUP
	Else
		$Mouse2SwitchTab = ""
	EndIf
	If GUICtrlRead($hKeepLastTab) = $GUI_CHECKED Then
		$KeepLastTab = 1
	Else
		$KeepLastTab = 0
	EndIf

	IniWrite($inifile, "Settings", "Bosskey", $Bosskey)
	IniWrite($inifile, "Settings", "BosskeyM", $BosskeyM)
	IniWrite($inifile, "Settings", "Hide2Tray", $Hide2Tray)
	IniWrite($inifile, "Settings", "MouseClick2CloseTab", $MouseClick2CloseTab)
	IniWrite($inifile, "Settings", "Mouse2SwitchTab", $Mouse2SwitchTab)
	IniWrite($inifile, "Settings", "KeepLastTab", $KeepLastTab)

	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Opt("ExpandEnvStrings", 1)
	If Not FileExists($ChromePath) Then
		$LangChromeNotExistsTips = lang("GUI", "ChromeNotExistsTips", _
				'找不到 Chrome 程序文件，请重新设置或者从网络下载：\n%s\n\n需要从网络下载 Google Chrome 的最新版本吗？')
		Local $msg = MsgBox(36, "MyChrome", StringFormat($LangChromeNotExistsTips, $ChromePath), 0, $hSettings)
		If $msg <> 6 Then
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
				$LangCopyDataTips = lang("GUI", "CopyDataTips", _
						'浏览器正在运行，无法提取用户数据文件！\n请关闭 Chrome 浏览器后继续。')
				$msg = MsgBox(17, "MyChrome", StringFormat($LangCopyDataTips, 0))
				If $msg <> 1 Then ExitLoop
			Else
				$LangCopyingUserData = lang("GUI", "CopyingUserData", '正在复制 Chrome 用户数据文件...')
				_GUICtrlStatusBar_SetText($hStausbar, $LangCopyingUserData)
				SplashTextOn("MyChrome", $LangCopyingUserData, 300, 100)
				DirCopy($DefaultUserDataDir, $UserDataDir, 1) ; copy user data
				SplashOff()
				$LangSettingsTips = StringFormat(lang("GUI", "SettingsTips", '双击软件目录下的 "%s.vbs" 文件可显示此窗口'), $AppName)
				_GUICtrlStatusBar_SetText($hStausbar, $LangSettingsTips)
				ExitLoop
			EndIf
		WEnd
		GUICtrlSetState($hCopyData, $GUI_UNCHECKED)
	EndIf

	If Not FileExists($ChromePath) Then
		MsgBox(64, "MyChrome", lang("GUI", "WillDownloadChrome", '即将从网络下载 Google Chrome 的最新版本！'), 0, $hSettings)
		GUI_Start_End_ChromeUpdate()
	EndIf
EndFunc   ;==>GUI_SettingsApply

Func GUI_CheckChrome()
	Global $Channel = GUICtrlRead($hChannel)
	GUI_CheckChromeInSystem($Channel)
	AdlibRegister("GUI_ShowLatestChromeVer", 10)
EndFunc   ;==>GUI_CheckChrome

Func GUI_CheckChromeInSystem($Channel)
	Local $dir, $Subkey, $value = "version"
	If StringInStr($Channel, "Chromium") Then
		$DefaultUserDataDir = @LocalAppDataDir & "\Chromium\User Data"
		$dir = "Chromium\Application"
	ElseIf StringInStr($Channel, "Canary") Then
		$DefaultUserDataDir = @LocalAppDataDir & "\Google\Chrome SxS\User Data"
		$dir = "Google\Chrome SxS\Application"
	Else ; chrome stable / beta / dev
		$DefaultUserDataDir = @LocalAppDataDir & "\Google\Chrome\User Data"
		$dir = "Google\Chrome\Application"
	EndIf

	If FileExists($DefaultUserDataDir & "\Local State") Then
		GUICtrlSetState($hCopyData, $GUI_ENABLE)
	Else
		GUICtrlSetState($hCopyData, $GUI_UNCHECKED)
		GUICtrlSetState($hCopyData, $GUI_DISABLE)
	EndIf

	; @ProgramFilesDir if intalled as admin
	Local $ProgramFilesDir, $ProgramFilesDir32
	If @OSArch = "X86" Then
		$ProgramFilesDir32 = @ProgramFilesDir
	Else
		$ProgramFilesDir = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir")
		$ProgramFilesDir32 = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir (x86)")
	EndIf

	If $ProgramFilesDir Then
		$DefaultChromeDir = $ProgramFilesDir & "\" & $dir
		If FileExists($DefaultChromeDir & "\chrome.exe") Then
			$DefaultChromeVer = FindChromeVer($DefaultChromeDir)
			If $DefaultChromeVer Then Return 1
		EndIf
	EndIf
	If $ProgramFilesDir32 Then
		$DefaultChromeDir = $ProgramFilesDir32 & "\" & $dir
		If FileExists($DefaultChromeDir & "\chrome.exe") Then
			$DefaultChromeVer = FindChromeVer($DefaultChromeDir)
			If $DefaultChromeVer Then Return 1
		EndIf
	EndIf

	; @LocalAppDataDir
	$DefaultChromeDir = @LocalAppDataDir & "\" & $dir
	If FileExists($DefaultChromeDir & "\chrome.exe") Then
		$DefaultChromeVer = FindChromeVer($DefaultChromeDir)
		If $DefaultChromeVer Then
			Return 1
		Else
			$DefaultChromeDir = ""
		EndIf
	EndIf
EndFunc   ;==>GUI_CheckChromeInSystem

Func FindChromeVer($dir)
	Local $hSearch = FileFindFirstFile($dir & "\*.*")
	If $hSearch = -1 Then Return

	Local $dirName, $version = 0
	While 1
		$dirName = FileFindNextFile($hSearch)
		If @error Then ExitLoop

		If StringInStr(FileGetAttrib($dir & "\" & $dirName), "D") And FileExists($dir & "\" & $dirName & "\chrome.dll") Then
			If VersionCompare($dirName, $version) Then
				$version = $dirName
			EndIf
		EndIf
	WEnd

	FileClose($hSearch)
	Return $version
EndFunc   ;==>FindChromeVer

Func GUI_ShowLatestChromeVer()
	AdlibUnRegister("GUI_ShowLatestChromeVer")
	If $IsUpdating Then Return
	If ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf

	Local $aDlInfo[6]
	Local $ResponseTimer

	GUI_SetProxy()
	$LatestChromeVer = ""
	$LatestChromeUrls = ""
	$error = ""
	GUICtrlSetData($hLatestChromeVer, "")

	_SetVar("DLInfo", "|||||")
	_SetVar("ResponseTimer", _NowCalc())
	If $ProxyType = "DIRECT" Or Not $ProxySever Then
		$iThreadPid = _StartThread(@ScriptFullPath, $get_latest_chrome_ver, $Channel, $x86, $inifile)
	Else
		$iThreadPid = _StartThread(@ScriptFullPath, $get_latest_chrome_ver, $Channel, $x86, $inifile, _
				'HTTP:' & $ProxySever & ':' & $ProxyPort)
	EndIf

	While 1
		$ResponseTimer = _GetVar("ResponseTimer")
		$aDlInfo = StringSplit(_GetVar("DLInfo"), "|", 2)
		If UBound($aDlInfo) >= 6 Then
			_GUICtrlStatusBar_SetText($hStausbar, $aDlInfo[5])
			If $aDlInfo[2] Then ExitLoop
		EndIf

		If Not ProcessExists($iThreadPid) Or _DateDiff("s", $ResponseTimer, _NowCalc()) > 30 Then
			$error = lang("GUI", "NoResponse", '进程意外中止或无响应')
			ExitLoop
		EndIf
		Sleep(100)
	WEnd
	_KillThread($iThreadPid)
	If $aDlInfo[3] Then
		$LatestChromeVer = $aDlInfo[0]
		$LatestChromeUrls = $aDlInfo[1]
	Else
		If $aDlInfo[4] Then
			$error = $aDlInfo[5]
		EndIf
		_GUICtrlStatusBar_SetText($hStausbar, lang("GUI", "GetUpdateInfoFailed", '获取 Chrome 更新信息失败') & ' ' & $error)
	EndIf
	GUICtrlSetData($hLatestChromeVer, $LatestChromeVer)
EndFunc   ;==>GUI_ShowLatestChromeVer

; 打开网站
Func OpenWebsite()
	ShellExecute("http://bbs.kafan.cn/thread-1725205-1-1.html")
EndFunc   ;==>OpenWebsite

;~ 显示下载地址
Func GUI_ShowUrl()
	If $LatestChromeUrls <> "" Then
		Local $hGUI = GUICreate("MyChrome", 500, 260)
		GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_ShowUrlExit")
		GUICtrlCreateLabel(lang("GUI", "UpdateUrlTips", '选择链接可下载或复制到剪贴板'), 10, 10)
		$hUrlList = GUICtrlCreateList("", 10, 40, 480, 170, BitOR($WS_BORDER, $WS_VSCROLL))
		GUICtrlSetData(-1, StringReplace($LatestChromeUrls, " ", "|"))
		GUICtrlCreateButton(lang("GUI", "UrlCopy", '复制'), 300, 220, 80, 20)
		GUICtrlSetOnEvent(-1, "GUI_CopyUrl")
		GUICtrlCreateButton(lang("GUI", "UrlDownload", '下载'), 400, 220, 80, 20)
		GUICtrlSetOnEvent(-1, "GUI_DownloadUrl")
		If $IsUpdating Then
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf
		GUISetState(@SW_SHOW, $hGUI)
	EndIf
EndFunc   ;==>GUI_ShowUrl
Func GUI_ShowUrlExit()
	GUIDelete(@GUI_WinHandle)
EndFunc   ;==>GUI_ShowUrlExit
Func GUI_CopyUrl()
	Local $url = GUICtrlRead($hUrlList)
	If $url = "" Then Return
	ClipPut($url)
	MsgBox(64, "MyChrome", lang("GUI", "UrlCopySuccessful", '下载地址已复制到剪贴板!'), 0, @GUI_WinHandle)
EndFunc   ;==>GUI_CopyUrl
Func GUI_DownloadUrl()
	$SelectedUrl = GUICtrlRead($hUrlList)
	If $SelectedUrl = "" Then Return
	GUIDelete(@GUI_WinHandle)
	GUI_Start_End_ChromeUpdate()
EndFunc   ;==>GUI_DownloadUrl

Func GUI_EventChromeSource()
	$LangChromeSourceSys = lang("GUI", "ChromeSourceSys", '从系统中提取')
	$LangChromeSourceInstaller = lang("GUI", "ChromeSourceInstaller", '从离线安装包提取')

	Local $source = GUICtrlRead($hChromeSource)
	If $source = $LangChromeSourceSys Then
		If GUI_CheckChromeInSystem($Channel) Then
			GUI_CopyChromeFromSystem()
		Else
			$LangNoChromeFound = lang("GUI", "NoChromeFound", '在您的系统中未找到 Chrome（%s）程序文件!')
			MsgBox(64, "MyChrome", StringFormat($LangNoChromeFound, $Channel), 0, $hSettings)
		EndIf
		_GUICtrlComboBox_SelectString($hChromeSource, $ChromeSource)
	ElseIf $source = $LangChromeSourceInstaller Then
		Local $installer = FileOpenDialog(lang("GUI", "ChooseChromeInstaller", '选择离线安装文件（chrome_installer.exe）'), _
				@ScriptDir, "Executable files (*.exe)", 1 + 2, "chrome_installer.exe", $hSettings)
		If $installer <> "" Then
			$ChromePath = GUICtrlRead($hChromePath)
			$ChromePath = FullPath($ChromePath)
			InstallChrome($installer)
			EndUpdate()
		EndIf
		_GUICtrlComboBox_SelectString($hChromeSource, $ChromeSource)
	Else
		$ChromeSource = $source
		If $ChromeSource = "sina.com.cn" Then
			$get_latest_chrome_ver = "get_latest_chrome_ver_sina"
		Else
			$get_latest_chrome_ver = "get_latest_chrome_ver"
		EndIf
		AdlibRegister("GUI_ShowLatestChromeVer", 10)
	EndIf
EndFunc   ;==>GUI_EventChromeSource

;~ thread 1~10
Func GUI_CheckThreadsNum()
	Local $Threads = GUICtrlRead($hDownloadThreads)
	If $Threads > 10 Then
		GUICtrlSetData($hDownloadThreads, 10)
	ElseIf $Threads < 1 Then
		GUICtrlSetData($hDownloadThreads, 1)
	EndIf
EndFunc   ;==>GUI_CheckThreadsNum

;~ start / stop update
Func GUI_Start_End_ChromeUpdate()
	If Not $IsUpdating Then
		$IsUpdating = 1
		_KillThread($iThreadPid)
		AdlibRegister("GUI_CheckChromeUpdate", 10)
	ElseIf MsgBox(292, "MyChrome", lang("GUI", "ConfirmUpdate", '确定要取消浏览器更新吗？'), 0, $hSettings) = 6 Then
		$IsUpdating = 0
	EndIf
EndFunc   ;==>GUI_Start_End_ChromeUpdate

Func GUI_SelectCacheDir()
	Local $sCacheDir = FileSelectFolder(lang("GUI", "ChooseCacheDir", '选择浏览器缓存文件夹'), "", 1 + 4, _
			FullPath($UserDataDir) & "\Default", $hSettings)
	If $sCacheDir <> "" Then
		$CacheDir = RelativePath($sCacheDir)
		GUICtrlSetData($hCacheDir, $CacheDir)
	EndIf
EndFunc   ;==>GUI_SelectCacheDir

; update google chrome
Func GUI_CheckChromeUpdate()
	AdlibUnRegister("GUI_CheckChromeUpdate")
	$ChromePath = GUICtrlRead($hChromePath)
	$Channel = GUICtrlRead($hChannel)
	$DownloadThreads = GUICtrlRead($hDownloadThreads)
	GUI_SetProxy()
	GUICtrlSetData($hCheckUpdate, lang("GUI", "CancelUpdate", '取消更新'))
	GUICtrlSetState($hSettingsOK, $GUI_DISABLE)
	GUICtrlSetState($hSettingsApply, $GUI_DISABLE)

	If $SelectedUrl Then
		Local $strUrl = $SelectedUrl
		$SelectedUrl = ""
		UpdateChrome($ChromePath, $Channel, $strUrl)
	Else
		UpdateChrome($ChromePath, $Channel)
	EndIf
EndFunc   ;==>GUI_CheckChromeUpdate

Func UpdateChrome($ChromePath, $Channel, $strUrl = "")
	$ChromePath = FullPath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	If ChromeIsUpdating($ChromeDir) Then
		If IsHWnd($hSettings) Then
			MsgBox(64, "MyChrome", lang("Update", "UpdateInProgress", 'Chrome 浏览器上次更新仍在进行中！'), 0, $hSettings)
		EndIf
		EndUpdate()
		Return
	EndIf

	If $ProxyType = "SYSTEM" Then
		GetIEProxy($ProxySever, $ProxyPort)
	EndIf

	$IsUpdating = 1
	Local $msg, $error, $ResponseTimer, $aDlInfo[6]
	If Not $LatestChromeVer Then
		Do
			$LatestChromeVer = ""
			$LatestChromeUrls = ""
			$error = ""
			_SetVar("DLInfo", "|||||")
			$ResponseTimer = _NowCalc()
			_SetVar("ResponseTimer", $ResponseTimer)
			If $ProxyType = "DIRECT" Or Not $ProxySever Then
				$iThreadPid = _StartThread(@ScriptFullPath, $get_latest_chrome_ver, $Channel, $x86, $inifile)
			Else
				$iThreadPid = _StartThread(@ScriptFullPath, $get_latest_chrome_ver, $Channel, $x86, $inifile, _
						'HTTP:' & $ProxySever & ':' & $ProxyPort)
			EndIf

			While 1
				$ResponseTimer = _GetVar("ResponseTimer")
				$aDlInfo = StringSplit(_GetVar("DLInfo"), "|", 2)
				If UBound($aDlInfo) >= 6 Then
					If IsHWnd($hSettings) Then
						_GUICtrlStatusBar_SetText($hStausbar, $aDlInfo[5])
					EndIf
					If $aDlInfo[2] Then ExitLoop ; complete
				EndIf

				If Not ProcessExists($iThreadPid) Or _DateDiff("s", $ResponseTimer, _NowCalc()) > 30 Then
					$error = lang("Update", "NoResponse", '进程意外中止或无响应')
					ExitLoop
				EndIf
				If Not $IsUpdating Then
					ExitLoop 2 ; 手动停止更新
				EndIf
				Sleep(100)
			WEnd
			_KillThread($iThreadPid)
			If $aDlInfo[3] Then
				$LatestChromeVer = $aDlInfo[0]
				$LatestChromeUrls = $aDlInfo[1]
			Else
				If $aDlInfo[4] Then
					$error = $aDlInfo[5]
				EndIf
				If IsHWnd($hSettings) Then
					_GUICtrlStatusBar_SetText($hStausbar, lang("GUI", "GetUpdateInfoFailed", '获取 Chrome 更新信息失败') & " " & $error)
				EndIf
			EndIf

			If Not $LatestChromeVer Then
				If Not IsHWnd($hSettings) Then ExitLoop
				$msg = MsgBox(16 + 5, "MyChrome", lang("GUI", "GetUpdateInfoFailed", '获取 Chrome 更新信息失败') & "！" & @CRLF & _
						$error, 0, $hSettings)
			EndIf
		Until $LatestChromeVer Or $msg = 2 ; Cancel
		If $LatestChromeVer And IsHWnd($hSettings) Then
			GUICtrlSetData($hLatestChromeVer, $LatestChromeVer)
		EndIf
	EndIf

	If Not $LatestChromeVer Then
		EndUpdate()
		Return
	EndIf

	$LastCheckUpdate = _NowCalc()
	IniWrite($inifile, "Settings", "LastCheckUpdate", $LastCheckUpdate)
	$ChromeFileVersion = FileGetVersion($ChromeDir & "\chrome.dll", "FileVersion")
	$ChromeLastChange = GetChromeLastChange($ChromeDir & "\chrome.dll")
	If $LatestChromeVer = $ChromeLastChange Or $LatestChromeVer = $ChromeFileVersion Then
		If Not IsHWnd($hSettings) Then
			EndUpdate()
			Return
		EndIf
	EndIf

	Local $LangUpdateTips = lang("Update", "UpdateTips", _
			'Google Chrome (%s) 可以更新，是否立即下载？\n\n最新版本：\t%s\n您的版本：\t%s  %s')
	Local $info = StringFormat($LangUpdateTips, $Channel, $LatestChromeVer, $ChromeFileVersion, $ChromeLastChange)
	$msg = 6
	If Not IsHWnd($hSettings) Then
		$msg = MsgBox(68, 'MyChrome', $info)
	EndIf
	If $msg <> 6 Then ; not YES
		EndUpdate()
		Return
	EndIf

	Local $updated, $urls, $iCancel
	Local $LangDownloadingChrome = lang("Update", "DownloadingChrome", '下载 Chrome')
	$IsUpdating = $LatestChromeUrls
	$TempDir = $ChromeDir & "\~update"
	Local $localfile = $TempDir & "\chrome_installer.exe"
	If Not FileExists($TempDir) Then
		DirCreate($TempDir)
	EndIf
	If IsHWnd($hSettings) Then
		_GUICtrlStatusBar_SetText($hStausbar, $LangDownloadingChrome & ' ...')
	ElseIf Not @TrayIconVisible Then
		TraySetState(1)
		TraySetClick(8)
		TraySetToolTip("MyChrome")
		TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "TrayTipProgress")
		$iCancel = TrayCreateItem(lang("Update", "CancelUpdate", '取消更新') & " ...")
		TrayItemSetOnEvent(-1, "CancelUpdate")
		TrayTip("MyChrome", StringFormat("%s ...\n%s", _
				$LangDownloadingChrome, lang("Update", "DownloadChromeTips", '点击图标可查看下载进度')), 10, 1)
	EndIf

	Local $ResumeDownload = 0, $error, $errormsg
	If $strUrl Then
		$urls = $strUrl
	Else
		$urls = $LatestChromeUrls
	EndIf


	While 1
		_SetVar("ResponseTimer", _NowCalc())
		_SetVar("DLInfo", StringFormat('|||||%s ...', $LangDownloadingChrome))
		If Not $IsUpdating Then
			ExitLoop ; 手动停止
		EndIf
		If $ResumeDownload Then
			_SetVar("ResumeDownload", 1)
			If IsHWnd($hSettings) Then
				_GUICtrlStatusBar_SetText($hStausbar, lang("Update", "RestoringDownload", '尝试恢复下载') & ' ...')
			EndIf
		Else
			If $ProxyType = "DIRECT" Or Not $ProxySever Then
				$iThreadPid = _StartThread(@ScriptFullPath, "download_chrome", $urls, $localfile, $DownloadThreads, $inifile)
			Else
				$iThreadPid = _StartThread(@ScriptFullPath, "download_chrome", $urls, $localfile, _
						$DownloadThreads, $inifile, "HTTP:" & $ProxySever & ":" & $ProxyPort)
			EndIf

			IniWrite($TempDir & "\Update.ini", "general", "pid", $iThreadPid) ; 执行更新的程序pid,用来验证chrome是否正在更新
			IniWrite($TempDir & "\Update.ini", "general", "exe", StringRegExpReplace(@AutoItExe, ".*\\", "")) ; 正在执行更新的程序名
			IniWrite($TempDir & "\Update.ini", "general", "latest", $LatestChromeVer) ; 最新版本号
			IniWrite($TempDir & "\Update.ini", "general", "url", $urls) ; 下载地址
		EndIf

		Local $aDlInfo[6]
		While 1 ; 等待下载结束
			$aDlInfo = StringSplit(_GetVar("DLInfo"), "|", 2)
			If IsHWnd($hSettings) Then
				_GUICtrlStatusBar_SetText($hStausbar, $aDlInfo[5])
			ElseIf $TrayTipProgress Or TrayTipExists($LangDownloadingChrome) Then
				$tips = StringRegExpReplace($aDlInfo[5], "\.\.\. *", "..." & @CRLF)
				TrayTip("MyChrome", $tips, 10, 1)
				$TrayTipProgress = 0
			EndIf
			If $aDlInfo[2] Then ExitLoop ; 任务完成

			If Not ProcessExists($iThreadPid) Or _DateDiff("s", _GetVar("ResponseTimer"), _NowCalc()) > 30 Then
				$error = lang("Update", "NoResponse", '进程意外中止或无响应')
				ExitLoop
			EndIf

			If Not $IsUpdating Then ; 手动停止
				ExitLoop 2
			EndIf
			Sleep(100)
		WEnd

		If $aDlInfo[2] And $aDlInfo[3] Then ; 下载成功
			FileSetAttrib($localfile, "+A") ; Win8中没这行会出错
			$updated = InstallChrome() ; 安装更新
			ExitLoop
		EndIf

		If $aDlInfo[4] Then
			$error = $aDlInfo[5]
		EndIf
		If $aDlInfo[4] = 10 Then
			$ResumeDownload = 1 ; 下载出错未完成，可续传
		Else
			$ResumeDownload = 0 ; 下载出错，不能续传
			_KillThread($iThreadPid)
		EndIf

		Local $LangDownloadFailed = lang("Update", "DownloadFailed", '下载 Google Chrome 失败')
		If IsHWnd($hSettings) Then
			_GUICtrlStatusBar_SetText($hStausbar, $LangDownloadFailed & " " & $error)
		EndIf

		$msg = MsgBox(16 + 5, "MyChrome", $LangDownloadFailed & "！" & @CRLF & $error, 0, $hSettings)
		If $msg <> 4 Then ExitLoop
	WEnd

	If @TrayIconVisible Then
		TrayItemDelete($iCancel)
		TraySetState(2)
	EndIf
	EndUpdate()
	Return $updated
EndFunc   ;==>UpdateChrome

Func CancelUpdate()
	Local $msg = MsgBox(292, "MyChrome", _
			lang("Update", "CancelUpdateConfirm", '浏览器正在更新，确定要取消吗？'))
	If $msg = 6 Then
		$IsUpdating = 0
	EndIf
EndFunc   ;==>CancelUpdate

Func get_latest_chrome_ver_sina($Channel, $x86 = 0, $inifile = "", $Proxy = "")
	Local $LatestVer, $LatestUrls
	Local $OSArch = StringLower(@OSArch)
	$x86 = $x86 * 1
	AdlibRegister("ResetTimer", 1000) ; 定时向父进程发送时间信息（响应信息）
	Local $sProxy
	If StringInStr($Proxy, "HTTP:") == 1 Then ; support HTTP only
		$arr = StringSplit($Proxy, ":", 2)
		$ProxySever = $arr[1]
		$ProxyPort = $arr[2]
		$sProxy = $ProxySever & ":" & $ProxyPort
	EndIf

	#cs
		http://down.tech.sina.com.cn/page/40975.html
		http://down.tech.sina.com.cn/download/d_load.php?d_id=40975&down_id=9
		stable: down_id=9 / dwon_id=10
		beta: down_id=7 / dwon_id=8
		DEV: down_id=5 / dwon_id=6
	#ce
	Local $down_id, $need_x86
	If $x86 Or $OSArch = "x86" Or VersionCompare($WinVersion, "6.1") < 0 Then
		$need_x86 = True
	EndIf
	Switch $Channel
		Case "Stable"
			If $need_x86 Then
				$down_id = 9
			Else
				$down_id = 10
			EndIf
		Case "Beta"
			If $need_x86 Then
				$down_id = 7
			Else
				$down_id = 8
			EndIf
		Case "Dev"
			If $need_x86 Then
				$down_id = 5
			Else
				$down_id = 6
			EndIf
		Case Else
			_SetVar("DLInfo", '||1||1|' & lang("Update", "ChanelNotExists", '新浪没有该分支的更新信息：') & $Channel)
			Return
	EndSwitch

	Local $hHTTPOpen, $hConnect, $hRequest, $error
	If Not $sProxy Then
		$hHTTPOpen = _WinHttpOpen($UserAgent)
	Else
		$hHTTPOpen = _WinHttpOpen($UserAgent, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $sProxy, "localhost")
	EndIf
	_WinHttpSetTimeouts($hHTTPOpen, 0, 3000, 3000, 3000)

	$LangGetChromeChances = lang("Update", "GetChromeChances", '从服务器获取 %s 更新信息... 第 %d 次尝试')
	$LangNoServerResp = lang("Update", "NoServerResp", '服务器无响应')
	$LangParseInfoFailed = lang("Update", "ParseInfoFailed", '服务器返回的更新信息无法解析')
	For $i = 1 To 3
		_SetVar("DLInfo", '|||||' & StringFormat($LangGetChromeChances, "Chrome", $i))

		$hConnect = _WinHttpConnect($hHTTPOpen, "http://down.tech.sina.com.cn")
		$hRequest = _WinHttpSimpleSendRequest($hConnect, "GET", "/download/d_load.php?d_id=40975&down_id=" & $down_id)
		_WinHttpReceiveResponse($hRequest)
		$LatestUrls = _WinHttpQueryOption($hRequest, $WINHTTP_OPTION_URL)
		$error = @error
		_WinHttpCloseHandle($hRequest)
		_WinHttpCloseHandle($hConnect)

		If $error Then
			$error = $LangNoServerResp
		Else
			$match = StringRegExp($LatestUrls, '(?i)/(\d+\.\d+\.\d+\.\d+)_chrome\S+\.exe', 1)
			If @error Then
				$error = $LangParseInfoFailed
			Else
				$LatestVer = $match[0]
				$error = ""
				ExitLoop
			EndIf
		EndIf
	Next
	_WinHttpCloseHandle($hHTTPOpen)
	If $LatestVer Then
		$LangUpdateGot = lang("Update", "UpdateGot", '已成功获取 %s 更新信息')
		_SetVar("DLInfo", $LatestVer & "|" & $LatestUrls & '|1|1||' & StringFormat($LangUpdateGot, "Chrome"))
	Else
		_SetVar("DLInfo", "||1||1|" & $error)
	EndIf
EndFunc   ;==>get_latest_chrome_ver_sina

#Region get Chrome update info (latest version, urls）
;~ $aDlInfo[6]
;~ 0 - Latest Chrome Version
;~ 1 - Latest Chrome url
;~ 2 - Set to True if the download is complete, False if the download is still ongoing.
;~ 3 - True if the download was successful. If this is False then the next data member will be non-zero.
;~ 4 - The error value for the download. The value itself is arbitrary. Testing that the value is non-zero is sufficient for determining if an error occurred.
;~ 5 - The extended value for the download. The value is arbitrary and is primarily only useful to the AutoIt developers.
Func get_latest_chrome_ver($Channel, $x86 = 0, $inifile = "MyChrome.ini", $Proxy = "")
	Local $host, $urlbase, $var, $LatestVer, $LatestUrls
	Local $http = "https"
	Local $OSArch = StringLower(@OSArch)
	$x86 = $x86 * 1
	AdlibRegister("ResetTimer", 1000) ; 定时向父进程发送时间信息（响应信息）

	Local $sProxy
	If StringInStr($Proxy, "HTTP:") == 1 Then ; support HTTP only
		$arr = StringSplit($Proxy, ":", 2)
		$ProxySever = $arr[1]
		$ProxyPort = $arr[2]
		$sProxy = $ProxySever & ":" & $ProxyPort
	EndIf

	Local $hHTTPOpen, $hConnect, $name, $a, $hRequest, $sHeader, $error
	If Not $sProxy Then
		$hHTTPOpen = _WinHttpOpen($UserAgent)
	Else
		$hHTTPOpen = _WinHttpOpen($UserAgent, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $sProxy, "localhost")
	EndIf
	_WinHttpSetTimeouts($hHTTPOpen, 0, 3000, 3000, 3000)

	$LangGetChromeChances = lang("Update", "GetChromeChances", '从服务器获取 %s 更新信息... 第 %d 次尝试')
	$LangNoServerResp = lang("Update", "NoServerResp", '服务器无响应')
	$LangParseInfoFailed = lang("Update", "ParseInfoFailed", '服务器返回的更新信息无法解析')
	$LangUpdateGot = lang("Update", "UpdateGot", '已成功获取 %s 更新信息')

	; get latest Chromium developer build
	If StringInStr($Channel, "Chromium") Then
		$host = $http & "://storage.googleapis.com"
		$urlbase = "chromium-browser-snapshots/Win"

		For $i = 1 To 3
			_SetVar("DLInfo", '|||||' & StringFormat($LangGetChromeChances, "Chromium", $i))
			$hConnect = _WinHttpConnect($hHTTPOpen, $host)
			$var = _WinHttpSimpleSSLRequest($hConnect, "GET", $urlbase & "/LAST_CHANGE")
			$error = @error
			_WinHttpCloseHandle($hConnect)
			If $error Then
				$error = $LangNoServerResp
			Else
				If StringIsDigit($var) And $var > 0 Then
					$LatestVer = $var
					$LatestUrls = $host & "/" & $urlbase & "/" & $var & "/mini_installer.exe"
					ExitLoop
				Else
					$error = $LangParseInfoFailed
				EndIf
			EndIf
		Next
		_WinHttpCloseHandle($hHTTPOpen)
		If $LatestVer Then
			_SetVar("DLInfo", $LatestVer & "|" & $LatestUrls & '|1|1||' & StringFormat($LangUpdateGot, "Chromium"))
		Else
			_SetVar("DLInfo", "||1||1|" & $error)
		EndIf
		Return
	EndIf

	; http://code.google.com/p/omaha/wiki/ServerProtocol
	Local $need_x86, $appid, $ap, $data, $match
	If $x86 Or $OSArch = "x86" Then
		$need_x86 = True
	EndIf
	Switch $Channel
		Case "Stable"
			$appid = "8A69D345-D564-463C-AFF1-A69D9E530F96"
			If $need_x86 Then
				$ap = ""
				$OSArch = "x86"
			Else
				$ap = "x64-stable-multi-chrome"
			EndIf
		Case "Beta"
			$appid = "8A69D345-D564-463C-AFF1-A69D9E530F96"
			If $need_x86 Then
				$ap = "1.1-beta"
				$OSArch = "x86"
			Else
				$ap = "x64-beta-multi-chrome"
			EndIf
		Case "Dev"
			$appid = "8A69D345-D564-463C-AFF1-A69D9E530F96"
			If $need_x86 Then
				$ap = "2.0-dev"
				$OSArch = "x86"
			Else
				$ap = "x64-dev-statsdef_1"
			EndIf
		Case "Canary"
			$appid = "4EA16AC7-FD5A-47C3-875B-DBF4A2008C20"
			If $need_x86 Then
				$ap = ""
				$OSArch = "x86"
			Else
				$ap = "x64-canary"
			EndIf
	EndSwitch

	Local $a = MemGetStats()
	Local $physmemory = Round($a[1]/1024/1024)

	; omaha protocol v3
	;<?xml version="1.0" encoding="UTF-8"?><request protocol="3.0" version="1.3.32.7" shell_version="1.3.32.7" ismachine="1" installsource="update3web-ondemand" dedup="cr">
	;<hw physmemory="4" sse="1" sse2="1" sse3="1" ssse3="1" sse41="0" sse42="0" avx="0"/>
	;<os platform="win" version="10.0.14393.693" sp="" arch="x64"/>
	;<app appid="{8A69D345-D564-463C-AFF1-A69D9E530F96}" version="" nextversion="" ap="x64-dev-statsdef_1"><updatecheck/></app></request>

	$data = '<?xml version="1.0" encoding="UTF-8"?><request protocol="3.0" version="1.3.32.7" ismachine="0" installsource="update3web-ondemand" dedup="cr">' & _
			'<hw physmemory="' & $physmemory & '" sse="1" sse2="1" sse3="1" ssse3="1" sse41="0" sse42="0" avx="0"/>' & _
			'<os platform="win" version="' & $WinVersion & '" sp="' & @OSServicePack & '" arch="' & $OSArch & '"/>' & _
			'<app appid="{' & $appid & '}" version="" nextversion="" ap="' & $ap & '" lang="zh-CN"><updatecheck/></app></request>'

	For $i = 1 To 3
		_SetVar("DLInfo", '|||||' & StringFormat($LangGetChromeChances, "Chrome", $i))
		$hConnect = _WinHttpConnect($hHTTPOpen, "https://tools.google.com")
		$var = _WinHttpSimpleSSLRequest($hConnect, "POST", "service/update2", Default, $data, "User-Agent: Google Update/1.3.32.7;winhttp;cup-ecdsa")
		$error = @error
		_WinHttpCloseHandle($hConnect)

		If $error Then
			$error = $LangNoServerResp
		Else
			$match = StringRegExp($var, '(?i)<manifest +version="(.+?)".* name="(.+?)"', 1)
			If @error Then
				$error = $LangParseInfoFailed
			Else
				$error = ""
				ExitLoop
			EndIf
		EndIf
	Next
	If Not $error Then
		$version = $match[0]
		$name = $match[1]
		$match = StringRegExp($var, '(?i)<url +codebase="(.+?)"', 3)
		If Not @error Then
			For $i = 0 To UBound($match) - 1
				$LatestUrls &= " " & $match[$i] & $name
			Next
			$LatestVer = $version
			$LatestUrls = StringStripWS($LatestUrls, 3)
		EndIf
	EndIf

	_WinHttpCloseHandle($hHTTPOpen)
	If $LatestVer Then
		_SetVar("DLInfo", $LatestVer & "|" & $LatestUrls & "|1|1||" & StringFormat($LangUpdateGot, "Chrome"))
	Else
		_SetVar("DLInfo", "||1||1|" & $error)
	EndIf
EndFunc   ;==>get_latest_chrome_ver
Func ResetTimer() ; 定时向父进程发送时间信息，告诉父进程：我还活着！
	_SetVar("ResponseTimer", _NowCalc())
EndFunc   ;==>ResetTimer
#EndRegion get Chrome update info (latest version, urls）

#Region DownloadChrome
; #FUNCTION# ;===============================================================================
; Name...........: DownloadChrome
; Description ...: 下载 chrome
; Syntax.........: DownloadChrome($url, $localfile, $DownloadThreads = 3, $ProxySever = "", $ProxyPort = "")
; Parameters ....: $url - space separated urls
;                  $localfile - local file path
;                  $DownloadThreads - download threads
;                  $ProxySever - proxy sever for update
;                  $ProxyPort - proxy port for update
;                  _SetVar("ResumeDownload", 1) - 0 - re-download totally，1 - resume download
; Return values .: Success - @error = 0, @extended = ""
;                  Failure - @error = 1: 连接服务器失败，不能续传
;                            @error = 2:下载出错，可以续传
;                            @error = 3:下载的文件不正确，不能续传
;============================================================================================
Func download_chrome($urls, $localfile, $DownloadThreads = 3, $inifile = "MyChrome.ini", $Proxy = "")
	Local $DownLoadInfo
	; Dim $DownLoadInfo[1][5]
;~ [n, 0] - bytes from
;~ [n, 1] - current pos(pointer)
;~ [n, 2] - bytes to
;~ [n, 3] - $hHttpRequest, special falg: 0 - error, -1 - complete
;~ [n, 4] - $hHttpConnect

	AdlibRegister("ResetTimer", 1000) ; 定时向父进程发送时间信息（响应信息）
	If StringInStr($Proxy, "HTTP:") = 1 Then ; support HTTP only
		$arr = StringSplit($Proxy, ":", 2)
		$ProxySever = $arr[1]
		$ProxyPort = $arr[2]
	EndIf
	Local $hHTTPOpen, $ret, $error
	If $ProxySever = "" Or $ProxyPort = "" Then ; try direct download first if google.com set as proxy
		$hHTTPOpen = _WinHttpOpen($UserAgent)
	Else
		$hHTTPOpen = _WinHttpOpen($UserAgent, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxySever & ":" & $ProxyPort, "localhost")
	EndIf
	_WinHttpSetTimeouts($hHTTPOpen, 0, 5000, 5000, 5000) ; 设置超时


	; get valid url
	$ChromeSource = IniRead($inifile, "Settings", "ChromeSource", "Google")
	Local $i, $j, $a, $hConnect, $hRequest, $sHeader, $url
	Local $aUrl = StringSplit($urls, " ")
	For $j = 1 To 2
		For $i = 1 To $aUrl[0]
			_SetVar("DLInfo", "|||||" & lang("Update", "Connecting", '尝试连接') & " " & $aUrl[$i])
			$a = HttpParseUrl($aUrl[$i])
			$hConnect = _WinHttpConnect($hHTTPOpen, $a[0], $a[2])
			If $a[2] = 443 Then
				$hRequest = _WinHttpOpenRequest($hConnect, "GET", $a[1], Default, Default, Default, _
						BitOR($WINHTTP_FLAG_SECURE, $WINHTTP_FLAG_ESCAPE_DISABLE))
			Else
				$hRequest = _WinHttpOpenRequest($hConnect, "GET", $a[1])
			EndIf
			_WinHttpSendRequest($hRequest)
			_WinHttpReceiveResponse($hRequest)
			$sHeader = _WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_STATUS_CODE)
			_WinHttpCloseHandle($hRequest)
			_WinHttpCloseHandle($hConnect)
			If $sHeader = 200 Then
				$url = $aUrl[$i]
				ExitLoop 2
			EndIf
		Next
	Next

	If Not $url Then
		_WinHttpCloseHandle($hHTTPOpen)
		_SetVar("DLInfo", "||1||1|" & lang("Update", "ConnectServerFailed", '连接更新服务器失败'))
		Return
	Else
		Local $TempDir = StringMid($localfile, 1, StringInStr($localfile, "\", 0, -1) - 1)
		If Not FileExists($TempDir) Then DirCreate($TempDir)
		If FileExists($localfile) Then FileDelete($localfile)
		Local $hDlFile = FileOpen($localfile, 25)
		While 1
			$ret = __DownloadChrome($url, $localfile, $hDlFile, $DownloadThreads, $hHTTPOpen, $DownLoadInfo)
			$error = @error
			_SetVar("DLInfo", $ret)
			For $i = 0 To UBound($DownLoadInfo) - 1
				If Not $DownLoadInfo[$i][3] Or $DownLoadInfo[$i][3] = -1 Then ContinueLoop
				_WinHttpCloseHandle($DownLoadInfo[$i][3])
				_WinHttpCloseHandle($DownLoadInfo[$i][4])
			Next
			If $error <> 10 Then ExitLoop
			While 1
				Sleep(100)
				If _GetVar("ResumeDownload") = 1 Then
					_SetVar("ResumeDownload", 0)
					ExitLoop 1
				EndIf
				If Not WinExists($__hwnd_vars) Then ExitLoop 2
			WEnd
		WEnd
		FileClose($hDlFile)
		If Not WinExists($__hwnd_vars) Then
			DirRemove($TempDir, 1) ; remove if father process is dead
		EndIf
	EndIf
	_WinHttpCloseHandle($hHTTPOpen)
EndFunc   ;==>download_chrome
Func __DownloadChrome($url, $localfile, $hDlFile, $DownloadThreads, $hHTTPOpen, ByRef $DownLoadInfo)
	Local $i, $header, $remotesize, $aThread, $match
	Local $TempDir = StringMid($localfile, 1, StringInStr($localfile, "\", 0, -1) - 1)
	Local $resume = IsArray($DownLoadInfo)
	Local $LangDownloadingChrome = lang("Update", "DownloadingChrome", '下载 Chrome')

	If Not $resume Then
		; 测试服务器是否支持断点续传、获取远程文件大小，分块
		_SetVar("DLInfo", "|||||" & lang("Update", "ConnectingServer", '正在连接服务器 ...'))
		For $i = 1 To 3
			$aThread = CreateThread($url, $hHTTPOpen, "10-20")
			$header = _WinHttpQueryHeaders($aThread[0])
			_WinHttpCloseHandle($aThread[0])
			_WinHttpCloseHandle($aThread[1])
			If StringRegExp($header, '(?is)^HTTP/[\d\.]+ +2') Then ExitLoop
			Sleep(500)
			If Not WinExists($__hwnd_vars) Then ExitLoop
		Next

		If Not $aThread[0] Or $header = "" Then
			Return SetError(1, 0, "||1||1|" & lang("Update", "ConnectServerFailed", '连接更新服务器失败'))
		EndIf
		If StringRegExp($header, '(?is)^HTTP/[\d\.]+ +200 ') Then ; 不支持断点续传
			Dim $DownLoadInfo[1][5] = [[0, 0, 0]]
			$match = StringRegExp($header, '(?im)Content-Length: *(\d+)', 1)
			If Not @error Then
				$remotesize = $match[0]
				$DownLoadInfo[0][2] = $remotesize - 1
			EndIf
		Else
			Dim $DownLoadInfo[$DownloadThreads][5]
			$match = StringRegExp($header, '(?im)^Content-Range: *bytes +\d+-\d+/(\d+)', 1)
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

	_SetVar("DLInfo", StringFormat("|||||%s ...", $LangDownloadingChrome))
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
	Local $timeDiff, $timeinit = $t
	Local $speed, $progress
	Local $ErrorThreads, $LiveThreads, $FileError, $complete = 0
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

			If $complete Then
				$complete = 0
				$RecvError = -1
				$RecvLen = 0
			Else
				If _WinHttpQueryDataAvailable($DownLoadInfo[$i][3]) Then
					$bytes = @extended
				Else
					$bytes = Default
				EndIf

				$data = _WinHttpReadData($DownLoadInfo[$i][3], 2, $bytes) ; read binary
				$RecvError = @error
				$RecvLen = @extended
			EndIf
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
					If $DownLoadInfo[$i][1] > $DownLoadInfo[$i][2] + 1 Then
						$DownLoadInfo[$i][1] = $DownLoadInfo[$i][2] + 1
						$complete = 1 ; mark current thread for complete
						$i = $i - 1 ; return to handle current thread
					EndIf
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

		If $FileError Then
			Return SetError(2, 0, $size & "|" & $remotesize & "|1||2|" & lang("Update", "SaveFileFailed", '保存已下载的文件出错'))
		EndIf

		If Not $LiveThreads And $ErrorThreads Then
			Return SetError(10, 0, $size & "|" & $remotesize & "|1||10|") ; 下载出错，可续传
		EndIf

		If TimerDiff($t) > 200 Then
			$speed = 0
			$t = TimerInit()
			$timeDiff = TimerDiff($timeinit)
			_ArrayPush($S, $timeDiff & ":" & $size)
			$a = StringSplit($S[0], ":")
			If $a[0] >= 2 Then
				$speed = ($size - $a[2]) / ($timeDiff - $a[1]) / 1.024
				If $speed < 1000 Then
					$speed = StringFormat("%.1fKB/s", $speed)
				Else
					$speed = StringFormat("%.1fMB/s", $speed / 1024)
				EndIf
			EndIf
			$progress = StringFormat('%.1f% - %.1fMB / %.1fMB - %s', _
					$size / $remotesize * 100, $size / 1024 / 1024, $remotesize / 1024 / 1024, $speed)
			_SetVar("DLInfo", StringFormat("%d|%d||||%s ...  %s", $size, $remotesize, $LangDownloadingChrome, $progress))
		EndIf
	Until Not $LiveThreads

	FileClose($hDlFile)
	FileSetAttrib($localfile, "+A") ; Win8中没这行会出错
	If $remotesize And $remotesize <> FileGetSize($localfile) Then ; 文件大小不对，下载出错
		Return SetError(3, 0, $size & "|" & $remotesize & "|1||3|" & lang("Update", "InstallerSizeError", '已下载的 Chrome 安装包大小不正确'))
	Else
		Return SetError(0, 0, $size & "|" & $remotesize & "|1|1||" & lang("Update", "ChromeDownloadFinished", 'Google Chrome 下载完成'))
	EndIf
EndFunc   ;==>__DownloadChrome
#EndRegion DownloadChrome

; #FUNCTION# ;===============================================================================
; Name...........: CreateThread
; Description ...: create thread
; Syntax.........: CreateThread($url, $hHttpOpen, $range = "")
; Parameters ....: $url - usr as "http://dl.google.com/chrome/install/912.12/chrome_installer.exe"
;                  $hHttpOpen -
;                  $range - request range as "0-10000"
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

	$LangExtractingChrome = lang("Update", "ExtractingChrome", '正在提取 Google Chrome 程序文件')
	If IsHWnd($hSettings) Then
		_GUICtrlStatusBar_SetText($hStausbar, $LangExtractingChrome & " ...")
	Else
		TraySetState(1)
		TraySetClick(0)
		TraySetToolTip("MyChrome")
		TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "")
		TrayTip("MyChrome", $LangExtractingChrome & " ...", 5, 1)
	EndIf

	; 解压
	FileInstall("7zr.exe", $TempDir & "\7zr.exe", 1) ; http://www.7-zip.org/download.html
	RunWait($TempDir & '\7zr.exe x "' & $ChromeInstaller & '" -y', $TempDir, @SW_HIDE)
	RunWait($TempDir & '\7zr.exe x "' & $TempDir & '\chrome.7z" -y', $TempDir, @SW_HIDE)

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
		MsgBox(64, "MyChrome", lang("Update", "ExtractChromeFailed", '提取 Google Chrome 程序文件失败！'), 0, $hSettings)
		Return SetError(1, 0, 0) ; 解压错误
	EndIf

	FileMove($TempDir & "\Chrome-bin\*.*", $TempDir & "\Chrome-bin\" & $latest & "\", 9)
	DirRemove($ChromeDir & "\~updated", 1)
	DirMove($TempDir & "\Chrome-bin\" & $latest, $ChromeDir & "\~updated", 1)

	; Copy chrome
	$LangUpdateCloseChrome = lang("Update", "UpdateCloseChrome", _
			'是否关闭 Chrome 浏览器以完成更新？\n点击“是”强制关闭浏览器，点击“否”推迟到下次启动时应用更新。')
	$ChromeIsRunning = ChromeIsRunning($ChromePath, StringFormat($LangUpdateCloseChrome, 0))
	If $ChromeIsRunning Then Return
	Return ApplyUpdate() ; 返回版本号
EndFunc   ;==>InstallChrome


Func ApplyUpdate()
	$LangApplyUpdate = lang("Update", "ApplyUpdate", '正在应用浏览器更新')
	If IsHWnd($hSettings) Then
		_GUICtrlStatusBar_SetText($hStausbar, $LangApplyUpdate & ' ...')
	ElseIf @TrayIconVisible Then
		TrayTip("MyChrome", $LangApplyUpdate & ' ...', 5, 1)
	EndIf
	FileMove($ChromeDir & "\~updated\*.*", $ChromeDir, 9)
	DirCopy($ChromeDir & "\~updated", $ChromeDir, 1)

	If StringRegExpReplace($ChromePath, ".*\\", "") <> "chrome.exe" Then
		FileMove($ChromeDir & "\chrome.exe", $ChromePath, 1)
	EndIf
	Local $chromedll = $ChromeDir & "\chrome.dll"
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = GetChromeLastChange($chromedll)
	If IsHWnd($hSettings) Then
		GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	EndIf

	$LangUpdatedTo = lang("Update", "UpdatedTo", "Google Chrome 浏览器已更新至 %s %s !")
	MsgBox(64, "MyChrome", StringFormat($LangUpdatedTo, $ChromeFileVersion, $ChromeLastChange), 0, $hSettings)
	DirRemove($ChromeDir & "\~updated", 1)
	Return $ChromeFileVersion ; 返回版本号
EndFunc   ;==>ApplyUpdate

Func TrayTipProgress()
	$TrayTipProgress = 1
EndFunc   ;==>TrayTipProgress

Func EndUpdate()
	If ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf

	If Not ChromeIsUpdating($ChromeDir) Then
		Local $TempDir = $ChromeDir & "\~update"
		If FileExists($TempDir) Then
			DirRemove($TempDir, 1)
		EndIf
	EndIf

	If IsHWnd($hSettings) Then
		GUICtrlSetData($hCheckUpdate, lang("GUI", "UpdateNow", '立即更新'))
		GUICtrlSetState($hSettingsOK, $GUI_ENABLE)
		GUICtrlSetState($hSettingsApply, $GUI_ENABLE)
		$LangSettingsTips = StringFormat(lang("GUI", "SettingsTips", '双击软件目录下的 "%s.vbs" 文件可显示此窗口'), $AppName)
		_GUICtrlStatusBar_SetText($hStausbar, $LangSettingsTips)
	EndIf
	$IsUpdating = 0
EndFunc   ;==>EndUpdate

; 退出前检查是否在更新
Func ExitApp()
	If $IsUpdating Then
		Local $msg = MsgBox(292, "MyChrome", _
				StringFormat(lang("Update", "ExitConfirm", '浏览器正在更新，确定要取消更新并退出吗？')), _
				0, $hSettings)
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
Func ChromeIsRunning($AppPath = "chrome.exe", $msg = "Do you want to close Chrome？")
	If Not AppIsRunning($AppPath) Then Return 0
	$var = MsgBox(52, 'MyChrome', $msg, 0, $hSettings)
	If $var <> 6 Then Return 1
	$exe = StringRegExpReplace($AppPath, '.*\\', '')
	For $j = 1 To 20
		; close chrome
		$list = WinList("[REGEXPCLASS:(?i)Chrome; REGEXPTITLE:\S+]")
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
	Local $host, $page, $Port, $aResults[3]
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
		If Not BitAND(WinGetState($aWindows[$i][1]), 2) Then ContinueLoop ; ignore hidden windows
		$hWnd = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $aWindows[$i][1])
		If @error Then Return SetError(@error, @extended, 0)
		$class = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd[0], "wstr", "", "int", 1024)
		If @error Then Return SetError(@error, @extended, 0)
		If $class[2] <> "Shell_TrayWnd" Then ContinueLoop

		$text = WinGetTitle($aWindows[$i][1]) ; actually get the text of TrayTip()
		If $MatchMode = 1 Then
			If StringRegExp($text, $TrayText) Then Return $aWindows[$i][1]
		Else
			If StringInStr($text, $TrayText) Then Return $aWindows[$i][1]
		EndIf
	Next
EndFunc   ;==>TrayTipExists

;~ http://www.autoitscript.com/forum/index.php?showtopic=13399&hl=GetCurrentProcessId&st=20
; Original version : w_Outer
; modified by Rajesh V R to include process ID
Func ReduceMemory($ProcID = @AutoItPID)
	Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $ProcID)
	Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
	DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
	Return $ai_Return[0]
EndFunc   ;==>ReduceMemory

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
	If @OSArch <> "X86" And Not @AutoItX64 And Not _WinAPI_IsWow64Process($pid) Then ; much slower than dllcall method
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

; Return $v1 - $v1
Func VersionCompare($v1, $v2)
	Local $i, $a1, $a2, $ret = 0
	$a1 = StringSplit($v1, ".", 2)
	$a2 = StringSplit($v2, ".", 2)
	If UBound($a1) > UBound($a2) Then
		ReDim $a2[UBound($a1)]
	Else
		ReDim $a1[UBound($a2)]
	EndIf
	For $i = 0 To UBound($a1) - 1
		$ret = $a1[$i] - $a2[$i]
		If $ret <> 0 Then ExitLoop
	Next
	Return $ret
EndFunc   ;==>VersionCompare

Func Pixel_Distance($x1, $y1, $x2, $y2) ;Pythagoras theorem for 2D
	Local $a, $b, $c
	If $x2 = $x1 And $y2 = $y1 Then
		Return 0
	Else
		$a = $y2 - $y1
		$b = $x2 - $x1
		$c = Sqrt($a * $a + $b * $b)
		Return $c
	EndIf
EndFunc   ;==>Pixel_Distance
