module fileview;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import core.stdc.string;
import std.string;
import std.utf;
import winmain;
import resource;

nothrow:

int init_grippy(HWND hwnd,int idc)
{
	int result=FALSE;
	HWND hgrippy;
	LONG style;
	if(hwnd==NULL)
		return result;
	hgrippy=GetDlgItem(hwnd,idc);
	if(hgrippy==NULL)
		return result;
	style=WS_CHILD|WS_VISIBLE|SBS_SIZEGRIP;
	result=SetWindowLong(hgrippy,GWL_STYLE,style);
	return result;
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
*/
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

