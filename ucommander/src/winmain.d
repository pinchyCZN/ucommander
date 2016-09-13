module winmain;

//https://github.com/smjgordon/bindings.git
//put win32 bindings in ...\dmd2\src\druntime\import\win32

import core.runtime;
import core.sys.windows.windows;
import core.sys.windows.commctrl;
import std.string;
import std.utf;
import std.stdio;
//import windows_etc;
//import test;
import resource;

HWND ghmain=NULL;

extern (Windows)
nothrow
BOOL dlg_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_COMMAND:
		switch(LOWORD(wparam)){
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
	return 0;
}

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg;
    INITCOMMONCONTROLSEX ctrls;

	Runtime.initialize();

	ctrls.dwSize=ctrls.sizeof;
    ctrls.dwICC=ICC_LISTVIEW_CLASSES;
	InitCommonControlsEx(&ctrls);

	ghmain=CreateDialogParam(hInstance,MAKEINTRESOURCE(IDD_MAIN_DLG),NULL,&dlg_proc,0);
	if(ghmain==NULL){
		MessageBox(NULL,"Unable to create window","ERROR",MB_OK|MB_SYSTEMMODAL);
		return -1;
	}
	ShowWindow(ghmain,SW_SHOW);
	while(GetMessage(&msg,NULL,0,0))
	{
		if(!IsDialogMessage(ghmain,&msg)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
    return 0;
}

