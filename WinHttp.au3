#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include-once
#include "WinHttpConstants.au3"

; #INDEX# ===================================================================================
; Title ...............: WinHttp
; File Name............: WinHttp.au3
; File Version.........: 1.6.2.5
; Min. AutoIt Version..: v3.3.2.0
; Description .........: AutoIt wrapper for WinHttp functions
; Author... ...........: trancexx, ProgAndy
; Dll .................: winhttp.dll, kernel32.dll
; ===========================================================================================

; #CONSTANTS# ===============================================================================
Global Const $hWINHTTPDLL__WINHTTP = DllOpen("winhttp.dll")
DllOpen("winhttp.dll") ; making sure reference count never reaches 0
;============================================================================================

; #CURRENT# =================================================================================
;_WinHttpAddRequestHeaders
;_WinHttpBinaryConcat
;_WinHttpCheckPlatform
;_WinHttpCloseHandle
;_WinHttpConnect
;_WinHttpCrackUrl
;_WinHttpCreateUrl
;_WinHttpDetectAutoProxyConfigUrl
;_WinHttpGetDefaultProxyConfiguration
;_WinHttpGetIEProxyConfigForCurrentUser
;_WinHttpOpen
;_WinHttpOpenRequest
;_WinHttpQueryDataAvailable
;_WinHttpQueryHeaders
;_WinHttpQueryOption
;_WinHttpReadData
;_WinHttpReceiveResponse
;_WinHttpSendRequest
;_WinHttpSetCredentials
;_WinHttpSetDefaultProxyConfiguration
;_WinHttpSetOption
;_WinHttpSetStatusCallback
;_WinHttpSetTimeouts
;_WinHttpSimpleFormFill
;_WinHttpSimpleReadData
;_WinHttpSimpleReadDataAsync
;_WinHttpSimpleRequest
;_WinHttpSimpleSendRequest
;_WinHttpSimpleSendSSLRequest
;_WinHttpSimpleSSLRequest
;_WinHttpTimeFromSystemTime
;_WinHttpTimeToSystemTime
;_WinHttpWriteData
; ===========================================================================================

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpAddRequestHeaders
; Description ...: Adds one or more HTTP request headers to the HTTP request handle.
; Syntax.........: _WinHttpAddRequestHeaders ($hRequest, $sHeaders [, $iModifiers = Default ])
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest function.
;                  $sHeader - [optional] Header(s) to append to the request.
;                  $iModifier - [optional] Contains the flags used to modify the semantics of this function. Default is $WINHTTP_ADDREQ_FLAG_ADD_IF_NEW.
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: In case of multiple additions at once, must use @CRLF to separate each $hRequest and responded $sHeaders and $iModifiers.
; Related .......: _WinHttpOpenRequest, _WinHttpQueryHeaders
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384087(VS.85).aspx
; Example .......: 3456
;============================================================================================
Func _WinHttpAddRequestHeaders($hRequest, $sHeader, $iModifier = Default)
	__WinHttpDefault($iModifier, $WINHTTP_ADDREQ_FLAG_ADD_IF_NEW)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpAddRequestHeaders", _
			"handle", $hRequest, _
			"wstr", $sHeader, _
			"dword", -1, _
			"dword", $iModifier)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpAddRequestHeaders

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpBinaryConcat
; Description ...: Concatenates two binary data returned by _WinHttpReadData() in binary mode.
; Syntax.........: _WinHttpBinaryConcat(ByRef $bBinary1, ByRef $bBinary2)
; Parameters ....: $bBinary1 - Binary data that is to be concatenated.
;                  $bBinary2 - Binary data to concatenate.
; Return values .: Success - Returns concatenated binary data.
;                  Failure - Returns empty binary and sets @error:
;                  |1 - Invalid input.
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......:
; Related .......: _WinHttpReadData
; Link ..........:
; Example .......:
;============================================================================================
Func _WinHttpBinaryConcat(ByRef $bBinary1, ByRef $bBinary2)
	Switch IsBinary($bBinary1) + 2 * IsBinary($bBinary2)
		Case 0
			Return SetError(1, 0, Binary(''))
		Case 1
			Return $bBinary1
		Case 2
			Return $bBinary2
	EndSwitch
	Local $tAuxiliary = DllStructCreate("byte[" & BinaryLen($bBinary1) & "];byte[" & BinaryLen($bBinary2) & "]")
	DllStructSetData($tAuxiliary, 1, $bBinary1)
	DllStructSetData($tAuxiliary, 2, $bBinary2)
	Local $tOutput = DllStructCreate("byte[" & DllStructGetSize($tAuxiliary) & "]", DllStructGetPtr($tAuxiliary))
	Return DllStructGetData($tOutput, 1)
