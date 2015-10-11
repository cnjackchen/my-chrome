#include-once
;https://www.autoitscript.com/forum/topic/174460-is-there-a-way-to-detect-any-sound-file-played/
;Danyfirex 02/08/2015
#include <WinAPIProc.au3>

Global Const $sCLSID_MMDeviceEnumerator = "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
Global Const $sIID_IMMDeviceEnumerator = "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
Global Const $sTagIMMDeviceEnumerator = _
		"EnumAudioEndpoints hresult(int;dword;ptr*);" & _
		"GetDefaultAudioEndpoint hresult(int;int;ptr*);" & _
		"GetDevice hresult(wstr;ptr*);" & _
		"RegisterEndpointNotificationCallback hresult(ptr);" & _
		"UnregisterEndpointNotificationCallback hresult(ptr)"

Global Const $sIID_IMMDevice = "{D666063F-1587-4E43-81F1-B948E807363F}"
Global Const $sTagIMMDevice = _
		"Activate hresult(struct*;dword;ptr;ptr*);" & _
		"OpenPropertyStore hresult(dword;ptr*);" & _
		"GetId hresult(wstr*);" & _
		"GetState hresult(dword*)"

Global Const $sIID_IAudioSessionManager2 = "{77aa99a0-1bd6-484f-8bc7-2c654c9a9b6f}"
Global Const $sTagIAudioSessionManager = "GetAudioSessionControl hresult(ptr;dword;ptr*);" & _
		"GetSimpleAudioVolume hresult(ptr;dword;ptr*);"
Global Const $sTagIAudioSessionManager2 = $sTagIAudioSessionManager & "GetSessionEnumerator hresult(ptr*);" & _
		"RegisterSessionNotification hresult(ptr);" & _
		"UnregisterSessionNotification hresult(ptr);" & _
		"RegisterDuckNotification hresult(wstr;ptr);" & _
		"UnregisterDuckNotification hresult(ptr)"

Global Const $sIID_IAudioSessionEnumerator = "{e2f5bb11-0570-40ca-acdd-3aa01277dee8}"
Global Const $sTagIAudioSessionEnumerator = "GetCount hresult(int*);GetSession hresult(int;ptr*)"

Global Const $sIID_IAudioSessionControl = "{f4b1a599-7266-4319-a8ca-e70acb11e8cd}"
Global Const $sTagIAudioSessionControl = "GetState hresult(int*);GetDisplayName hresult(ptr);" & _
		"SetDisplayName hresult(wstr);GetIconPath hresult(ptr);" & _
		"SetIconPath hresult(wstr;ptr);GetGroupingParam hresult(ptr*);" & _
		"SetGroupingParam hresult(ptr;ptr);RegisterAudioSessionNotification hresult(ptr);" & _
		"UnregisterAudioSessionNotification hresult(ptr);"

Global Const $sIID_IAudioSessionControl2 = "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
Global Const $sTagIAudioSessionControl2 = $sTagIAudioSessionControl & "GetSessionIdentifier hresult(ptr)" & _
		"GetSessionInstanceIdentifier hresult(ptr);" & _
		"GetProcessId hresult(dword*);IsSystemSoundsSession hresult();" & _
		"SetDuckingPreferences hresult(bool);"

; http://answers.awesomium.com/questions/3398/controlling-the-sound-using-pinvoke-the-volume-mix.html
Global Const $sIID_ISimpleAudioVolume = "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"
Global Const $sTagISimpleAudioVolume = _
		"SetMasterVolume hresult(float;ptr);" & _
		"GetMasterVolume hresult(float*);" & _
		"SetMute hresult(int;ptr);" & _
		"GetMute hresult(int*)"

Global $__oIAudioSessionManager2

;Audio_SetAppMute("chrome.exe", 1) ; Mute Chrome


Func Audio_GetAppMute($pid)
	If Not IsObj($__oIAudioSessionManager2) Then
		$__oIAudioSessionManager2 = Audio_GetIAudioSessionManager2()
	EndIf
	If Not IsObj($__oIAudioSessionManager2) Then Return

	Local $pIAudioSessionEnumerator, $oIAudioSessionEnumerator
	If $__oIAudioSessionManager2.GetSessionEnumerator($pIAudioSessionEnumerator) < 0 Then Return
	$oIAudioSessionEnumerator = ObjCreateInterface($pIAudioSessionEnumerator, $sIID_IAudioSessionEnumerator, $sTagIAudioSessionEnumerator)
	If Not IsObj($oIAudioSessionEnumerator) Then Return SetError(1)

	Local $i, $nSessions, $pIAudioSessionControl2, $oIAudioSessionControl2
	Local $ProcessID, $oISimpleAudioVolume
	Local $bMute = 0, $error = 1
	If $oIAudioSessionEnumerator.GetCount($nSessions) >= 0 Then
		For $i = 0 To $nSessions - 1
			If $oIAudioSessionEnumerator.GetSession($i, $pIAudioSessionControl2) >= 0 Then
				$oIAudioSessionControl2 = ObjCreateInterface($pIAudioSessionControl2, $sIID_IAudioSessionControl2, $sTagIAudioSessionControl2)
				If @error Then ContinueLoop
				$oIAudioSessionControl2.GetProcessId($ProcessID)
				If $ProcessID = $pid Then
					$oISimpleAudioVolume = ObjCreateInterface($pIAudioSessionControl2, $sIID_ISimpleAudioVolume, $sTagISimpleAudioVolume)
					If @error Then ContinueLoop
					$oIAudioSessionControl2.AddRef() ;stabilize
					If $oISimpleAudioVolume.GetMute($bMute) >= 0 Then
						$error = 0
						ExitLoop
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	$oISimpleAudioVolume = 0
	$oIAudioSessionControl2 = 0
	$oIAudioSessionEnumerator = 0
	;MsgBox(0, $error, "App muted: " & $bMute)
	Return SetError($error, 0, $bMute)
