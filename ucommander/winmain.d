module winmain;

import core.runtime;
import core.sys.windows.windows;
import std.string;
import std.utf;
import test;

extern (Windows)

@nogc
{
HWND CreateDialogParamA(
				   HINSTANCE hInstance,
				   LPCSTR lpTemplateName,
				   HWND hWndParent ,
				   DLGPROC lpDialogFunc,
				   LPARAM dwInitParam);
}

BOOL dlg_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	return 0;
}
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result=0;

	//CreateDialogParamA(hInstance,MAKEINTRESOURCEA(IDD_MAIN_DLG),0,dlg_proc,0);	
	MessageBoxW(cast(void*)0,"123".toUTF16z,"qwe".toUTF16z,MB_OK|MB_SYSTEMMODAL);
    return result;
}

