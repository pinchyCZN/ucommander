
#include <windows.h>

HINSTANCE hinstance=0;

LRESULT CALLBACK WndProc( HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam )
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
			htmp=CreateWindow(TEXT("BUTTON"),TEXT("BUTTON"),WS_VISIBLE|WS_CHILD|BS_PUSHBUTTON,0,0,100,100,hwnd,2000,hinstance,NULL);
			htmp=CreateWindow(TEXT("EDIT"),TEXT("EDIT"),WS_VISIBLE|WS_CHILD|ES_READONLY,0,100,100,100,hwnd,2000,hinstance,NULL);
			style=GetWindowLong(htmp,GWL_STYLE);
			style=style;
		}
        break;
	case WM_TIMER:
		break;
	case WM_USER:
		break;
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
		}
		break;
	case WM_CTLCOLORBTN:
		break;
	}
	//return FALSE;
	if(msg==WM_CTLCOLORBTN)
		msg=msg;
	return DefWindowProc(hwnd, msg, wparam, lparam);
}

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow )
//__declspec(noinline) int WinMainCRTStartup(void)
{
	
	MSG msg;    
	WNDCLASS wc={0};
	const TCHAR *class_name=TEXT("TEST");
	HWND hwnd;
	int style;
	int *ptr=0x400000;
	int protect;
	hinstance=hInstance;
	//hinstance=0x400000;
	wc.lpszClassName = class_name;
	wc.hInstance     = hinstance ;
	wc.lpfnWndProc   = WndProc ;
	RegisterClass(&wc);
	hwnd=CreateWindow(class_name,class_name,WS_OVERLAPPEDWINDOW|WS_VISIBLE,0,0,500,500,NULL,NULL,hinstance,NULL);
	style=GetWindowLong(hwnd,GWL_STYLE);
	
	{
		HINSTANCE hlib;
		hlib=LoadLibrary(TEXT("USER32.DLL"));
		if(hlib!=NULL){
			int (__stdcall *SetSysColorsTemp)(int *,int *,int);
			SetSysColorsTemp=GetProcAddress(hlib,"SetSysColorsTemp");
			if(SetSysColorsTemp){
				int colors[0x1f];
				int table[0x1f];
				table[0]=COLOR_BTNFACE; //COLOR_WINDOW;
				colors[0]=0xFFFFFF;
				//SetSysColors(1,table,colors);
//				SetSysColorsTemp(NULL,NULL);
			}
		}
	}
	
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

