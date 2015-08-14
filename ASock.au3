#cs
https://www.autoitscript.com/forum/topic/45189-asynchronous-sockets-udf/#comment-336619

Events that shall be used and are tested to perfectly work in AutoIt:
$FD_READ - posted when data has arrived on the socket. I suggest you TCPRecv()'ing only when this occurs.
$FD_WRITE - the conditions to TCPSend() are very good. Nevertheless, use TCPSend() anywhere else.
$FD_ACCEPT - a connection attempt from outside is pending. TCPAccept() it if you want. I suggest you TCPAccept()'ing only when this occurs.
$FD_CLOSE - the remote side has closed the connection / connection lost. Don't forget to TCPCloseSocket() to free the resources used!
$FD_CONNECT - connected to a peer. When you call _ASockConnect(), it returns immediately and almost always (check @extended) is not able to connect/fail that fast, so Winsock posts $FD_CONNECT when the connection is finally made OR an error has occured.
$FD_OOB - UNTESTED You state that you are interested in receiving OOB data. Winsock will announce when such data arrives.
NOTE: check $iError (or whatever you have named it) whether Winsock is telling you about a succeeded event (or one that it hasn't encountered any error on) or a failed event.
These functions have to be used in order to use asynchronous sockets:
Posts a $FD_CONNECT when connected or when afailed.
These functions can be used as usual:
TCPSend() - returns IMMEDIATELY. Attempts to send all the data, no need to check how much is sent.
Returns 0 on closed connection.
Note that $FD_WRITE is posted when it is likely that TCPSend() will succeed very fast / immediately. Nevertheless, call it when you need it.
TCPRecv() - don't call it as usual. Call it when you get a $FD_READ event. This event is posted when data has arrived on the socket.
If you call it on a $FD_READ event and do not receive all the data that has arrived, $FD_READ will be posted again.
TCPAccept() - don't call it as usual. Call it when you get a $FD_ACCEPT event. This event is posted when there is a pending connection to be TCPAccept()'ed.
TCPCloseSocket(), TCPStartup(), TCPShutdown(), TCPNameToIP(), UDFs like SocketToIP() and such.
#ce

Global Const $FD_READ = 1
Global Const $FD_WRITE = 2
Global Const $FD_OOB = 4
Global Const $FD_ACCEPT = 8
Global Const $FD_CONNECT = 16
Global Const $FD_CLOSE = 32

; * Address families.
Global Const $AF_INET = 2

Global Const $IPPROTO_TCP =	6 ; tcp
Global Const $IPPROTO_UDP = 17 ; user datagram protocol

; * Types
Global Const $SOCK_STREAM = 1 ; /* stream socket */
Global Const $SOCK_DGRAM = 2 ; /* datagram socket */
Global Const $SOCK_RAW = 3 ; /* raw-protocol interface */
Global Const $SOCK_RDM = 4 ; /* reliably-delivered message */
Global Const $SOCK_SEQPACKET = 5 ; /* sequenced packet stream */

Const $SOL_SOCKET = 0xFFFF ; Level number for (get/set)sockopt() to apply to socket itself
Const $SO_SECURE = 0x2001;
Const $SO_SEC_SSL = 0x2004;

Local $hWs2_32 = -1

Func _ASocket($iAddressFamily = 2, $iType = 1, $iProtocol = 6)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $hSocket = DllCall($hWs2_32, "uint", "socket", "int", $iAddressFamily, "int", $iType, "int", $iProtocol)
	If @error Then Return SetError(1, @error, -1)
	If $hSocket[ 0 ] = -1 Then Return SetError(2, _WSAGetLastError(), -1)
	Return $hSocket[ 0 ]
EndFunc   ;==>_ASocket

Func _ASockShutdown($hSocket)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall($hWs2_32, "int", "shutdown", "uint", $hSocket, "int", 2)
	If @error Then Return SetError(1, @error, False)
	If $iRet[ 0 ] <> 0 Then Return SetError(2, _WSAGetLastError(), False)
	Return True
EndFunc   ;==>_ASockShutdown

Func _ASockClose($hSocket)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall($hWs2_32, "int", "closesocket", "uint", $hSocket)
	If @error Then Return SetError(1, @error, False)
	If $iRet[ 0 ] <> 0 Then Return SetError(2, _WSAGetLastError(), False)
	Return True
EndFunc   ;==>_ASockClose

Func _ASockSelect($hSocket, $hWnd, $uiMsg, $iEvent)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall( _
			$hWs2_32, _
			"int", "WSAAsyncSelect", _
			"uint", $hSocket, _
			"hwnd", $hWnd, _
			"uint", $uiMsg, _
			"int", $iEvent _
			)
	If @error Then Return SetError(1, @error, False)
	If $iRet[ 0 ] <> 0 Then Return SetError(2, _WSAGetLastError(), False)
	Return True
EndFunc   ;==>_ASockSelect

; Note: you can see that $iMaxPending is set to 5 by default.
; IT DOES NOT MEAN THAT DEFAULT = 5 PENDING CONNECTIONS
; 5 == SOMAXCONN, so don't worry be happy
Func _ASockListen($hSocket, $sIP, $uiPort, $iMaxPending = 5); 5 == SOMAXCONN => No need to change it.
	Local $iRet
	Local $stAddress
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )

	$stAddress = __SockAddr($sIP, $uiPort)
	If @error Then Return SetError(@error, @extended, False)

	$iRet = DllCall($hWs2_32, "int", "bind", "uint", $hSocket, "ptr", DllStructGetPtr($stAddress), "int", DllStructGetSize($stAddress))
	If @error Then Return SetError(3, @error, False)
	If $iRet[ 0 ] <> 0 Then
		$stAddress = 0; Deallocate
		Return SetError(4, _WSAGetLastError(), False)
	EndIf

	$iRet = DllCall($hWs2_32, "int", "listen", "uint", $hSocket, "int", $iMaxPending)
	If @error Then Return SetError(5, @error, False)
	If $iRet[ 0 ] <> 0 Then
		$stAddress = 0; Deallocate
		Return SetError(6, _WSAGetLastError(), False)
	EndIf

	Return True
