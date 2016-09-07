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
//import resource;



extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	Runtime.initialize();
	//    int result=0;
	string s="1123";

//	CreateDialogParamW(hInstance,MAKEINTRESOURCEA(IDD_MAIN_DLG),0,dlg_proc,0);
    MessageBoxA(null, s.toStringz(), "Error", MB_OK | MB_ICONEXCLAMATION);
	//MessageBoxA(null,cast(char *)s.toStringz(),"qwe",MB_OK|MB_SYSTEMMODAL);
	//	MessageBoxA(cast(void*)0,"123".toStringz,"qwe".toStringz,MB_OK|MB_SYSTEMMODAL);
    return 0;
}


/*
BOOL dlg_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	return 0;
}
*/