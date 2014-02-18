#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon_1.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=Google Chrome 便携版
#AutoIt3Wrapper_Res_Fileversion=2.8.0.0
#AutoIt3Wrapper_Res_LegalCopyright=(C)甲壳虫<jdchenjian@gmail.com>
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Au3Check_Parameters=-q
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/striponly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------
	AutoIt Version: 3.3.8.1
	作者:        甲壳虫 < jdchenjian@gmail.com >
	网站:        http://hi.baidu.com/jdchenjian
	脚本说明：   MyChrome - 可自动更新的 Google Chrome 便携版
	脚本版本：
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
#include "WinHttp.au3" ; http://www.autoitscript.com/forum/topic/84133-winhttp-functions/
#include "SimpleMultiThreading.au3"

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1 + 2) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayOnEventMode", 1)
Opt("GUIOnEventMode", 1)
Opt("WinTitleMatchMode", 4)

Global Const $AppVersion = "2.8" ; MyChrome version
Global $AppName, $inifile, $FirstRun = 0, $ChromePath, $ChromeDir, $ChromeExe, $UserDataDir, $Params
Global $CacheDir, $CacheSize
Global $LastCheckUpdate, $CheckingInterval, $Channel, $IsUpdating = 0, $AskBeforeUpdateChrome
Global $EnableProxy, $ProxySever, $ProxyPort
Global $AutoUpdateApp, $LastCheckAppUpdate

#Region ; ====设置界面全局变量====
Global $hSettingsGUI
Global $hSettingsOK, $hSettingsApply, $hStausbar
Global $hChromePath, $hGetChromeDir, $hGetChromePath, $hChromeSource, $hCheckUpdate
Global $hChannel, $hCheckingInterval, $hLatestChromeVer, $hCurrentVer, $hUserDataDir, $hCopyData
Global $hAutoUpdateApp, $hCustomCacheDir, $hCacheDir, $hSelectCacheDir, $hCustomCacheSize, $hCacheSize
Global $hparams, $hDownloadThreads, $hEnableProxy, $hProxySever, $hProxyPort
Global $LOCALAPPDATA, $hAskBeforeUpdateChrome
Global $hExtAppPath, $ExtAppPath, $hExtAppParam, $ExtAppParam
#EndRegion ; ====设置界面全局变量====

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

#Region 自动执行部分
FileChangeDir(@ScriptDir)
; 得到程序本身的文件名（不含扩展名），用作 .ini 文件名，以便于允许多个MyChrome 更名后可放在同一文件夹中
$AppName = StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 0, -1) - 1)
$inifile = @ScriptDir & "\" & $AppName & ".ini"
If Not FileExists($inifile) Then
	$FirstRun = 1
	IniWrite($inifile, "Settings", "ChromePath", "Chrome\chrome.exe")
	IniWrite($inifile, "Settings", "UserDataDir", "User Data")
	IniWrite($inifile, "Settings", "CacheDir", "*")
	IniWrite($inifile, "Settings", "CacheSize", 0)
	IniWrite($inifile, "Settings", "Channel", "Stable")
	IniWrite($inifile, "Settings", "LastCheckUpdate", "2012/01/01")
	IniWrite($inifile, "Settings", "CheckingInterval", 1)
	IniWrite($inifile, "Settings", "AskBeforeUpdateChrome", 1) ; 1 - 更新前询问
	IniWrite($inifile, "Settings", "EnableUpdateProxy", 0)
	IniWrite($inifile, "Settings", "UpdateProxy", "")
	IniWrite($inifile, "Settings", "UpdatePort", "")
	IniWrite($inifile, "Settings", "DownloadThreads", 3)
	IniWrite($inifile, "Settings", "Params", "")
	IniWrite($inifile, "Settings", "AutoUpdateApp", 1) ; 0 - 什么也不做，1 - 通知我，2 - 自动更新（无提示）
	IniWrite($inifile, "Settings", "LastCheckAppUpdate", "2012/01/01")
	IniWrite($inifile, "Settings", "CheckDefaultBrowser", 1)
	IniWrite($inifile, "Settings", "ExtAppPath", "")
	IniWrite($inifile, "Settings", "ExtAppParam", "")
EndIf
;~ 从配置文件读取参数
$ChromePath = IniRead($inifile, "Settings", "ChromePath", "Chrome\chrome.exe")
$UserDataDir = IniRead($inifile, "Settings", "UserDataDir", "User Data")
$CacheDir = IniRead($inifile, "Settings", "CacheDir", "*")
$CacheSize = IniRead($inifile, "Settings", "CacheSize", 0)
$Channel = IniRead($inifile, "Settings", "Channel", "Stable")
$LastCheckUpdate = IniRead($inifile, "Settings", "LastCheckUpdate", "2012/01/01")
$CheckingInterval = IniRead($inifile, "Settings", "CheckingInterval", 1)
If Not StringIsInt($CheckingInterval) Then $CheckingInterval = 1
$AskBeforeUpdateChrome = IniRead($inifile, "Settings", "AskBeforeUpdateChrome", 1)
$EnableProxy = IniRead($inifile, "Settings", "EnableUpdateProxy", 0)
$ProxySever = IniRead($inifile, "Settings", "UpdateProxy", "")
$ProxyPort = IniRead($inifile, "Settings", "UpdatePort", "")
$DownloadThreads = IniRead($inifile, "Settings", "DownloadThreads", 3)
$Params = IniRead($inifile, "Settings", "Params", "")
$AutoUpdateApp = IniRead($inifile, "Settings", "AutoUpdateApp", 1)
$LastCheckAppUpdate = IniRead($inifile, "Settings", "LastCheckAppUpdate", "2012/01/01")
$CheckDefaultBrowser = IniRead($inifile, "Settings", "CheckDefaultBrowser", 1)
$ExtAppPath = IniRead($inifile, "Settings", "ExtAppPath", "")
$ExtAppParam = IniRead($inifile, "Settings", "ExtAppParam", "")
If $EnableProxy = 1 Then
	HttpSetProxy(2, $ProxySever & ":" & $ProxyPort)
EndIf

;~ 第一个启动参数为“-set”，或第一次运行，Chrome.exe、用户数据文件夹不存在，则显示设置窗口
Opt("ExpandEnvStrings", 1)
If ($cmdline[0] = 1 And $cmdline[1] = "-set") Or $FirstRun Or Not FileExists($ChromePath) Or ($UserDataDir <> "" And Not FileExists($UserDataDir)) Then
	CreateSettingsShortcut(@ScriptDir & "\" & $AppName & "设置.vbs")
	Settings()
EndIf

;~ 转换成绝对路径
$ChromePath = AbsolutePath($ChromePath)
SplitPath($ChromePath, $ChromeDir, $ChromeExe)
$UserDataDir = AbsolutePath($UserDataDir)

;~ 第一个参数为 -SetDefaultGlobal，表明这是为写注册表HKLM而以管理员身份运行的进程
;~ $cmdline[1] - -SetDefaultGlobal  $cmdline[2] - $Progid
If $CheckDefaultBrowser = 1 And IsAdmin() And $cmdline[0] = 2 And $cmdline[1] = "-SetDefaultGlobal" Then
	SetDefaultGlobal($ChromePath, $cmdline[2])
	Exit ; 完成任务，退出
EndIf

If $CheckDefaultBrowser = 1 Then
	CheckDefaultBrowser($ChromePath)
EndIf

;~ Chrome 第一次运行时会在桌面和任务栏生成指向非便携 chrome.exe 的快捷方式，
;~ 以下方法可禁止其生成快捷方式：1)写入 First Run 这个文件，或 2) 用启动参数: --no-first-run
If Not FileExists($ChromeDir & "\First Run") Then FileWrite($ChromeDir & "\First Run", "")

; 给带空格的外部参数加上引号。
For $i = 1 To $cmdline[0]
	If StringInStr($cmdline[$i], "--user-data-dir=") Then ContinueLoop ; 防止重复参数

	If StringInStr($cmdline[$i], " ") Then
		$Params &= ' "' & $cmdline[$i] & '"'
	Else
		$Params &= ' ' & $cmdline[$i]
	EndIf
Next

Global $PortableParam = '--user-data-dir="' & $UserDataDir & '"'
If $CacheDir <> "*" Then
	$CacheDir = AbsolutePath($CacheDir)
	$PortableParam &= ' --disk-cache-dir="' & $CacheDir & '"'
EndIf
If $CacheSize <> 0 And StringIsDigit($CacheSize) Then
	$PortableParam &= ' --disk-cache-size=' & $CacheSize
EndIf

; 启动浏览器，工作目录设为Chrome所在目录
Run('"' & $ChromePath & '" ' & $PortableParam & ' ' & $Params, $ChromeDir)

; Start the external app
If FileExists($ExtAppPath) Then
	$dir = ""
	$file = ""
	SplitPath($ExtAppPath, $dir, $file)
	If Not ProcessExists($file) Then
		Run('"' & $ExtAppPath & '" ' & $ExtAppParam)
	EndIf
EndIf


