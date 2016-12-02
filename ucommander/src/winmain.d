module winmain;

//https://github.com/smjgordon/bindings.git
//put win32 bindings in ...\dmd2\src\druntime\import\win32

import core.runtime;
import core.sys.windows.windows;
import core.sys.windows.commctrl;
import std.string;
import std.utf;
import std.stdio;
import file_pane;
import window_anchor;
import windows_etc;
import worker_thread_module;
import resource;
import console;

enum epane_id{left,right};

class MainWindow
{
	HWND hinstance;
	HWND hwnd;
	HWND hmenu;
	HWND hpanel_left,hpanel_right;
	HWND hsplit;
	HWND hcmd_info,hcommand;
	HWND hgrippy;
	WORKER_CONTROL wctrl;
	CONTROL_ANCHOR[] main_win_achor=[
		{IDC_CMD_PATH,			ANCHOR_LEFT|ANCHOR_BOTTOM},
		{IDC_CMD_EDIT,			ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_BOTTOM},
		{IDC_GRIPPY,			ANCHOR_RIGHT|ANCHOR_BOTTOM}
	];
	enum esplit{vertical,horizontal};
	esplit split_style=esplit.vertical;
	float split_percent=.50;

	FilePane[2] fpanes;

	void get_handles(HWND hparent)
	{
		struct CTRL_LIST{HWND *hwnd; int idc;}
		CTRL_LIST[] ctrl_list=[
			{&hpanel_left,	IDC_FILE_PANEL_LEFT},
			{&hpanel_right,	IDC_FILE_PANEL_RIGHT},
			{&hcmd_info,	IDC_CMD_PATH},
			{&hcommand,		IDC_CMD_EDIT},
			{&hgrippy,		IDC_GRIPPY}
		];
		foreach(ctrl;ctrl_list){
			*ctrl.hwnd=GetDlgItem(hparent,ctrl.idc);
		}
	}
	this(HINSTANCE hinst,int dlg_id)
	{
		LPARAM lparam;
		hinstance=hinst;
		hwnd=CreateDialogParam(hinstance,MAKEINTRESOURCE(dlg_id),NULL,&main_win_proc,cast(LPARAM)cast(void*)this);
		if(hwnd==NULL){
			MessageBox(NULL,"Unable to create window","ERROR",MB_OK|MB_SYSTEMMODAL);
			return;
		}
		get_handles(hwnd);
		load_menu(hwnd,IDR_MAIN_MENU);
		init_grippy(hwnd,IDC_GRIPPY);
		anchor_init(hwnd,main_win_achor);
		create_fpanels(hwnd);
		resize_main_win();
		if(initialize_worker_control(wctrl)){
			wctrl.hthread=CreateThread(NULL,0,&worker_thread,cast(void*)&wctrl,0,&wctrl.thread_id);
		}

	}
	nothrow
	int load_menu(HWND hparent,int menu_id)
	{
		int result=FALSE;
		HMENU hmenu=LoadMenu(hinstance,MAKEINTRESOURCE(menu_id));
		if(hmenu!=NULL){
			RECT rect;
			int delta;
			GetClientRect(hparent,&rect);
			delta=rect.bottom-rect.top;
			SetMenu(hparent,hmenu);
			GetClientRect(hparent,&rect);
			delta-=rect.bottom-rect.top;
			if(delta<0)
				delta=0;
			foreach(idc;[IDC_CMD_PATH,IDC_CMD_EDIT,IDC_GRIPPY,IDC_FILE_PANEL_LEFT,IDC_FILE_PANEL_RIGHT]){
				import std.algorithm.comparison;
				HWND htmp=GetDlgItem(hwnd,idc);
				int x,y,h,w;
				int flag=SWP_NOSIZE|SWP_NOZORDER;
				GetClientRect(htmp,&rect);
				MapWindowPoints(htmp,hparent,cast(POINT*)&rect,2);
				x=rect.left;
				y=rect.top-delta;
				if(idc.among(IDC_FILE_PANEL_LEFT,IDC_FILE_PANEL_RIGHT)){
					flag=SWP_NOZORDER;
					y+=delta;
					w=rect.right-rect.left;
					h=rect.bottom-rect.top-delta;
				}
				SetWindowPos(htmp,NULL,x,y,w,h,flag);
			}
			result=TRUE;
		}
		return result;
	}
	int create_fpanels(HWND hparent)
	{
		int result=FALSE;
		struct CTRL_LIST{HWND *hwnd; int idc; epane_id eid;}
		CTRL_LIST[] ctrl_list=[
			{&hpanel_left,	IDC_FILE_PANEL_LEFT,	epane_id.left},
			{&hpanel_right,	IDC_FILE_PANEL_RIGHT,	epane_id.right}
		];
		foreach(i,ref ctrl;ctrl_list){
			if(init_pane(hparent,fpanes[i],ctrl.idc,ctrl.eid))
				*ctrl.hwnd=fpanes[i].hwnd;
		}
		return result;
	}
	int init_pane(HWND hparent,ref FilePane fpane,int idc,epane_id id)
	{
		int result=FALSE;
		fpane=new FilePane(hinstance,hparent,id,idc);
		if(fpane.hwnd!=NULL){
			result=TRUE;
		}
		return result;
	}
	int init_grippy(HWND hparent,int idc)
	{
		int result=FALSE;
		HWND hgrippy;
		LONG style;
		if(hparent==NULL)
			return result;
		hgrippy=GetDlgItem(hparent,idc);
		if(hgrippy==NULL)
			return result;
		style=WS_CHILD|WS_VISIBLE|SBS_SIZEGRIP;
		result=SetWindowLong(hgrippy,GWL_STYLE,style);
		return result;
	}
	nothrow
	int resize_main_win()
	{
		anchor_resize(hwnd,main_win_achor);
		resize_panes();
		return TRUE;
	}
	nothrow
	int resize_panes()
	{
		int result=FALSE;
		int bottom_y;
		{
			RECT rect;
			GetClientRect(hcommand,&rect);
			MapWindowPoints(hcommand,hwnd,cast(LPPOINT)&rect,2);
			bottom_y=rect.top;
		}
		HWND hparent;
		int center;
		int x1,y1,x2,y2;
		int w1,h1,w2,h2;
		RECT rect;
		hparent=hwnd;
		if(hparent==NULL)
			return result;
		GetClientRect(hparent,&rect);
		if(split_style==esplit.horizontal){
			int height=bottom_y;
			center=cast(int)(cast(float)height*split_percent);
			x1=x2=0;
			y1=0;
			h1=center-3;
			y2=center+3;
			h2=height-y2;
			w1=w2=rect.right-rect.left;
			SetWindowPos(hpanel_left,NULL,x1,y1,w1,h1,SWP_NOZORDER);
			SetWindowPos(hpanel_right,NULL,x2,y2,w2,h2,SWP_NOZORDER);
		}
		else{ //vertical
			int width=(rect.right-rect.left);
			center=cast(int)(cast(float)width*split_percent);
			x1=0;
			y1=y2=0;
			w1=center-3;
			x2=center+3;
			w2=width-x2;
			h1=h2=bottom_y;
			SetWindowPos(hpanel_left,NULL,x1,y1,w1,h1,SWP_NOZORDER);
			SetWindowPos(hpanel_right,NULL,x2,y2,w2,h2,SWP_NOZORDER);
		}
		return result;
	}
}

