#include-once
#include "WinAPI.au3"
#include "AutoItConstants.au3"

#cs
Global Const $ROLE_SYSTEM_TITLEBAR           = 0x1
Global Const $ROLE_SYSTEM_MENUBAR            = 0x2
Global Const $ROLE_SYSTEM_SCROLLBAR          = 0x3
Global Const $ROLE_SYSTEM_GRIP               = 0x4
Global Const $ROLE_SYSTEM_SOUND              = 0x5
Global Const $ROLE_SYSTEM_CURSOR             = 0x6
Global Const $ROLE_SYSTEM_CARET              = 0x7
Global Const $ROLE_SYSTEM_ALERT              = 0x8
Global Const $ROLE_SYSTEM_WINDOW             = 0x9
Global Const $ROLE_SYSTEM_CLIENT             = 0xa
Global Const $ROLE_SYSTEM_MENUPOPUP          = 0xb
Global Const $ROLE_SYSTEM_MENUITEM           = 0xc
Global Const $ROLE_SYSTEM_TOOLTIP            = 0xd
Global Const $ROLE_SYSTEM_APPLICATION        = 0xe
Global Const $ROLE_SYSTEM_DOCUMENT           = 0xf
Global Const $ROLE_SYSTEM_PANE               = 0x10
Global Const $ROLE_SYSTEM_CHART              = 0x11
Global Const $ROLE_SYSTEM_DIALOG             = 0x12
Global Const $ROLE_SYSTEM_BORDER             = 0x13
Global Const $ROLE_SYSTEM_GROUPING           = 0x14
Global Const $ROLE_SYSTEM_SEPARATOR          = 0x15
Global Const $ROLE_SYSTEM_TOOLBAR            = 0x16
Global Const $ROLE_SYSTEM_STATUSBAR          = 0x17
Global Const $ROLE_SYSTEM_TABLE              = 0x18
Global Const $ROLE_SYSTEM_COLUMNHEADER       = 0x19
Global Const $ROLE_SYSTEM_ROWHEADER          = 0x1a
Global Const $ROLE_SYSTEM_COLUMN             = 0x1b
Global Const $ROLE_SYSTEM_ROW                = 0x1c
Global Const $ROLE_SYSTEM_CELL               = 0x1d
Global Const $ROLE_SYSTEM_LINK               = 0x1e
Global Const $ROLE_SYSTEM_HELPBALLOON        = 0x1f
Global Const $ROLE_SYSTEM_CHARACTER          = 0x20
Global Const $ROLE_SYSTEM_LIST               = 0x21
Global Const $ROLE_SYSTEM_LISTITEM           = 0x22
Global Const $ROLE_SYSTEM_OUTLINE            = 0x23
Global Const $ROLE_SYSTEM_OUTLINEITEM        = 0x24
Global Const $ROLE_SYSTEM_PAGETAB            = 0x25
Global Const $ROLE_SYSTEM_PROPERTYPAGE       = 0x26
Global Const $ROLE_SYSTEM_INDICATOR          = 0x27
Global Const $ROLE_SYSTEM_GRAPHIC            = 0x28
Global Const $ROLE_SYSTEM_STATICTEXT         = 0x29
Global Const $ROLE_SYSTEM_TEXT               = 0x2a
Global Const $ROLE_SYSTEM_PUSHBUTTON         = 0x2b
Global Const $ROLE_SYSTEM_CHECKBUTTON        = 0x2c
Global Const $ROLE_SYSTEM_RADIOBUTTON        = 0x2d
Global Const $ROLE_SYSTEM_COMBOBOX           = 0x2e
Global Const $ROLE_SYSTEM_DROPLIST           = 0x2f
Global Const $ROLE_SYSTEM_PROGRESSBAR        = 0x30
Global Const $ROLE_SYSTEM_DIAL               = 0x31
Global Const $ROLE_SYSTEM_HOTKEYFIELD        = 0x32
Global Const $ROLE_SYSTEM_SLIDER             = 0x33
Global Const $ROLE_SYSTEM_SPINBUTTON         = 0x34
Global Const $ROLE_SYSTEM_DIAGRAM            = 0x35
Global Const $ROLE_SYSTEM_ANIMATION          = 0x36
Global Const $ROLE_SYSTEM_EQUATION           = 0x37
Global Const $ROLE_SYSTEM_BUTTONDROPDOWN     = 0x38
Global Const $ROLE_SYSTEM_BUTTONMENU         = 0x39
Global Const $ROLE_SYSTEM_BUTTONDROPDOWNGRID = 0x3a
Global Const $ROLE_SYSTEM_WHITESPACE         = 0x3b
Global Const $ROLE_SYSTEM_PAGETABLIST        = 0x3c
Global Const $ROLE_SYSTEM_CLOCK              = 0x3d
Global Const $ROLE_SYSTEM_SPLITBUTTON        = 0x3e
Global Const $ROLE_SYSTEM_IPADDRESS          = 0x3f
Global Const $ROLE_SYSTEM_OUTLINEBUTTON      = 0x40
#ce

