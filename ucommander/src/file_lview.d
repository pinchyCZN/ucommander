module file_lview;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import core.stdc.string;
import std.string;
import std.utf;
import winmain;
import resource;

nothrow:
class FileListView{
	HINSTANCE hinstance;
	HWND hwnd,hparent;
	HWND hlview;
	HWND hinfo;
	this(HINSTANCE hinst,HWND hpwnd){
		hinstance=hinst;
		hparent=hpwnd;

	}
}