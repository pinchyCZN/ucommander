module file_pane;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import core.stdc.string;
import std.string;
import std.utf;
import std.conv;
import std.algorithm;
import winmain;
import resource;
import window_anchor;
import windows_etc;
import worker_thread_module;


nothrow:
private struct PaneEntry{
	FilePane fpane;
	HWND hwnd;
}
PaneEntry[] fptable;

struct FileTab{
	
}

class FilePane{
	HINSTANCE hinstance;
	HWND hwnd,hparent;
	HWND hlistdrives;
	HWND hdriveinfo;
	HWND htab;
	HWND hbtnup,hbtnroot;
	HWND hpath;
	HWND hhotlist;
	HWND hhistory;
	HWND hlistview;
	epane_id pane_id;
	CONTROL_ANCHOR[] file_pane_anchor=[
		{IDC_COMBO_DRIVE,	ANCHOR_LEFT|ANCHOR_TOP},
		{IDC_DRIVE_INFO,	ANCHOR_LEFT|ANCHOR_TOP},
		{IDC_TAB_VIEW,		ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_TOP},
		{IDC_UP_DIR,		ANCHOR_RIGHT|ANCHOR_TOP},
		{IDC_ROOT,			ANCHOR_RIGHT|ANCHOR_TOP},
		{IDC_FILE_PATH,		ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_TOP},
		{IDC_HOTLIST,		ANCHOR_RIGHT|ANCHOR_TOP},
		{IDC_HISTORY,		ANCHOR_RIGHT|ANCHOR_TOP},
		{IDC_LISTVIEW,		ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_TOP|ANCHOR_BOTTOM},
		{IDC_FILE_INFO,		ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_BOTTOM}
	];

	this(HINSTANCE hinst,HWND hpwnd,epane_id id,int panel_idc){
		hinstance=hinst;
		hparent=hpwnd;
		pane_id=id;
		hwnd=NULL;
		replace_with_panel(hinstance,IDD_FILE_PANE,panel_idc,hparent,hwnd,&dlg_pane_proc);
		if(hwnd!=NULL){
			struct CTRL_LIST{HWND *hwnd; int idc;}
			CTRL_LIST[] ctrl_list=[
				{&hlistdrives,	IDC_COMBO_DRIVE},
				{&hdriveinfo,	IDC_DRIVE_INFO},
				{&htab,			IDC_TAB_VIEW},
				{&hbtnup,		IDC_UP_DIR},
				{&hbtnroot,		IDC_ROOT},
				{&hpath,		IDC_FILE_PATH},
				{&hhotlist,		IDC_HOTLIST},
				{&hhistory,		IDC_HISTORY},
				{&hlistview,	IDC_LISTVIEW}
			];
			foreach(ctrl;ctrl_list){
				*ctrl.hwnd=GetDlgItem(hwnd,ctrl.idc);
			}
			fptable~=PaneEntry(this,hwnd);
			anchor_init(hwnd,file_pane_anchor);
			ShowWindow(hwnd,SW_SHOW);
		}
	}
	~this(){
		int i;
		for(i=0;i<fptable.length;i++){
			if(hwnd==fptable[i].hwnd){
				fptable=remove(fptable,i);
				break;
			}
		}
	}
	int add_tab(uint pos,const wstring caption){
		int result=-1;
		int count;
		count=TabCtrl_GetItemCount(htab);
		if(count>=0){
			wstring tmp;
			TC_ITEM tci;
			tmp=caption[0..min(caption.length,40)]~"\0";
			tci.mask=TCIF_TEXT;
			tci.pszText=cast(wchar*)tmp;
			result=TabCtrl_InsertItem(htab,pos,&tci);
		}
		return result;
	}

}

int get_fpane(HWND hwnd,ref FilePane fpane)
{
	int result=FALSE;
	foreach(pane;fptable){
		if(pane.hwnd==hwnd){
			fpane=pane.fpane;
			result=TRUE;
			break;
		}
	}
	return result;
}

nothrow
extern (Windows)
BOOL dlg_pane_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_INITDIALOG:
		break;
	case WM_COMMAND:
		switch(LOWORD(wparam)){
			case IDC_UP_DIR:
				add_work_task(COMMAND.CMD_RENAME_FILE,"","");
			{
				int i;
				i++;
			}
			//writeln("234234");
				break;
			default:
				break;
		}
		break;
	case WM_SIZE:
	case WM_SIZING:
		{
			FilePane fp=null;
			if(get_fpane(hwnd,fp))
				anchor_resize(hwnd,fp.file_pane_anchor);
		}
		break;
	default:
		break;
	}
	return 0;
}