EndFunc   ;==>Audio_GetAppMute

Func Audio_SetAppMute($pid, $bMute = 0)
	If Not IsObj($__oIAudioSessionManager2) Then
		$__oIAudioSessionManager2 = Audio_GetIAudioSessionManager2()
	EndIf
	If Not IsObj($__oIAudioSessionManager2) Then Return

	Local $pIAudioSessionEnumerator, $oIAudioSessionEnumerator
	If $__oIAudioSessionManager2.GetSessionEnumerator($pIAudioSessionEnumerator) < 0 Then Return
	$oIAudioSessionEnumerator = ObjCreateInterface($pIAudioSessionEnumerator, $sIID_IAudioSessionEnumerator, $sTagIAudioSessionEnumerator)
	If Not IsObj($oIAudioSessionEnumerator) Then Return SetError(1)

	Local $i, $nSessions, $pIAudioSessionControl2, $oIAudioSessionControl2
	Local $ProcessID, $oISimpleAudioVolume, $ok = 0
	If $oIAudioSessionEnumerator.GetCount($nSessions) >= 0 Then
		For $i = 0 To $nSessions - 1
			If $oIAudioSessionEnumerator.GetSession($i, $pIAudioSessionControl2) >= 0 Then
				$oIAudioSessionControl2 = ObjCreateInterface($pIAudioSessionControl2, $sIID_IAudioSessionControl2, $sTagIAudioSessionControl2)
				If @error Then ContinueLoop
				$oIAudioSessionControl2.GetProcessId($ProcessID)
				If $ProcessID = $pid Then
					$oISimpleAudioVolume = ObjCreateInterface($pIAudioSessionControl2, $sIID_ISimpleAudioVolume, $sTagISimpleAudioVolume)
					If @error Then ContinueLoop
					$oIAudioSessionControl2.AddRef() ;stabilize
					If $oISimpleAudioVolume.SetMute($bMute, 0) >= 0 Then
						$ok = 1
						ExitLoop
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	$oISimpleAudioVolume = 0
	$oIAudioSessionControl2 = 0
	$oIAudioSessionEnumerator = 0
	Return $ok
EndFunc   ;==>Audio_SetAppMute

Func Audio_GetIAudioSessionManager2()
	Local $oIAudioSessionManager2 = 0
	Local Const $eMultimedia = 1, $CLSCTX_INPROC_SERVER = 0x01
	Local $pIMMDevice, $oMMDevice, $pIAudioSessionManager2
	Local $oMMDeviceEnumerator = ObjCreateInterface($sCLSID_MMDeviceEnumerator, $sIID_IMMDeviceEnumerator, $sTagIMMDeviceEnumerator)
	If IsObj($oMMDeviceEnumerator) Then
		If $oMMDeviceEnumerator.GetDefaultAudioEndpoint(0, $eMultimedia, $pIMMDevice) >= 0 Then
			$oMMDevice = ObjCreateInterface($pIMMDevice, $sIID_IMMDevice, $sTagIMMDevice)
			If IsObj($oMMDevice) Then
				If $oMMDevice.Activate(__uuidof($sIID_IAudioSessionManager2), $CLSCTX_INPROC_SERVER, 0, $pIAudioSessionManager2) >= 0 Then
					$oIAudioSessionManager2 = ObjCreateInterface($pIAudioSessionManager2, $sIID_IAudioSessionManager2, $sTagIAudioSessionManager2)
				EndIf
				$oMMDevice = 0
			EndIf
		EndIf
		$oMMDeviceEnumerator = 0
	EndIf

	If IsObj($oIAudioSessionManager2) Then
		Return $oIAudioSessionManager2
	EndIf
EndFunc   ;==>Audio_GetIAudioSessionManager2

Func __uuidof($sGUID)
	Local $tGUID = DllStructCreate("ulong Data1;ushort Data2;ushort Data3;byte Data4[8]")
	DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $tGUID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tGUID
EndFunc   ;==>__uuidof

Func CLSIDFromString($sGUID)
	Local $tGUID = DllStructCreate("ulong Data1;ushort Data2;ushort Data3;byte Data4[8]")
	DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $tGUID)
	Return $tGUID
EndFunc   ;==>CLSIDFromString