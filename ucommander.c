#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include "resource.h"


HINSTANCE ghinstance=0;
HWND ghmain=0;
HMENU ghmainmenu=0;
HWND ghfileview1=0,ghfileview2=0;

int create_listview(HWND hparent,HWND *hlview,int idc,int counter)
{
	int result=FALSE;
	int exstyle;
	HWND htmp;
	TCHAR tmp[40]={0};
	DestroyWindow(GetDlgItem(hparent,idc));
	exstyle=LVS_EX_GRIDLINES|LVS_EX_FULLROWSELECT;
	_snprintf(tmp,sizeof(tmp)/sizeof(TCHAR),TEXT("FILE LISTVIEW %i"),counter);
	htmp=CreateWindowEx(exstyle,WC_LISTVIEW,tmp,
		WS_TABSTOP|WS_CHILD|WS_CLIPSIBLINGS|WS_VISIBLE|LVS_REPORT|LVS_SHOWSELALWAYS|LVS_OWNERDRAWFIXED,
		0,0,0,0,hparent,idc,ghinstance,counter);
	if(htmp!=0){
		result=TRUE;
	}
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
	memset(&rtmp,0,sizeof(rtmp));
	SendMessage(htmp,TCM_GETITEMRECT,0,&rtmp);
	if(0==rtmp.left && 0==rtmp.right){
		w=h=0;
	}
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
	return 0;
}
LRESULT CALLBACK file_view_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_INITDIALOG:
		{
			HWND hlview=0;
			create_listview(hwnd,&hlview,IDC_LVIEW,lparam);
			resize_fileview(hwnd);
			SetDlgItemTextW(hwnd,IDC_HOTLIST,TEXT("\x3D\x27")); //0x273D asterisk
			SetDlgItemTextW(hwnd,IDC_HISTORY,TEXT("\xBC\x25")); //0x25BC downarrow
		}
		break;
	}
	return 0;
}

int create_fileview(HWND hparent,HWND *hfview,int id)
{
	int result=FALSE;
	HWND htmp=0;
	htmp=CreateDialogParam(ghinstance,MAKEINTRESOURCE(IDD_FILE_VIEW),hparent,file_view_proc,id);
	if(0==htmp)
		return result;
	ShowWindow(htmp,SW_SHOW);
	SetWindowPos(htmp,HWND_TOP,0,40,0,0,SWP_NOSIZE|SWP_SHOWWINDOW);
	if(hfview!=0){
		*hfview=htmp;
		result=TRUE;
	}
	return result;
}

LRESULT CALLBACK MainDlg(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_INITDIALOG:
		ghmainmenu=LoadMenu(ghinstance,MAKEINTRESOURCE(IDR_MAIN_MENU));
		if(ghmainmenu!=0)
			SetMenu(hwnd,ghmainmenu);
		create_fileview(hwnd,&ghfileview1,0);
		create_fileview(hwnd,&ghfileview2,0);
		break;
	case WM_COMMAND:
		switch(LOWORD(wparam)){
		case IDCANCEL:
			PostQuitMessage(0);
			break;
		}
		break;
	case WM_CLOSE:
		PostQuitMessage(0);
		break;
	}
	return 0;
}

int WINAPI WinMain(HINSTANCE hinstance,HINSTANCE hprevinstance,PSTR cmdline,int cmdshow)
{
	int result=0;
	MSG msg={0};
    INITCOMMONCONTROLSEX ctrls={0};

	ghinstance=hinstance;

	OleInitialize(0);

	ctrls.dwSize=sizeof(ctrls);
    ctrls.dwICC = ICC_LISTVIEW_CLASSES|ICC_TREEVIEW_CLASSES|ICC_BAR_CLASSES;
	InitCommonControlsEx(&ctrls);

	ghmain=CreateDialog(ghinstance,MAKEINTRESOURCE(IDD_MAIN_DLG),NULL,MainDlg);
	if(!ghmain){
		MessageBox(NULL,TEXT("Could not create main dialog"),TEXT("ERROR"),MB_SYSTEMMODAL|MB_ICONERROR|MB_OK);
		return -1;
	}
	ShowWindow(ghmain,cmdshow);
	while(GetMessage(&msg,NULL,0,0))
	{
		if(!IsDialogMessage(ghmain,&msg)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	return result;
}	