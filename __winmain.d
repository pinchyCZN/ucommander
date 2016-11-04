module winmain;

import core.runtime;
import core.sys.windows.windows;
import core.sys.windows.commctrl;

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result;

//    try
    {
     //   Runtime.initialize();

        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);

        Runtime.terminate();
    }
//    catch (Throwable o) // catch any uncaught exceptions
    {
//        MessageBoxA(null, cast(char *)o.toString(), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

HINSTANCE hinstance;

nothrow
extern (Windows)
LRESULT WndProc( HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam )
{
	RECT rect;

	switch(msg){
		case WM_INITDIALOG:
			break;
		case WM_CTLCOLOREDIT:
			break;
		case WM_MENUSELECT:
			break;
		case WM_CREATE:
			{
				HWND htmp;
				int style;
				htmp=CreateWindow("BUTTON","BUTTON",WS_VISIBLE|WS_CHILD|BS_PUSHBUTTON,0,0,100,100,hwnd,cast(void*)2000,hinstance,NULL);
				htmp=CreateWindow("EDIT","EDIT",WS_VISIBLE|WS_CHILD|ES_READONLY,0,100,100,100,hwnd,cast(void*)2001,hinstance,NULL);
				style=GetWindowLong(hwnd,GWL_STYLE);
				style=style;
			}
			break;
		case WM_TIMER:
			break;
		case WM_USER:
			break;
		case WM_CLOSE:
		case WM_DESTROY:
			PostQuitMessage(0);
			break;
		case WM_KEYDOWN:
			break;
		case WM_ENDSESSION:
			return 0;
		case WM_QUERYENDSESSION:
			return TRUE;
			break;
		case WM_COMMAND:
			switch(LOWORD(wparam)){
				case IDOK:
				case IDCANCEL:
					PostQuitMessage(0);
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	//return FALSE;
	return DefWindowProc(hwnd, msg, wparam, lparam);
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg;    
	WNDCLASS wc={0};
	const TCHAR *class_name="TEST";
	HWND hwnd;
	int style;
	hinstance=hInstance;
	InitCommonControls();

	wc.lpszClassName = class_name;
	wc.hInstance     = hInstance ;
	wc.lpfnWndProc   = &WndProc ;
	RegisterClass(&wc);
	hwnd=CreateWindow(class_name,class_name,WS_OVERLAPPEDWINDOW|WS_VISIBLE,0,0,500,500,NULL,NULL,hinstance,NULL);
	//ShowWindow(hwnd,SW_SHOW);
	style=GetWindowLong(hwnd,GWL_STYLE);
	style=style;


	//	open_console();
	//	move_console();
	while( GetMessage(&msg, NULL, 0, 0)) {
		if(!IsDialogMessage(hwnd,&msg)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	return 0;
}