Global Const $ROLE_SYSTEM_CLIENT             = 0xa
Global Const $ROLE_SYSTEM_PAGETAB            = 0x25
Global Const $ROLE_SYSTEM_STATICTEXT         = 0x29
Global Const $ROLE_SYSTEM_TEXT               = 0x2a
Global Const $ROLE_SYSTEM_PUSHBUTTON         = 0x2b
Global Const $ROLE_SYSTEM_PAGETABLIST        = 0x3c


Global Const $sIID_IAccessible="{618736E0-3C3D-11CF-810C-00AA00389B71}"
Global Const $dtagIAccessible = "QueryInterface;" & _
"AddRef;" & _
"Release;" & _ ; IUnknown
"GetTypeInfoCount hresult(uint*);" & _ ; IDispatch
"GetTypeInfo hresult(uint;int;ptr*);" & _
"GetIDsOfNames hresult(struct*;wstr;uint;int;int);" & _
"Invoke hresult(int;struct*;int;word;ptr*;ptr*;ptr*;uint*);" & _
"get_accParent hresult(ptr*);" & _                               ; IAccessible
"get_accChildCount hresult(long*);" & _
"get_accChild hresult(variant;idispatch*);" & _
"get_accName hresult(variant;bstr*);" & _
"get_accValue hresult(variant;bstr*);" & _
"get_accDescription hresult(variant;bstr*);" & _
"get_accRole hresult(variant;variant*);" & _
"get_accState hresult(variant;variant*);" & _
"get_accHelp hresult(variant;bstr*);" & _
"get_accHelpTopic hresult(bstr*;variant;long*);" & _
"get_accKeyboardShortcut hresult(variant;bstr*);" & _
"get_accFocus hresult(struct*);" & _
"get_accSelection hresult(variant*);" & _
"get_accDefaultAction hresult(variant;bstr*);" & _
"accSelect hresult(long;variant);" & _
"accLocation hresult(long*;long*;long*;long*;variant);" & _
"accNavigate hresult(long;variant;variant*);" & _
"accHitTest hresult(long;long;variant*);" & _
"accDoDefaultAction hresult(variant);" & _
"put_accName hresult(variant;bstr);" & _
"put_accValue hresult(variant;bstr);"

;Global Const $tagVARIANT = "ushort vt;ushort r1;ushort r2;ushort r3;uint64 data"
;Global $tagVariant = "USHORT vt;WORD r1;WORD r2;WORD r3;byte union[8]"
;Global Const $tagVARIANT = "word vt;word r1;word r2;word r3;int_ptr data;int_ptr;"
If @AutoItX64 Then
	Global $tagVARIANT = "dword[6];" ; Use this form to be able to build an
Else                                 ; array in function AccessibleChildren.
	Global $tagVARIANT = "dword[4];"
EndIf
Global $hdllOleacc

Func AccessibleIni()
	$hdllOleacc = DllOpen("oleacc.dll")
	DllCall($hdllOleacc, "long", "CoInitializeEx", "ptr", 0, "dword", 2)
	OnAutoItExitRegister("AccessibleExit")
EndFunc

Func AccessibleExit()
	;DllCall("ole32.dll", "none", "CoUninitialize")
	DllClose($hdllOleacc)
EndFunc


Func AccessibleParent($oAcc, $iRole, $iLevel)
    If Not IsObj($oAcc) Then Return

	Local $pAcc, $sName, $Role
	For $i = 1 To $iLevel
		$oAcc.get_accParent($pAcc)
		$oAcc = ObjCreateInterface($pAcc, $sIID_IAccessible, $dtagIAccessible)
		If Not IsObj($oAcc) Then Return

		$oAcc.AddRef()
		;$oAcc.get_accName(0, $sName )
		$oAcc.get_accRole(0, $Role)
		If $Role = $iRole Then
			Dim $oP = [$pAcc, $oAcc]
			Return $oP
		EndIf
	Next
