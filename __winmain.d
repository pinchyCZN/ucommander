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
				style=GetWindowLong(htmp,GWL_STYLE);
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
	if(msg==WM_CTLCOLORBTN)
		msg=msg;
	return DefWindowProc(hwnd, msg, wparam, lparam);
}

nothrow
extern (Windows)
int function (int *,int *,int)SetSysColorsTemp;

nothrow
int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg;    
	WNDCLASS wc={0};
	const TCHAR *class_name="TEST";
	HWND hwnd;
	int style;
	HINSTANCE hlib;
	hlib=LoadLibrary("USER32.DLL");
	if(hlib!=NULL){
		int[0x1e] colors;
		int[0x1e] table;
		foreach(i,ref c;colors){
			c=GetSysColor(i);
			//if(i>=4 && i<=5)
			if(i==COLOR_WINDOW)
				c=0xFFFFFF;
			//COLOR_GRAYTEXT
			table[i]=i;
		}
		SetSysColorsTemp=cast(typeof(SetSysColorsTemp))GetProcAddress(hlib,"SetSysColorsTemp");
		//if(SetSysColorsTemp)
		//	SetSysColorsTemp(cast(int*)&colors,cast(int*)&table,0x1E);
		table[0]=COLOR_WINDOW;
		colors[0]=0xFFFFFF;
		//SetSysColors(1,cast(int*)table,cast(uint*)colors);
	}
	hinstance=hInstance;

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

