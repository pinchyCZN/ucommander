module file_lview;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import core.stdc.string;
import std.string;
import std.utf;
import winmain;
import resource;
import file_list;

nothrow:
class FileListView{
	HINSTANCE hinstance;
	HWND hwnd,hparent;
	HWND hlview;
	HWND hinfo;
	string path;
	FileEntry[] files;
	this(HINSTANCE hinst,HWND hpwnd){
		hinstance=hinst;
		hparent=hpwnd;
		hwnd=CreateDialogParam(hinstance,MAKEINTRESOURCE(IDD_LVIEW),hparent,&lview_dlg_proc,cast(LPARAM)cast(void*)this);
		if(hwnd!=NULL){
			struct CTRL_LIST{HWND *hwnd; int idc;}
			CTRL_LIST[] ctrl_list=[
				{&hlview,		IDC_LISTVIEW},
				{&hinfo,		IDC_DRIVE_INFO},
			];
			foreach(ctrl;ctrl_list){
				*ctrl.hwnd=GetDlgItem(hwnd,ctrl.idc);
			}
		}
	}
}


nothrow
extern (Windows)
BOOL lview_dlg_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
		case WM_INITDIALOG:
			break;
		case WM_COMMAND:
			break;
		default:
			break;
	}
	return 0;
}