EndFunc   ;==>_ASockListen

Func _ASockConnect($hSocket, $sIP, $uiPort)
	Local $iRet
	Local $stAddress

	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )

	$stAddress = __SockAddr($sIP, $uiPort)
	If @error Then Return SetError(@error, @extended, False)

	$iRet = DllCall($hWs2_32, "int", "connect", "uint", $hSocket, "ptr", DllStructGetPtr($stAddress), "int", DllStructGetSize($stAddress))
	If @error Then Return SetError(3, @error, False)

	$iRet = _WSAGetLastError()
	If $iRet = 10035 Then; WSAEWOULDBLOCK
		Return True; Asynchronous connect attempt has been started.
	EndIf
	SetExtended(1); Connected immediately
	Return True
EndFunc   ;==>_ASockConnect

; A wrapper function to ease all the pain in creating and filling the sockaddr struct
Func __SockAddr($sIP, $iPort, $iAddressFamily = 2)
	Local $iRet
	Local $stAddress

	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )

	$stAddress = DllStructCreate("short; ushort; uint; char[8]")
	If @error Then Return SetError(1, @error, False)

	DllStructSetData($stAddress, 1, $iAddressFamily)
	$iRet = DllCall($hWs2_32, "ushort", "htons", "ushort", $iPort)
	DllStructSetData($stAddress, 2, $iRet[ 0 ])
	$iRet = DllCall($hWs2_32, "uint", "inet_addr", "str", $sIP)
	If $iRet[ 0 ] = 0xffffffff Then; INADDR_NONE
		$stAddress = 0; Deallocate
		Return SetError(2, _WSAGetLastError(), False)
	EndIf
	DllStructSetData($stAddress, 3, $iRet[ 0 ])

	Return $stAddress
EndFunc   ;==>__SockAddr

Func _WSAGetLastError()
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall($hWs2_32, "int", "WSAGetLastError")
	If @error Then
		ConsoleWrite("+> _WSAGetLastError(): WSAGetLastError() failed. Script line number: " & @ScriptLineNumber & @CRLF)
		SetExtended(1)
		Return 0
	EndIf
	Return $iRet[ 0 ]
EndFunc   ;==>_WSAGetLastError

Func _SetSockOpt($hSocket, $level, $optname, $optval)
	If $hWs2_32 = -1 Then $hWs2_32 = DllOpen( "Ws2_32.dll" )
	Local $iRet = DllCall( _
			$hWs2_32, _
			"int", "setsockopt", _
			"uint", $hSocket, _
			"int", $level, _
			"int", $optname, _
			"ptr", DllStructGetPtr($optval), _
			"int", DllStructGetSize($optval) _
			)
	If @error Then Return SetError(1, @error, False)
	If $iRet[ 0 ] <> 0 Then Return SetError(2, _WSAGetLastError(), False)
	Return True
EndFunc

; Got these here:
; http://www.autoitscript.com/forum/index.php?showtopic=5620&hl=MAKELONG
Func _MakeLong($LoWord, $HiWord)
	Return BitOR($HiWord * 0x10000, BitAND($LoWord, 0xFFFF)); Thanks Larry
EndFunc   ;==>_MakeLong

Func _HiWord($Long)
	Return BitShift($Long, 16); Thanks Valik
EndFunc   ;==>_HiWord

Func _LoWord($Long)
	Return BitAND($Long, 0xFFFF); Thanks Valik
EndFunc   ;==>_LoWord



