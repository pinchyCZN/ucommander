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
			stdout.setvbuf(0,_IONBF);
			consolecreated=TRUE;
		}
	}
	HWND hwnd=GetConsoleWindow();
	if(hwnd!=NULL)
		SetForegroundWindow(hwnd);
}
void hide_console()
{
	HWND hwnd=GetConsoleWindow();
	if(hwnd!=NULL){
		ShowWindow(hwnd,SW_HIDE);
	}
}
void move_console(int x,int y)
{
	HWND hwnd=GetConsoleWindow();
	if(hwnd!=NULL){
		SetWindowPos(hwnd,NULL,x,y,0,0,SWP_NOSIZE);
	}
}
void set_console_size(short width,short height,short buf_height)
{
	import std.algorithm.comparison;
	HANDLE hcon;
	hcon=GetStdHandle(STD_OUTPUT_HANDLE);
	if(hcon!=NULL){
		SMALL_RECT rect;
		CONSOLE_SCREEN_BUFFER_INFO conbi;
		GetConsoleScreenBufferInfo(hcon,&conbi);
		if(width>=conbi.dwSize.X || height>=conbi.dwSize.Y){
			short maxy;
			maxy=max(height,buf_height);
			if(width>=conbi.dwSize.X)
				conbi.dwSize.X=cast(short)(width+1);
			if(maxy>=conbi.dwSize.Y)
				conbi.dwSize.Y=cast(short)(maxy+1);
			SetConsoleScreenBufferSize(hcon,conbi.dwSize);
		}
		rect.Bottom=height;
		rect.Right=width;
		rect.Top=0;
		rect.Left=0;
		SetConsoleWindowInfo(hcon,TRUE,&rect);
	}
}