int resize_fileview(HWND hwnd)
{
	RECT rect={0},rtmp={0};
	HWND htmp;
	int x,y,w,h;
	GetClientRect(hwnd,&rect);
	htmp=GetDlgItem(hwnd,IDC_COMBO_DRIVE);
	x=y=0;
	w=60;
	h=250;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	GetClientRect(htmp,&rtmp);
	x=rtmp.right+5;
	h=rtmp.bottom-rtmp.top;
	w=rect.right-rect.left-x;
	htmp=GetDlgItem(hwnd,IDC_DRIVE_INFO);
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	htmp=GetDlgItem(hwnd,IDC_TAB_VIEW);
	x=0;y=rtmp.bottom+5;
	w=rect.right;
	h=rect.bottom-y-20;

	w=h=0;
	if(2<=SendMessage(htmp,TCM_GETITEMCOUNT,0,0)){
		memset(&rtmp,0,rtmp.sizeof);
		SendMessage(htmp,TCM_GETITEMRECT,0,cast(LPARAM)&rtmp);
		if(0==rtmp.left && 0==rtmp.right){
			w=h=0;
		}else{
			w=rect.right;
			h=rtmp.bottom-rtmp.top;
		}
	}
	/*
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	htmp=GetDlgItem(hwnd,IDC_EDIT_PATH);
	x=0;
	y+=h+2;
	w=rect.right-50;
	h=22;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	htmp=GetDlgItem(hwnd,IDC_HOTLIST);
	x=w;
	y=y;
	w=22;
	h=22;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	htmp=GetDlgItem(hwnd,IDC_HISTORY);
	x=x+w;
	y=y;
	w=22;
	h=22;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);

	htmp=GetDlgItem(hwnd,IDC_LVIEW);
	x=0;
	y+=h+2;
	w=rect.right;
	h=rect.bottom-y-22;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	htmp=GetDlgItem(hwnd,IDC_FILE_INFO);
	x=0;
	y+=h+2;
	w=rect.right;
	h=22;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
	htmp=GetDlgItem(hwnd,IDC_GRIPPY);
	x=rect.right-15;
	y=rect.bottom-15;
	w=h=15;
	SetWindowPos(htmp,NULL,x,y,w,h,SWP_NOZORDER);
	*/
	return 0;
}
/*
int draw_item(DRAWITEMSTRUCT *di,int mode)
{
	int result=FALSE;
	TCHAR text[2048];
	int textcolor,bgcolor;
	if(0==di)
		return result;
	ListView_GetItemText(di.hwndItem,di.itemID,0,text,sizeof(text)/sizeof(TCHAR));
	text[sizeof(text)/sizeof(TCHAR)-1]=0;
	bgcolor=GetSysColor(di->itemState&ODS_SELECTED ? COLOR_HIGHLIGHT:COLOR_WINDOW);
	textcolor=GetSysColor(di->itemState&ODS_SELECTED ? COLOR_HIGHLIGHTTEXT:COLOR_WINDOWTEXT);
	SetTextColor(di->hDC,textcolor);
	SetBkColor(di->hDC,bgcolor);
	DrawText(di->hDC,text,-1,&di->rcItem,DT_LEFT|DT_NOPREFIX);
	return result;
}

extern(Windows)
LRESULT file_view_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
		case WM_INITDIALOG:
			{
				const char *asterisk="\x3D\x27\0\0",downarrow="\xBC\x25\0\0";
				resize_fileview(hwnd);
				SetDlgItemTextW(hwnd,IDC_HOTLIST,cast(wchar*)asterisk); //0x273D asterisk
				SetDlgItemTextW(hwnd,IDC_HISTORY,cast(wchar*)downarrow); //0x25BC downarrow
			}
			break;
		case WM_DRAWITEM:
			{
				DRAWITEMSTRUCT *di=cast(DRAWITEMSTRUCT*)lparam;
				if(di!=NULL && di.CtlType==ODT_LISTVIEW){
//					draw_item(di,0);
					return TRUE;
				}
			}
			break;
		case WM_SIZE:
			resize_fileview(hwnd);
			break;
		default:
			break;
	}
	return 0;
}

int create_fileview(HWND hparent,HWND *hfview,int id)
{
	int result=FALSE;
	HWND htmp=NULL;
	htmp=CreateDialogParam(ghinstance,MAKEINTRESOURCE(IDD_FILE_VIEW),hparent,&file_view_proc,id);
	if(htmp==NULL)
		return result;
	ShowWindow(htmp,SW_SHOW);
	SetWindowPos(htmp,HWND_TOP,0,40,0,0,SWP_NOSIZE|SWP_SHOWWINDOW);
	if(hfview!=NULL){
		*hfview=htmp;
		result=TRUE;
	}
	return result;
}

*/