EndFunc


Func AccessibleChildren($pAcc, $oAcc, $Role, $iLevel = 0, $iLevels = 1)
	If $iLevel >= $iLevels Then Return

	If Not IsObj($oAcc) Then Return
	$oAcc.AddRef()

	Local $iChildCount, $iReturnCount, $tVarChildren
	If $oAcc.get_accChildCount($iChildCount) Or Not $iChildCount Then
		Return
	EndIf
	Local $sVarArray = ""
	For $i = 1 To $iChildCount
		$sVarArray &= $tagVARIANT
	Next
	$tVarChildren = DllStructCreate($sVarArray)
	Local $aRet = DllCall($hdllOleacc, "int", "AccessibleChildren", _
			"ptr", $pAcc, _
			"int", 0, _
			"int", $iChildCount, _
			"struct*", $tVarChildren, _
			"int*", 0 )

	If @error Or $aRet[0] Then Return
	$iReturnCount = $aRet[5]

	Local $vt, $pChild, $oChild, $iRole, $aChilden[2]
	Local $VT_DISPATCH = 9
	For $i = 1 To $iReturnCount
		; $tVarChildren is an array of VARIANTs with information about the children
		$vt = BitAND(DllStructGetData($tVarChildren, $i, 1), 0xFFFF)
		If $vt <> $VT_DISPATCH Then ContinueLoop

		$pChild = DllStructGetData($tVarChildren, $i, 3)
		$oChild = ObjCreateInterface($pChild, $sIID_IAccessible, $dtagIAccessible)
		If Not IsObj($oChild) Then Return

		$oChild.AddRef()
		If $oChild.get_accRole(0, $iRole) <> 0 Then Return
		If $iRole = $Role Then
			$aChilden[0] = $pChild
			$aChilden[1] = $oChild
			Return $aChilden

		ElseIf ($iLevel+1) < $iLevels And _
				($iRole = $ROLE_SYSTEM_PAGETAB Or $iRole = $ROLE_SYSTEM_PAGETABLIST Or $iRole = $ROLE_SYSTEM_CLIENT) Then

			$arr = AccessibleChildren($pChild, $oChild, $Role, $iLevel + 1, $iLevels)
			If IsArray($arr) Then Return $arr

		EndIf
	Next
EndFunc   ;==>AccessibleChildren

Func AccessibleObjectFromPoint($x, $y, ByRef $pAccessible, ByRef $tVarChild)
	Local $tPOINT = DllStructCreate("long;long")
	DllStructSetData($tPOINT, 1, $x)
	DllStructSetData($tPOINT, 2, $y)
	Local $tPOINT64 = DllStructCreate("int64", DllStructGetPtr( $tPOINT))
	Local $tVARIANT = DllStructCreate($tagVARIANT)
	Local $aRet = DllCall($hdllOleacc, "int", "AccessibleObjectFromPoint", _
			"int64", DllStructGetData($tPOINT64, 1), _
			"ptr*", 0, _
			"struct*", $tVARIANT)
	If @error Or $aRet[0] Then Return SetError(1)
	$pAccessible = $aRet[2]
	$tVarChild = $aRet[3]
	Return 1
EndFunc

Func AccessibleObjectFromWindow($hWnd)
	Local Const $OBJID_CLIENT = 0xFFFFFFFC
	Local Static $tIID_IAccessible = _WinAPI_GUIDFromString($sIID_IAccessible)
	Local $aRet = DllCall($hdllOleacc, "int", "AccessibleObjectFromWindow", _
			"hwnd", $hWnd, _
			"dword", $OBJID_CLIENT, _
			"struct*", $tIID_IAccessible, _
			"int*", 0)
	If @error Or $aRet[0] Then Return SetError(1)
	Return $aRet[4]
EndFunc

Func GetRoleText( $iRole, $sRole, $iRoleMax )
	Local $aRet = DllCall( $hdllOleacc, "uint", "GetRoleTextW", "dword", $iRole, "ptr", $sRole, "uint", $iRoleMax )
	If @error Then Return SetError(1, 0, 0)
	If Not $aRet[0] Then Return SetError(2, 0, 0)
	Return $aRet[0]
EndFunc