nothrow
extern (Windows)
BOOL main_win_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_INITDIALOG:
		MainWindow mwin=cast(MainWindow)cast(void*)lparam;
		if(mwin is null)
			break;
		/*
		mwin.load_menu(hwnd,IDR_MAIN_MENU);
		*/
		//create_fileview(hwnd,&ghfileview1,0);
		//create_fileview(hwnd,&ghfileview2,0);
		break;
	case WM_COMMAND:
		switch(LOWORD(wparam)){
			case IDCANCEL:
				PostQuitMessage(0);
				break;
			default:
				break;
		}
		break;
	case WM_SIZE:
	case WM_SIZING:
		if(main_win!is null)
			main_win.resize_main_win();
		break;
	default:
		break;
	}
	return 0;
}



__gshared MainWindow main_win;

extern (Windows)
int WinMain(HINSTANCE hinstance, HINSTANCE hprevinstance, LPSTR cmd_line, int cmd_show)
{
	MSG msg;
    INITCOMMONCONTROLSEX ctrls;

	Runtime.initialize();

	ctrls.dwSize=ctrls.sizeof;
    ctrls.dwICC=ICC_LISTVIEW_CLASSES;
	InitCommonControlsEx(&ctrls);

	open_console();
	set_console_size(120,80,800);
	main_win=new MainWindow(hinstance,IDD_MAIN_DLG);

	ShowWindow(main_win.hwnd,SW_SHOW);
	move_console(1920,0);
	add_work_task(COMMAND.CMD_LOAD_SETTINGS,"","");

	while(GetMessage(&msg,NULL,0,0))
	{
		if(!IsDialogMessage(main_win.hwnd,&msg)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
    return 0;
}

