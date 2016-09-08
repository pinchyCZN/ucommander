module winmain;

//https://github.com/smjgordon/bindings.git
//put win32 bindings in ...\dmd2\src\druntime\import\win32

import core.runtime;
import core.sys.windows.windows;
//import win32.windows;
import std.string;
import std.utf;
import std.stdio;
//import windows_etc;
//import test;
import resource;


extern (Windows)
//nothrow
BOOL dlg_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	return 0;
}

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	Runtime.initialize();
	myWinMain(hInstance,hPrevInstance,lpCmdLine,nCmdShow);
    return 0;
}
int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow)
{
	WNDCLASS wnd;
	wnd.lpfnWndProc=&dlg_proc;
//	CreateDialogParam(hInstance,MAKEINTRESOURCE(IDD_MAIN_DLG),0,wnd.lpfnWndProc,0);
	return 0;
}


