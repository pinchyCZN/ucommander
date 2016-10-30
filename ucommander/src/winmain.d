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
import resource;
import console;

enum epane_id{left,right};

private MainWindow mwin=null;

class MainWindow
{
	HWND hinstance;
	HWND hwnd;
	HWND hmenu;
	HWND hfpanel;
	HWND hsplit;
	HWND hcmd_info,hcommand;
	HWND hgrippy;
	CONTROL_ANCHOR[] main_win_achor=[
		{IDC_CMD_PATH,		ANCHOR_LEFT|ANCHOR_BOTTOM},
		{IDC_CMD_EDIT,		ANCHOR_LEFT|ANCHOR_BOTTOM},
		{IDC_GRIPPY,		ANCHOR_RIGHT|ANCHOR_BOTTOM},
		{IDC_FILE_PANEL,	ANCHOR_LEFT|ANCHOR_RIGHT|ANCHOR_TOP|ANCHOR_BOTTOM},
	];
	enum esplit{vertical,horizontal};
	esplit split_style=esplit.vertical;
	float split_percent=.50;

	FilePane[2] fpanes;

	this(HINSTANCE hinst,int dlg_id)
	{
		LPARAM lparam;
		hinstance=hinst;
		hwnd=CreateDialogParam(hinstance,MAKEINTRESOURCE(dlg_id),NULL,&main_win_proc,cast(LPARAM)cast(void*)this);
		if(hwnd==NULL){
			MessageBox(NULL,"Unable to create window","ERROR",MB_OK|MB_SYSTEMMODAL);
			return;
		}
		load_menu(hwnd,IDR_MAIN_MENU);
		init_grippy(hwnd,IDC_GRIPPY);
		create_fpanel(hwnd);
		anchor_init(hwnd,main_win_achor);
		resize_main_win();
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
			foreach(idc;[IDC_CMD_PATH,IDC_CMD_EDIT,IDC_GRIPPY,IDC_FILE_PANEL]){
				HWND htmp=GetDlgItem(hwnd,idc);
				int x,y,h,w;
				int flag=SWP_NOSIZE|SWP_NOZORDER;
				GetWindowRect(htmp,&rect);
				MapWindowPoints(NULL,hparent,cast(POINT*)&rect,2);
				x=rect.left;
				y=rect.top-delta;
				if(idc==IDC_FILE_PANEL){
					flag=SWP_NOZORDER;
					w=rect.right-rect.left;
					h=rect.bottom-rect.top-delta;
				}
				SetWindowPos(htmp,NULL,x,y,w,h,flag);
			}
			result=TRUE;
		}
		return result;
	}
	int init_pane(HWND hparent,ref FilePane fpane,epane_id id)
	{
		int result=FALSE;
		fpane=new FilePane(hinstance,hparent,id);
		if(fpane.hwnd!=NULL)
			result=TRUE;
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
	int create_fpanel(HWND hparent)
	{
		int result=FALSE;
/*
		hfpanel=GetDlgItem(hparent,IDC_FILE_PANEL);
		if(hfpanel!=NULL){
			RECT rect;
//			GetWindowRect(hfpanel,&rect);
//			MapWindowPoints(NULL,hparent,cast(POINT*)&rect,2);

			GetClientRect(hfpanel,&rect);
			DestroyWindow(hfpanel);
			hfpanel=CreateDialogParam(hinstance,MAKEINTRESOURCE(IDD_PANEL),hparent,&fpanel_proc,cast(LPARAM)cast(void*)this);
			if(hfpanel!=NULL){
				int x,y,w,h;
				SetWindowLong(hfpanel,GWL_ID,IDC_FILE_PANEL);
				x=rect.left;
				y=rect.top;
				w=rect.right-rect.left;
				h=rect.bottom-rect.top;
				SetWindowPos(hfpanel,NULL,x,y,w,h,SWP_NOZORDER|SWP_SHOWWINDOW);
				//init_pane(hfpanel,fpanes[0],epane_id.left);
				//init_pane(hfpanel,fpanes[1],epane_id.right);
				result=TRUE;
			}
		}
*/
		
		if(replace_with_panel(hinstance,IDD_PANEL,IDC_FILE_PANEL,hparent,hfpanel,&fpanel_proc)){
			init_pane(hfpanel,fpanes[0],epane_id.left);
			init_pane(hfpanel,fpanes[1],epane_id.right);
			ShowWindow(hfpanel,SW_SHOW);
			result=TRUE;
		}
		
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
		HWND hparent;
		int center;
		int x1,y1,x2,y2;
		int w1,h1,w2,h2;
		RECT rect;
		hparent=hfpanel;
		if(hparent==NULL)
			return result;
		GetClientRect(hparent,&rect);
		if(split_style==esplit.horizontal){
			int height=(rect.bottom-rect.top);
			center=cast(int)(cast(float)height*split_percent);
			x1=x2=0;
			y1=0;
			h1=center-3;
			y2=center+3;
			h2=height-y2;
			w1=w2=rect.right-rect.left;
		}
		else{
			int width=(rect.right-rect.left);
			center=cast(int)(cast(float)width*split_percent);
			x1=0;
			y1=y2=0;
			w1=center-3;
			x2=center+3;
			w2=width-x2;
			h1=h2=rect.bottom-rect.top;
		}
		if((fpanes[0] !is NULL) && (fpanes[1] !is NULL)){
			SetWindowPos(fpanes[0].hwnd,NULL,x1,y1,w1,h1,SWP_NOZORDER);
			SetWindowPos(fpanes[1].hwnd,NULL,x2,y2,w2,h2,SWP_NOZORDER);
			result=TRUE;
		}
		return result;
	}
}
nothrow
extern (Windows)
BOOL fpanel_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_INITDIALOG:
		break;
	default:
		break;
	}
	return FALSE;
}

nothrow
extern (Windows)
BOOL main_win_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
	case WM_INITDIALOG:
		/*
		MainWindow mwin=cast(MainWindow)cast(void*)lparam;
		if(mwin is null)
			break;
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



MainWindow main_win;

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
	main_win=new MainWindow(hinstance,IDD_MAIN_DLG);

	ShowWindow(main_win.hwnd,SW_SHOW);
	while(GetMessage(&msg,NULL,0,0))
	{
		if(!IsDialogMessage(main_win.hwnd,&msg)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
    return 0;
}

