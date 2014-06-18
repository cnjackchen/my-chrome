#cs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  SMT - Simple Multi Threading  ;;;
;;;;;;;;;  By NoCow AKA Mea  ;;;;;;;;;
;;;;;;;;;  Revised by Jack Chen  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        Functions


        _CreateThread("Function", "Param1", "Param2", ...)
        Creates a new thread of a function in the script
                Return: $PID of the new thread

        _KillThread($PID)
        Destroy the target Thread
                Return: 1 for success. 0 for failed

        _SetVar("var","value")
        Set Global var to the value, Can be get with _GetVar()

        _GetVar("var")
        Get a variable set by _SetVar()


        Examples
;=========================================================================================================
;  move the mouse random to 1-500,1-500 and sleep 10secounds for show its multitasking
;=========================================================================================================
#include "SimpleMultiThreading.au3"                              ; Include the multithreaded libary maded by Mea(Aka NoCow)
$pid = _CreateThread("hookmouse")               ; Start new thread with the function hookmouse()
Sleep(10000)                                    ; Sleep in 10secounds
_KillThread($pid)                               ; Close the thread hookmouse()


Func hookmouse()                                ; Function hookmouse() start
        While 1
                MouseMove(Random(1,500),Random(1,500))  ; Move Mouse random on the screen
        WEnd
EndFunc                                         ; Function hookmouse() end
;=========================================================================================================


;=========================================================================================================
;  Tooltip every 50milisecounds the variable text on 0,0 while change it every 4secound
;  For then force the thread to close
;=========================================================================================================
#include "SimpleMultiThreading.au3"
_SetVar("text","hello with a foo in a boo")
$pid = _CreateThread("showtooltip")
Sleep(4000)
_SetVar("text","lol this is too easy")
Sleep(4000)
_SetVar("text",InputBox("What you want to our tooltip message?","Text: "))
Sleep(10000)
_KillThread($pid)

Func showtooltip()
        While 1
                ToolTip(_GetVar("text"),0,0)
                Sleep(50)
        WEnd
EndFunc
;=========================================================================================================
#ce

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

$__hwnd_vars = GUICreate("threaded by mea")
GUICtrlCreateEdit("", 0, 0)

Func _StartThread($function, $p1 = "", $p2 = "", $p3 = "", $p4 = "", $p5 = "", $p6 = "", $p7 = "", $p8 = "", $p9 = "", $p10 = "")
	Local $i, $p, $para
	For $i = 1 to 10
		$p = Eval("p" & $i)
		If StringInStr($p, " ") Then ; 带空格的参数加上引号
			$p = '"' & $p & '"'
		EndIf
		$para &= ' ' & $p
	Next
	$para = StringStripWS($para, 3)
	If @Compiled Then
		Return Run('"' & @AutoItExe & '" child_thread_by ' & $__hwnd_vars & ' ' & $function & ' ' & $para)
	Else
		Return Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" child_thread_by ' & $__hwnd_vars & ' ' & $function & ' ' & $para)
	EndIf
EndFunc

Func _KillThread($thread)
	Local $i
	For $i = 1 To 3
		ProcessClose($thread)
		Sleep(50)
		If Not ProcessExists($thread) Then ExitLoop
	Next
	Return SetError(Not ProcessExists($thread))
EndFunc

Func _SetVar($var, $it = "")
	Local $text = ControlGetText($__hwnd_vars, "", "Edit1")
	$text = StringRegExpReplace($text, "(?i)(?m)^" & $var & " .*$", $var & " " & $it)
	If Not @extended Then
		$text &=  @CRLF & $var & " " & $it
	EndIf
	ControlSetText($__hwnd_vars, "", "Edit1", $text)
EndFunc

Func _GetVar($var)
	Local $text = ControlGetText($__hwnd_vars, "", "Edit1")
	Local $match = StringRegExp($text, "(?i)(?m)^" & $var & " (.*)$", 1)
	If Not @error Then
		Return SetError(0, 0, $match[0])
	Else
		Return SetError(1, 0, "")
	EndIf
EndFunc