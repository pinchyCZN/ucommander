module file_lview;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import core.stdc.string;
import std.string;
import std.utf;
import std.algorithm;
import winmain;
import window_anchor;
import windows_etc;
import resource;
import file_list;

nothrow:
private struct LViewEntry{
	FileListView flview;
	HWND hwnd;
}
LViewEntry[] lvtable;

class FileListView{
	HINSTANCE hinstance;
	HWND hwnd,hparent;
	HWND hlview;
	HWND hinfo;
	string path;
	FileEntry[] files;
	CONTROL_ANCHOR[] lview_anchor=[
		{IDC_LISTVIEW,	ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_TOP|ANCHOR_BOTTOM},
		{IDC_FILE_INFO,	ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_BOTTOM}
	];
	this(HINSTANCE hinst,HWND hpwnd,int panel_idc){
		hinstance=hinst;
		hparent=hpwnd;
		hwnd=NULL;
		replace_with_panel(hinstance,IDD_LVIEW,panel_idc,hparent,hwnd,&lview_dlg_proc);
		if(hwnd!=NULL){
			struct CTRL_LIST{HWND *hwnd; int idc;}
			CTRL_LIST[] ctrl_list=[
				{&hlview,		IDC_LISTVIEW},
				{&hinfo,		IDC_DRIVE_INFO},
			];
			foreach(ctrl;ctrl_list){
				*ctrl.hwnd=GetDlgItem(hwnd,ctrl.idc);
			}
			lvtable~=LViewEntry(this,hwnd);
			anchor_init(hwnd,lview_anchor);
			ShowWindow(hwnd,SW_SHOW);
		}
	}
	~this(){
		int i;
		for(i=0;i<lvtable.length;i++){
			if(hwnd==lvtable[i].hwnd){
				lvtable=remove(lvtable,i);
				break;
			}
		}
	}

}

int get_lview(HWND hwnd,ref FileListView flv)
{
	int result=FALSE;
	foreach(lv;lvtable){
		if(lv.hwnd==hwnd){
			flv=lv.flview;
			result=TRUE;
			break;
		}
	}
	return result;
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
	case WM_SIZE:
	case WM_SIZING:
		{
			FileListView flv=null;
			if(get_lview(hwnd,flv))
				anchor_resize(hwnd,flv.lview_anchor);
		}
		break;
	default:
		break;
	}
	return 0;
}