EndFunc   ;==>_WinHttpBinaryConcat

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpCheckPlatform
; Description ...: Determines whether the current platform is supported by this version of Microsoft Windows HTTP Services (WinHTTP).
; Syntax.........: _WinHttpCheckPlatform()
; Parameters ....: None
; Return values .: Success - Returns 1 if current platform is supported
;                          - Returns 0 if current platform is not supported
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384089(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpCheckPlatform()
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpCheckPlatform")
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_WinHttpCheckPlatform

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpCloseHandle
; Description ...: Closes a single handle.
; Syntax.........: _WinHttpCloseHandle($hInternet)
; Parameters ....: $hInternet - Valid handle to be closed.
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpConnect, _WinHttpOpen, _WinHttpOpenRequest
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384090(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpCloseHandle($hInternet)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpCloseHandle", "handle", $hInternet)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpCloseHandle

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpConnect
; Description ...: Specifies the initial target server of an HTTP request and returns connection handle to an HTTP session for that initial target.
; Syntax.........: _WinHttpConnect($hSession, $sServerName [, $iServerPort = Default ])
; Parameters ....: $hSession - Valid WinHttp session handle returned by a previous call to WinHttpOpen.
;                  $sServerName - Host name of an HTTP server.
;                  $iServerPort - [optional] TCP/IP port on the server to which a connection is made (default is $INTERNET_DEFAULT_PORT)
; Return values .: Success - Returns a valid connection handle to the HTTP session
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: $iServerPort can be defined via global constants $INTERNET_DEFAULT_PORT, $INTERNET_DEFAULT_HTTP_PORT or $INTERNET_DEFAULT_HTTPS_PORT
; Related .......: _WinHttpOpen
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384091(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpConnect($hSession, $sServerName, $iServerPort = Default)
	__WinHttpDefault($iServerPort, $INTERNET_DEFAULT_PORT)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpConnect", _
			"handle", $hSession, _
			"wstr", $sServerName, _
			"dword", $iServerPort, _
			"dword", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_WinHttpConnect

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpCrackUrl
; Description ...: Separates a URL into its component parts such as host name and path.
; Syntax.........: _WinHttpCrackUrl($sURL [, $iFlag = Default ])
; Parameters ....: $sURL - String. Canonical URL to separate.
;                  $iFlag - [optional] Flag that control the operation. Default is $ICU_ESCAPE
; Return values .: Success - Returns array with 8 elements:
;                  |$array[0] - is scheme name
;                  |$array[1] - is internet protocol scheme
;                  |$array[2] - is host name
;                  |$array[3] - is port number
;                  |$array[4] - is user name
;                  |$array[5] - is password
;                  |$array[6] - is URL path
;                  |$array[7] - is extra information
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......: $iFlag is defined in WinHttpConstants.au3 and can be:
;                  |$ICU_DECODE - Converts characters that are "escape encoded" (%xx) to their non-escaped form.
;                  |$ICU_ESCAPE - Escapes certain characters to their escape sequences (%xx).
; Related .......: _WinHttpCreateUrl
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384092(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpCrackUrl($sURL, $iFlag = Default)
	__WinHttpDefault($iFlag, $ICU_ESCAPE)
	Local $tURL_COMPONENTS = DllStructCreate("dword StructSize;" & _
			"ptr SchemeName;" & _
			"dword SchemeNameLength;" & _
			"int Scheme;" & _
			"ptr HostName;" & _
			"dword HostNameLength;" & _
			"word Port;" & _
			"ptr UserName;" & _
			"dword UserNameLength;" & _
			"ptr Password;" & _
			"dword PasswordLength;" & _
			"ptr UrlPath;" & _
			"dword UrlPathLength;" & _
			"ptr ExtraInfo;" & _
			"dword ExtraInfoLength")
	DllStructSetData($tURL_COMPONENTS, 1, DllStructGetSize($tURL_COMPONENTS))
	Local $tBuffers[6]
	Local $iURLLen = StringLen($sURL)
	For $i = 0 To 5
		$tBuffers[$i] = DllStructCreate("wchar[" & $iURLLen + 1 & "]")
	Next
	DllStructSetData($tURL_COMPONENTS, "SchemeNameLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "SchemeName", DllStructGetPtr($tBuffers[0]))
	DllStructSetData($tURL_COMPONENTS, "HostNameLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "HostName", DllStructGetPtr($tBuffers[1]))
	DllStructSetData($tURL_COMPONENTS, "UserNameLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "UserName", DllStructGetPtr($tBuffers[2]))
	DllStructSetData($tURL_COMPONENTS, "PasswordLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "Password", DllStructGetPtr($tBuffers[3]))
	DllStructSetData($tURL_COMPONENTS, "UrlPathLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "UrlPath", DllStructGetPtr($tBuffers[4]))
	DllStructSetData($tURL_COMPONENTS, "ExtraInfoLength", $iURLLen)
	DllStructSetData($tURL_COMPONENTS, "ExtraInfo", DllStructGetPtr($tBuffers[5]))
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpCrackUrl", _
			"wstr", $sURL, _
			"dword", $iURLLen, _
			"dword", $iFlag, _
			"ptr", DllStructGetPtr($tURL_COMPONENTS))
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Local $aRet[8] = [DllStructGetData($tBuffers[0], 1), _
			DllStructGetData($tURL_COMPONENTS, "Scheme"), _
			DllStructGetData($tBuffers[1], 1), _
			DllStructGetData($tURL_COMPONENTS, "Port"), _
			DllStructGetData($tBuffers[2], 1), _
			DllStructGetData($tBuffers[3], 1), _
			DllStructGetData($tBuffers[4], 1), _
			DllStructGetData($tBuffers[5], 1)]
	Return $aRet
EndFunc   ;==>_WinHttpCrackUrl

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpCreateUrl
; Description ...: Creates a URL from array of components such as the host name and path.
; Syntax.........: _WinHttpCreateUrl($aURLArray)
; Parameters ....: $aURLArray - Array of URL data.
; Return values .: Success - Returns created URL
;                  Failure - Returns empty string and sets @error:
;                  |1 - Invalid input.
;                  |2 - Initial DllCall failed
;                  |3 - Main DllCall failed
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......: Input is one dimensional 8 elements in size array:
;                  |- first element [0] is scheme name
;                  |- second element [1] is internet protocol scheme
;                  |- third element [2] is host name
;                  |- fourth element [3] is port number
;                  |- fifth element [4] is user name
;                  |- sixth element [5] is password
;                  |- seventh element [6] is URL path
;                  |- eighth element [7] is extra information
; Related .......: _WinHttpCrackUrl
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384093(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpCreateUrl($aURLArray)
	If UBound($aURLArray) - 8 Then Return SetError(1, 0, "")
	Local $tURL_COMPONENTS = DllStructCreate("dword StructSize;" & _
			"ptr SchemeName;" & _
			"dword SchemeNameLength;" & _
			"int Scheme;" & _
			"ptr HostName;" & _
			"dword HostNameLength;" & _
			"word Port;" & _
			"ptr UserName;" & _
			"dword UserNameLength;" & _
			"ptr Password;" & _
			"dword PasswordLength;" & _
			"ptr UrlPath;" & _
			"dword UrlPathLength;" & _
			"ptr ExtraInfo;" & _
			"dword ExtraInfoLength;")
	DllStructSetData($tURL_COMPONENTS, 1, DllStructGetSize($tURL_COMPONENTS))
	Local $tBuffers[6][2]
	$tBuffers[0][1] = StringLen($aURLArray[0])
	If $tBuffers[0][1] Then
		$tBuffers[0][0] = DllStructCreate("wchar[" & $tBuffers[0][1] + 1 & "]")
		DllStructSetData($tBuffers[0][0], 1, $aURLArray[0])
	EndIf
	$tBuffers[1][1] = StringLen($aURLArray[2])
	If $tBuffers[1][1] Then
		$tBuffers[1][0] = DllStructCreate("wchar[" & $tBuffers[1][1] + 1 & "]")
		DllStructSetData($tBuffers[1][0], 1, $aURLArray[2])
	EndIf
	$tBuffers[2][1] = StringLen($aURLArray[4])
	If $tBuffers[2][1] Then
		$tBuffers[2][0] = DllStructCreate("wchar[" & $tBuffers[2][1] + 1 & "]")
		DllStructSetData($tBuffers[2][0], 1, $aURLArray[4])
	EndIf
	$tBuffers[3][1] = StringLen($aURLArray[5])
	If $tBuffers[3][1] Then
		$tBuffers[3][0] = DllStructCreate("wchar[" & $tBuffers[3][1] + 1 & "]")
		DllStructSetData($tBuffers[3][0], 1, $aURLArray[5])
	EndIf
	$tBuffers[4][1] = StringLen($aURLArray[6])
	If $tBuffers[4][1] Then
		$tBuffers[4][0] = DllStructCreate("wchar[" & $tBuffers[4][1] + 1 & "]")
		DllStructSetData($tBuffers[4][0], 1, $aURLArray[6])
	EndIf
	$tBuffers[5][1] = StringLen($aURLArray[7])
	If $tBuffers[5][1] Then
		$tBuffers[5][0] = DllStructCreate("wchar[" & $tBuffers[5][1] + 1 & "]")
		DllStructSetData($tBuffers[5][0], 1, $aURLArray[7])
	EndIf
	DllStructSetData($tURL_COMPONENTS, "SchemeNameLength", $tBuffers[0][1])
	DllStructSetData($tURL_COMPONENTS, "SchemeName", DllStructGetPtr($tBuffers[0][0]))
	DllStructSetData($tURL_COMPONENTS, "HostNameLength", $tBuffers[1][1])
	DllStructSetData($tURL_COMPONENTS, "HostName", DllStructGetPtr($tBuffers[1][0]))
	DllStructSetData($tURL_COMPONENTS, "UserNameLength", $tBuffers[2][1])
	DllStructSetData($tURL_COMPONENTS, "UserName", DllStructGetPtr($tBuffers[2][0]))
	DllStructSetData($tURL_COMPONENTS, "PasswordLength", $tBuffers[3][1])
	DllStructSetData($tURL_COMPONENTS, "Password", DllStructGetPtr($tBuffers[3][0]))
	DllStructSetData($tURL_COMPONENTS, "UrlPathLength", $tBuffers[4][1])
	DllStructSetData($tURL_COMPONENTS, "UrlPath", DllStructGetPtr($tBuffers[4][0]))
	DllStructSetData($tURL_COMPONENTS, "ExtraInfoLength", $tBuffers[5][1])
	DllStructSetData($tURL_COMPONENTS, "ExtraInfo", DllStructGetPtr($tBuffers[5][0]))
	DllStructSetData($tURL_COMPONENTS, "Scheme", $aURLArray[1])
	DllStructSetData($tURL_COMPONENTS, "Port", $aURLArray[3])
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpCreateUrl", _
			"ptr", DllStructGetPtr($tURL_COMPONENTS), _
			"dword", $ICU_ESCAPE, _
			"ptr", 0, _
			"dword*", 0)
	If @error Then Return SetError(2, 0, "")
	Local $iURLLen = $aCall[4]
	Local $URLBuffer = DllStructCreate("wchar[" & ($iURLLen + 1) & "]")
	$aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpCreateUrl", _
			"ptr", DllStructGetPtr($tURL_COMPONENTS), _
			"dword", $ICU_ESCAPE, _
			"ptr", DllStructGetPtr($URLBuffer), _
			"dword*", $iURLLen)
	If @error Or Not $aCall[0] Then Return SetError(3, 0, "")
	Return DllStructGetData($URLBuffer, 1)
EndFunc   ;==>_WinHttpCreateUrl

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpDetectAutoProxyConfigUrl
; Description ...: Finds the URL for the Proxy Auto-Configuration (PAC) file.
; Syntax.........: _WinHttpDetectAutoProxyConfigUrl($iAutoDetectFlags)
; Parameters ....: $iAutoDetectFlags - Specifies what protocols to use to locate the PAC file.
; Return values .: Success - Returns URL for the PAC file.
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall failed
;                  |2 - Internal failure.
; Author ........: trancexx
; Modified.......:
; Remarks .......: $iAutoDetectFlags values are defined in WinHttpconstants.au3
; Related .......: _WinHttpGetDefaultProxyConfiguration, _WinHttpGetIEProxyConfigForCurrentUser, _WinHttpSetDefaultProxyConfiguration
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384094(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpDetectAutoProxyConfigUrl($iAutoDetectFlags)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpDetectAutoProxyConfigUrl", "dword", $iAutoDetectFlags, "ptr*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, "")
	Local $pString = $aCall[2]
	If $pString Then
		Local $iLen = __WinHttpPtrStringLenW($pString)
		If @error Then Return SetError(2, 0, "")
		Local $tString = DllStructCreate("wchar[" & $iLen + 1 & "]", $pString)
		Local $sString = DllStructGetData($tString, 1)
		__WinHttpMemGlobalFree($pString)
		Return $sString
	EndIf
	Return ""
EndFunc   ;==>_WinHttpDetectAutoProxyConfigUrl


; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpGetDefaultProxyConfiguration
; Description ...: Retrieves the default WinHttp proxy configuration.
; Syntax.........: _WinHttpGetDefaultProxyConfiguration()
; Parameters ....: None.
; Return values .: Success - Returns array with 3 elements:
;                  |$array[0] - Integer. Access type.
;                  |$array[1] - String. Proxy server list.
;                  |$array[2] - String. Proxy bypass list.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: Access types are defined in WinHttpconstants.au3:
;                  |$WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0
;                  |$WINHTTP_ACCESS_TYPE_NO_PROXY = 1
;                  |$WINHTTP_ACCESS_TYPE_NAMED_PROXY = 3
; Related .......: _WinHttpDetectAutoProxyConfigUrl, _WinHttpGetIEProxyConfigForCurrentUser, _WinHttpSetDefaultProxyConfiguration
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384095(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpGetDefaultProxyConfiguration()
	Local $tWINHTTP_PROXY_INFO = DllStructCreate("dword AccessType;" & _
			"ptr Proxy;" & _
			"ptr ProxyBypass")
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpGetDefaultProxyConfiguration", "ptr", DllStructGetPtr($tWINHTTP_PROXY_INFO))
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Local $iAccessType = DllStructGetData($tWINHTTP_PROXY_INFO, "AccessType")
	Local $pProxy = DllStructGetData($tWINHTTP_PROXY_INFO, "Proxy")
	Local $pProxyBypass = DllStructGetData($tWINHTTP_PROXY_INFO, "ProxyBypass")
	Local $sProxy
	If $pProxy Then
		Local $iProxyLen = __WinHttpPtrStringLenW($pProxy)
		If Not @error Then
			Local $tProxy = DllStructCreate("wchar[" & $iProxyLen + 1 & "]", $pProxy)
			$sProxy = DllStructGetData($tProxy, 1)
			__WinHttpMemGlobalFree($pProxy)
		EndIf
	EndIf
	Local $sProxyBypass
	If $pProxyBypass Then
		Local $iProxyBypassLen = __WinHttpPtrStringLenW($pProxyBypass)
		If Not @error Then
			Local $tProxyBypass = DllStructCreate("wchar[" & $iProxyBypassLen + 1 & "]", $pProxyBypass)
			$sProxyBypass = DllStructGetData($tProxyBypass, 1)
			__WinHttpMemGlobalFree($pProxyBypass)
		EndIf
	EndIf
	Local $aRet[3] = [$iAccessType, $sProxy, $sProxyBypass]
	Return $aRet
EndFunc   ;==>_WinHttpGetDefaultProxyConfiguration

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpGetIEProxyConfigForCurrentUser
; Description ...: Retrieves the Internet Explorer proxy configuration for the current user.
; Syntax.........: _WinHttpGetIEProxyConfigForCurrentUser()
; Parameters ....: None.
; Return values .: Success - Returns array with 4 elements:
;                  |$array[0] - if 1 indicates that the Internet Explorer proxy configuration for the current user specifies "automatically detect settings",
;                  |$array[1] - auto-configuration URL if the Internet Explorer proxy configuration for the current user specifies "Use automatic proxy configuration",
;                  |$array[2] - proxy URL if the Internet Explorer proxy configuration for the current user specifies "use a proxy server",
;                  |$array[3] - optional proxy by-pass server list.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
;                  |2 - Internal failure.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpDetectAutoProxyConfigUrl, _WinHttpGetDefaultProxyConfiguration, _WinHttpSetDefaultProxyConfiguration
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384096(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpGetIEProxyConfigForCurrentUser()
	Local $tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG = DllStructCreate("int AutoDetect;" & _
			"ptr AutoConfigUrl;" & _
			"ptr Proxy;" & _
			"ptr ProxyBypass;")
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpGetIEProxyConfigForCurrentUser", "ptr", DllStructGetPtr($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG))
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Local $iAutoDetect = DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "AutoDetect")
	Local $pAutoConfigUrl = DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "AutoConfigUrl")
	Local $pProxy = DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "Proxy")
	Local $pProxyBypass = DllStructGetData($tWINHTTP_CURRENT_USER_IE_PROXY_CONFIG, "ProxyBypass")
	Local $sAutoConfigUrl
	If $pAutoConfigUrl Then
		Local $iAutoConfigUrlLen = __WinHttpPtrStringLenW($pAutoConfigUrl)
		If Not @error Then
			Local $tAutoConfigUrl = DllStructCreate("wchar[" & $iAutoConfigUrlLen + 1 & "]", $pAutoConfigUrl)
			$sAutoConfigUrl = DllStructGetData($tAutoConfigUrl, 1)
			__WinHttpMemGlobalFree($pAutoConfigUrl)
		EndIf
	EndIf
	Local $sProxy
	If $pProxy Then
		Local $iProxyLen = __WinHttpPtrStringLenW($pProxy)
		If Not @error Then
			Local $tProxy = DllStructCreate("wchar[" & $iProxyLen + 1 & "]", $pProxy)
			$sProxy = DllStructGetData($tProxy, 1)
			__WinHttpMemGlobalFree($pProxy)
		EndIf
	EndIf
	Local $sProxyBypass
	If $pProxyBypass Then
		Local $iProxyBypassLen = __WinHttpPtrStringLenW($pProxyBypass)
		If Not @error Then
			Local $tProxyBypass = DllStructCreate("wchar[" & $iProxyBypassLen + 1 & "]", $pProxyBypass)
			$sProxyBypass = DllStructGetData($tProxyBypass, 1)
			__WinHttpMemGlobalFree($pProxyBypass)
		EndIf
	EndIf
	Local $aOutput[4] = [$iAutoDetect, $sAutoConfigUrl, $sProxy, $sProxyBypass]
	Return $aOutput
EndFunc   ;==>_WinHttpGetIEProxyConfigForCurrentUser

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpOpen
; Description ...: Initializes the use of WinHttp functions and returns a WinHttp-session handle.
; Syntax.........: _WinHttpOpen([$sUserAgent = Default [, $iAccessType = Default [, $sProxyName = Default [, $sProxyBypass = Default [, $iFlag = Default ]]]]])
; Parameters ....: $sUserAgent - [optional] The name of the application or entity calling the WinHttp functions. Default is "AutoIt/3.3".
;                  $iAccessType - [optional] Type of access required. Default is $WINHTTP_ACCESS_TYPE_NO_PROXY.
;                  $sProxyName - [optional] The name of the proxy server to use when proxy access is specified by setting $iAccessType to $WINHTTP_ACCESS_TYPE_NAMED_PROXY. Default is $WINHTTP_NO_PROXY_NAME.
;                  $sProxyBypass - [optional] An optional list of host names or IP addresses, or both, that should not be routed through the proxy when $iAccessType is set to $WINHTTP_ACCESS_TYPE_NAMED_PROXY. Default is $WINHTTP_NO_PROXY_BYPASS.
;                  $iFlag - [optional] Integer containing the flags that indicate various options affecting the behavior of this function. Default is 0.
; Return values .: Success - Returns valid session handle.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: For asynchronous mode set $iFlag to $WINHTTP_FLAG_ASYNC
; Related .......: _WinHttpCloseHandle, _WinHttpConnect
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384098(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpOpen($sUserAgent = Default, $iAccessType = Default, $sProxyName = Default, $sProxyBypass = Default, $iFlag = Default)
	__WinHttpDefault($sUserAgent, "AutoIt/3.3")
	__WinHttpDefault($iAccessType, $WINHTTP_ACCESS_TYPE_NO_PROXY)
	__WinHttpDefault($sProxyName, $WINHTTP_NO_PROXY_NAME)
	__WinHttpDefault($sProxyBypass, $WINHTTP_NO_PROXY_BYPASS)
	__WinHttpDefault($iFlag, 0)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpOpen", _
			"wstr", $sUserAgent, _
			"dword", $iAccessType, _
			"wstr", $sProxyName, _
			"wstr", $sProxyBypass, _
			"dword", $iFlag)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_WinHttpOpen

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpOpenRequest
; Description ...: Creates an HTTP request handle.
; Syntax.........: _WinHttpOpenRequest($hConnect [, $sVerb = Default [, $sObjectName = Default [, $sVersion = Default [, $sReferrer = Default [, $sAcceptTypes = Default [, $iFlags = Default ]]]]]])
; Parameters ....: $hConnect - Handle to an HTTP session returned by _WinHttpConnect().
;                  $sVerb - [optional] HTTP verb to use in the request. Default is "GET".
;                  $sObjectName - [optional] The name of the target resource of the specified HTTP verb.
;                  $sVersion - [optional] HTTP version. Default is "HTTP/1.1"
;                  $sReferrer - [optional] URL of the document from which the URL in the request $sObjectName was obtained. Default is $WINHTTP_NO_REFERER.
;                  $sAcceptTypes - [optional] Media types accepted by the client. Default is $WINHTTP_DEFAULT_ACCEPT_TYPES
;                  $iFlags - [optional] Integer specifying the Internet flag values. Default is $WINHTTP_FLAG_ESCAPE_DISABLE
; Return values .: Success - Returns valid session handle.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpCloseHandle, _WinHttpConnect, _WinHttpSendRequest
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384099(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpOpenRequest($hConnect, $sVerb = Default, $sObjectName = Default, $sVersion = Default, $sReferrer = Default, $sAcceptTypes = Default, $iFlags = Default)
	__WinHttpDefault($sVerb, "GET")
	__WinHttpDefault($sObjectName, "")
	__WinHttpDefault($sVersion, "HTTP/1.1")
	__WinHttpDefault($sReferrer, $WINHTTP_NO_REFERER)
	__WinHttpDefault($iFlags, $WINHTTP_FLAG_ESCAPE_DISABLE)
	Local $pAcceptTypes
	If $sAcceptTypes = Default Or Number($sAcceptTypes) = -1 Then
		$pAcceptTypes = $WINHTTP_DEFAULT_ACCEPT_TYPES
	Else
		Local $aTypes = StringSplit($sAcceptTypes, ",", 2)
		Local $tAcceptTypes = DllStructCreate("ptr[" & UBound($aTypes) + 1 & "]")
		Local $tType[UBound($aTypes)]
		For $i = 0 To UBound($aTypes) - 1
			$tType[$i] = DllStructCreate("wchar[" & StringLen($aTypes[$i]) + 1 & "]")
			DllStructSetData($tType[$i], 1, $aTypes[$i])
			DllStructSetData($tAcceptTypes, 1, DllStructGetPtr($tType[$i]), $i + 1)
		Next
		$pAcceptTypes = DllStructGetPtr($tAcceptTypes)
	EndIf
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "handle", "WinHttpOpenRequest", _
			"handle", $hConnect, _
			"wstr", StringUpper($sVerb), _
			"wstr", $sObjectName, _
			"wstr", StringUpper($sVersion), _
			"wstr", $sReferrer, _
			"ptr", $pAcceptTypes, _
			"dword", $iFlags)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_WinHttpOpenRequest

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpQueryDataAvailable
; Description ...: Returns the availability to be read with _WinHttpReadData().
; Syntax.........: _WinHttpQueryDataAvailable($hRequest)
; Parameters ....: $hRequest - handle returned by _WinHttpOpenRequest().
; Return values .: Success - Returns 1 if data is available.
;                          - Returns 0 if no data is available.
;                          - @extended receives the number of available bytes.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: _WinHttpReceiveResponse must have been called for this handle and completed before _WinHttpQueryDataAvailable is called.
; Related .......: _WinHttpOpenRequest, _WinHttpReadData, _WinHttpReceiveResponse
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384101(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpQueryDataAvailable($hRequest)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpQueryDataAvailable", "handle", $hRequest, "dword*", 0)
	If @error Then Return SetError(1, 0, 0)
	Return SetExtended($aCall[2], $aCall[0])
EndFunc   ;==>_WinHttpQueryDataAvailable

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpQueryHeaders
; Description ...: Retrieves header information associated with an HTTP request.
; Syntax.........: _WinHttpQueryHeaders($hRequest [, $iInfoLevel = Default [, $sName = Default [, $iIndex = Default ]]])
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest().
;                  $iInfoLevel - [optional] A combination of attribute and modifier flags. Default is $WINHTTP_QUERY_RAW_HEADERS_CRLF.
;                  $sName - [optional] Header name string. Default is $WINHTTP_HEADER_NAME_BY_INDEX.
;                  $iIndex - [optional] Index used to enumerate multiple headers with the same name
; Return values .: Success - Returns string that contains header.
;                          - @extended is set to the index of the next header
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpAddRequestHeaders, _WinHttpOpenRequest
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384102(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpQueryHeaders($hRequest, $iInfoLevel = Default, $sName = Default, $iIndex = Default)
	__WinHttpDefault($iInfoLevel, $WINHTTP_QUERY_RAW_HEADERS_CRLF)
	__WinHttpDefault($sName, $WINHTTP_HEADER_NAME_BY_INDEX)
	__WinHttpDefault($iIndex, $WINHTTP_NO_HEADER_INDEX)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpQueryHeaders", _
			"handle", $hRequest, _
			"dword", $iInfoLevel, _
			"wstr", $sName, _
			"wstr", "", _
			"dword*", 65536, _
			"dword*", $iIndex)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, "")
	Return SetExtended($aCall[6], $aCall[4])
EndFunc   ;==>_WinHttpQueryHeaders

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpQueryOption
; Description ...: Queries an Internet option on the specified handle.
; Syntax.........: _WinHttpQueryOption($hInternet, $iOption)
; Parameters ....: $hInternet - Handle on which to query information.
;                  $iOption - Internet option to query.
; Return values .: Success - Returns data containing requested information.
;                  Failure - Returns empty string and sets @error:
;                  |1 - Initial DllCall failed
;                  |2 - Main DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: Type of the returned data varies on request.
; Related .......: _WinHttpSetOption
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384103(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpQueryOption($hInternet, $iOption)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpQueryOption", _
			"handle", $hInternet, _
			"dword", $iOption, _
			"ptr", 0, _
			"dword*", 0)
	If @error Or $aCall[0] Then Return SetError(1, 0, "")
	Local $iSize = $aCall[4]
	Local $tBuffer
	Switch $iOption
		Case $WINHTTP_OPTION_CONNECTION_INFO, $WINHTTP_OPTION_PASSWORD, $WINHTTP_OPTION_PROXY_PASSWORD, $WINHTTP_OPTION_PROXY_USERNAME, $WINHTTP_OPTION_URL, $WINHTTP_OPTION_USERNAME, $WINHTTP_OPTION_USER_AGENT, _
				$WINHTTP_OPTION_PASSPORT_COBRANDING_TEXT, $WINHTTP_OPTION_PASSPORT_COBRANDING_URL
			$tBuffer = DllStructCreate("wchar[" & $iSize + 1 & "]")
		Case $WINHTTP_OPTION_PARENT_HANDLE, $WINHTTP_OPTION_CALLBACK
			$tBuffer = DllStructCreate("ptr")
		Case $WINHTTP_OPTION_CONNECT_TIMEOUT, $WINHTTP_AUTOLOGON_SECURITY_LEVEL_HIGH, $WINHTTP_AUTOLOGON_SECURITY_LEVEL_LOW, $WINHTTP_AUTOLOGON_SECURITY_LEVEL_MEDIUM, _
				$WINHTTP_OPTION_CONFIGURE_PASSPORT_AUTH, $WINHTTP_OPTION_CONNECT_RETRIES, $WINHTTP_OPTION_EXTENDED_ERROR, $WINHTTP_OPTION_HANDLE_TYPE, $WINHTTP_OPTION_MAX_CONNS_PER_1_0_SERVER, _
				$WINHTTP_OPTION_MAX_CONNS_PER_SERVER, $WINHTTP_OPTION_MAX_HTTP_AUTOMATIC_REDIRECTS, $WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT, $WINHTTP_OPTION_RECEIVE_TIMEOUT, _
				$WINHTTP_OPTION_RESOLVE_TIMEOUT, $WINHTTP_OPTION_SECURITY_FLAGS, $WINHTTP_OPTION_SECURITY_KEY_BITNESS, $WINHTTP_OPTION_SEND_TIMEOUT
			$tBuffer = DllStructCreate("int")
		Case Else
			$tBuffer = DllStructCreate("byte[" & $iSize & "]")
	EndSwitch
	$aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpQueryOption", _
			"handle", $hInternet, _
			"dword", $iOption, _
			"ptr", DllStructGetPtr($tBuffer), _
			"dword*", $iSize)
	If @error Or Not $aCall[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($tBuffer, 1)
EndFunc   ;==>_WinHttpQueryOption

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpReadData
; Description ...: Reads data from a handle opened by the _WinHttpOpenRequest() function.
; Syntax.........: _WinHttpReadData($hRequest [, $iMode = Default [, $iNumberOfBytesToRead = Default ]])
; Parameters ....: $hRequest - Valid handle returned from a previous call to _WinHttpOpenRequest().
;                  $iMode - [optional] Integer representing reading mode. Default is 0 (charset is decoded as it is ANSI).
;                  $iNumberOfBytesToRead - [optional] The number of bytes to read. Default is 8192 bytes.
; Return values .: Success - Returns data read.
;                          - @extended receives the number of bytes read.
;                  Special: Sets @error to -1 if no more data to read (end reached).
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx, ProgAndy
; Modified.......:
; Remarks .......: $iMode can have these values:
;                  |0 - ANSI
;                  |1 - UTF8
;                  |2 - Binary
; Related .......: _WinHttpOpenRequest, _WinHttpWriteData
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384104(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpReadData($hRequest, $iMode = Default, $iNumberOfBytesToRead = Default, $pBuffer = Default)
	__WinHttpDefault($iMode, 0)
	__WinHttpDefault($iNumberOfBytesToRead, 8192)
	Local $tBuffer
	Switch $iMode
		Case 1, 2
			If $pBuffer And $pBuffer <> Default Then
				$tBuffer = DllStructCreate("byte[" & $iNumberOfBytesToRead & "]", $pBuffer)
			Else
				$tBuffer = DllStructCreate("byte[" & $iNumberOfBytesToRead & "]")
			EndIf
		Case Else
			$iMode = 0
			If $pBuffer And $pBuffer <> Default Then
				$tBuffer = DllStructCreate("char[" & $iNumberOfBytesToRead & "]", $pBuffer)
			Else
				$tBuffer = DllStructCreate("char[" & $iNumberOfBytesToRead & "]")
			EndIf
	EndSwitch
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpReadData", _
			"handle", $hRequest, _
			"ptr", DllStructGetPtr($tBuffer), _
			"dword", $iNumberOfBytesToRead, _
			"dword*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, "")
	If Not $aCall[4] Then Return SetError(-1, 0, "")
	If $aCall[4] < $iNumberOfBytesToRead Then
		Switch $iMode
			Case 0
				Return SetExtended($aCall[4], StringLeft(DllStructGetData($tBuffer, 1), $aCall[4]))
			Case 1
				Return SetExtended($aCall[4], BinaryToString(BinaryMid(DllStructGetData($tBuffer, 1), 1, $aCall[4]), 4))
			Case 2
				Return SetExtended($aCall[4], BinaryMid(DllStructGetData($tBuffer, 1), 1, $aCall[4]))
		EndSwitch
	Else
		Switch $iMode
			Case 0, 2
				Return SetExtended($aCall[4], DllStructGetData($tBuffer, 1))
			Case 1
				Return SetExtended($aCall[4], BinaryToString(DllStructGetData($tBuffer, 1), 4))
		EndSwitch
	EndIf
EndFunc   ;==>_WinHttpReadData

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpReceiveResponse
; Description ...: Waits to receive the response to an HTTP request initiated by WinHttpSendRequest().
; Syntax.........: _WinHttpReceiveResponse($hRequest)
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest() and sent by _WinHttpSendRequest().
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: Call to _WinHttpReceiveResponse() must be done before _WinHttpQueryDataAvailable() and _WinHttpReadData().
; Related .......: _WinHttpOpenRequest, _WinHttpSetTimeouts
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384105(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpReceiveResponse($hRequest)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpReceiveResponse", "handle", $hRequest, "ptr", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpReceiveResponse

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSendRequest
; Description ...: Sends the specified request to the HTTP server.
; Syntax.........: _WinHttpSendRequest($hRequest [, $sHeaders = Default [, $sOptional = Default [, $iTotalLength = Default [, $iContext = Default ]]]])
; Parameters ....: $hRequest - Handle returned by _WinHttpOpenRequest().
;                  $sHeaders - [optional] Additional headers to append to the request. Default is $WINHTTP_NO_ADDITIONAL_HEADERS.
;                  $sOptional - [optional] Optional data to send immediately after the request headers. Default is $WINHTTP_NO_REQUEST_DATA.
;                  $iTotalLength - [optional] Length, in bytes, of the total optional data sent. Default is 0.
;                  $iContext - [optional] Application-defined value that is passed, with the request handle, to any callback functions. Default is 0.
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: Specifying optional data ($sOptional) will cause $iTotalLength to receive the size of that data if left default value.
; Related .......: _WinHttpOpenRequest
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384110(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpSendRequest($hRequest, $sHeaders = Default, $sOptional = Default, $iTotalLength = Default, $iContext = Default)
	__WinHttpDefault($sHeaders, $WINHTTP_NO_ADDITIONAL_HEADERS)
	__WinHttpDefault($sOptional, $WINHTTP_NO_REQUEST_DATA)
	__WinHttpDefault($iTotalLength, 0)
	__WinHttpDefault($iContext, 0)
	Local $pOptional = 0, $iOptionalLength = 0
	If @NumParams > 2 Then
		Local $tOptional
		$iOptionalLength = BinaryLen($sOptional)
		$tOptional = DllStructCreate("byte[" & $iOptionalLength & "]")
		If $iOptionalLength Then $pOptional = DllStructGetPtr($tOptional)
		DllStructSetData($tOptional, 1, $sOptional)
	EndIf
	If Not $iTotalLength Or $iTotalLength < $iOptionalLength Then $iTotalLength += $iOptionalLength
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSendRequest", _
			"handle", $hRequest, _
			"wstr", $sHeaders, _
			"dword", 0, _
			"ptr", $pOptional, _
			"dword", $iOptionalLength, _
			"dword", $iTotalLength, _
			"dword_ptr", $iContext)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpSendRequest

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSetCredentials
; Description ...: Passes the required authorization credentials to the server.
; Syntax.........: _WinHttpSetCredentials($hRequest, $iAuthTargets, $iAuthScheme, $sUserName, $sPassword)
; Parameters ....: $hRequest - Valid handle returned by _WinHttpOpenRequest().
;                  $iAuthTargets - Authentication target.
;                  $iAuthScheme - Authentication scheme.
;                  $sUserName - Valid user name.
;                  $sPassword - Valid password.
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpOpenRequest
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384112(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpSetCredentials($hRequest, $iAuthTargets, $iAuthScheme, $sUserName, $sPassword)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSetCredentials", _
			"handle", $hRequest, _
			"dword", $iAuthTargets, _
			"dword", $iAuthScheme, _
			"wstr", $sUserName, _
			"wstr", $sPassword, _
			"ptr", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpSetCredentials

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSetDefaultProxyConfiguration
; Description ...: Sets the default WinHttp proxy configuration.
; Syntax.........: _WinHttpSetDefaultProxyConfiguration($iAccessType [, $sProxy = "" [, $sProxyBypass = ""])
; Parameters ....: $iAccessType - Integer. Access type.
;                  $sProxy - [optional] String. Proxy server list.
;                  $sProxyBypass - [optional] String. Proxy bypass list.
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpDetectAutoProxyConfigUrl, _WinHttpGetDefaultProxyConfiguration, _WinHttpGetIEProxyConfigForCurrentUser
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384113(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpSetDefaultProxyConfiguration($iAccessType, $sProxy = "", $sProxyBypass = "")
	Local $tProxy = DllStructCreate("wchar[" & StringLen($sProxy) + 1 & "]")
	DllStructSetData($tProxy, 1, $sProxy)
	Local $tProxyBypass = DllStructCreate("wchar[" & StringLen($sProxyBypass) + 1 & "]")
	DllStructSetData($tProxyBypass, 1, $sProxyBypass)
	Local $tWINHTTP_PROXY_INFO = DllStructCreate("dword AccessType;" & _
			"ptr Proxy;" & _
			"ptr ProxyBypass")
	DllStructSetData($tWINHTTP_PROXY_INFO, "AccessType", $iAccessType)
	If $iAccessType <> $WINHTTP_ACCESS_TYPE_NO_PROXY Then
		DllStructSetData($tWINHTTP_PROXY_INFO, "Proxy", DllStructGetPtr($tProxy))
		DllStructSetData($tWINHTTP_PROXY_INFO, "ProxyBypass", DllStructGetPtr($tProxyBypass))
	EndIf
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSetDefaultProxyConfiguration", "ptr", DllStructGetPtr($tWINHTTP_PROXY_INFO))
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpSetDefaultProxyConfiguration

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSetOption
; Description ...: Sets an Internet option.
; Syntax.........: _WinHttpSetOption($hInternet, $iOption, $vSetting [, $iSize = Default ])
; Parameters ....: $hInternet - Handle on which to set data.
;                  $iOption - Integer value that contains the Internet option to set.
;                  $vSetting - Value of setting
;                  $iSize    - [optional] Size of $vSetting, required if $vSetting is pointer to memory block
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - Invalid Internet option
;                  |2 - Size required
;                  |3 - Datatype of value does not fit to option
;                  |4 - DllCall failed
; Author ........: ProgAndy, trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpQueryOption
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384114(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpSetOption($hInternet, $iOption, $vSetting, $iSize = Default)
	If $iSize = Default Then $iSize = -1
	If IsBinary($vSetting) Then
		$iSize = DllStructCreate("byte[" & BinaryLen($vSetting) & "]")
		DllStructSetData($iSize, 1, $vSetting)
		$vSetting = $iSize
		$iSize = DllStructGetSize($vSetting)
	EndIf
	Local $sType
	Switch $iOption
		Case $WINHTTP_OPTION_AUTOLOGON_POLICY, $WINHTTP_OPTION_CODEPAGE, $WINHTTP_OPTION_CONFIGURE_PASSPORT_AUTH, $WINHTTP_OPTION_CONNECT_RETRIES, _
				$WINHTTP_OPTION_CONNECT_TIMEOUT, $WINHTTP_OPTION_DISABLE_FEATURE, $WINHTTP_OPTION_ENABLE_FEATURE, $WINHTTP_OPTION_ENABLETRACING, _
				$WINHTTP_OPTION_MAX_CONNS_PER_1_0_SERVER, $WINHTTP_OPTION_MAX_CONNS_PER_SERVER, $WINHTTP_OPTION_MAX_HTTP_AUTOMATIC_REDIRECTS, _
				$WINHTTP_OPTION_MAX_HTTP_STATUS_CONTINUE, $WINHTTP_OPTION_MAX_RESPONSE_DRAIN_SIZE, $WINHTTP_OPTION_MAX_RESPONSE_HEADER_SIZE, _
				$WINHTTP_OPTION_READ_BUFFER_SIZE, $WINHTTP_OPTION_RECEIVE_TIMEOUT, _
				$WINHTTP_OPTION_RECEIVE_RESPONSE_TIMEOUT, $WINHTTP_OPTION_REDIRECT_POLICY, $WINHTTP_OPTION_REJECT_USERPWD_IN_URL, _
				$WINHTTP_OPTION_REQUEST_PRIORITY, $WINHTTP_OPTION_RESOLVE_TIMEOUT, $WINHTTP_OPTION_SECURE_PROTOCOLS, $WINHTTP_OPTION_SECURITY_FLAGS, _
				$WINHTTP_OPTION_SECURITY_KEY_BITNESS, $WINHTTP_OPTION_SEND_TIMEOUT, $WINHTTP_OPTION_SPN, $WINHTTP_OPTION_USE_GLOBAL_SERVER_CREDENTIALS, _
				$WINHTTP_OPTION_WORKER_THREAD_COUNT, $WINHTTP_OPTION_WRITE_BUFFER_SIZE
			$sType = "dword*"
			$iSize = 4
		Case $WINHTTP_OPTION_CALLBACK, $WINHTTP_OPTION_PASSPORT_SIGN_OUT
			$sType = "ptr*"
			$iSize = 4
			If @AutoItX64 Then $iSize = 8
			If Not IsPtr($vSetting) Then Return SetError(3, 0, 0)
		Case $WINHTTP_OPTION_CONTEXT_VALUE
			$sType = "dword_ptr"
			$iSize = 4
			If @AutoItX64 Then $iSize = 8
		Case $WINHTTP_OPTION_PASSWORD, $WINHTTP_OPTION_PROXY_PASSWORD, $WINHTTP_OPTION_PROXY_USERNAME, $WINHTTP_OPTION_USER_AGENT, $WINHTTP_OPTION_USERNAME
			$sType = "wstr"
			If (IsDllStruct($vSetting) Or IsPtr($vSetting)) Then Return SetError(3, 0, 0)
			If $iSize < 1 Then $iSize = StringLen($vSetting)
		Case $WINHTTP_OPTION_CLIENT_CERT_CONTEXT, $WINHTTP_OPTION_GLOBAL_PROXY_CREDS, $WINHTTP_OPTION_GLOBAL_SERVER_CREDS, $WINHTTP_OPTION_HTTP_VERSION, _
				$WINHTTP_OPTION_PROXY
			$sType = "ptr"
			If Not (IsDllStruct($vSetting) Or IsPtr($vSetting)) Then Return SetError(3, 0, 0)
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch
	If $iSize < 1 Then
		If IsDllStruct($vSetting) Then
			$iSize = DllStructGetSize($vSetting)
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Local $aCall
	If IsDllStruct($vSetting) Then
		$aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSetOption", "handle", $hInternet, "dword", $iOption, $sType, DllStructGetPtr($vSetting), "dword", $iSize)
	Else
		$aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSetOption", "handle", $hInternet, "dword", $iOption, $sType, $vSetting, "dword", $iSize)
	EndIf
	If @error Or Not $aCall[0] Then Return SetError(4, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpSetOption

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSetStatusCallback
; Description ...: Sets up a callback function that WinHttp can call as progress is made during an operation.
; Syntax.........: _WinHttpSetStatusCallback($hInternet, $hInternetCallback [, $iNotificationFlags = Default ])
; Parameters ....: $hInternet - Handle for which the callback is to be set.
;                  $hInternetCallback - Callback function to call when progress is made.
;                  $iNotificationFlags - [optional] Flags to indicate which events activate the callback function. Default is $WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS.
; Return values .: Success - Returns a pointer to the previously defined status callback function or NULL if there was no previously defined status callback function.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......:
; Related .......: _WinHttpOpen
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384115(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpSetStatusCallback($hInternet, $hInternetCallback, $iNotificationFlags = Default)
	__WinHttpDefault($iNotificationFlags, $WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "ptr", "WinHttpSetStatusCallback", _
			"handle", $hInternet, _
			"ptr", DllCallbackGetPtr($hInternetCallback), _
			"dword", $iNotificationFlags, _
			"ptr", 0)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_WinHttpSetStatusCallback

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSetTimeouts
; Description ...: Sets time-outs involved with HTTP transactions.
; Syntax.........: _WinHttpSetTimeouts($hInternet [, $iResolveTimeout = Default [, $iConnectTimeout = Default [, $iSendTimeout = Default [, $iReceiveTimeout = Default ]]]])
; Parameters ....: $hInternet - Handle returned by _WinHttpOpen() or _WinHttpOpenRequest().
;                  $iResolveTimeout - [optional] Time-out value, in milliseconds, to use for name resolution. Default is 0 ms.
;                  $iConnectTimeout - [optional] Time-out value, in milliseconds, to use for server connection requests. Default is 60000 ms.
;                  $iSendTimeout - [optional] Time-out value, in milliseconds, to use for sending requests. Default is 30000 ms.
;                  $iReceiveTimeout - [optional] Time-out value, in milliseconds, to receive a response to a request. Default is 30000 ms.
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......: Initial values are:
;                  |- $iResolveTimeout = 0
;                  |- $iConnectTimeout = 60000
;                  |- $iSendTimeout = 30000
;                  |- $iReceiveTimeout = 30000
; Related .......: _WinHttpReceiveResponse
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384116(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpSetTimeouts($hInternet, $iResolveTimeout = Default, $iConnectTimeout = Default, $iSendTimeout = Default, $iReceiveTimeout = Default)
	__WinHttpDefault($iResolveTimeout, 0)
	__WinHttpDefault($iConnectTimeout, 60000)
	__WinHttpDefault($iSendTimeout, 30000)
	__WinHttpDefault($iReceiveTimeout, 30000)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpSetTimeouts", _
			"handle", $hInternet, _
			"int", $iResolveTimeout, _
			"int", $iConnectTimeout, _
			"int", $iSendTimeout, _
			"int", $iReceiveTimeout)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_WinHttpSetTimeouts

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpSimpleFormFill
; Description ...: Fills form.
; Syntax.........: _WinHttpSimpleFormFill(ByRef $hInternet [, $sActionPage = Default [, $sFormId = Default [, $sFieldId1 = Default [, $sData1 = Default [, (...)]]]]])
; Parameters ....: $hInternet - Handle returned by _WinHttpConnect() or string variable with form.
;                  $sActionPage -  [optional] path to the page with form or session handle if $hInternet is string (default: "" - empty string; meaning 'default' page on the server in former).
;                  $sFormId - [optional] Id of the form. Can be name or zero-based index too (read Remarks section).
;                  $sFieldId1 - [optional] Id of the input.
;                  $sData1 - [optional] Data to set to coresponding field.
;                  (...) - [optional] Other pairs of Id/Data. Overall number of fields is 40.
; Return values .: Success - Returns HTML source of the page returned by the server on submited form.
;                  Failure - Returns empty string and sets @error:
;                  |1 - No forms on the page
;                  |2 - Invalid form
;                  |3 - No forms with specified attributes on the page
;                  |4 - Connection problems
;                  |5 - form's "action" is invalid
;                  |6 - invalid session handle passed
; Author ........: trancexx
; Modified.......:
; Remarks .......: In case form requires redirection and $hInternet is internet handle, this handle will be closed and replaced with new and required one.
;                  +When $hInternet is form string, form's "action" must specify URL and $sActionPage parameter must be session handle. On succesful call this variable will be changed to connection handle of the internally made connection.
;                  Don't forget to close this handle after the function returns and when no longer needed.
;                  +$sFormId specifies Id of the form same as .getElementById(FormId). Aditionally you can use "index:FormIndex" to
;                  identify form by its zero-based index number (in case of e.g. three forms on some page first one will have index=0, second index=1, third index=2).
;                  Use "name:FormName" to identify form by its name like with .getElementsByName(FormName). FormName will be taken to be what's right of colon mark.
;                  In that case first form with that name is filled.
;                  +As for fields, If "name:FieldName" option is used all the fields except last with that name are removed from the form. Last one is filled with specified $sData data.
;                  +This function can be used to fill forms with up to 40 fields at once.
;                  +"Submit" control you want to keep (click) set to True. If no such control is set then the first one found in the form is "clicked"
;                  and the other removed from the submited form. "Checkbox" and "Button" input types are removed from the submitted form unless explicitly set. Same goes for "Radio" with exception that
;                  only one such control can be set, the rest are removed. These controls are set by their values. Wrong value makes them invalid and therefore not part of the submited data.
;                  +All other non-set fields are left default.
;                  +
;                  +If this function is used to upload multiple files then there are two available ways. Default would be to submit the form following RFC2388 specification.
;                  In that case every file is represented as multipart/mixed part embedded within the multipart/form-data.
;                  +If you want to upload using alternative way (to avoid certain PHP bug that could exist on server side) then prefix the file string with "PHP#50338:" string.
;                  +For example: ..."name:files[]", "PHP#50338:" & $sFile1 & ...
;                  +Muliple files are always separated with vertical line ASCII character when filling the form.
; Related .......: _WinHttpConnect
; Link ..........:
; Example .......:
;============================================================================================
Func _WinHttpSimpleFormFill(ByRef $hInternet, $sActionPage = Default, $sFormId = Default, $sFieldId1 = Default, $sData1 = Default, $sFieldId2 = Default, $sData2 = Default, $sFieldId3 = Default, $sData3 = Default, $sFieldId4 = Default, $sData4 = Default, $sFieldId5 = Default, $sData5 = Default, $sFieldId6 = Default, $sData6 = Default, $sFieldId7 = Default, $sData7 = Default, $sFieldId8 = Default, $sData8 = Default, $sFieldId9 = Default, $sData9 = Default, $sFieldId10 = Default, $sData10 = Default, _
		$sFieldId11 = Default, $sData11 = Default, $sFieldId12 = Default, $sData12 = Default, $sFieldId13 = Default, $sData13 = Default, $sFieldId14 = Default, $sData14 = Default, $sFieldId15 = Default, $sData15 = Default, $sFieldId16 = Default, $sData16 = Default, $sFieldId17 = Default, $sData17 = Default, $sFieldId18 = Default, $sData18 = Default, $sFieldId19 = Default, $sData19 = Default, $sFieldId20 = Default, $sData20 = Default, _
		$sFieldId21 = Default, $sData21 = Default, $sFieldId22 = Default, $sData22 = Default, $sFieldId23 = Default, $sData23 = Default, $sFieldId24 = Default, $sData24 = Default, $sFieldId25 = Default, $sData25 = Default, $sFieldId26 = Default, $sData26 = Default, $sFieldId27 = Default, $sData27 = Default, $sFieldId28 = Default, $sData28 = Default, $sFieldId29 = Default, $sData29 = Default, $sFieldId30 = Default, $sData30 = Default, _
		$sFieldId31 = Default, $sData31 = Default, $sFieldId32 = Default, $sData32 = Default, $sFieldId33 = Default, $sData33 = Default, $sFieldId34 = Default, $sData34 = Default, $sFieldId35 = Default, $sData35 = Default, $sFieldId36 = Default, $sData36 = Default, $sFieldId37 = Default, $sData37 = Default, $sFieldId38 = Default, $sData38 = Default, $sFieldId39 = Default, $sData39 = Default, $sFieldId40 = Default, $sData40 = Default)
	#forceref $sFieldId1, $sData1, $sFieldId2, $sData2, $sFieldId3, $sData3, $sFieldId4, $sData4, $sFieldId5, $sData5, $sFieldId6, $sData6, $sFieldId7, $sData7, $sFieldId8, $sData8, $sFieldId9, $sData9, $sFieldId10, $sData10
	#forceref $sFieldId11, $sData11, $sFieldId12, $sData12, $sFieldId13, $sData13, $sFieldId14, $sData14, $sFieldId15, $sData15, $sFieldId16, $sData16, $sFieldId17, $sData17, $sFieldId18, $sData18, $sFieldId19, $sData19, $sFieldId20, $sData20
	#forceref $sFieldId21, $sData21, $sFieldId22, $sData22, $sFieldId23, $sData23, $sFieldId24, $sData24, $sFieldId25, $sData25, $sFieldId26, $sData26, $sFieldId27, $sData27, $sFieldId28, $sData28, $sFieldId29, $sData29, $sFieldId30, $sData30
	#forceref $sFieldId31, $sData31, $sFieldId32, $sData32, $sFieldId33, $sData33, $sFieldId34, $sData34, $sFieldId35, $sData35, $sFieldId36, $sData36, $sFieldId37, $sData37, $sFieldId38, $sData38, $sFieldId39, $sData39, $sFieldId40, $sData40
	__WinHttpDefault($sActionPage, "")
	; Get page source
	Local $hOpen, $sHTML, $fVarForm
	If IsString($hInternet) Then ; $hInternet is page source
		$sHTML = $hInternet
		If _WinHttpQueryOption($sActionPage, $WINHTTP_OPTION_HANDLE_TYPE) <> $WINHTTP_HANDLE_TYPE_SESSION Then Return SetError(6, 0, "")
		$hOpen = $sActionPage
		$fVarForm = True
	Else
		$sHTML = _WinHttpSimpleRequest($hInternet, Default, $sActionPage, Default, Default, "Accept: text/html;q=0.9,text/plain;q=0.8,*/*;q=0.5")
	EndIf
	$sHTML = StringRegExpReplace($sHTML, "(?s)<!--.*?-->", "") ; removing comments
	$sHTML = StringRegExpReplace($sHTML, "(?s)<!\[CDATA\[.*?\]\]>", "") ; removing CDATA
	Local $fSend = False ; preset 'Sending flag'
	; Find all forms on page
	Local $aForm = StringRegExp($sHTML, "(?si)<\s*form\s*(.*?)<\s*/form\s*>", 3)
	If @error Then Return SetError(1, 0, "") ; There are no forms available
	; Process input
	Local $fGetFormByName, $sFormName, $fGetFormByIndex, $fGetFormById, $iFormIndex
	Local $aSplitForm = StringSplit($sFormId, ":", 2)
	If @error Then ; like .getElementById(FormId)
		$fGetFormById = True
	Else
		If $aSplitForm[0] = "name" Then ; like .getElementsByName(FormName)
			$sFormName = $aSplitForm[1]
			$fGetFormByName = True
		ElseIf $aSplitForm[0] = "index" Then
			$iFormIndex = Number($aSplitForm[1])
			$fGetFormByIndex = True
		Else ; like .getElementById(FormId)
			$sFormId = $aSplitForm[0]
			$fGetFormById = True
		EndIf
	EndIf
	; Variables
	Local $sForm, $sAttributes, $aAttributes, $aInput
	Local $iNumParams = Ceiling((@NumParams - 2) / 2)
	Local $sAddData
	Local $aCrackURL, $sNewURL
	; Loop thru all forms on the page and find one that was specified
	For $iFormOrdinal = 0 To UBound($aForm) - 1
		If $fGetFormByIndex And $iFormOrdinal <> $iFormIndex Then ContinueLoop
		$sForm = $aForm[$iFormOrdinal]
		; Extract form attributes
		$sAttributes = StringRegExp($sForm, "(?s)(.*?)>", 3)
		If Not @error Then $sAttributes = $sAttributes[0]
		$aAttributes = StringRegExp($sAttributes, '\s*([^=]+)\h*=\h*(?:"|''|)(.*?)(?:"|''| |\Z)', 3) ; e.g. method="post" or method=post or method='post'
		If @error Then Return SetError(2, 0, "") ; invalid form
		If Mod(UBound($aAttributes), 2) Then ReDim $aAttributes[UBound($aAttributes) + 1]
		Local $sAction = "", $sAccept = "", $sEnctype = "", $sMethod = "", $sName = "", $sId = ""
		; Check set attributes
		For $i = 0 To UBound($aAttributes) - 2 Step 2 ; array of form attributes
			Switch $aAttributes[$i]
				Case "action"
					$sAction = StringReplace($aAttributes[$i + 1], "&amp;", "&")
				Case "accept"
					$sAccept = $aAttributes[$i + 1]
				Case "enctype"
					$sEnctype = $aAttributes[$i + 1]
				Case "id"
					$sId = $aAttributes[$i + 1]
					If $fGetFormById And $sFormId <> Default And $aAttributes[$i + 1] <> $sFormId Then ContinueLoop 2
				Case "method"
					$sMethod = $aAttributes[$i + 1]
				Case "name"
					$sName = $aAttributes[$i + 1]
					If $fGetFormByName And $sFormName <> $sName Then ContinueLoop 2
			EndSwitch
		Next
		If $sFormId <> Default And $fGetFormById And $sFormId <> $sId Then ContinueLoop
		If $fGetFormByName And $sFormName <> $sName Then ContinueLoop
		If Not $sMethod Then $sMethod = "GET"
		$aCrackURL = _WinHttpCrackUrl($sAction)
		If @error Then
			If $sAction Then
				If StringLeft($sAction, 1) <> "/" Then
					Local $sCurrent
					Local $aURL = StringRegExp($sActionPage, '(.*)/', 3)
					If Not @error Then $sCurrent = $aURL[0]
					If $sCurrent Then $sAction = $sCurrent & "/" & $sAction
				EndIf
				If StringLeft($sAction, 1) = "?" Then $sAction = $sActionPage & $sAction
			EndIf
			If Not $sAction Then $sAction = $sActionPage
			$sAction = StringRegExpReplace($sAction, "\A(/*\.\./)*", "") ; /../
		Else
			$sNewURL = $aCrackURL[2]
			$sAction = $aCrackURL[6] & $aCrackURL[7]
		EndIf
		If $fVarForm And Not $sNewURL Then Return SetError(5, 0, "") ; "action" must have URL specified
		; Requested form is found. Set $fSend flag to true
		$fSend = True
		Local $aSplit, $sBoundary, $sPassedId, $sPassedData, $iNumRepl, $fMultiPart = False, $sSubmit, $sRadio, $sCheckBox, $sButton
		Local $sGrSep = Chr(29)
		$aInput = StringRegExp($sForm, "(?si)<\h*(?:input|textarea|label|fieldset|legend|select|optgroup|option|button)\h*(.*?)/*\h*>", 3)
		If @error Then Return SetError(2, 0, "") ; invalid form
		Local $aInputIds[4][UBound($aInput)]
		Switch $sEnctype
			Case "", "application/x-www-form-urlencoded"
				For $i = 0 To UBound($aInput) - 1 ; for all input elements
					__WinHttpFormAttrib($aInputIds, $i, $aInput[$i])
					If $aInputIds[1][$i] Then ; if there is 'name' field then add it
						$sAddData &= $aInputIds[1][$i] & "=" & $aInputIds[2][$i] & "&"
						If $aInputIds[3][$i] = "submit" Then $sSubmit &= $aInputIds[1][$i] & "=" & $aInputIds[2][$i] & $sGrSep ; add to overall "submit" string
						If $aInputIds[3][$i] = "radio" Then $sRadio &= $aInputIds[1][$i] & "=" & $aInputIds[2][$i] & $sGrSep ; add to overall "radio" string
						If $aInputIds[3][$i] = "checkbox" Then $sCheckBox &= $aInputIds[1][$i] & "=" & $aInputIds[2][$i] & $sGrSep ; add to overall "checkbox" string
						If $aInputIds[3][$i] = "button" Then $sButton &= $aInputIds[1][$i] & "=" & $aInputIds[2][$i] & $sGrSep ; add to overall "button" string
					EndIf
				Next
				$sSubmit = StringTrimRight($sSubmit, 1)
				$sRadio = StringTrimRight($sRadio, 1)
				$sCheckBox = StringTrimRight($sCheckBox, 1)
				$sButton = StringTrimRight($sButton, 1)
				$sAddData = StringTrimRight($sAddData, 1)
				For $k = 1 To $iNumParams
					$sPassedData = __WinHttpURLEncode(Eval("sData" & $k))
					$sPassedId = Eval("sFieldId" & $k)
					$aSplit = StringSplit($sPassedId, ":", 2)
					If @error Or $aSplit[0] <> "name" Then ; like .getElementById
						For $j = 0 To UBound($aInputIds, 2) - 1
							If $aInputIds[0][$j] = $sPassedId Then
								If $aInputIds[3][$j] = "submit" Then
									If $sPassedData = True Then ; if this "submit" is set to TRUE then
										If $sSubmit Then ; If not already processed; only the first is valid
											Local $fDelId = False
											For $sChunkSub In StringSplit($sSubmit, $sGrSep, 3) ; go tru all "submit" controls
												If $sChunkSub = $aInputIds[1][$j] & "=" & $aInputIds[2][$j] Then
													If $fDelId Then $sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $sChunkSub & "\E(?:&|\Z)", "&", 1)
													$fDelId = True
												Else
													$sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $sChunkSub & "\E(?:&|\Z)", "&") ; delete all but the TRUE one
												EndIf
												__WinHttpTrimBounds($sAddData, "&")
											Next
											$sSubmit = ""
										EndIf
									EndIf
								ElseIf $aInputIds[3][$j] = "radio" Then
									If $sRadio Then ; If not already processed; only the first is valid
										If $sPassedData = $aInputIds[2][$j] Then
											For $sChunkSub In StringSplit($sRadio, $sGrSep, 3) ; go tru all "radio" controls
												If $sChunkSub <> $aInputIds[1][$j] & "=" & $sPassedData Then ; delete all but the set one
													$sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $sChunkSub & "\E(?:&|\Z)", "&")
													__WinHttpTrimBounds($sAddData, "&")
												EndIf
											Next
											$sRadio = ""
										EndIf
									EndIf
								ElseIf $aInputIds[3][$j] = "checkbox" Then
									$sCheckBox = StringRegExpReplace($sCheckBox, "(?i)\Q" & $aInputIds[1][$j] & "=" & $sPassedData & "\E" & $sGrSep & "*", "")
									__WinHttpTrimBounds($sCheckBox, $sGrSep)
								ElseIf $aInputIds[3][$j] = "button" Then
									$sButton = StringRegExpReplace($sButton, "(?i)\Q" & $aInputIds[1][$j] & "=" & $sPassedData & "\E" & $sGrSep & "*", "")
									__WinHttpTrimBounds($sButton, $sGrSep)
								Else
									$sAddData = StringRegExpReplace(StringReplace($sAddData, "&", "&&"), "(?i)(?:&|\A)\Q" & $aInputIds[1][$j] & "=" & $aInputIds[2][$j] & "\E(?:&|\Z)", "&" & $aInputIds[1][$j] & "=" & $sPassedData & "&")
									$iNumRepl = @extended
									$sAddData = StringReplace($sAddData, "&&", "&")
									If $iNumRepl > 1 Then ; equalize ; TODO: remove duplicates
										$sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $aInputIds[1][$j] & "\E=.*?(?:&|\Z)", "&", $iNumRepl - 1)
									EndIf
									__WinHttpTrimBounds($sAddData, "&")
								EndIf
							EndIf
						Next
					Else ; like .getElementsByName
						For $j = 0 To UBound($aInputIds, 2) - 1
							If $aInputIds[3][$j] = "submit" Then
								If $sPassedData = True Then ; if this "submit" is set to TRUE then
									If $aInputIds[1][$j] = $aSplit[1] Then
										If $sSubmit Then ; If not already processed; only the first is valid
											Local $fDel = False
											For $sChunkSub In StringSplit($sSubmit, $sGrSep, 3) ; go tru all "submit" controls
												If $sChunkSub = $aInputIds[1][$j] & "=" & $aInputIds[2][$j] Then
													If $fDel Then $sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $sChunkSub & "\E(?:&|\Z)", "&", 1)
													$fDel = True
												Else
													$sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $sChunkSub & "\E(?:&|\Z)", "&") ; delete all but the TRUE one
												EndIf
												__WinHttpTrimBounds($sAddData, "&")
											Next
											$sSubmit = ""
										EndIf
										ContinueLoop 2 ; process next parameter
									EndIf
								Else ; False means do nothing
									ContinueLoop 2 ; process next parameter
								EndIf
							ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "radio" Then
								If $sRadio Then ; If not already processed; only the first is valid
									For $sChunkSub In StringSplit($sRadio, $sGrSep, 3) ; go tru all "radio" controls
										If $sChunkSub <> $aInputIds[1][$j] & "=" & $sPassedData Then ; delete all but the set one
											$sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $sChunkSub & "\E(?:&|\Z)", "&")
											__WinHttpTrimBounds($sAddData, "&")
										EndIf
									Next
									$sRadio = ""
								EndIf
								ContinueLoop 2 ; process next parameter
							ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "checkbox" Then
								$sCheckBox = StringRegExpReplace($sCheckBox, "(?i)\Q" & $aInputIds[1][$j] & "=" & $sPassedData & "\E" & $sGrSep & "*", "")
								__WinHttpTrimBounds($sCheckBox, $sGrSep)
								ContinueLoop 2 ; process next parameter
							ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "button" Then
								$sButton = StringRegExpReplace($sButton, "(?i)\Q" & $aInputIds[1][$j] & "=" & $sPassedData & "\E" & $sGrSep & "*", "")
								__WinHttpTrimBounds($sButton, $sGrSep)
								ContinueLoop 2 ; process next parameter
							EndIf
						Next
						$sAddData = StringRegExpReplace(StringReplace($sAddData, "&", "&&"), "(?i)(?:&|\A)\Q" & $aSplit[1] & "\E=.*?(?:&|\Z)", "&" & $aSplit[1] & "=" & $sPassedData & "&")
						$iNumRepl = @extended
						$sAddData = StringReplace($sAddData, "&&", "&")
						If $iNumRepl > 1 Then ; remove duplicates
							$sAddData = StringRegExpReplace($sAddData, "(?i)(?:&|\A)\Q" & $aSplit[1] & "\E=.*?(?:&|\Z)", "&", $iNumRepl - 1)
						EndIf
						__WinHttpTrimBounds($sAddData, "&")
					EndIf
				Next
				__WinHttpFinalizeCtrls($sSubmit, $sRadio, $sCheckBox, $sButton, $sAddData, $sGrSep, "&")
				If $sMethod = "GET" Then
					$sAction &= "?" & $sAddData
					$sAddData = "" ; not to send as addition to the request (this is GET)
				EndIf
			Case "multipart/form-data"
				If $sMethod = "POST" Then ; can't be GET
					$fMultiPart = True
					; Define boundary line
					$sBoundary = StringFormat("%s%.5f", "----WinHttpBoundaryLine_", Random(10000, 99999))
					Local $sCDisp = 'Content-Disposition: form-data; name="'
					For $i = 0 To UBound($aInput) - 1 ; for all input elements
						__WinHttpFormAttrib($aInputIds, $i, $aInput[$i])
						If $aInputIds[1][$i] Then ; if there is 'name' field
							If $aInputIds[3][$i] = "file" Then
								$sAddData &= "--" & $sBoundary & @CRLF & _
										$sCDisp & $aInputIds[1][$i] & '"; filename=""' & @CRLF & @CRLF & _
										$aInputIds[2][$i] & @CRLF
							Else
								$sAddData &= "--" & $sBoundary & @CRLF & _
										$sCDisp & $aInputIds[1][$i] & '"' & @CRLF & @CRLF & _
										$aInputIds[2][$i] & @CRLF
							EndIf
							If $aInputIds[3][$i] = "submit" Then $sSubmit &= "--" & $sBoundary & @CRLF & _
									$sCDisp & $aInputIds[1][$i] & '"' & @CRLF & @CRLF & _
									$aInputIds[2][$i] & @CRLF & $sGrSep
							If $aInputIds[3][$i] = "radio" Then $sRadio &= "--" & $sBoundary & @CRLF & _
									$sCDisp & $aInputIds[1][$i] & '"' & @CRLF & @CRLF & _
									$aInputIds[2][$i] & @CRLF & $sGrSep
							If $aInputIds[3][$i] = "checkbox" Then $sCheckBox &= "--" & $sBoundary & @CRLF & _
									$sCDisp & $aInputIds[1][$i] & '"' & @CRLF & @CRLF & _
									$aInputIds[2][$i] & @CRLF & $sGrSep
							If $aInputIds[3][$i] = "button" Then $sButton &= "--" & $sBoundary & @CRLF & _
									$sCDisp & $aInputIds[1][$i] & '"' & @CRLF & @CRLF & _
									$aInputIds[2][$i] & @CRLF & $sGrSep
						EndIf
					Next
					$sSubmit = StringTrimRight($sSubmit, 1)
					$sRadio = StringTrimRight($sRadio, 1)
					$sCheckBox = StringTrimRight($sCheckBox, 1)
					$sButton = StringTrimRight($sButton, 1)
					$sAddData &= "--" & $sBoundary & "--" & @CRLF
					For $k = 1 To $iNumParams
						$sPassedData = Eval("sData" & $k)
						$sPassedId = Eval("sFieldId" & $k)
						$aSplit = StringSplit($sPassedId, ":", 2)
						If @error Or $aSplit[0] <> "name" Then ; like getElementById
							For $j = 0 To UBound($aInputIds, 2) - 1
								If $aInputIds[0][$j] = $sPassedId Then
									If $aInputIds[3][$j] = "file" Then
										$sAddData = StringReplace($sAddData, _
												$sCDisp & $aInputIds[1][$j] & '"; filename=""' & @CRLF & @CRLF & $aInputIds[2][$j] & @CRLF, _
												__WinHttpFileContent($sAccept, $aInputIds[1][$j], $sPassedData, $sBoundary))
									ElseIf $aInputIds[3][$j] = "submit" Then
										If $sPassedData = True Then ; if this "submit" is set to TRUE then
											If $sSubmit Then ; If not already processed; only the first is valid
												Local $fMDelId = False
												For $sChunkSub In StringSplit($sSubmit, $sGrSep, 3) ; go tru all "submit" controls
													If $sChunkSub = "--" & $sBoundary & @CRLF & _
															$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
															$aInputIds[2][$j] & @CRLF Then
														If $fMDelId Then $sAddData = StringReplace($sAddData, $sChunkSub, "", 1) ; Removing duplicates
														$fMDelId = True
													Else
														$sAddData = StringReplace($sAddData, $sChunkSub, "") ; delete all but the TRUE one
													EndIf
												Next
												$sSubmit = ""
											EndIf
										EndIf
									ElseIf $aInputIds[3][$j] = "radio" Then
										If $sRadio Then ; If not already processed; only the first is valid
											If $sPassedData = $aInputIds[2][$j] Then
												For $sChunkSub In StringSplit($sRadio, $sGrSep, 3) ; go tru all "radio" controls
													If $sChunkSub <> "--" & $sBoundary & @CRLF & _
															$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
															$sPassedData & @CRLF Then $sAddData = StringReplace($sAddData, $sChunkSub, "") ; delete all but the set one
												Next
												$sRadio = ""
											EndIf
										EndIf
									ElseIf $aInputIds[3][$j] = "checkbox" Then
										$sCheckBox = StringRegExpReplace($sCheckBox, "(?i)\Q--" & $sBoundary & @CRLF & _
												$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
												$sPassedData & @CRLF & "\E" & $sGrSep & "*", "")
										If StringRight($sCheckBox, 1) = $sGrSep Then $sCheckBox = StringTrimRight($sCheckBox, 1)
									ElseIf $aInputIds[3][$j] = "button" Then
										$sButton = StringRegExpReplace($sButton, "(?i)\Q--" & $sBoundary & @CRLF & _
												$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
												$sPassedData & @CRLF & "\E" & $sGrSep & "*", "")
										If StringRight($sButton, 1) = $sGrSep Then $sButton = StringTrimRight($sButton, 1)
									Else
										$sAddData = StringReplace($sAddData, _
												$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & $aInputIds[2][$j] & @CRLF, _
												$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & $sPassedData & @CRLF)
										$iNumRepl = @extended
										If $iNumRepl > 1 Then ; equalize ; TODO: remove duplicates
											$sAddData = StringRegExpReplace($sAddData, '(?si)\Q--' & $sBoundary & @CRLF & $sCDisp & $aInputIds[1][$j] & '"' & '\E\r\n\r\n.*?\r\n', "", $iNumRepl - 1)
										EndIf
									EndIf
								EndIf
							Next
						Else ; like getElementsByName
							For $j = 0 To UBound($aInputIds, 2) - 1
								If $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "file" Then
									$sAddData = StringReplace($sAddData, _
											$sCDisp & $aSplit[1] & '"; filename=""' & @CRLF & @CRLF & $aInputIds[2][$j] & @CRLF, _
											__WinHttpFileContent($sAccept, $aInputIds[1][$j], $sPassedData, $sBoundary))
								ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "submit" Then
									If $sPassedData = True Then ; if this "submit" is set to TRUE then
										If $sSubmit Then ; If not already processed; only the first is valid
											Local $fMDel = False
											For $sChunkSub In StringSplit($sSubmit, $sGrSep, 3) ; go tru all "submit" controls
												If $sChunkSub = "--" & $sBoundary & @CRLF & _
														$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
														$aInputIds[2][$j] & @CRLF Then
													If $fMDel Then $sAddData = StringReplace($sAddData, $sChunkSub, "", 1) ; Removing duplicates
													$fMDel = True
												Else
													$sAddData = StringReplace($sAddData, $sChunkSub, "") ; delete all but the TRUE one
												EndIf
											Next
											$sSubmit = ""
										EndIf
										ContinueLoop 2 ; process next parameter
									Else ; False means do nothing
										ContinueLoop 2 ; process next parameter
									EndIf
								ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "radio" Then
									If $sRadio Then ; If not already processed; only the first is valid
										For $sChunkSub In StringSplit($sRadio, $sGrSep, 3) ; go tru all "radio" controls
											If $sChunkSub <> "--" & $sBoundary & @CRLF & _
													$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
													$sPassedData & @CRLF Then $sAddData = StringReplace($sAddData, $sChunkSub, "") ; delete all but the set one
										Next
										$sRadio = ""
									EndIf
									ContinueLoop 2 ; process next parameter
								ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "checkbox" Then
									$sCheckBox = StringRegExpReplace($sCheckBox, "(?i)\Q--" & $sBoundary & @CRLF & _
											$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
											$sPassedData & @CRLF & "\E" & $sGrSep & "*", "")
									If StringRight($sCheckBox, 1) = $sGrSep Then $sCheckBox = StringTrimRight($sCheckBox, 1)
									ContinueLoop 2 ; process next parameter
								ElseIf $aInputIds[1][$j] = $aSplit[1] And $aInputIds[3][$j] = "button" Then
									$sButton = StringRegExpReplace($sButton, "(?i)\Q--" & $sBoundary & @CRLF & _
											$sCDisp & $aInputIds[1][$j] & '"' & @CRLF & @CRLF & _
											$sPassedData & @CRLF & "\E" & $sGrSep & "*", "")
									If StringRight($sButton, 1) = $sGrSep Then $sButton = StringTrimRight($sButton, 1)
									ContinueLoop 2 ; process next parameter
								EndIf
							Next
							$sAddData = StringRegExpReplace($sAddData, '(?si)\Q' & $sCDisp & $aSplit[1] & '"' & '\E\r\n\r\n.*?\r\n', _
									$sCDisp & $aSplit[1] & '"' & @CRLF & @CRLF & $sPassedData & @CRLF)
							$iNumRepl = @extended
							If $iNumRepl > 1 Then ; remove duplicates
								$sAddData = StringRegExpReplace($sAddData, '(?si)\Q--' & $sBoundary & @CRLF & $sCDisp & $aSplit[1] & '"' & '\E\r\n\r\n.*?\r\n', "", $iNumRepl - 1)
							EndIf
						EndIf
					Next
				EndIf
				__WinHttpFinalizeCtrls($sSubmit, $sRadio, $sCheckBox, $sButton, $sAddData, $sGrSep)
		EndSwitch
	Next
	; Send
	If $fSend Then
		If $fVarForm Then
			$hInternet = _WinHttpConnect($hOpen, $sNewURL)
		Else
			If $sNewURL Then
				$hOpen = _WinHttpQueryOption($hInternet, $WINHTTP_OPTION_PARENT_HANDLE)
				_WinHttpCloseHandle($hInternet)
				$hInternet = _WinHttpConnect($hOpen, $sNewURL)
			EndIf
		EndIf
		Local $hRequest = __WinHttpFormSend($hInternet, $sMethod, $sAction, $fMultiPart, $sBoundary, $sAddData)
		If _WinHttpQueryHeaders($hRequest, $WINHTTP_QUERY_STATUS_CODE) > $HTTP_STATUS_BAD_REQUEST Then
			_WinHttpCloseHandle($hRequest)
			$hRequest = __WinHttpFormSend($hInternet, $sMethod, $sAction, $fMultiPart, $sBoundary, $sAddData, True) ; try adding $WINHTTP_FLAG_SECURE
		EndIf
		Local $sReturned = _WinHttpSimpleReadData($hRequest)
		If @error Then
			_WinHttpCloseHandle($hRequest)
			Return SetError(4, 0, "") ; either site is expiriencing problems or your connection
		EndIf
		_WinHttpCloseHandle($hRequest)
		Return $sReturned
	EndIf
	; If here then there is no form on the page with specified attributes (name, id or index)
	Return SetError(3, 0, "")
EndFunc   ;==>_WinHttpSimpleFormFill

; #FUNCTION# ====================================================================================================================
; Name...........: _WinHttpSimpleReadData
; Description ...: Reads data from a request
; Syntax.........: _WinHttpSimpleReadData($hRequest [, $iMode = Default ])
; Parameters ....: $hRequest - request handle after _WinHttpReceiveResponse
;                  $iMode         - [optional] type of data returned (default: 0)
;                  |0 - ASCII-String
;                  |1 - UTF-8-String
;                  |2 - binary data
; Return values .: Success      - String or binary depending on $iMode
;                  Failure      - empty string or empty binary (mode 2) and set @error
;                  |1 - invalid mode
;                  |2 - no data available
; Author ........: ProgAndy
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpReadData, _WinHttpSimpleRequest, _WinHttpSimpleSSLRequest
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinHttpSimpleReadData($hRequest, $iMode = Default)
	__WinHttpDefault($iMode, 0)
	If $iMode > 2 Or $iMode < 0 Then Return SetError(1, 0, '')
	Local $vData = ''
	If $iMode = 2 Then $vData = Binary('')
	If _WinHttpQueryDataAvailable($hRequest) Then
		If $iMode = 0 Then
			Do
				$vData &= _WinHttpReadData($hRequest, 0)
			Until @error
			Return $vData
		Else
			$vData = Binary('')
			Do
				$vData &= _WinHttpReadData($hRequest, 2)
			Until @error
			If $iMode = 1 Then Return BinaryToString($vData, 4)
			Return $vData
		EndIf
	EndIf
	Return SetError(2, 0, $vData)
EndFunc   ;==>_WinHttpSimpleReadData

; #FUNCTION# ====================================================================================================================
; Name...........: _WinHttpSimpleReadDataAsync
; Description ...: Reads data from a request in asynchronous mode
; Syntax.........: _WinHttpSimpleReadDataAsync($hInternet, Byref $pBuffer [, $iNumberOfBytesToRead = Default ])
; Parameters ....: $hInternet - Request handle (first parameter while in callback function).
;                  $pBuffer - Pointer to memory buffer to which to read.
;                  $iNumberOfBytesToRead - [optional] The number of bytes to read. Default is 8192 bytes.
;                  |0 - ASCII-String
;                  |1 - UTF-8-String
;                  |2 - binary data
; Return values .: Same as for _WinHttpReadData. Due to async nature here it has no meaning except in case of possible error.
; Author ........: trancexx
; Modified.......:
; Remarks .......: WinHttp is rentrant during asynchronous completion callback. Make sure you have only one callback running and only one request handled though it at time.
;                  +Also make sure memory buffer is at least 8192 bytes in size if $iNumberOfBytesToRead is left default.
; Related .......: _WinHttpSimpleReadData, _WinHttpReadData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinHttpSimpleReadDataAsync($hInternet, ByRef $pBuffer, $iNumberOfBytesToRead = Default)
	__WinHttpDefault($iNumberOfBytesToRead, 8192)
	Local $vOut = _WinHttpReadData($hInternet, 2, $iNumberOfBytesToRead, $pBuffer)
	Return SetError(@error, @extended, $vOut)
EndFunc   ;==>_WinHttpSimpleReadDataAsync

; #FUNCTION# ====================================================================================================================
; Name...........: _WinHttpSimpleRequest
; Description ...: A function to send a request in a simpler form
; Syntax.........: _WinHttpSimpleRequest($hConnect, $sType, $sPath [, $sReferrer = Default [, $sData = Default [, $sHeader = Default [, $fGetHeaders = Default [, $iMode = Default ]]]]])
; Parameters ....: $hConnect  - Handle from _WinHttpConnect
;                  $sType       - [optional] GET or POST (default: GET)
;                  $sPath       - [optional] request path (default: "" - empty string; meaning 'default' page on the server)
;                  $sReferrer   - [optional] referrer (default: $WINHTTP_NO_REFERER)
;                  $sData       - [optional] POST-Data (default: $WINHTTP_NO_REQUEST_DATA)
;                  $sHeader     - [optional] additional Headers (default: $WINHTTP_NO_ADDITIONAL_HEADERS)
;                  $fGetHeaders - [optional] return response headers (default: False)
;                  $iMode       - [optional] reading mode of result (default: 0)
;                  |0 - ASCII-text
;                  |1 - UTF-8 text
;                  |2 - binary data
; Return values .: Success      - response data if $fGetHeaders = False (default)
;                  |Array if $fGetHeaders = True
;                  | [0] - response headers
;                  | [1] - response data
;                  Failure      - 0 and set @error
;                  |1 - could not open request
;                  |2 - could not send request
;                  |3 - could not receive response
;                  |4 - $iMode is not valid
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......:
; Related .......: _WinHttpSimpleSSLRequest, _WinHttpSimpleSendRequest, _WinHttpSimpleSendSSLRequest, _WinHttpQueryHeaders, _WinHttpSimpleReadData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinHttpSimpleRequest($hConnect, $sType = Default, $sPath = Default, $sReferrer = Default, $sData = Default, $sHeader = Default, $fGetHeaders = Default, $iMode = Default)
	; Author: ProgAndy
	__WinHttpDefault($sType, "GET")
	__WinHttpDefault($sPath, "")
	__WinHttpDefault($sReferrer, $WINHTTP_NO_REFERER)
	__WinHttpDefault($sData, $WINHTTP_NO_REQUEST_DATA)
	__WinHttpDefault($sHeader, $WINHTTP_NO_ADDITIONAL_HEADERS)
	__WinHttpDefault($fGetHeaders, False)
	__WinHttpDefault($iMode, 0)
	If $iMode > 2 Or $iMode < 0 Then Return SetError(4, 0, 0)
	Local $hRequest = _WinHttpSimpleSendRequest($hConnect, $sType, $sPath, $sReferrer, $sData, $sHeader)
	If @error Then Return SetError(@error, 0, 0)
	If $fGetHeaders Then
		Local $aData[2] = [_WinHttpQueryHeaders($hRequest), _WinHttpSimpleReadData($hRequest, $iMode)]
		_WinHttpCloseHandle($hRequest)
		Return $aData
	EndIf
	Local $sOutData = _WinHttpSimpleReadData($hRequest, $iMode)
	_WinHttpCloseHandle($hRequest)
	Return $sOutData
EndFunc   ;==>_WinHttpSimpleRequest

; #FUNCTION# ====================================================================================================================
; Name...........: _WinHttpSimpleSendRequest
; Description ...: A function to send a request in a simpler form, but not read the data
; Syntax.........: _WinHttpSimpleSendRequest($hConnect, $sType, $sPath [, $sReferrer = Default [, $sData = Default [, $sHeader = Default ]]])
; Parameters ....: $hConnect  - Handle from _WinHttpConnect
;                  $sType       - [optional] GET or POST (default: GET)
;                  $sPath       - [optional] request path (default: "" - empty string; meaning 'default' page on the server)
;                  $sReferrer   - [optional] referrer (default: $WINHTTP_NO_REFERER)
;                  $sData       - [optional] POST-Data (default: $WINHTTP_NO_REQUEST_DATA)
;                  $sHeader     - [optional] additional Headers (default: $WINHTTP_NO_ADDITIONAL_HEADERS)
; Return values .: Success      - handle of request after _WinHttpReceiveResponse.
;                  Failure      - 0 and set @error
;                  |1 - could not open request
;                  |2 - could not send request
;                  |3 - could not receive response
; Author ........: ProgAndy
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpSimpleRequest, _WinHttpSimpleSendSSLRequest, _WinHttpSimpleReadData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinHttpSimpleSendRequest($hConnect, $sType = Default, $sPath = Default, $sReferrer = Default, $sData = Default, $sHeader = Default)
	; Author: ProgAndy
	__WinHttpDefault($sType, "GET")
	__WinHttpDefault($sPath, "")
	__WinHttpDefault($sReferrer, $WINHTTP_NO_REFERER)
	__WinHttpDefault($sData, $WINHTTP_NO_REQUEST_DATA)
	__WinHttpDefault($sHeader, $WINHTTP_NO_ADDITIONAL_HEADERS)
	Local $hRequest = _WinHttpOpenRequest($hConnect, $sType, $sPath, Default, $sReferrer)
	If Not $hRequest Then Return SetError(1, @error, 0)
	If $sType = "POST" And $sHeader = $WINHTTP_NO_ADDITIONAL_HEADERS Then $sHeader = "Content-Type: application/x-www-form-urlencoded" & @CRLF
	_WinHttpSendRequest($hRequest, $sHeader, $sData)
	If @error Then Return SetError(2, 0 * _WinHttpCloseHandle($hRequest), 0)
	_WinHttpReceiveResponse($hRequest)
	If @error Then Return SetError(3, 0 * _WinHttpCloseHandle($hRequest), 0)
	Return $hRequest
EndFunc   ;==>_WinHttpSimpleSendRequest

; #FUNCTION# ====================================================================================================================
; Name...........: _WinHttpSimpleSendSSLRequest
; Description ...: A function to send a SSL request in a simpler form, but not read the data
; Syntax.........: _WinHttpSimpleSendSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sData = Default [, $sHeader = Default ]]]]])
; Parameters ....: $hConnect  - Handle from _WinHttpConnect
;                  $sType       - [optional] GET or POST (default: GET)
;                  $sPath       - [optional] request path (default: "" - empty string; meaning 'default' page on the server)
;                  $sReferrer   - [optional] referrer (default: $WINHTTP_NO_REFERER)
;                  $sData       - [optional] POST-Data (default: $WINHTTP_NO_REQUEST_DATA)
;                  $sHeader     - [optional] additional Headers (default: $WINHTTP_NO_ADDITIONAL_HEADERS)
; Return values .: Success      - handle of request after _WinHttpReceiveResponse.
;                  Failure      - 0 and set @error
;                  |1 - could not open request
;                  |2 - could not send request
;                  |3 - could not receive response
; Author ........: ProgAndy
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpSimpleSSLRequest, _WinHttpSimpleSendRequest, _WinHttpSimpleReadData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinHttpSimpleSendSSLRequest($hConnect, $sType = Default, $sPath = Default, $sReferrer = Default, $sData = Default, $sHeader = Default)
	; Author: ProgAndy
	__WinHttpDefault($sType, "GET")
	__WinHttpDefault($sPath, "")
	__WinHttpDefault($sReferrer, $WINHTTP_NO_REFERER)
	__WinHttpDefault($sData, $WINHTTP_NO_REQUEST_DATA)
	__WinHttpDefault($sHeader, $WINHTTP_NO_ADDITIONAL_HEADERS)
	Local $hRequest = _WinHttpOpenRequest($hConnect, $sType, $sPath, Default, $sReferrer, Default, BitOR($WINHTTP_FLAG_SECURE, $WINHTTP_FLAG_ESCAPE_DISABLE))
	If Not $hRequest Then Return SetError(1, @error, 0)
	If $sType = "POST" And $sHeader = $WINHTTP_NO_ADDITIONAL_HEADERS Then $sHeader = "Content-Type: application/x-www-form-urlencoded" & @CRLF
	_WinHttpSendRequest($hRequest, $sHeader, $sData)
	If @error Then Return SetError(2, 0 * _WinHttpCloseHandle($hRequest), 0)
	_WinHttpReceiveResponse($hRequest)
	If @error Then Return SetError(3, 0 * _WinHttpCloseHandle($hRequest), 0)
	Return $hRequest
EndFunc   ;==>_WinHttpSimpleSendSSLRequest

; #FUNCTION# ====================================================================================================================
; Name...........: _WinHttpSimpleSSLRequest
; Description ...: A function to send a SSL request in a simpler form
; Syntax.........: _WinHttpSimpleSSLRequest($hConnect [, $sType [, $sPath [, $sReferrer = Default [, $sData = Default [, $sHeader = Default [, $fGetHeaders = Default [, $iMode = Default ]]]]]]])
; Parameters ....: $hConnect  - Handle from _WinHttpConnect
;                  $sType       - [optional] GET or POST (default: GET)
;                  $sPath       - [optional] request path (default: "" - empty string; meaning 'default' page on the server)
;                  $sReferrer   - [optional] referrer (default: $WINHTTP_NO_REFERER)
;                  $sData       - [optional] POST-Data (default: $WINHTTP_NO_REQUEST_DATA)
;                  $sHeader     - [optional] additional Headers (default: $WINHTTP_NO_ADDITIONAL_HEADERS)
;                  $fGetHeaders - [optional] return response headers (default: False)
;                  $iMode       - [optional] reading mode of result (default: 0)
;                  |0 - ASCII-text
;                  |1 - UTF-8 text
;                  |2 - binary data
; Return values .: Success      - response data if $fGetHeaders = False (default)
;                  |Array if $fGetHeaders = True
;                  | [0] - response headers
;                  | [1] - response data
;                  Failure      - 0 and set @error
;                  |1 - could not open request
;                  |2 - could not send request
;                  |3 - could not receive response
;                  |4 - $iMode is not valid
; Author ........: ProgAndy
; Modified.......: trancexx
; Remarks .......:
; Related .......: _WinHttpSimpleRequest, _WinHttpSimpleSendSSLRequest, _WinHttpSimpleSendRequest, _WinHttpQueryHeaders, _WinHttpSimpleReadData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinHttpSimpleSSLRequest($hConnect, $sType = Default, $sPath = Default, $sReferrer = Default, $sData = Default, $sHeader = Default, $fGetHeaders = Default, $iMode = Default)
	; Author: ProgAndy
	__WinHttpDefault($sType, "GET")
	__WinHttpDefault($sPath, "")
	__WinHttpDefault($sReferrer, $WINHTTP_NO_REFERER)
	__WinHttpDefault($sData, $WINHTTP_NO_REQUEST_DATA)
	__WinHttpDefault($sHeader, $WINHTTP_NO_ADDITIONAL_HEADERS)
	__WinHttpDefault($fGetHeaders, False)
	__WinHttpDefault($iMode, 0)
	If $iMode > 2 Or $iMode < 0 Then Return SetError(4, 0, 0)
	Local $hRequest = _WinHttpSimpleSendSSLRequest($hConnect, $sType, $sPath, $sReferrer, $sData, $sHeader)
	If @error Then Return SetError(@error, 0, 0)
	If $fGetHeaders Then
		Local $aData[2] = [_WinHttpQueryHeaders($hRequest), _WinHttpSimpleReadData($hRequest, $iMode)]
		_WinHttpCloseHandle($hRequest)
		Return $aData
	EndIf
	Local $sOutData = _WinHttpSimpleReadData($hRequest, $iMode)
	_WinHttpCloseHandle($hRequest)
	Return $sOutData
EndFunc   ;==>_WinHttpSimpleSSLRequest

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpTimeFromSystemTime
; Description ...: Formats a system date and time according to the HTTP version 1.0 specification.
; Syntax.........: _WinHttpTimeFromSystemTime()
; Parameters ....: None.
; Return values .: Success - Returns time string.
;                  Failure - Returns empty string and sets @error:
;                  |1 - Initial DllCall failed
;                  |2 - Main DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpTimeToSystemTime
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384117(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpTimeFromSystemTime()
	Local $SYSTEMTIME = DllStructCreate("word Year;" & _
			"word Month;" & _
			"word DayOfWeek;" & _
			"word Day;" & _
			"word Hour;" & _
			"word Minute;" & _
			"word Second;" & _
			"word Milliseconds")
	DllCall("kernel32.dll", "none", "GetSystemTime", "ptr", DllStructGetPtr($SYSTEMTIME))
	If @error Then Return SetError(1, 0, "")
	Local $tTime = DllStructCreate("wchar[62]")
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpTimeFromSystemTime", "ptr", DllStructGetPtr($SYSTEMTIME), "ptr", DllStructGetPtr($tTime))
	If @error Or Not $aCall[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($tTime, 1)
EndFunc   ;==>_WinHttpTimeFromSystemTime

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpTimeToSystemTime
; Description ...: Takes an HTTP time/date string and converts it to array (SYSTEMTIME structure values).
; Syntax.........: _WinHttpTimeToSystemTime($sHttpTime)
; Parameters ....: $sHttpTime - Date/time string to convert.
; Return values .: Success - Returns array with 8 elements:
;                  |$array[0] - is Year,
;                  |$array[1] - is Month,
;                  |$array[2] - is DayOfWeek,
;                  |$array[3] - is Day,
;                  |$array[4] - is Hour,
;                  |$array[5] - is Minute,
;                  |$array[6] - is Second.,
;                  |$array[7] - is Milliseconds.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinHttpTimeFromSystemTime
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384118(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpTimeToSystemTime($sHttpTime)
	Local $SYSTEMTIME = DllStructCreate("word Year;" & _
			"word Month;" & _
			"word DayOfWeek;" & _
			"word Day;" & _
			"word Hour;" & _
			"word Minute;" & _
			"word Second;" & _
			"word Milliseconds")
	Local $tTime = DllStructCreate("wchar[62]")
	DllStructSetData($tTime, 1, $sHttpTime)
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpTimeToSystemTime", "ptr", DllStructGetPtr($tTime), "ptr", DllStructGetPtr($SYSTEMTIME))
	If @error Or Not $aCall[0] Then Return SetError(2, 0, 0)
	Local $aRet[8] = [DllStructGetData($SYSTEMTIME, "Year"), _
			DllStructGetData($SYSTEMTIME, "Month"), _
			DllStructGetData($SYSTEMTIME, "DayOfWeek"), _
			DllStructGetData($SYSTEMTIME, "Day"), _
			DllStructGetData($SYSTEMTIME, "Hour"), _
			DllStructGetData($SYSTEMTIME, "Minute"), _
			DllStructGetData($SYSTEMTIME, "Second"), _
			DllStructGetData($SYSTEMTIME, "Milliseconds")]
	Return $aRet
EndFunc   ;==>_WinHttpTimeToSystemTime

; #FUNCTION# ;===============================================================================
; Name...........: _WinHttpWriteData
; Description ...: Writes request data to an HTTP server.
; Syntax.........: _WinHttpWriteData($hRequest, $vData [, $iMode = Default ])
; Parameters ....: $hRequest - Valid handle returned by _WinHttpSendRequest().
;                  $vData - Data to write.
;                  $iMode - [optional] Integer representing writing mode. Default is 0 - write ANSI string.
; Return values .: Success - Returns 1
;                          - @extended receives the number of bytes written.
;                  Failure - Returns 0 and sets @error:
;                  |1 - DllCall failed
; Author ........: trancexx, ProgAndy
; Modified.......:
; Remarks .......: $vData variable is either string or binary data to write.
;                  $iMode can have these values:
;                  |0 - to write ANSI string
;                  |1 - to write binary data
; Related .......: _WinHttpSendRequest, _WinHttpReadData
; Link ..........: http://msdn.microsoft.com/en-us/library/aa384120(VS.85).aspx
; Example .......:
;============================================================================================
Func _WinHttpWriteData($hRequest, $vData, $iMode = Default)
	__WinHttpDefault($iMode, 0)
	Local $iNumberOfBytesToWrite, $tData
	If $iMode = 1 Then
		$iNumberOfBytesToWrite = BinaryLen($vData)
		$tData = DllStructCreate("byte[" & $iNumberOfBytesToWrite & "]")
		DllStructSetData($tData, 1, $vData)
	ElseIf IsDllStruct($vData) Then
		$iNumberOfBytesToWrite = DllStructGetSize($vData)
		$tData = $vData
	Else
		$iNumberOfBytesToWrite = StringLen($vData)
		$tData = DllStructCreate("char[" & $iNumberOfBytesToWrite + 1 & "]")
		DllStructSetData($tData, 1, $vData)
	EndIf
	Local $aCall = DllCall($hWINHTTPDLL__WINHTTP, "bool", "WinHttpWriteData", _
			"handle", $hRequest, _
			"ptr", DllStructGetPtr($tData), _
			"dword", $iNumberOfBytesToWrite, _
			"dword*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return SetExtended($aCall[4], 1)
EndFunc   ;==>_WinHttpWriteData


; #INTERNAL FUNCTIONS# ;=====================================================================
Func __WinHttpFileContent($sAccept, $sName, $sFileString, $sBoundaryMain)
	#forceref $sAccept ; FIXME: $sAccept is specified by the server (or left default). In case $sFileString is non-supported MIME type action should be aborted.
	Local $fNonStandard = False
	If StringLeft($sFileString, 10) = "PHP#50338:" Then
		$sFileString = StringTrimLeft($sFileString, 10)
		$fNonStandard = True
	EndIf
	Local $sOut = 'Content-Disposition: form-data; name="' & $sName & '"'
	If Not $sFileString Then Return $sOut & '; filename=""' & @CRLF & @CRLF & @CRLF
	; Check $sFileString string
	If StringRight($sFileString, 1) = "|" Then $sFileString = StringTrimRight($sFileString, 1)
	Local $aFiles = StringSplit($sFileString, "|", 2)
	If UBound($aFiles) = 1 Then
		$sOut &= '; filename="' & StringRegExpReplace($aFiles[0], ".*\\", "") & '"' & @CRLF & _
				"Content-Type: " & __WinHttpMIMEType($aFiles[0]) & @CRLF & @CRLF & FileRead($aFiles[0]) & @CRLF
		Return $sOut ; That's it
	EndIf
	; Multiple files specified, separated by "|". Support on server side required!
	If $fNonStandard Then
		; This way is forced by some browsers to avoid PHP's inability to parse multipart/mixed content
		$sOut = "" ; discharge
		Local $iFiles = UBound($aFiles)
		For $i = 0 To $iFiles - 1
			$sOut &= 'Content-Disposition: form-data; name="' & $sName & '"' & _
					'; filename="' & StringRegExpReplace($aFiles[$i], ".*\\", "") & '"' & @CRLF & _
					"Content-Type: " & __WinHttpMIMEType($aFiles[$i]) & @CRLF & @CRLF & FileRead($aFiles[$i]) & @CRLF
			If $i < $iFiles - 1 Then $sOut &= "--" & $sBoundaryMain & @CRLF
		Next
	Else
		; RFC2388 ( http://www.ietf.org/rfc/rfc2388.txt )
		Local $sBoundary = StringFormat("%s%.5f", "----WinHttpSubBoundaryLine_", Random(10000, 99999))
		$sOut &= @CRLF & "Content-Type: multipart/mixed; boundary=" & $sBoundary & @CRLF & @CRLF
		For $i = 0 To UBound($aFiles) - 1
			$sOut &= "--" & $sBoundary & @CRLF & _
					'Content-Disposition: file; filename="' & StringRegExpReplace($aFiles[$i], ".*\\", "") & '"' & @CRLF & _
					"Content-Type: " & __WinHttpMIMEType($aFiles[$i]) & @CRLF & @CRLF & FileRead($aFiles[$i]) & @CRLF
		Next
		$sOut &= "--" & $sBoundary & "--" & @CRLF
	EndIf
	Return $sOut
EndFunc   ;==>__WinHttpFileContent

Func __WinHttpMIMEType($sFileName)
	Local $aArray = StringRegExp(__WinHttpMIMEAssocString(), "(?i)\Q;" & StringRegExpReplace($sFileName, ".*\.", "") & "\E\|(.*?);", 3)
	If @error Then Return "application/octet-stream"
	Return $aArray[0]
EndFunc   ;==>__WinHttpMIMEType

Func __WinHttpMIMEAssocString()
	Return ";ai|application/postscript;aif|audio/x-aiff;aifc|audio/x-aiff;aiff|audio/x-aiff;asc|text/plain;atom|application/atom+xml;au|audio/basic;avi|video/x-msvideo;bcpio|application/x-bcpio;bin|application/octet-stream;bmp|image/bmp;cdf|application/x-netcdf;cgm|image/cgm;class|application/octet-stream;cpio|application/x-cpio;cpt|application/mac-compactpro;csh|application/x-csh;css|text/css;dcr|application/x-director;dif|video/x-dv;dir|application/x-director;djv|image/vnd.djvu;djvu|image/vnd.djvu;dll|application/octet-stream;dmg|application/octet-stream;dms|application/octet-stream;doc|application/msword;dtd|application/xml-dtd;dv|video/x-dv;dvi|application/x-dvi;dxr|application/x-director;eps|application/postscript;etx|text/x-setext;exe|application/octet-stream;ez|application/andrew-inset;gif|image/gif;gram|application/srgs;grxml|application/srgs+xml;gtar|application/x-gtar;hdf|application/x-hdf;hqx|application/mac-binhex40;htm|text/html;html|text/html;ice|x-conference/x-cooltalk;ico|image/x-icon;ics|text/calendar;ief|image/ief;ifb|text/calendar;iges|model/iges;igs|model/iges;jnlp|application/x-java-jnlp-file;jp2|image/jp2;jpe|image/jpeg;jpeg|image/jpeg;jpg|image/jpeg;js|application/x-javascript;kar|audio/midi;latex|application/x-latex;lha|application/octet-stream;lzh|application/octet-stream;m3u|audio/x-mpegurl;m4a|audio/mp4a-latm;m4b|audio/mp4a-latm;m4p|audio/mp4a-latm;m4u|video/vnd.mpegurl;m4v|video/x-m4v;mac|image/x-macpaint;man|application/x-troff-man;mathml|application/mathml+xml;me|application/x-troff-me;mesh|model/mesh;mid|audio/midi;midi|audio/midi;mif|application/vnd.mif;mov|video/quicktime;movie|video/x-sgi-movie;mp2|audio/mpeg;mp3|audio/mpeg;mp4|video/mp4;mpe|video/mpeg;mpeg|video/mpeg;mpg|video/mpeg;mpga|audio/mpeg;ms|application/x-troff-ms;msh|model/mesh;mxu|video/vnd.mpegurl;nc|application/x-netcdf;oda|application/oda;ogg|application/ogg;pbm|image/x-portable-bitmap;pct|image/pict;pdb|chemical/x-pdb;pdf|application/pdf;pgm|image/x-portable-graymap;pgn|application/x-chess-pgn;pic|image/pict;pict|image/pict;png|image/png;pnm|image/x-portable-anymap;pnt|image/x-macpaint;pntg|image/x-macpaint;ppm|image/x-portable-pixmap;ppt|application/vnd.ms-powerpoint;ps|application/postscript;qt|video/quicktime;qti|image/x-quicktime;qtif|image/x-quicktime;ra|audio/x-pn-realaudio;ram|audio/x-pn-realaudio;ras|image/x-cmu-raster;rdf|application/rdf+xml;rgb|image/x-rgb;rm|application/vnd.rn-realmedia;roff|application/x-troff;rtf|text/rtf;rtx|text/richtext;sgm|text/sgml;sgml|text/sgml;sh|application/x-sh;shar|application/x-shar;silo|model/mesh;sit|application/x-stuffit;skd|application/x-koan;skm|application/x-koan;skp|application/x-koan;skt|application/x-koan;smi|application/smil;smil|application/smil;snd|audio/basic;so|application/octet-stream;spl|application/x-futuresplash;src|application/x-wais-source;sv4cpio|application/x-sv4cpio;sv4crc|application/x-sv4crc;svg|image/svg+xml;swf|application/x-shockwave-flash;t|application/x-troff;tar|application/x-tar;tcl|application/x-tcl;tex|application/x-tex;texi|application/x-texinfo;texinfo|application/x-texinfo;tif|image/tiff;tiff|image/tiff;tr|application/x-troff;tsv|text/tab-separated-values;txt|text/plain;ustar|application/x-ustar;vcd|application/x-cdlink;vrml|model/vrml;vxml|application/voicexml+xml;wav|audio/x-wav;wbmp|image/vnd.wap.wbmp;wbmxl|application/vnd.wap.wbxml;wml|text/vnd.wap.wml;wmlc|application/vnd.wap.wmlc;wmls|text/vnd.wap.wmlscript;wmlsc|application/vnd.wap.wmlscriptc;wrl|model/vrml;xbm|image/x-xbitmap;xht|application/xhtml+xml;xhtml|application/xhtml+xml;xls|application/vnd.ms-excel;xml|application/xml;xpm|image/x-xpixmap;xsl|application/xml;xslt|application/xslt+xml;xul|application/vnd.mozilla.xul+xml;xwd|image/x-xwindowdump;xyz|chemical/x-xyz;zip|application/zip;"
EndFunc   ;==>__WinHttpMIMEAssocString

Func __WinHttpURLEncode($sData)
	Local $aData = StringToASCIIArray($sData, Default, Default, 2)
	Local $sOut
	For $i = 0 To UBound($aData) - 1
		Switch $aData[$i]
			Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
				$sOut &= Chr($aData[$i])
			Case 32
				$sOut &= "+"
			Case Else
				$sOut &= "%" & Hex($aData[$i], 2)
		EndSwitch
	Next
	Return $sOut
EndFunc   ;==>__WinHttpURLEncode

Func __WinHttpFinalizeCtrls($sSubmit, $sRadio, $sCheckBox, $sButton, ByRef $sAddData, $sGrSep, $sBound = "")
	If $sSubmit Then ; If no submit is specified
		Local $aSubmit = StringSplit($sSubmit, $sGrSep, 3)
		For $m = 1 To UBound($aSubmit) - 1
			$sAddData = StringRegExpReplace($sAddData, "(?:\Q" & $sBound & "\E|\A)\Q" & $aSubmit[$m] & "\E(?:\Q" & $sBound & "\E|\z)", $sBound)
		Next
		__WinHttpTrimBounds($sAddData, $sBound)
	EndIf
	If $sRadio Then ; If no radio is specified
		For $sElem In StringSplit($sRadio, $sGrSep, 3)
			$sAddData = StringRegExpReplace($sAddData, "(?:\Q" & $sBound & "\E|\A)\Q" & $sElem & "\E(?:\Q" & $sBound & "\E|\z)", $sBound)
		Next
		__WinHttpTrimBounds($sAddData, $sBound)
	EndIf
	If $sCheckBox Then ; If no checkbox is specified
		For $sElem In StringSplit($sCheckBox, $sGrSep, 3)
			$sAddData = StringRegExpReplace($sAddData, "(?:\Q" & $sBound & "\E|\A)\Q" & $sElem & "\E(?:\Q" & $sBound & "\E|\z)", $sBound)
		Next
		__WinHttpTrimBounds($sAddData, $sBound)
	EndIf
	If $sButton Then ; If no button is specified
		For $sElem In StringSplit($sButton, $sGrSep, 3)
			$sAddData = StringRegExpReplace($sAddData, "(?:\Q" & $sBound & "\E|\A)\Q" & $sElem & "\E(?:\Q" & $sBound & "\E|\z)", $sBound)
		Next
		__WinHttpTrimBounds($sAddData, $sBound)
	EndIf
EndFunc   ;==>__WinHttpFinalizeCtrls

Func __WinHttpTrimBounds(ByRef $sData, $sBound)
	Local $iBLen = StringLen($sBound)
	If StringRight($sData, $iBLen) = $sBound Then $sData = StringTrimRight($sData, $iBLen)
	If StringLeft($sData, $iBLen) = $sBound Then $sData = StringTrimLeft($sData, $iBLen)
EndFunc   ;==>__WinHttpTrimBounds

Func __WinHttpFormAttrib(ByRef $aAttrib, $i, $sElement)
	Local $aArray = StringRegExp($sElement, '(?i).*?id\h*=(\h*"(.*?)"|' & "\h*'(.*?)'|" & '(.*?)(?: |\Z))', 3) ; e.g. id="abc" or id='abc' or id=abc
	If Not @error Then $aAttrib[0][$i] = $aArray[UBound($aArray) - 1] ; id
	$aArray = StringRegExp($sElement, '(?i).*?name\h*=(\h*"(.*?)"|' & "\h*'(.*?)'" & '|(.*?)(?: |\Z))', 3) ; e.g. name="abc" or name='abc' or name=abc
	If Not @error Then $aAttrib[1][$i] = $aArray[UBound($aArray) - 1] ; name
	$aArray = StringRegExp($sElement, '(?i).*?value\h*=(\h*"(.*?)"|' & "\h*'(.*?)'" & '|(.*?)(?: |\Z))', 3) ; e.g. value="abc" or value='abc' or value=abc
	If Not @error Then $aAttrib[2][$i] = $aArray[UBound($aArray) - 1] ; value
	$aArray = StringRegExp($sElement, '(?i).*?type\h*=(\h*"(.*?)"|' & "\h*'(.*?)'|" & '(.*?)(?: |\Z))', 3) ; e.g. type="abc" or type='abc' or type=abc
	If Not @error Then $aAttrib[3][$i] = $aArray[UBound($aArray) - 1] ; type
EndFunc   ;==>__WinHttpFormAttrib

Func __WinHttpFormSend($hInternet, $sMethod, $sAction, $fMultiPart, $sBoundary, $sAddData, $fSecure = False)
	Local $hRequest
	If $fSecure Then
		$hRequest = _WinHttpOpenRequest($hInternet, $sMethod, $sAction, Default, Default, Default, $WINHTTP_FLAG_SECURE)
	Else
		$hRequest = _WinHttpOpenRequest($hInternet, $sMethod, $sAction)
	EndIf
	If $fMultiPart Then
		_WinHttpAddRequestHeaders($hRequest, "Content-Type: multipart/form-data; boundary=" & $sBoundary)
	Else
		If $sMethod = "POST" Then _WinHttpAddRequestHeaders($hRequest, "Content-Type: application/x-www-form-urlencoded")
	EndIf
	_WinHttpAddRequestHeaders($hRequest, "Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,*/*;q=0.5")
	_WinHttpAddRequestHeaders($hRequest, "Accept-Charset: utf-8;q=0.7")
	_WinHttpSendRequest($hRequest, Default, $sAddData)
	_WinHttpReceiveResponse($hRequest)
	Return $hRequest
EndFunc   ;==>__WinHttpFormSend

Func __WinHttpDefault(ByRef $vInput, $vOutput)
	If $vInput = Default Or Number($vInput) = -1 Then $vInput = $vOutput
EndFunc   ;==>__WinHttpDefault

Func __WinHttpMemGlobalFree($pMem)
	Local $aCall = DllCall("kernel32.dll", "ptr", "GlobalFree", "ptr", $pMem)
	If @error Or $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__WinHttpMemGlobalFree

Func __WinHttpPtrStringLenW($pString)
	Local $aCall = DllCall("kernel32.dll", "dword", "lstrlenW", "ptr", $pString)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__WinHttpPtrStringLenW
;============================================================================================