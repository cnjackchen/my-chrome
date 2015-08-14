#NoTrayIcon
Global $__hwnd_vars

If $cmdline[0] > 0 And $cmdline[1] = "child_thread_by" Then
	;MsgBox(0, "$CmdLineRaw", $CmdLineRaw )
	$__hwnd_vars = HWnd($cmdline[2])
	Local $i, $p = ""
	For $i = 4 To $cmdline[0]
		$p &= '"' & $cmdline[$i] & '",'
	Next
	$p = StringTrimRight($p, 1)
	Execute($cmdline[3] & '(' & $p & ')')
	Exit
EndIf

$__hwnd_vars = GUICreate("main thread")
GUICtrlCreateEdit("", 0, 0, 350)
;~ GUISetState(@SW_SHOW)

Func _StartThread($exe, $function, $p1 = "", $p2 = "", $p3 = "", $p4 = "", $p5 = "", $p6 = "", $p7 = "", $p8 = "", $p9 = "", $p10 = "")
	Local $i, $p, $para
	For $i = 1 to 10
		$p = Eval("p" & $i)
		If StringInStr($p, " ") Then ; 带空格的参数加上引号
			$p = '"' & $p & '"'
		EndIf
		$para &= ' ' & $p
	Next
	$para = StringStripWS($para, 3)

	If $exe == @ScriptFullPath Or $exe == @ScriptName Then
		If @Compiled Then
			Return Run('"' & @AutoItExe & '" child_thread_by ' & $__hwnd_vars & ' ' & $function & ' ' & $para)
		Else
			Return Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" child_thread_by ' & $__hwnd_vars & ' ' & $function & ' ' & $para)
		EndIf
	ElseIf FileExists($exe) Then
		Return ShellExecute($exe, ' child_thread_by ' & $__hwnd_vars & ' ' & $function & ' ' & $para, "", "open", @SW_HIDE)
	EndIf
EndFunc

Func _KillThread($thread)
	If $thread And ProcessExists($thread) Then
		Run(@ComSpec & ' /c taskkill /PID ' & $thread & ' /T /F', '', @SW_HIDE)
		Return SetError(Not ProcessExists($thread))
	EndIf
EndFunc

Func _SetVar($var, $it = "")
	Local $text = ControlGetText($__hwnd_vars, "", "Edit1")
	$text = StringRegExpReplace($text, "(?i)(?m)^" & $var & "=.*$", $var & "=" & $it)
	If Not @extended Then
		$text &=  @CRLF & $var & "=" & $it
	EndIf
	ControlSetText($__hwnd_vars, "", "Edit1", $text)
EndFunc

Func _GetVar($var)
	Local $text = ControlGetText($__hwnd_vars, "", "Edit1")
	Local $match = StringRegExp($text, "(?i)(?m)^" & $var & "=(.*)$", 1)
	If Not @error Then
		Return SetError(0, 0, $match[0])
	Else
		Return SetError(1, 0, "")
	EndIf
EndFunc