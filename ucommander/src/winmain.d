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
//import windows_etc;
//import test;
import resource;

class MainWindow{
	HWND hinstance;
	HWND hwnd;
	HWND hmenu;
	HWND hsplit;
	HWND hcmd_info,hcommand;
	HWND hgrippy;
	
	enum esplit{vertical,horizontal};
	esplit split=esplit.vertical;

	FilePane fpane[2];

	this(HINSTANCE hinst,int dlg_id){
		LPARAM lparam;
		hinstance=hinst;
		hwnd=CreateDialogParam(hinstance,MAKEINTRESOURCE(dlg_id),NULL,&main_win_proc,cast(LPARAM)&this);
		if(hwnd==NULL){
			MessageBox(NULL,"Unable to create window","ERROR",MB_OK|MB_SYSTEMMODAL);
			return;
		}
		init_pane(hwnd,fpane[0]);
		init_pane(hwnd,fpane[1]);
	}
	nothrow
	int load_menu(HWND hwnd,int menu_id){
		int result=FALSE;
		HMENU hmenu=LoadMenu(hinstance,MAKEINTRESOURCE(menu_id));
		if(hmenu!=NULL){
			SetMenu(hwnd,hmenu);
			result=TRUE;
		}
		return result;
	}
	int init_pane(HWND hwnd,ref FilePane fpane){
		int result=FALSE;
		fpane=new FilePane(hinstance,hwnd);
		return result;
	}
}


nothrow
extern (Windows)
BOOL main_win_proc(HWND hwnd,UINT msg,WPARAM wparam,LPARAM lparam)
{
	switch(msg){
		case WM_INITDIALOG:
			MainWindow *mwin=cast(MainWindow*)lparam;
			if(mwin==NULL)
				break;
			mwin.load_menu(hwnd,IDR_MAIN_MENU);
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