CreateSettingsShortcut(@ScriptDir & "\" & $AppName & "设置.vbs")

;~ Check mychrome update
If $AutoUpdateApp <> 0 And _DateDiff("D", $LastCheckAppUpdate, _NowCalcDate()) >= 7 Then
	CheckAppUpdate()
EndIf

; 检查google chrome更新
If $CheckingInterval <> 0 Then
	$var = _DateDiff("D", $LastCheckUpdate, _NowCalcDate())
	If $CheckingInterval = -1 Or $var < $CheckingInterval Then Exit ; 不需检查更新，则退出
EndIf

If UpdateChrome($ChromePath, $Channel) Then
	; 检测 chrome 是否正在运行
	$IsRunning = 0
	$list = ProcessList($ChromeExe)
	For $i = 1 To $list[0][0]
		If StringInStr(_GetProcPath($list[$i][1]), $ChromePath) Then
			$IsRunning = 1
			ExitLoop
		EndIf
	Next

	; 重启程序，恢复最后的标签页
	If Not $IsRunning Then
		If @Compiled Then
			Run('"' & @AutoItExe & '" --restore-last-session')
		Else
			Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" --restore-last-session')
		EndIf
	EndIf
EndIf

If 0 Then ; ========= Lines below will never be executed =========
	; put functions here to prevent these functions from being stripped by Obfuscator
	GetLatestVersion("")
	DownloadChrome("", "")
EndIf ; ============= Lines above will never be executed =========

Exit
#EndRegion ======================= 以上为自动执行部分 ======================================


;~ 设置批处理
Func CreateSettingsShortcut($fname)
	Local $var = FileRead($fname)
	If $var <> 'CreateObject("shell.application").ShellExecute "' & @ScriptName & '", "-set"' Then
		FileDelete($fname)
		FileWrite($fname, 'CreateObject("shell.application").ShellExecute "' & @ScriptName & '", "-set"')
	EndIf
EndFunc

#region 设置默认浏览器
;~ 检查默认浏览器，当检测到由 MyChrome 启动的 Chrome 浏览器被设为默认客户端时，
;~ 将默认浏览器重定向至 MyChrome。设置默认浏览器必须修改的注册表内容并不止这些，
;~ MyChrome 只是在 google chrome 浏览器将自己设为默认的基础上作必要的修改。
;~ 力求注册表项与原版一致，只修改值而不在注册表内留下没用的垃圾
Func CheckDefaultBrowser($ChromePath)
	Local $Progid, $path, $i, $InternetClient, $var, $param, $prefs, $path

	; 修改Preferences，禁止Chrome原版启动时检查默认浏览器
	; 也可加启动参数 --no-default-browser-check
	$prefs = FileRead($UserDataDir & '\Default\Preferences')
	If Not $prefs Then
		FileWrite($UserDataDir & '\Default\Preferences', '{' & @CRLF & '"browser": {' & @CRLF & '"check_default_browser": false' & @CRLF & '}' & @CRLF & '}')
	ElseIf Not StringInStr($prefs, '"check_default_browser": false') Then
		; 若浏览器正在运行，Preferences 会被覆盖，无法禁止 google chrome 原版启动时检查默认浏览器
		$path = UserDataInUse($UserDataDir)
		If $path Then WaitChromeClose($path, "请关闭 Google Chrome 以便完成默认浏览器设置！")

		If StringInStr($prefs, '"check_default_browser": true') Then
			$prefs = StringReplace($prefs, '"check_default_browser": true', '"check_default_browser": false')
		ElseIf StringInStr($prefs, '"browser": {') Then
			$prefs = StringReplace($prefs, '"browser": {', '"browser": {' & @CRLF & '"check_default_browser": false,')
		Else
			$prefs = StringReplace($prefs, '{', '{' & @CRLF & '"browser": {' & @CRLF & '"check_default_browser": false,')
		EndIf
		FileDelete($UserDataDir & '\Default\Preferences')
		FileWrite($UserDataDir & '\Default\Preferences', $prefs)
	EndIf

	If @OSVersion = "WIN_XP" Then
		$path = RegRead('HKCR\http\shell\open\command', '')
		If Not StringInStr($path, $ChromePath) Then
			Return ; 待引导的Chrome未被设为默认则返回
		EndIf
		$Progid = RegRead('HKCR\.htm', '') ; ChromeHTML
	Else ; Win7/Win8
		$Progid = RegRead('HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice', 'Progid')
		$path = RegRead('HKCR\' & $Progid & '\shell\open\command', '')
		If Not StringInStr($path, $ChromePath) Then
			Return
		EndIf
	EndIf

	$i = 1
	While 1
		$InternetClient = RegEnumKey("HKCU\Software\Clients\StartMenuInternet", $i)
		If @error <> 0 Then ExitLoop
		$var = RegRead('HKCU\SOFTWARE\Clients\StartMenuInternet\' & $InternetClient & '\shell\open\command', '')
		If StringInStr($var, $ChromePath) Then
			$var = StringReplace($var, $ChromePath, @ScriptFullPath)
			RegWrite('HKCU\SOFTWARE\Clients\StartMenuInternet\' & $InternetClient & '\shell\open\command', '', 'REG_SZ', $var)
		EndIf
		$i += 1
	WEnd

	$var = RegRead('hkcu\Software\Classes\' & $Progid & '\shell\open\command', '')
	If StringInStr($var, $ChromePath) Then
		$var = StringReplace($var, $ChromePath, @ScriptFullPath)
		RegWrite('hkcu\Software\Classes\' & $Progid & '\shell\open\command', '', 'REG_SZ', $var)
	EndIf
	RegDelete('hkcu\Software\Classes\' & $Progid & '\shell\open\command', 'DelegateExecute') ; 解决 Win8“未注册类”错误

	RegRead('hkcu\Software\Classes\http\shell\open\command', '')
	If Not @error Then
		RegWrite('hkcu\Software\Classes\ftp\shell\open\command', '', 'REG_SZ', '"' & @ScriptFullPath & '" -- "%1"')
		RegWrite('hkcu\Software\Classes\http\shell\open\command', '', 'REG_SZ', '"' & @ScriptFullPath & '" -- "%1"')
		RegWrite('hkcu\Software\Classes\https\shell\open\command', '', 'REG_SZ', '"' & @ScriptFullPath & '" -- "%1"')
	EndIf

	; 以下设置后，Win XP 中点击开始菜单的“Internet”项才能正确启动便携版
	; Win vista / 7 中开始菜单的 “默认程序” 设置后才能正确启动便携版
	If IsAdmin() Then ; 以下操作需要管理员权限。
		SetDefaultGlobal($ChromePath, $Progid)
	Else ; 尝试以管理员身份启动另一进程，以便将信息写入注册表HKLM
		$param = '-SetDefaultGlobal "' & $Progid & '"'
		If @Compiled Then
			ShellExecute(@ScriptName, $param, @ScriptDir, "runas")
		Else
			ShellExecute(@AutoItExe, '"' & @ScriptFullPath & '" ' & $param, @ScriptDir, "runas")
		EndIf
	EndIf
EndFunc   ;==>CheckDefaultBrowser
Func SetDefaultGlobal($ChromePath, $Progid)
	Local $InternetClient, $var, $i
	$i = 1
	While 1
		$InternetClient = RegEnumKey("HKLM64\Software\Clients\StartMenuInternet", $i)
		If @error <> 0 Then ExitLoop
		$var = RegRead('HKLM64\SOFTWARE\Clients\StartMenuInternet\' & $InternetClient & '\shell\open\command', '')
		If StringInStr($var, $ChromePath) Then
			$var = StringReplace($var, $ChromePath, @ScriptFullPath)
			RegWrite('HKLM64\SOFTWARE\Clients\StartMenuInternet\' & $InternetClient & '\shell\open\command', '', 'REG_SZ', $var)
		EndIf
		$i += 1
	WEnd

	RegRead('HKLM64\SOFTWARE\Clients\StartMenuInternet\chrome.exe\shell\open\command', '')
	If Not @error Then
		RegWrite('HKLM64\SOFTWARE\Clients\StartMenuInternet\chrome.exe\shell\open\command', '', 'REG_SZ', '"' & @ScriptFullPath & '"')
	EndIf

	$var = RegRead('HKLM64\Software\Classes\' & $Progid & '\shell\open\command', '')
	If StringInStr($var, $ChromePath) Then
		$var = StringReplace($var, $ChromePath, @ScriptFullPath)
		RegWrite('HKLM64\Software\Classes\' & $Progid & '\shell\open\command', '', 'REG_SZ', $var)
	EndIf
	RegDelete('HKLM64\Software\Classes\' & $Progid & '\shell\open\command', 'DelegateExecute') ; 解决 Win8“未注册类”错误

	RegRead('HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', '')
	If Not @error Then
		RegWrite('HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', '', 'REG_SZ', @ScriptFullPath)
		RegWrite('HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', 'Path', 'REG_SZ', @ScriptDir)
	EndIf
	MsgBox(64, "MyChrome", "已将当前配置的 Google Chrome 设为您的默认浏览器!")
EndFunc
#endregion 设置默认浏览器

;~ 查检 MyChrome 更新
Func CheckAppUpdate()
	Local $var, $match, $LatestAppVer, $msg, $IgnoreAppVer, $update, $url
	IniWrite($inifile, "Settings", "LastCheckAppUpdate", _NowCalcDate())
	$IgnoreAppVer = IniRead($inifile, "Settings", "IgnoreAppVer", "")

	; 从 http://my-chrome.googlecode.com 检查更新
	$var = BinaryToString(InetRead("https://my-chrome.googlecode.com/svn/Update.txt", 27), 4)
	$var = StringStripWS($var, 3) ; 去掉开头、结尾的空字符
	$match = StringRegExp($var, "(?i)(?s)([\d\.]+)\s*\n+\s*(https?://\S+)\s*\n+\s*(.*)", 1)
	If Not @error Then
		$LatestAppVer = $match[0]
		$url = $match[1]
		$update = $match[2]
		If $AppVersion = $LatestAppVer Or $IgnoreAppVer = $LatestAppVer Then Return
		If $AutoUpdateApp = 1 Then
			$msg = MsgBoxE(67, 'MyChrome 更新', "MyChrome " & $LatestAppVer & " 已发布，更新内容：" & _
				@CRLF & @CRLF & $update & @CRLF & @CRLF & "是否自动更新？", 0, '', '', '', '不再提示')
			If $msg <> 6 Then
				If $msg = 2 Then IniWrite($inifile, "Settings", "IgnoreAppVer", $LatestAppVer) ; 下次不再显示
				Return
			EndIf
		EndIf

		Local $temp = @ScriptDir & "\MyChrome_temp"
		Local $file = StringRegExpReplace($url, ".*/", "")
		If StringInStr($file, ".") Then
			$file = $temp & "\" & $file
		Else
			$file = $temp & "\MyChrome.zip"
		EndIf
		If Not FileExists($temp) Then DirCreate($temp)

		TraySetState(1)
		TraySetClick(8)
		TraySetToolTip("MyChrome")
		TrayCreateItem("取消 MyChrome 更新")
		TrayTip("MyChrome 更新", "正在下载 MyChrome 最新版...", 5, 1)

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
			MsgBox(64, "MyChrome 更新", "MyChrome 已更新至 " & $LatestAppVer & " ！" & @CRLF & "原来的 MyChrome 已备份为 " & @ScriptName & ".bak。")
		Else
			MsgBox(64, "MyChrome 更新", "MyChrome " & $LatestAppVer & " 自动更新失败！")
		EndIf
		DirRemove($temp, 1)
		TraySetState(2)
	Else ; hi.baidu.com/jdchenjian/blog/item/23114bf153aba5c47831aa60.html
		Local $hHTTPOpen, $hConnect, $hRequest
		$hHTTPOpen = _WinHttpOpen(Default, $WINHTTP_ACCESS_TYPE_NO_PROXY) ; connect directly
		$hConnect = _WinHttpConnect($hHTTPOpen, "hi.baidu.com", 80)
		$hRequest = _WinHttpSimpleSendRequest($hConnect, "GET", "jdchenjian/item/e04f06df3975724eddf9bedc")
		_WinHttpReceiveResponse($hRequest)
		$var = BinaryToString(_WinHttpReadData($hRequest, 2, 500)) ; read first 500 bytes
		_WinHttpCloseHandle($hRequest)
		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hHTTPOpen)
		$match = StringRegExp($var, '(?i)<title>\s*MyChrome\s*v?([\d\.]+)', 1)
		If @error Then Return
		$LatestAppVer = $match[0]
		If $AppVersion = $LatestAppVer Or $IgnoreAppVer = $LatestAppVer Then Return

		$msg = MsgBoxE(67, 'MyChrome 更新', "MyChrome " & $LatestAppVer & " 已发布，是否去软件发布页看看？", 0, '', '', '', '忽略')
		If $msg <> 7 Then ; other than No
			IniWrite($inifile, "Settings", "IgnoreAppVer", $LatestAppVer) ; ignore this version
			If $msg = 6 Then
				Run('"' & $ChromePath & '" ' & $PortableParam & ' http://hi.baidu.com/jdchenjian/item/e04f06df3975724eddf9bedc', $ChromeDir)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>CheckAppUpdate

;~ 显示设置窗口
Func Settings()
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	$ChromeDir = AbsolutePath($ChromeDir)
	Switch $CheckingInterval
		Case -1
			$CheckingInterval = "从不"
		Case 7
			$CheckingInterval = "每周"
		Case 1
			$CheckingInterval = "每天"
		Case Else
			$CheckingInterval = "每次启动时"
	EndSwitch
	$ChromeFileVersion = FileGetVersion($ChromeDir & "\chrome.dll", "FileVersion")
	$ChromeLastChange = FileGetVersion($ChromeDir & "\chrome.dll", "LastChange")
	$hSettingsGUI = GUICreate("MyChrome - 打造自己的 Google Chrome 便携版", 500, 430)
	GUISetOnEvent($GUI_EVENT_CLOSE, "ExitApp")
	GUICtrlCreateLabel("MyChrome " & $AppVersion & " (" & StringLeft(FileGetTime(@ScriptFullPath, 0, 1), 8) & _
		") by 甲壳虫 <jdchenjian@gmail.com>", 5, 5, 490, -1, $SS_CENTER)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetTip(-1, "点击打开 MyChrome 主页")
	GUICtrlSetOnEvent(-1, "Website")

	;常规
	GUICtrlCreateTab(5, 25, 492, 350)
	GUICtrlCreateTabItem("常规")

	GUICtrlCreateGroup("Google Chrome 程序文件", 10, 60, 480, 180)
	GUICtrlCreateLabel("chrome 路径：", 20, 90, 120, 20)
	Opt("ExpandEnvStrings", 0)
	$hChromePath = GUICtrlCreateEdit($ChromePath, 130, 86, 230, 20, $ES_AUTOHSCROLL)
	Opt("ExpandEnvStrings", 1)
	GUICtrlSetTip(-1, "浏览器主程序路径")
	$hGetChromeDir = GUICtrlCreateButton("文件夹", 370, 86, 50, 20)
	GUICtrlSetTip(-1, "选择便携版浏览器" & @CRLF & "程序文件夹")
	GUICtrlSetOnEvent(-1, "GetChromePath")
	$hGetChromePath = GUICtrlCreateButton("exe", 430, 86, 50, 20)
	GUICtrlSetTip(-1, "选择便携版浏览器" & @CRLF & "主程序（chrome.exe）")
	GUICtrlSetOnEvent(-1, "GetChromePath")

	GUICtrlCreateLabel("获取 Google Chrome 浏览器程序文件：", 20, 124, 250, 20)
	$hChromeSource = GUICtrlCreateCombo("", 280, 120, 130, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "----  请选择  ----|从系统中提取|从网络下载|从离线安装文件提取", "----  请选择  ----")
	GUICtrlSetTip(-1, "获取便携版浏览器程序文件")
	GUICtrlSetOnEvent(-1, "GetChrome")

	GUICtrlCreateLabel("分支：", 20, 154, 110, 20)
	$hChannel = GUICtrlCreateCombo("", 130, 150, 120, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "Stable|Beta|Dev|Canary|Chromium-Continuous|Chromium-Snapshots", $Channel)
	GUICtrlSetTip(-1, "Stable - 稳定版(正式版)" & @CRLF & "Beta - 测试版" & @CRLF & "Dev - 开发版" & @CRLF & _
		"Canary - 金丝雀版" & @CRLF & "Chromium - 更新快但不稳定")
	GUICtrlSetOnEvent(-1, "CheckChrome")

	GUICtrlCreateLabel("检查浏览器更新：", 20, 184, 110, 20)
	$hCheckingInterval = GUICtrlCreateCombo("", 130, 180, 120, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "每次启动时|每天|每周|从不", $CheckingInterval)

	GUICtrlCreateLabel("最新版本：", 280, 154, 80, 20)
	$hLatestChromeVer = GUICtrlCreateLabel("", 360, 154, 140, 20)
	GUICtrlSetTip(-1, "复制下载地址到剪贴板")
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetOnEvent(-1, "ShowUrl")

	GUICtrlCreateLabel("当前版本：", 280, 184, 80, 20)
	$hCurrentVer = GUICtrlCreateLabel("", 360, 184, 140, 20)
	GUICtrlSetData(-1, $ChromeFileVersion & "  " & $ChromeLastChange)

	GUICtrlCreateLabel("发现新版本时", 20, 215, 110, 20)
	$hAskBeforeUpdateChrome = GUICtrlCreateCombo("", 130, 210, 120, 20, $CBS_DROPDOWNLIST)
	Local $sAskBeforeUpdateChrome
	If $AskBeforeUpdateChrome = 1 Then
		$sAskBeforeUpdateChrome = "通知我"
	Else
		$sAskBeforeUpdateChrome = "自动更新"
	EndIf
	GUICtrlSetData(-1, "通知我|自动更新", $sAskBeforeUpdateChrome)

	$hCheckUpdate = GUICtrlCreateButton("立即更新", 280, 210, 100, 20)
	GUICtrlSetTip(-1, "检查浏览器更新" & @CRLF & "下载最新版至 chrome 程序文件夹")
	GUICtrlSetOnEvent(-1, "Start_End_ChromeUpdate")


	GUICtrlCreateGroup("Google Chrome 用户数据文件", 10, 250, 480, 75)
	GUICtrlCreateLabel("用户数据文件夹：", 20, 280, 110, 20)
	Opt("ExpandEnvStrings", 0)
	$hUserDataDir = GUICtrlCreateEdit($UserDataDir, 130, 275, 290, 20, $ES_AUTOHSCROLL)
	Opt("ExpandEnvStrings", 1)
	GUICtrlSetTip(-1, "浏览器用户数据文件夹")
	GUICtrlCreateButton("浏览", 430, 275, 50, 20)
	GUICtrlSetTip(-1, "选择用户数据文件夹")
	GUICtrlSetOnEvent(-1, "GetUserDataDir")
	$hCopyData = GUICtrlCreateCheckbox("从系统中提取用户数据文件", 20, 300, -1, 20)

	GUICtrlCreateLabel("MyChrome 发布新版时", 20, 340, 130, 20)
	$hAutoUpdateApp = GUICtrlCreateCombo("", 150, 335, 120, 20, $CBS_DROPDOWNLIST)
	Local $sAutoUpdateApp

	If $AutoUpdateApp = 0 Then
		$sAutoUpdateApp = "什么也不做"
	ElseIf $AutoUpdateApp = 1 Then
		$sAutoUpdateApp = "通知我"
	Else
		$sAutoUpdateApp = "自动更新"
	EndIf
	GUICtrlSetData(-1, "通知我|自动更新|什么也不做", $sAutoUpdateApp)

	; 高级
	GUICtrlCreateTabItem("高级")
	GUICtrlCreateGroup("Google Chrome 缓存", 10, 60, 480, 90)
	$hCustomCacheDir = GUICtrlCreateCheckbox("缓存位置：", 30, 90, 120, 20)
	GUICtrlSetOnEvent(-1, "ToggleCacheDir")
	If $CacheDir <> "*" Then GUICtrlSetState($hCustomCacheDir, $GUI_CHECKED)
	Opt("ExpandEnvStrings", 0)
	$hCacheDir = GUICtrlCreateEdit(StringReplace($CacheDir, "*", ""), 150, 90, 270, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "浏览器缓存位置" & @CRLF & "空白 = MyChrome 所在目录\Cache" & @CRLF & "支持环境变量，如 %TEMP%\ChromeCache")
	Opt("ExpandEnvStrings", 1)
	$hSelectCacheDir = GUICtrlCreateButton("浏览", 430, 90, 50, 20)
	GUICtrlSetTip(-1, "选择缓存位置")
	GUICtrlSetOnEvent(-1, "SelectCacheDir")
	$hCustomCacheSize = GUICtrlCreateCheckbox("缓存大小：", 30, 120, 80, 20)
	GUICtrlSetOnEvent(-1, "ToggleCacheSize")
	If $CacheSize <> 0 Then GUICtrlSetState($hCustomCacheSize, $GUI_CHECKED)
	$hCacheSize = GUICtrlCreateEdit(Round($CacheSize / 1024 / 1024), 150, 120, 70, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "缓存大小（ 1 MB = 1024 KB ）" & @CRLF & "0 = 大小不限")
	GUICtrlCreateLabel(" MB", 220, 125, 35, 20)

	; 启动参数
	GUICtrlCreateLabel("Google Chrome 启动参数", 20, 170)
	Opt("ExpandEnvStrings", 0)
	Local $lparams = StringReplace($Params, " --", Chr(13) & Chr(10) & "--") ; 空格换成换行符，便于显示
	$hparams = GUICtrlCreateEdit($lparams, 20, 190, 400, 60, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
	Opt("ExpandEnvStrings", 1)
	GUICtrlSetTip(-1, "Google Chrome 浏览器启动参数" & @CRLF & "多个参数之间用空格隔开，" & @CRLF & "也可每行写一个参数。")

	; 线程数
	GUICtrlCreateLabel("下载线程数(1-10)：", 20, 270, 130, 20)
	$hDownloadThreads = GUICtrlCreateInput($DownloadThreads, 150, 266, 60, 20, $ES_NUMBER)
	GUICtrlSetTip(-1, "增减线程数可调节下载速度")
	GUICtrlSetOnEvent(-1, "ThreadsLimit")
	GUICtrlCreateUpdown($hDownloadThreads)
	GUICtrlSetLimit(-1, 10, 1)

	; 代理
	$hEnableProxy = GUICtrlCreateCheckbox("代理服务器：", 20, 296, 130, 20)
	GUICtrlSetTip(-1, "如果检查、下载更新出错，" & @CRLF & "可尝试通过代理服务器下载。")
	GUICtrlSetOnEvent(-1, "SetProxy")
	$hProxySever = GUICtrlCreateCombo($ProxySever, 150, 296, 110, 20)
	GUICtrlSetData(-1, "127.0.0.1")
	GUICtrlSetTip(-1, "代理服务器IP地址")
	GUICtrlCreateLabel("端口：", 290, 300, 80, 20)
	$hProxyPort = GUICtrlCreateCombo($ProxyPort, 370, 296, 80, 20)
	GUICtrlSetData(-1, "8087")
	GUICtrlSetTip(-1, "代理服务器端口")
	If $EnableProxy = 1 Then
		GUICtrlSetState($hEnableProxy, $GUI_CHECKED)
	Else
		GUICtrlSetState($hProxySever, $GUI_DISABLE)
		GUICtrlSetState($hProxyPort, $GUI_DISABLE)
	EndIf
	SetProxy()

	; 外部程序
	GUICtrlCreateLabel("启动外部程序：", 20, 330, 100, 20)
	Opt("ExpandEnvStrings", 0)
	$hExtAppPath = GUICtrlCreateEdit($ExtAppPath, 120, 326, 190, 20, $ES_AUTOHSCROLL)
	Opt("ExpandEnvStrings", 1)
	GUICtrlSetTip(-1, "与浏览器一起启动的外部程序")
	GUICtrlCreateButton("浏览", 320, 326, 30, 20)
	GUICtrlSetTip(-1, "选择外部程序")
	GUICtrlSetOnEvent(-1, "GetExtAppPath")
	GUICtrlCreateLabel("参数：", 370, 330, 40, 20)
	$hExtAppParam = GUICtrlCreateEdit($ExtAppParam, 410, 326, 70, 20, $ES_AUTOHSCROLL)
	GUICtrlSetTip(-1, "外部程序启动参数")


	GUICtrlCreateTabItem("")
	$hSettingsOK = GUICtrlCreateButton("确定", 260, 380, 70, 20)
	GUICtrlSetTip(-1, "应用设置并启动浏览器")
	GUICtrlSetOnEvent(-1, "SettingsOK")
	GUICtrlSetState(-1, $GUI_FOCUS)
	GUICtrlCreateButton("取消", 340, 380, 70, 20)
	GUICtrlSetTip(-1, "取消")
	GUICtrlSetOnEvent(-1, "ExitApp")
	$hSettingsApply = GUICtrlCreateButton("应用", 420, 380, 70, 20)
	GUICtrlSetTip(-1, "应用")
	GUICtrlSetOnEvent(-1, "SettingsApply")
	$hStausbar = _GUICtrlStatusBar_Create($hSettingsGUI, -1, '双击软件目录下的 "' & $AppName & '设置.vbs" 文件可调出此窗口')

	Local $WinVer = WinVer()
	Global $LOCALAPPDATA
	If @OSVersion = "WIN_XP" Or ($WinVer And $WinVer < 6) Then ; Win Vista / Win 7 version 6.x
		$LOCALAPPDATA = EnvGet("USERPROFILE") & "\Local Settings\Application Data" ; WinXP
	Else
		$LOCALAPPDATA = EnvGet("LOCALAPPDATA") ; win7/vista or up
	EndIf

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
	If Not FileExists(AbsolutePath($UserDataDir) & "\Local State") And FileExists($DefaultUserDataDir & "\Local State") Then ; 文件夹中无数据文件且系统中有，则勾选复制
		GUICtrlSetState($hCopyData, $GUI_CHECKED)
	EndIf

	ToggleCacheDir()
	ToggleCacheSize()
	GUISetState(@SW_SHOW)
	AdlibRegister("ShowLatestChromeVer", 10) ; Channel 对应的 Chrome 程序文件及对应的最新版本号

	While 1
		Sleep(100)
	WEnd
EndFunc   ;==>Settings

;~ chrome.exe路径
Func GetChromePath()
	Local $sChromePath
	If @GUI_CtrlId = $hGetChromePath Then ; 查找Chrome主程序
		$sChromePath = FileOpenDialog("选择 Chrome 浏览器主程序（chrome.exe）", @ScriptDir, _
			"可执行文件(*.exe)", 1 + 2, "chrome.exe", $hSettingsGUI)
		If $sChromePath = "" Then Return
	Else ; @GUI_CtrlId = $hGetChromeDir 选择Chrome目标文件夹
		$sChromePath = FileSelectFolder("选择 Chrome 浏览器程序文件夹", "", 1 + 4, @ScriptDir & "\Chrome", $hSettingsGUI)
		If $sChromePath = "" Then Return
		$sChromePath = StringRegExpReplace($sChromePath, "\\$", "") & "\chrome.exe"
	EndIf
	FileChangeDir(@ScriptDir) ; FileOpenDialog 会改变 @workingdir，将它改回来
	Local $chromedll = StringRegExpReplace($sChromePath, "[^\\]+$", "chrome.dll")
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = FileGetVersion($chromedll, "LastChange")
	GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	$ChromePath = RelativePath($sChromePath) ; 绝对路径转成相对路径（如果可以）
	GUICtrlSetData($hChromePath, $ChromePath)
EndFunc   ;==>GetChromePath


Func GetExtAppPath()
	Local $path
	$path = FileOpenDialog("选择与浏览器一起启动的外部程序", @ScriptDir, _
		"可执行文件 (*.exe)|任意文件 (*.*)", 1 + 2, "", $hSettingsGUI)
	If $path = "" Then Return
	$ExtAppPath = RelativePath($path) ; 绝对路径转成相对路径（如果可以）
	GUICtrlSetData($hExtAppPath, $ExtAppPath)
EndFunc   ;==>GetChromePath


; 指定用户数据文件夹
Func GetUserDataDir()
	Local $sUserDataDir = FileSelectFolder("选择一个文件夹用来保存用户数据文件", "", 1 + 4, _
		@ScriptDir & "\User Data", $hSettingsGUI)
	If $sUserDataDir <> "" Then
		$UserDataDir = RelativePath($sUserDataDir) ; 绝对路径转成相对路径（如果可以）
		GUICtrlSetData($hUserDataDir, $UserDataDir)
	EndIf
EndFunc   ;==>GetUserDataDir


;~ 从系统中复制chrome程序文件
Func CopyChromeFromSystem()
	$ChromePath = GUICtrlRead($hChromePath)
	$ChromePath = AbsolutePath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)

	Local $msg = 6
	If FileExists($ChromePath) Then
		$msg = MsgBox(292, "MyChrome", '“' & $ChromeDir & '”中已存在 Google Chrome 程序文件。如果继续，这些文件会被覆盖。' & _
				@CRLF & @CRLF & '是否继续？', 0, $hSettingsGUI)
	EndIf
	If $msg = 6 Then
		WaitChromeClose($ChromePath, "请关闭 Google Chrome 浏览器后继续！")
		_GUICtrlStatusBar_SetText($hStausbar, "从系统中提取 Google Chrome 程序文件...")
		FileCopy($DefaultChromeDir & "\*.*", $ChromeDir & "\", 1 + 8)
		DirCopy($DefaultChromeDir & "\" & $DefaultChromeVer, $ChromeDir, 1)

		; 如果设定的chrome程序文件路径不以chrome.exe结尾，则认为使用者将其改名，将chrome.exe重命名为设定的文件名
		If StringRight($ChromePath, 10) <> "chrome.exe" Then
			FileMove($ChromeDir & "\chrome.exe", $ChromePath, 1)
		EndIf
		Local $chromedll = StringRegExpReplace($ChromePath, "[^\\]+$", "chrome.dll")
		$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
		$ChromeLastChange = FileGetVersion($chromedll, "LastChange")
		GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
		_GUICtrlStatusBar_SetText($hStausbar, '提取 Google Chrome 程序文件成功！')
	EndIf
EndFunc   ;==>CopyChromeFromSystem

;~ 设置界面"确定"按钮
Func SettingsOK()
	SettingsApply()
	If @error Then Return
	If $IsUpdating Then Return ; 若正在更新则返回
	; 重启程序
	If @Compiled Then
		Run('"' & @AutoItExe & '"')
	Else
		Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '"')
	EndIf
	Exit
EndFunc   ;==>SettingsOK

;~ 设置界面"应用"按钮
Func SettingsApply()
	Local $msg
	Opt("ExpandEnvStrings", 0)
	$ChromePath = GUICtrlRead($hChromePath)
	$CheckingInterval = GUICtrlRead($hCheckingInterval)
	Switch $CheckingInterval
		Case "从不"
			$CheckingInterval = -1
		Case "每周"
			$CheckingInterval = 7
		Case "每天"
			$CheckingInterval = 1
		Case Else
			$CheckingInterval = 0
	EndSwitch
	$Channel = GUICtrlRead($hChannel)
	$UserDataDir = GUICtrlRead($hUserDataDir)
	Local $CopyData = GUICtrlRead($hCopyData)
	Local $sAutoUpdateApp = GUICtrlRead($hAutoUpdateApp)
	If $sAutoUpdateApp = "什么也不做" Then
		$AutoUpdateApp = 0
	ElseIf $sAutoUpdateApp = "通知我" Then
		$AutoUpdateApp = 1
	Else
		$AutoUpdateApp = 2
	EndIf

	If GUICtrlRead($hAskBeforeUpdateChrome) = "通知我" Then
		$AskBeforeUpdateChrome = 1
	Else
		$AskBeforeUpdateChrome = 0
	EndIf

	$Params = GUICtrlRead($hparams)
	$Params = StringReplace($Params, Chr(13) & Chr(10), " ") ; 换行符换成空格

	$ExtAppPath = RelativePath(GUICtrlRead($hExtAppPath))
	$ExtAppParam = GUICtrlRead($hExtAppParam)

	SetProxy()
	$DownloadThreads = GUICtrlRead($hDownloadThreads)
	IniWrite($inifile, "Settings", "AskBeforeUpdateChrome", $AskBeforeUpdateChrome)
	IniWrite($inifile, "Settings", "AutoUpdateApp", $AutoUpdateApp)
	IniWrite($inifile, "Settings", "EnableUpdateProxy", $EnableProxy)
	IniWrite($inifile, "Settings", "UpdateProxy", $ProxySever)
	IniWrite($inifile, "Settings", "UpdatePort", $ProxyPort)
	IniWrite($inifile, "Settings", "DownloadThreads", $DownloadThreads)
	IniWrite($inifile, "Settings", "ExtAppPath", $ExtAppPath)
	IniWrite($inifile, "Settings", "ExtAppParam", $ExtAppParam)

	$ChromePath = AbsolutePath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Opt("ExpandEnvStrings", 1)

	Local $ChromeSource = GUICtrlRead($hChromeSource)
	If $ChromeSource <> "从网络下载" And Not FileExists($ChromePath) Then ; Chrome 路径
		Local $msg = MsgBox(36, "MyChrome", "浏览器程序文件不存在或者路径错误：" & @CRLF & $ChromePath & @CRLF & @CRLF & _
			"请重新设置 chrome 浏览器路径，或者选择从网络下载浏览器程序文件。" & @CRLF & @CRLF & _
			"需要从网络下载 Google Chrome 最新版吗？", 0, $hSettingsGUI)
		If $msg = 6 Then
			GUICtrlSetData($hChromeSource, "")
			GUICtrlSetData($hChromeSource, "----  请选择  ----|从系统中提取|从网络下载|从离线安装文件提取", "从网络下载")
		Else
			GUICtrlSetState($hChromePath, $GUI_FOCUS)
			Return SetError(1)
		EndIf
	EndIf
	Opt("ExpandEnvStrings", 0)
	IniWrite($inifile, "Settings", "ChromePath", RelativePath($ChromePath))

	; 用户数据文件夹
	$UserDataDir = AbsolutePath($UserDataDir)
	Opt("ExpandEnvStrings", 1)
	If Not FileExists($UserDataDir) Then
		$msg = MsgBox(36, "MyChrome", "用户数据文件夹不存在，是否新建此文件夹？" & @CRLF & @CRLF & $UserDataDir, 0, $hSettingsGUI)
		If $msg = 7 Then
			GUICtrlSetState($hUserDataDir, $GUI_FOCUS)
			Return SetError(2)
		EndIf
		DirCreate($UserDataDir)
	EndIf
	If $CopyData = $GUI_CHECKED Then
		If FileExists(StringRegExpReplace($UserDataDir, "\\$", "") & "\Local State") Then
			$msg = MsgBox(292, "MyChrome", '“' & $UserDataDir & '”中已存在 Google Chrome 数据文件。如果继续，这些文件会被覆盖。' & _
				@CRLF & @CRLF & '请点击“是”继续，或者点击“否”重新选择文件夹。', 0, $hSettingsGUI)
			If $msg = 7 Then
				GetUserDataDir()
				Return SetError(3)
			EndIf
		EndIf

		Local $path = UserDataInUse($UserDataDir)
		If $path Then WaitChromeClose($path, "用户数据文件正在使用无法复制，请关闭 Google Chrome 后继续！")

		_GUICtrlStatusBar_SetText($hStausbar, "复制 Google Chrome 用户数据文件...")
		DirCopy($DefaultUserDataDir, $UserDataDir, 1) ; 复制原版数据文件
		_GUICtrlStatusBar_SetText($hStausbar, '双击软件目录下的 "' & $AppName & '设置.vbs" 文件可调出此窗口')
		GUICtrlSetState($hCopyData, $GUI_UNCHECKED)
	EndIf

	Opt("ExpandEnvStrings", 0)
	$UserDataDir = RelativePath($UserDataDir)
	If GUICtrlRead($hCustomCacheDir) = $GUI_CHECKED Then
		$CacheDir = RelativePath(GUICtrlRead($hCacheDir))
	Else
		$CacheDir = "*"
	EndIf

	If GUICtrlRead($hCustomCacheSize) = $GUI_CHECKED Then
		$CacheSize = GUICtrlRead($hCacheSize) * 1024 * 1024
	Else
		$CacheSize = 0
	EndIf

	IniWrite($inifile, "Settings", "UserDataDir", $UserDataDir)
	IniWrite($inifile, "Settings", "Params", $Params)
	IniWrite($inifile, "Settings", "CheckingInterval", $CheckingInterval)
	IniWrite($inifile, "Settings", "Channel", $Channel)
	IniWrite($inifile, "Settings", "CacheDir", $CacheDir)
	IniWrite($inifile, "Settings", "CacheSize", $CacheSize)

	Opt("ExpandEnvStrings", 1)
	$ChromeSource = GUICtrlRead($hChromeSource)
	If $ChromeSource = "从网络下载" Then
		MsgBox(64, "MyChrome", "即将启动更新程序，从网络下载 Google Chrome 最新版！", 0, $hSettingsGUI)
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
		$DefaultUserDataDir = $LOCALAPPDATA & "\Chromium\User Data"
		$dir = "Chromium\Application"
		$Subkey = "Software\Chromium"
	ElseIf $Channel = "Canary" Then
		$DefaultUserDataDir = $LOCALAPPDATA & "\Google\Chrome SxS\User Data"
		$dir = "Google\Chrome SxS\Application"
		$Subkey = "Software\Google\Update\Clients\{4ea16ac7-fd5a-47c3-875b-dbf4a2008c20}"
	Else ; chrome stable / beta / dev
		$DefaultUserDataDir = $LOCALAPPDATA & "\Google\Chrome\User Data"
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
	$DefaultChromeVer = RegRead("HKLM\" & $Subkey, "pv")
	If FileExists($DefaultChromeDir & "\chrome.exe") And FileExists($DefaultChromeDir & "\" & $DefaultChromeVer & "\chrome.dll") Then
		Return 1
	EndIf

	; 离线安装在 $LOCALAPPDATA
	$DefaultChromeDir = $LOCALAPPDATA & "\" & $dir
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
		$iThreadPid = _StartThread("GetLatestVersion", $Channel, $ProxySever, $ProxyPort)
	Else
		$iThreadPid = _StartThread("GetLatestVersion", $Channel)
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
		_GUICtrlStatusBar_SetText($hStausbar, "获取 Google Chrome 最新版信息失败")
	ElseIf $aDlInfo[3] Then
		$LatestChromeVer = $aDlInfo[0]
		$LatestChromeUrl = $aDlInfo[1]
	EndIf
	GUICtrlSetData($hLatestChromeVer, $LatestChromeVer)
EndFunc   ;==>ShowLatestChromeVer

; 打开网站
Func Website()
	ShellExecute("http://hi.baidu.com/jdchenjian/item/e04f06df3975724eddf9bedc")
EndFunc   ;==>Website

;~ 显示下载地址
Func ShowUrl()
	If $LatestChromeUrl Then
		ClipPut($LatestChromeUrl)
		MsgBox(64, "MyChrome", "下载地址已复制到剪贴板!" & @CRLF & @CRLF & $LatestChromeUrl, 0, $hSettingsGUI)
	EndIf
EndFunc   ;==>ShowUrl

Func GetChrome()
	Local $source = GUICtrlRead($hChromeSource)
	If $source = "从系统中提取" Then
		If CheckChromeInSystem($Channel) Then
			CopyChromeFromSystem()
		Else
			MsgBox(64, "MyChrome", "在您的系统中未发现 Google Chrome（" & $Channel & "）程序文件!", 0, $hSettingsGUI)
		EndIf
		_GUICtrlComboBox_SelectString($hChromeSource, "----  请选择  ----")
	ElseIf $source = "从离线安装文件提取" Then
		Local $installer = FileOpenDialog("选择离线安装文件（chrome_installer.exe）", @ScriptDir, _
			"可执行文件(*.exe)", 1 + 2, "chrome_installer.exe", $hSettingsGUI)
		If $installer <> "" Then
			$ChromePath = GUICtrlRead($hChromePath)
			$ChromePath = AbsolutePath($ChromePath)
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
	ElseIf MsgBox(292, "MyChrome", "确定要取消浏览器更新吗？", 0, $hSettingsGUI) = 6 Then
		$IsUpdating = 0
	EndIf
EndFunc   ;==>Start_End_ChromeUpdate

;~ 下载更新代理服务器选项
Func SetProxy()
	If GUICtrlRead($hEnableProxy) = $GUI_CHECKED Then
		If $EnableProxy <> 1 Then
			$EnableProxy = 1
			GUICtrlSetState($hProxySever, $GUI_ENABLE)
			GUICtrlSetState($hProxyPort, $GUI_ENABLE)
		EndIf
		$ProxySever = GUICtrlRead($hProxySever)
		$ProxyPort = GUICtrlRead($hProxyPort)
		HttpSetProxy(2, $ProxySever & ":" & $ProxyPort) ; 代理服务器
	Else
		If $EnableProxy <> 0 Then
			$EnableProxy = 0
			GUICtrlSetState($hProxySever, $GUI_DISABLE)
			GUICtrlSetState($hProxyPort, $GUI_DISABLE)
		EndIf
		HttpSetProxy(0) ; 无代理
	EndIf
EndFunc   ;==>SetProxy

;~ 缓存目录
Func ToggleCacheDir()
	If GUICtrlRead($hCustomCacheDir) = $GUI_CHECKED Then
		GUICtrlSetState($hCacheDir, $GUI_ENABLE)
		GUICtrlSetState($hSelectCacheDir, $GUI_ENABLE)
	Else
		GUICtrlSetState($hCacheDir, $GUI_DISABLE)
		GUICtrlSetState($hSelectCacheDir, $GUI_DISABLE)
	EndIf
EndFunc   ;==>ToggleCacheDir

;~ 缓存大小
Func ToggleCacheSize()
	If GUICtrlRead($hCustomCacheSize) = $GUI_CHECKED Then
		GUICtrlSetState($hCacheSize, $GUI_ENABLE)
	Else
		GUICtrlSetState($hCacheSize, $GUI_DISABLE)
	EndIf
EndFunc   ;==>ToggleCacheSize

;~ 选择缓存目录
Func SelectCacheDir()
	Local $sCacheDir = FileSelectFolder("选择一个文件夹用来保存浏览器缓存文件", "", 1 + 4, _
		AbsolutePath($UserDataDir) & "\Default", $hSettingsGUI)
	If $sCacheDir <> "" Then
		$CacheDir = RelativePath($sCacheDir) ; 绝对路径转成相对路径（如果可以）
		GUICtrlSetData($hCacheDir, $CacheDir)
	EndIf
EndFunc   ;==>SelectCacheDir

Func ShowSettings()
	If @Compiled Then
		Run('"' & @AutoItExe & '" -set')
	Else
		Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" -set')
	EndIf
EndFunc   ;==>ShowSettings

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
	$ChromePath = AbsolutePath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	If ChromeIsUpdating($ChromeDir) Then
		If IsHWnd($hSettingsGUI) Then
			MsgBox(64, "MyChrome", "Google Chrome 浏览器上次更新仍在进行中！", 0, $hSettingsGUI)
		EndIf
		EndUpdate()
		Return
	EndIf

	$IsUpdating = 1
	Local $msg, $ResponseTimer
	If Not $LatestChromeVer Then ; 获取最新版信息
		Do
			$LatestChromeVer = ""
			$LatestChromeUrl = ""
			_SetVar("DLInfo", "|||||")
			If $EnableProxy = 1 Then
				$iThreadPid = _StartThread("GetLatestVersion", $Channel, $ProxySever, $ProxyPort)
			Else
				$iThreadPid = _StartThread("GetLatestVersion", $Channel)
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
				_GUICtrlStatusBar_SetText($hStausbar, "获取 Google Chrome 最新版信息失败")
			ElseIf $aDlInfo[3] Then
				$LatestChromeVer = $aDlInfo[0]
				$LatestChromeUrl = $aDlInfo[1]
			EndIf
			If Not $LatestChromeVer Then
				If Not IsHWnd($hSettingsGUI) Then ExitLoop
				$msg = MsgBox(16 + 5, "更新错误-MyChrome", "获取 Google Chrome (" & $Channel & ") 最新版信息失败！" & @CRLF & _
						"请检查网络连接和设置，稍后再试。", 0, $hSettingsGUI)
			EndIf
		Until $LatestChromeVer Or $msg = 2 ; Cancel
	EndIf

	If Not $LatestChromeVer Then
		EndUpdate()
		Return
	EndIf

	IniWrite($inifile, "Settings", "LastCheckUpdate", _NowCalcDate())
	$ChromeFileVersion = FileGetVersion($ChromeDir & "\chrome.dll", "FileVersion")
	$ChromeLastChange = FileGetVersion($ChromeDir & "\chrome.dll", "LastChange")
	If $LatestChromeVer = $ChromeLastChange Or $LatestChromeVer = $ChromeFileVersion Then
		If IsHWnd($hSettingsGUI) Then
			MsgBox(64, "MyChrome", "您的 Google Chrome (" & $Channel & ") 已经是最新版!", 0, $hSettingsGUI)
		EndIf
		EndUpdate()
		Return
	EndIf

	$msg = 6
	Local $info = "Google Chrome (" & $Channel & ") 可以更新，是否立即下载浏览器的最新版本？" & @CRLF & @CRLF _
			 & "最新版本：" & $LatestChromeVer & @CRLF _
			 & "您的版本：" & $ChromeFileVersion & "  " & $ChromeLastChange

	If Not IsHWnd($hSettingsGUI) And $AskBeforeUpdateChrome = 1 Then
		$msg = MsgBoxE(67, 'MyChrome', $info, 0, '', '', '', '修改设置')
	EndIf

	Local $restart = 1, $error, $errormsg, $updated
	If $msg = 2 Then ; Cancel - 修改设置
		ShowSettings() ; 重启程序，显示设置窗口
		Exit
	ElseIf $msg = 6 Then ; YES
		$IsUpdating = $LatestChromeUrl
		Local $localfile = $ChromeDir & "\~Update\chrome_installer.exe"
		If IsHWnd($hSettingsGUI) Then
			_GUICtrlStatusBar_SetText($hStausbar, "下载 Google Chrome ...")
		ElseIf Not @TrayIconVisible Then
			TraySetState(1)
			TraySetClick(8)
			TraySetToolTip("MyChrome")
			TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "TrayTipProgress")
			TrayCreateItem("退出 MyChrome...")
			TrayItemSetOnEvent(-1, "ExitApp")
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
				If IsHWnd($hSettingsGUI) Then
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
			$msg = MsgBox(16 + 5, "更新错误-MyChrome", "下载 Google Chrome 出错！" & @CRLF & $errormsg, 0, $hSettingsGUI)
			If $msg <> 4 Then ExitLoop
			Dim $aDlInfo[6]
		WEnd
	EndIf

	EndUpdate()
	Return $updated
EndFunc   ;==>UpdateChrome

#Region 获取 Chrome 最新版信息（最新版本号，下载地址）
;~ $aDlInfo[6]
;~ 0 - Latest Chrome Version
;~ 1 - Latest Chrome url
;~ 2 - Set to True if the download is complete, False if the download is still ongoing.
;~ 3 - True if the download was successful. If this is False then the next data member will be non-zero.
;~ 4 - The error value for the download. The value itself is arbitrary. Testing that the value is non-zero is sufficient for determining if an error occurred.
;~ 5 - The extended value for the download. The value is arbitrary and is primarily only useful to the AutoIt developers.
;~ 从网络获取 chrome 最新版本号
Func GetLatestVersion($Channel, $ProxySever = "", $ProxyPort = "")
	Local $urlbase, $var, $LatestChromeVer, $LatestChromeUrl, $i, $j

	AdlibRegister("ResetTimer", 1000) ; 定时向父进程发送时间信息（响应信息）

	; get latest Chromium developer build
	If StringInStr($Channel, "Chromium") Then
		_SetVar("DLInfo", "|||||正在连接服务器，获取 Chromium 最新版信息...")
		If $ProxySever <> "" And $ProxyPort <> "" Then
			HttpSetProxy(2, $ProxySever & ":" & $ProxyPort)
		EndIf
		If $Channel = "Chromium-Continuous" Then
			$urlbase = "http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/"
		Else
			$urlbase = "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Win/"
		EndIf
		For $i = 1 To 3
			$var = BinaryToString(InetRead($urlbase & "LAST_CHANGE", 16))
			If StringIsDigit($var) Then ExitLoop
			Sleep(200)
		Next

		If Not StringIsDigit($var) Then ; try https
			$urlbase = StringReplace($urlbase, "http://", "https://")
			For $i = 1 To 3
				$var = BinaryToString(InetRead($urlbase & "LAST_CHANGE", 16))
				If StringIsDigit($var) Then ExitLoop
				Sleep(200)
			Next
		EndIf

		If Not StringIsDigit($var) Then
			_SetVar("DLInfo", "||1||1|获取 Chromium 最新版信息失败，请检查网络连接，稍后再试。")
			Return
		EndIf
		$LatestChromeVer = $var
		$LatestChromeUrl = $urlbase & $LatestChromeVer & "/mini_installer.exe"
		_SetVar("DLInfo", $LatestChromeVer & "|" & $LatestChromeUrl & "|1|1||已成功获取 Chromium 最新版信息")
		Return
	EndIf

	; 利用 Google Update API 获取 stable/beta/dev/canary 最新版本号 http://code.google.com/p/omaha/wiki/ServerProtocol
	Local $appid, $ap, $WinVer, $data, $match
	_SetVar("DLInfo", "|||||正在连接服务器，获取 Google Chrome 最新版信息...")
	Switch $Channel
		Case "Stable"
			$appid = "4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D"
			$ap = "-multi-chrome"
		Case "Beta"
			$appid = "4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D"
			$ap = "1.1-beta"
		Case "Dev"
			$appid = "4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D"
			$ap = "2.0-dev"
		Case "Canary"
			$appid = "4EA16AC7-FD5A-47C3-875B-DBF4A2008C20"
			$ap = ""
	EndSwitch
	$WinVer = WinVer()
	If Not $WinVer Then $WinVer = "6.1"
	$data = '<?xml version="1.0" encoding="UTF-8"?><request protocol="3.0" version="1.3.21.123" ismachine="0" ' & _
			'sessionid="{12345678-1234-1234-1234-123456789012}" installsource="ondemandcheckforupdate" ' & _
			'requestid="{12345678-1234-1234-1234-123456789012}"><os platform="win" version="' & $WinVer & '" ' & _
			'sp="' & @OSServicePack & '" arch="' & @OSArch & '"/><app appid="{' & $appid & '}" version="" nextversion="" ' & _
			'ap="' & $ap & '" lang="" brand="GGLS" client=""><updatecheck/><ping active="1"/></app></request>'

	Local $hHTTPOpen, $hConnect, $version, $name, $a, $hRequest, $sHeader, $error

	If $ProxySever <> "" And $ProxyPort <> "" Then
		$hHTTPOpen = _WinHttpOpen(Default, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxySever & ":" & $ProxyPort, "localhost")
	Else
		$hHTTPOpen = _WinHttpOpen() ; 无代理
	EndIf
	_WinHttpSetTimeouts($hHTTPOpen, 0, 10000, 10000, 10000) ; 设置超时
	For $i = 1 To 3
		$hConnect = _WinHttpConnect($hHTTPOpen, "tools.google.com", 80)
		$var = _WinHttpSimpleRequest($hConnect, "POST", "service/update2", Default, $data)
		_WinHttpCloseHandle($hConnect)
		$match = StringRegExp($var, '(?i)<manifest +version="([\d\.]+)".* name="([^" ]+)"', 1)
		$error = @error
		If Not $error Then ExitLoop
		Sleep(200)
	Next
	If $error Then
		_SetVar("DLInfo", "||1||1|获取 Google Chrome 最新版信息失败，请检查网络连接，稍后再试。") ; 无法获取更新地址
	Else
		$version = $match[0]
		$name = $match[1]
		$match = StringRegExp($var, '(?i)<url +codebase="([^" ]+)"', 3)
		If @error Then
			_SetVar("DLInfo", "||1||1|获取 Google Chrome 最新版信息失败，请检查网络连接，稍后再试。") ; 无法获取更新地址
		Else
			_SetVar("DLInfo", "|||||正在验证 Google Chrome 最新版下载地址...")
			For $i = 0 To UBound($match) - 1
				$a = HttpParseUrl($match[$i] & $name)
				For $j = 1 To 2
					$hConnect = _WinHttpConnect($hHTTPOpen, $a[0], $a[2])
					$hRequest = _WinHttpOpenRequest($hConnect, Default, $a[1])
					_WinHttpSendRequest($hRequest)
					_WinHttpReceiveResponse($hRequest)
					$sHeader = _WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_STATUS_CODE)
					_WinHttpCloseHandle($hRequest)
					_WinHttpCloseHandle($hConnect)
					If $sHeader = 200 Then ExitLoop
					Sleep(100)
				Next
				If $sHeader = 200 Then
					_WinHttpCloseHandle($hHTTPOpen)
					$LatestChromeVer = $version
					$LatestChromeUrl = $match[$i] & $name
					_SetVar("DLInfo", $LatestChromeVer & "|" & $LatestChromeUrl & "|1|1||已成功获取 Google Chrome 最新版信息")
					Return
				EndIf
			Next
			If Not $LatestChromeVer Then
				_SetVar("DLInfo", $LatestChromeVer & "|" & $LatestChromeUrl & "|1||2|已获取的 Google Chrome 下载地址无法连接，请稍后再试。")
			EndIf
		EndIf
	EndIf
	_WinHttpCloseHandle($hHTTPOpen)
EndFunc   ;==>GetLatestVersion
Func ResetTimer() ; 定时向父进程发送时间信息，告诉父进程：我还活着！
	_SetVar("ResponseTimer", TimerInit())
EndFunc   ;==>ResetTimer
#EndRegion 获取 Chrome 最新版信息（最新版本号，下载地址）

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

	Local $hHttpOpen, $ret, $error
	If $ProxySever <> "" And $ProxyPort <> "" Then
		$hHttpOpen = _WinHttpOpen(Default, $WINHTTP_ACCESS_TYPE_NAMED_PROXY, $ProxySever & ":" & $ProxyPort, "localhost")
	Else
		$hHttpOpen = _WinHttpOpen() ; 无代理
	EndIf
	_WinHttpSetTimeouts($hHttpOpen, 0, 10000, 10000, 10000) ; 设置超时
	While 1
		$ret = __DownloadChrome($url, $localfile, $hDlFile, $version, $DownloadThreads, $hHttpOpen, $DownLoadInfo)
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

	_WinHttpCloseHandle($hHttpOpen)
	FileClose($hDlFile)
	If Not WinExists($__hwnd_vars) Then
		DirRemove($TempDir, 1) ; 没有父进程则删除文件
	EndIf
EndFunc   ;==>DownloadChrome
Func __DownloadChrome($url, $localfile, $hDlFile, $version, $DownloadThreads, $hHttpOpen, ByRef $DownLoadInfo)
	Local $i, $header, $remotesize, $aThread, $match
	Local $TempDir = StringMid($localfile, 1, StringInStr($localfile, "\", 0, -1) - 1)
	Local $resume = IsArray($DownLoadInfo)

	If Not $resume Then
		IniWrite($TempDir & "\Update.ini", "general", "pid", @AutoItPID) ; 执行更新的程序pid,用来验证是否已有MyChrome进程在更新chrome
		IniWrite($TempDir & "\Update.ini", "general", "exe", StringRegExpReplace(@AutoItExe, ".*\\", "")) ; 正在执行更新的程序名
		If $version Then IniWrite($TempDir & "\Update.ini", "general", "latest", $version) ; 最新版本号
		IniWrite($TempDir & "\Update.ini", "general", "url", $url) ; 下载地址

		; 测试服务器是否支持断点续传、获取远程文件大小，分块
		_SetVar("DLInfo", "|||||正在连接 Google Chrome 服务器，获取最新版信息...")
		For $i = 1 To 3
			$aThread = CreateThread($url, $hHttpOpen, "10-20")
			$header = _WinHttpQueryHeaders($aThread[0])
			_WinHttpCloseHandle($aThread[0])
			_WinHttpCloseHandle($aThread[1])
			If StringRegExp($header, '(?i)(?s)^HTTP/[\d\.]+ +2') Then ExitLoop
			Sleep(500)
			If Not WinExists($__hwnd_vars) Then ExitLoop
		Next

		If Not $aThread[0] Or $header = "" Then
			Return SetError(1, "", "||1||1|连接 Google Chrome 更新服务器失败") ; 无法连接服务器
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
			$aThread = CreateThread($url, $hHttpOpen, $range)
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
						$aThread = CreateThread($url, $hHttpOpen, $DownLoadInfo[$n][1] & "-" & $DownLoadInfo[$n][2])
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
					$aThread = CreateThread($url, $hHttpOpen, $DownLoadInfo[$i][1] & "-" & $DownLoadInfo[$i][2])
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
			Return SetError(2, "", $size & "|" & $remotesize & "|1||2|下载 Google Chrome 出错") ; 文件写入出错或下载出错
		EndIf

		If TimerDiff($t) > 200 Then
			$speed = 0
			$t = TimerInit()
			$timediff = TimerDiff($timeinit)
			_ArrayPush($S, $timediff & ":" & $size)
			$a = StringSplit($S[0], ":")
			If $a[0] >=2 Then
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
		Return SetError(3, "", $size & "|" & $remotesize & "|1||3|已下载的 Google Chrome 文件大小不正确") ; 已下载的文件大小不正确
	Else
		Return SetError(0, "", $size & "|" & $remotesize & "|1|1||Google Chrome 下载完成")
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
Func CreateThread($url, $hHttpOpen, $range = "")
	Local $hHttpConnect, $hHttpRequest, $aHandle

	Local $aUrl = HttpParseUrl($url) ; $aUrl[0] - host, $aUrl[1] - page, $aUrl[2] - port
	$hHttpConnect = _WinHttpConnect($hHttpOpen, $aUrl[0], $aUrl[2])

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
	$ChromePath = AbsolutePath($ChromePath)
	SplitPath($ChromePath, $ChromeDir, $ChromeExe)
	Local $TempDir = $ChromeDir & "\~Update"
	If Not FileExists($TempDir) Then DirCreate($TempDir)
	If $ChromeInstaller = "" Then $ChromeInstaller = $TempDir & "\chrome_installer.exe"

	If IsHWnd($hSettingsGUI) Then
		_GUICtrlStatusBar_SetText($hStausbar, "正在提取 Google Chrome 程序文件...")
	Else
		If Not @TrayIconVisible Then
			TraySetState(1)
			TraySetClick(8)
			TraySetToolTip("MyChrome")
			TrayCreateItem("退出 MyChrome ...")
			TrayItemSetOnEvent(-1, "ExitApp")
		EndIf
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
		MsgBox(64, "更新错误-MyChrome", "提取 Google Chrome 程序文件失败！", 0, $hSettingsGUI)
		Return SetError(1, "", 0) ; 解压错误
	EndIf

	; 复制程序文件
	WaitChromeClose($ChromePath, "请关闭 Google Chrome 浏览器以便完成更新！") ;~ 等待 chrome 浏览器关闭
	DirCopy($TempDir & "\Chrome-bin\" & $latest, $ChromeDir, 1)
	DirRemove($TempDir & "\Chrome-bin\" & $latest, 1)
	DirCopy($TempDir & "\Chrome-bin", $ChromeDir, 1)
	Local $chromedll = $ChromeDir & "\chrome.dll"
	$ChromeFileVersion = FileGetVersion($chromedll, "FileVersion")
	$ChromeLastChange = FileGetVersion($chromedll, "LastChange")
	If IsHWnd($hSettingsGUI) Then
		GUICtrlSetData($hCurrentVer, $ChromeFileVersion & "  " & $ChromeLastChange)
	EndIf

	If $ChromeFileVersion <> $latest Then
		MsgBox(64, "更新错误-MyChrome", "复制 Google Chrome 程序文件失败！", 0, $hSettingsGUI)
		Return SetError(2, "", 0)
	Else
		; 如果设定的chrome程序文件路径不以chrome.exe结尾，则认为使用者将其改名，将chrome.exe重命名为设定的文件名
		If StringRight($ChromePath, 10) <> "chrome.exe" Then
			FileMove($ChromeDir & "\chrome.exe", $ChromePath, 1)
		EndIf
		MsgBox(64, "MyChrome", "Google Chrome 浏览器已更新至 " & $ChromeFileVersion & " (" & $ChromeLastChange & ") !", 0, $hSettingsGUI)
		Return SetError(0, "", $ChromeFileVersion) ; 返回版本号
	EndIf
EndFunc   ;==>InstallChrome

;~ 显示托盘气泡提示
Func TrayTipProgress()
	$TrayTipProgress = 1
EndFunc   ;==>TrayTipProgress

;~ 退出更新，清理临时文件，恢复状态
Func EndUpdate()
	Local $i
	If ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf

	; 检查是否有另一个 MyChrome 进程正在更新 Chrome，
	If Not ChromeIsUpdating($ChromeDir) Then
		Local $TempDir = $ChromeDir & "\~Update"
		If FileExists($TempDir) Then
			FileDelete($TempDir & "\Update.ini")
			FileDelete($TempDir & "\7z.exe")
			FileDelete($TempDir & "\7z.dll")
			FileDelete($TempDir & "\chrome_installer.exe")
			FileDelete($TempDir & "\chrome.7z")
			DirRemove($TempDir & "\Chrome-bin", 1)
			DirRemove($TempDir, 0) ; 如果此文件夹中没有其它文件则删除
		EndIf
	EndIf

	If IsHWnd($hSettingsGUI) Then
		GUICtrlSetData($hCheckUpdate, "立即更新")
		GUICtrlSetTip($hCheckUpdate, "检查浏览器更新" & @CRLF & "下载最新版至 chrome 程序文件夹")
		GUICtrlSetState($hSettingsOK, $GUI_ENABLE)
		GUICtrlSetState($hSettingsApply, $GUI_ENABLE)
		_GUICtrlStatusBar_SetText($hStausbar, '双击软件目录下的 "' & $AppName & '设置.vbs" 文件可调出此窗口')
	EndIf
	$IsUpdating = 0
EndFunc   ;==>EndUpdate

; 退出前检查是否在更新
Func ExitApp()
	If $IsUpdating Then
		Local $msg = MsgBox(292, "MyChrome", "正在更新浏览器，确定要退出吗？", 0, $hSettingsGUI)
		If $msg = 7 Then Return
		EndUpdate()
	ElseIf ProcessExists($iThreadPid) Then
		_KillThread($iThreadPid)
	EndIf
	Exit
EndFunc   ;==>ExitApp

;~ 绝对路径转成相对路径（如果可以）
Func RelativePath($path)
	If StringLeft($path, 1) <> "%" Then
		If StringInStr($path, @ScriptDir) = 1 Then
			$path = StringReplace($path, @ScriptDir, "", 1)
			If StringLeft($path, 1) = "\" Then $path = StringTrimLeft($path, 1)
		EndIf
	EndIf
	If StringRight($path, 1) = "\" Then $path = StringTrimRight($path, 1)
	Return $path
EndFunc   ;==>RelativePath

;~ 相对路径转换成绝对路径
Func AbsolutePath($path)
	If StringRight($path, 1) = "\" Then $path = StringTrimRight($path, 1)
	If StringLeft($path, 1) <> "%" Then ; relative path
		If Not StringInStr($path, ":") And StringLeft($path, 2) <> "\\" Then
			$path = @ScriptDir & "\" & $path
		EndIf
	EndIf
	Return $path
EndFunc   ;==>AbsolutePath


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
		$dir = ""
		$file = $path
	Else
		$dir = StringLeft($path, $pos - 1)
		$file = StringMid($path, $pos + 1)
	EndIf
EndFunc   ;==>SplitPath


;~ 判断是否有另一个 MyChrome 进程正在更新当前的 chrome
;~ 本程序是否正在更新 chrome 由 $IsUpdating 判断
Func ChromeIsUpdating($dir)
	Local $UpdateIni = $dir & "\~Update\Update.ini"
	If Not FileExists($UpdateIni) Then Return

	Local $pid = IniRead($UpdateIni, "general", "pid", "")
	Local $exe = IniRead($UpdateIni, "general", "exe", "")
	If $pid <> $iThreadPid And ProcessExists($pid) And ProcessExists($exe) Then
		Return 1
	EndIf
EndFunc   ;==>ChromeIsUpdating

;~ 判断数据文件夹是否正在使用中，返回使用数据文件夹的 chrome.exe 的完整路径
;~ 参考: http://www.autoitscript.com/forum/topic/70538-processlistproperties/
Func UserDataInUse($DataDir)
	Local $file = $DataDir & "\Default\Current Session"
	If Not FileExists($file) Or FileMove($file, $file, 1) Then Return "" ; 不在使用中

	Local $path = "chrome.exe"
	Local $objWMIService = ObjGet("winmgmts:\\localhost\root\CIMV2")
	If @error Then Return SetError(-1, 0, "")
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Process")
	If Not IsObj($colItems) Then Return SetError(-2, 0, "")
	For $objItem In $colItems
		If $objItem.CommandLine = '' Or StringLeft($objItem.CommandLine, 1) = '\' Then ContinueLoop

		If StringInStr($objItem.CommandLine, $DataDir) Then
			$path = $objItem.ExecutablePath
			ExitLoop
		EndIf
	Next
	Return $path
EndFunc   ;==>UserDataInUse


;~ 等待 chrome 浏览器关闭
Func WaitChromeClose($App = "chrome.exe", $msg = "请关闭 Google Chrome 浏览器后继续！")
	Local $exe = StringRegExpReplace($App, '.*\\+', '')
	Local $list, $AppIsRunning, $pid, $i
	Dim $hSettingsGUI

	While 1
		; 检测是否有 chrome 进程正在运行
		$AppIsRunning = 0
		$list = ProcessList($exe)
		For $i = 1 To $list[0][0]
			If StringInStr(_GetProcPath($list[$i][1]), $App) Then
				$AppIsRunning = 1
				ExitLoop
			EndIf
		Next
		If Not $AppIsRunning Then Return
		MsgBox(48, 'MyChrome', $msg & @CRLF & @CRLF & '提示：点击"确定"自动关闭浏览器。', 0, $hSettingsGUI)

		; 检查chrome浏览器是否关闭，若未关闭则自动关闭
		$list = WinList("[CLASS:Chrome_WidgetWin_0]")
		For $i = 1 To $list[0][0]
			$pid = WinGetProcess($list[$i][1])
			If StringInStr(_GetProcPath($pid), $App) Then
				WinClose($list[$i][1])
				WinWaitClose($list[$i][1], "", 2)
			EndIf
		Next

		; 检查是否还有后台运行的chrome进程，若有则强制关闭
		$list = ProcessList($exe)
		For $i = 1 To $list[0][0]
			If StringInStr(_GetProcPath($list[$i][1]), $App) Then
				ProcessClose($list[$i][1])
			EndIf
		Next
	WEnd
EndFunc   ;==>WaitChromeClose

; #FUNCTION# ;===============================================================================
; 参考 http://www.autoitscript.com/forum/topic/63947-read-full-exe-path-of-a-known-windowprogram/
; Name...........: _GetProcPath
; Description ...: 取得进程路径
; Syntax.........: _GetProcPath($Process_PID)
; Parameters ....: $Process_PID - 进程的 pid
; Return values .: Success - 完整路径
;                  Failure - set @error
;============================================================================================
Func _GetProcPath($pid)
	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', BitOR(0x0400, 0x0010), 'int', 0, 'dword', $pid)
	If (@error) Or (Not $hProcess[0]) Then Return SetError(1, 0, '')
	Local $ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetModuleFileNameExW', 'ptr', $hProcess[0], 'ptr', 0, 'wstr', '', 'int', 1024)
	If (@error) Or (Not $ret[0]) Then Return SetError(1, 0, '')
	Return $ret[3]
EndFunc   ;==>_GetProcPath

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
	If @error Then Return SetError(1, "", $aResults)
	$aResults[0] = $match[0] ; host
	$aResults[1] = $match[1] ; page
	If $aResults[1] = "" Then $aResults[1] = "/"
	If StringLeft($url, 5) = "https" Then
		$aResults[2] = 443
	Else
		$aResults[2] = 80
	EndIf
	Return SetError(0, "", $aResults)
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
