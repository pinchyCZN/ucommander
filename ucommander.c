#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include <fcntl.h>
#include "resource.h"
#include "cmd_list.h"

HINSTANCE ghinstance=0;
HWND ghmain=0;
HMENU ghmainmenu=0;
HWND ghfileview1=0,ghfileview2=0;
HANDLE ghevent=0;
DWORD gthreadid=0;
int worker_cmd=0;
int worker_target=0;
int gstyle=0;

DWORD WINAPI worker_thread(LPVOID);

void open_console()
{
	char title[MAX_PATH]={0};
	HWND hcon;
	FILE *hf;
	static BYTE consolecreated=FALSE;
	static int hcrt=0;

	if(consolecreated==TRUE)
	{
		GetConsoleTitle(title,sizeof(title));
		if(title[0]!=0){
			hcon=FindWindow(NULL,title);
			ShowWindow(hcon,SW_SHOW);
		}
		hcon=(HWND)GetStdHandle(STD_INPUT_HANDLE);
		FlushConsoleInputBuffer(hcon);
		return;
	}
	AllocConsole();
	hcrt=_open_osfhandle((long)GetStdHandle(STD_OUTPUT_HANDLE),_O_TEXT);

	fflush(stdin);
	hf=_fdopen(hcrt,"w");
	*stdout=*hf;
	setvbuf(stdout,NULL,_IONBF,0);
	GetConsoleTitle(title,sizeof(title));
	if(title[0]!=0){
		hcon=FindWindow(NULL,title);
		ShowWindow(hcon,SW_SHOW);
		SetForegroundWindow(hcon);
	}
	consolecreated=TRUE;
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
		{
			int i;
			for(i=0;i<1;i++){
				TCHAR tmp[40];
				_snprintf(tmp,sizeof(tmp),"test%i",i);
				add_tab(GetDlgItem(ghfileview1,IDC_TAB_VIEW),0,tmp);
			}
		}
		init_grippy(ghfileview2,IDC_GRIPPY);
		resize_main_dlg(hwnd,gstyle);
		ghevent=CreateEvent(NULL,FALSE,FALSE,TEXT("WORKEREVENT"));
		if(ghevent!=0){
			CreateThread(NULL,0,worker_thread,ghevent,0,&gthreadid);
			InterlockedExchange(&worker_cmd,CMD_INIT);
			SetEvent(ghevent);
			Sleep(100);
			InterlockedExchange(&worker_target,TARGET_LEFT);
			InterlockedExchange(&worker_cmd,CMD_NEWTAB);
			SetEvent(ghevent);
		}
		break;
	case WM_SIZE:
		resize_main_dlg(hwnd,gstyle);
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

	open_console();
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