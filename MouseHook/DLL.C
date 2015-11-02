#include <windows.h>
#include <string.h>
#include <math.h>
//#include <stdlib.h>


// ".shared" is defined in exports.def to allow
//  all instances of the dll to share these variables   
#pragma data_seg(".shared") 
    HWND        m_hHwndMouse = 0;
    HHOOK       m_hHookMouse = 0;
	int ignore_Events = 0;
	char Mouse_Events[1024] = "";
	char Block_Events[1024] = "";

#pragma data_seg()


#define WM_MOUSEWHEEL 0x020A
#define WM_XBUTTONDOWN  0x020B
#define WM_XBUTTONUP 0x020C
#define WM_XBUTTONDBLCLK 0x020D
#define XBUTTON1  0x0001
#define XBUTTON2  0x0002

#define AU3_LCLICK (WM_USER + 0x1A02)
#define AU3_LDCLICK (WM_USER + 0x1A04)
#define AU3_LDROP (WM_USER + 0x1A06)

#define AU3_RCLICK (WM_USER + 0x1B02)
#define AU3_RDCLICK (WM_USER + 0x1B04)
#define AU3_RDROP (WM_USER + 0x1B06)

#define AU3_MCLICK (WM_USER + 0x1C02)
#define AU3_MDCLICK (WM_USER + 0x1C04)
#define AU3_MDROP (WM_USER + 0x1C06)

#define AU3_XCLICK (WM_USER + 0x1D02)
#define AU3_XDCLICK (WM_USER + 0x1D04)
#define AU3_XDROP (WM_USER + 0x1D06)

#define AU3_WHEELUP (WM_USER + 0x1F02)
#define AU3_WHEELDOWN (WM_USER + 0x1F04)


// OS Version data
OSVERSIONINFO    OSvi;

UINT DoubleClickTime;

//typedef struct {
//    MOUSEHOOKSTRUCT MOUSEHOOKSTRUCT;
//    DWORD mouseData;
//} MOUSEHOOKSTRUCTEX, *PMOUSEHOOKSTRUCTEX;

// Set the values for the window and hook for the mouse hook
void WINAPI SetValuesMouse(HWND hWnd, HHOOK hk)
{
    m_hHwndMouse = hWnd;
    m_hHookMouse = hk;
}

void WINAPI IgnoreEvents(int ignore)
{
    ignore_Events = ignore;
}

void WINAPI MouseEvents(char *events)
{
	strcpy(Mouse_Events, events);
}

void WINAPI BlockEvents(char *events)
{
	strcpy(Block_Events, events);
}

LONG Pixel_Distance(LONG x1, LONG y1, LONG x2, LONG y2)
{
	LONG a, b, c;
	if (x2 == x1 && y2 == y1)
		return 0;
	else
	{
		a = y2 - y1;
		b = x2 - x1;
		c = sqrt(a * a + b * b);
		return c;
	}
}

// This is the mouse hook itself
LRESULT CALLBACK MouseProc( int nCode, WPARAM wParam, LPARAM lParam )
{
    if (nCode < 0 || wParam == WM_MOUSEMOVE || wParam == WM_NCMOUSEMOVE || ignore_Events > 0)
        return CallNextHookEx(m_hHookMouse, nCode, wParam, lParam);

	static LONG last_x, last_y;
	static UINT last_event = 0;
	static DWORD last_time;

    if (nCode == HC_ACTION)
    {
		DWORD time, timediff;
		time = GetTickCount();
		timediff = time - last_time;

		LONG x, y;
		x = ((MOUSEHOOKSTRUCT*) lParam)->pt.x;
		y = ((MOUSEHOOKSTRUCT*) lParam)->pt.y;

        // If the message is a WM_NC*, convert it to a WM_*
        if ((wParam >= 0xA0) & (wParam <= 0xAD))
            wParam = wParam + 352;
		
        switch (wParam) 
        {
            case WM_LBUTTONDOWN:
				last_x = x;
				last_y = y;
                break;
 
            case WM_RBUTTONDOWN:
				last_x = x;
				last_y = y;
                break;

            case WM_MBUTTONDOWN:
				last_x = x;
				last_y = y;
                break;

            case WM_XBUTTONDOWN:
				last_x = x;
				last_y = y;
                break;

            case WM_LBUTTONUP:
				if (Pixel_Distance(x, y, last_x, last_y) > 100)
					last_event = AU3_LDROP;
				else
					last_event = AU3_LCLICK;
				last_time = time;
                break;

            case WM_RBUTTONUP:	
				if (last_event == AU3_RCLICK && timediff < DoubleClickTime)
					last_event = AU3_RDCLICK;
				else if (Pixel_Distance(x, y, last_x, last_y) > 100)
					last_event = AU3_RDROP;
				else
					last_event = AU3_RCLICK;
				last_time = time;
                break;

            case WM_MBUTTONUP:
				if (Pixel_Distance(x, y, last_x, last_y) > 100)
					last_event = AU3_MDROP;
				else
					last_event = AU3_MCLICK;
				last_time = time;
                break;

            case WM_XBUTTONUP:
				if (Pixel_Distance(x, y, last_x, last_y) > 100)
					last_event = AU3_XDROP;
				else
					last_event = AU3_XCLICK;
				last_time = time;
                break;

            case WM_LBUTTONDBLCLK:
				last_event = AU3_LDCLICK;
				last_time = time;
                break;

            case WM_RBUTTONDBLCLK:
				last_event = AU3_RDCLICK;
				last_time = time;
                break;

            case WM_MBUTTONDBLCLK:
				last_event = AU3_MDCLICK;
				last_time = time;
                break;

            case WM_XBUTTONDBLCLK:
				last_event = AU3_XDCLICK;
				last_time = time;
                break;

            case WM_MOUSEWHEEL:
                if ((OSvi.dwPlatformId == VER_PLATFORM_WIN32_NT)&&(OSvi.dwMajorVersion>=5))
                {
                    if ((short)HIWORD(((MOUSEHOOKSTRUCTEX*)lParam)->mouseData) > 0)
                        last_event = AU3_WHEELUP;           
					else
                        last_event = AU3_WHEELDOWN;
                }
                else
                    last_event =  AU3_WHEELUP;

				last_time = time;
                break;

            default:
                return CallNextHookEx(m_hHookMouse, nCode, wParam, lParam);
        }
		
		if (time == last_time)
		{
			char str[256];
			int block = 0; 
			_itoa(last_event, str, 10);
			if (strstr(Mouse_Events, str))
			{
				if (strstr(Block_Events, str))
					block = 1;

	        	// Let the listening window know about the message
	        	PostMessage(m_hHwndMouse, last_event + block,
					(WPARAM)((MOUSEHOOKSTRUCT*) lParam)->hwnd, MAKELPARAM(x, y));
				
				if (block)
					return 1; // block
			}
		}
    }
    return CallNextHookEx(m_hHookMouse, nCode, wParam, lParam);
}


BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    if (fdwReason == DLL_PROCESS_ATTACH)
        DisableThreadLibraryCalls(hinstDLL);


    // Get details of the OS we are running on
    OSvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    GetVersionEx(&OSvi);

	DoubleClickTime = GetDoubleClickTime();
	if (!DoubleClickTime)
		DoubleClickTime = 500;

    return TRUE;
}

// This is to prevent the CRT from loading, thus making this a smaller
//  and faster dll.
extern BOOL __stdcall _DllMainCRTStartup( HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    return DllMain( hinstDLL, fdwReason, lpvReserved );
}


