module console;

import core.sys.windows.windows;
import std.stdio;

extern (C) int _open_osfhandle(long,int);

void open_console()
{
	static int consoleallocated=FALSE;
	static int consolecreated=FALSE;
	if(!consoleallocated){
		consoleallocated=AllocConsole();
	}
	if(!consolecreated){
		int hcrt;
		hcrt=_open_osfhandle(cast(long)GetStdHandle(STD_OUTPUT_HANDLE),_O_TEXT);
		if(hcrt!=0){
			stdout.fdopen(hcrt,"w");
			consolecreated=TRUE;
		}
	}
	HWND hwnd=GetConsoleWindow();
	if(hwnd!=NULL)
		SetForegroundWindow(hwnd);
}
