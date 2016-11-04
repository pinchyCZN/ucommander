//#pragma comment(lib, "user32.lib")
//#pragma comment(lib, "comctl32.lib")

#define CINTERFACE

#include <windows.h>
//#include <commctrl.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <math.h>
#include <Shlobj.h>
#include <shlwapi.h>
//#include <iostream.h>
#include "resource.h"

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void CreateToolTipForRect(HWND hwndParent);

HINSTANCE hinstance;
HMENU hmenu=0;

int move_console()
{
	char title[MAX_PATH]={0}; 
	HWND hcon; 
	GetConsoleTitle(title,sizeof(title));
	if(title[0]!=0){
		hcon=FindWindow(NULL,title);
		SetWindowPos(hcon,0,600,0,800,600,SWP_NOZORDER);
	}
	return 0;
}
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
void hide_console()
{
	char title[MAX_PATH]={0}; 
	HANDLE hcon; 
	
	GetConsoleTitle(title,sizeof(title));
	if(title[0]!=0){
		hcon=FindWindow(NULL,title);
		ShowWindow(hcon,SW_HIDE);
		SetForegroundWindow(hcon);
	}
}

int menu_id=0;

int invoke_command(IContextMenu *c,int id,HWND hwnd)
{
	CMINVOKECOMMANDINFO ci;
	memset(&ci,0,sizeof(ci));
	ci.cbSize=sizeof(ci);
	ci.hwnd=hwnd;
	ci.lpVerb=MAKEINTRESOURCE(id-1);
	ci.nShow=SW_SHOWNORMAL;
	c->lpVtbl->InvokeCommand(c,&ci);
	return 0;
}
int get_higher_context(IContextMenu *c)
{
	IContextMenu2 *c2=0;
	IContextMenu3 *c3=0;
	c->lpVtbl->QueryInterface(c,&IID_IContextMenu3,c3);
	if(c3==0){
		c->lpVtbl->QueryInterface(c,&IID_IContextMenu2,c2);
	}
	if(c2!=0 || c3!=0){
		c->lpVtbl->Release(c);
		if(c3!=0)
			c=c3;
		else
			c=c2;
	}
	return 0;
}
int get_wide_path(const char *fname,char *out_path,int psize,char *out_fname,int fsize)
{
	char drive[_MAX_DRIVE],dir[_MAX_DIR],fn[_MAX_FNAME],ext[_MAX_EXT];
	char tmp[MAX_PATH];
	drive[0]=dir[0]=fn[0]=ext[0]=0;
	_splitpath(fname,drive,dir,fn,ext);
	_snprintf(tmp,sizeof(tmp),"%s%s",drive,dir);
	mbstowcs(out_path,tmp,psize);
	_snprintf(tmp,sizeof(tmp),"%s%s",fn,ext);
	mbstowcs(out_fname,tmp,fsize);
	return 0;
}

int GetContextMenu(HWND hwnd,char *fname)
{
	HRESULT hr;
	ITEMIDLIST *folder=0,*file=0;
	IShellFolder *shell=0,*parent=0;
	static init=TRUE;
	if(init){
		hr=CoInitialize(0);
		if(hr!=S_OK)
			return 0;
		init=FALSE;
	}
	CoCreateInstance(&CLSID_ShellDesktop,NULL,CLSCTX_INPROC,&IID_IShellFolder,&shell);

	if(shell!=0){
		char wpath[MAX_PATH*2]={0,0},wfname[MAX_PATH*2]={0,0};
		get_wide_path(fname,wpath,sizeof(wpath),wfname,sizeof(wfname));
		hr=shell->lpVtbl->ParseDisplayName(shell,NULL,NULL,wpath,NULL,&folder,NULL);
		if(hr==S_OK){
			shell->lpVtbl->BindToObject(shell,folder,NULL,&IID_IShellFolder,&parent);
			if(parent!=0){
				IContextMenu *context=0;
				hr=parent->lpVtbl->ParseDisplayName(parent,NULL,NULL,wfname,NULL,&file,NULL);
				if(hr==S_OK)
					parent->lpVtbl->GetUIObjectOf(parent,NULL,1,&file,&IID_IContextMenu,NULL,&context);
				parent->lpVtbl->Release(parent);
				get_higher_context(context);
				if(context!=0){
					HMENU hmenu=0;
					hmenu=CreatePopupMenu();
					hr=context->lpVtbl->QueryContextMenu(context,hmenu,0,1,0x7FFF,CMF_NORMAL);
					if(hr>1)//returns largest menu identifier + 1
					{
						POINT pt;
						int menu_id=0;
						GetCursorPos(&pt);
						menu_id=TrackPopupMenu(hmenu,TPM_RETURNCMD,pt.x+10,pt.y+10,0,hwnd,NULL);
						if(menu_id>=1 && menu_id<=0x7FFF)
							invoke_command(context,menu_id,hwnd);
					}
					context->lpVtbl->Release(context);
					if(hmenu!=0)
						DestroyMenu(hmenu);
				}
			}
		}
		shell->lpVtbl->Release(shell);
	}
	if(folder!=0)
		CoTaskMemFree(folder);
	if(file!=0)
		CoTaskMemFree(file);
	//CoUninitialize();
    return 0;
}
void CreateToolTipForRect(HWND hwndParent)
{
    // Create a tooltip.
    TOOLINFO ti = { 0 };
    HWND hwndTT = CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, NULL, 
		WS_POPUP | TTS_NOPREFIX | TTS_ALWAYSTIP, 
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, 
		hwndParent, NULL, hinstance,NULL);
	
    SetWindowPos(hwndTT, HWND_TOPMOST, 0, 0, 0, 0, 
		SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
	
    // Set up "tool" information. In this case, the "tool" is the entire parent window.
    
	
    ti.cbSize   = sizeof(TOOLINFO);
    ti.uFlags   = TTF_SUBCLASS|TTF_IDISHWND|TTF_CENTERTIP;
    ti.hwnd     = hwndParent;
    ti.hinst    = hinstance;
    ti.lpszText = TEXT("This is your tooltip string.");;
	ti.uId		= hwndParent;
    
    //GetClientRect (hwndParent, &ti.rect);
	
    // Associate the tooltip with the "tool" window.
    SendMessage(hwndTT, TTM_ADDTOOL, 0, (LPARAM) (LPTOOLINFO) &ti);	
} 
void printrect(RECT rect)
{
	printf("x=%i\n",rect.left);
	printf("y=%i\n",rect.top);
	printf("r=%i\n",rect.right);
	printf("b=%i\n",rect.bottom);
}



int key_ctrl=FALSE;
int key_shift=FALSE;
int extended_key=FALSE;
int getkey()
{
	int i=0;
	key_ctrl=FALSE;
	key_shift=FALSE;
	extended_key=FALSE;
	i=getch();
	if (GetKeyState(VK_SHIFT) < 0)
		key_shift=TRUE;
	if(GetKeyState(VK_CONTROL) < 0)
		key_ctrl=TRUE;
	if(i==0 || i==0xE0)
	{
		i=getch();
		extended_key=TRUE;
	}
	return i&0xFF;

}
int getkey2()
{
	int i=0;
	key_ctrl=FALSE;
	key_shift=FALSE;
	extended_key=FALSE;
	if(kbhit())
	{
		i=getch();
		if(i==0 || i==0xE0)
		{
			i=getch();
			extended_key=TRUE;
		}
		if (GetKeyState(VK_SHIFT) < 0)
			key_shift=TRUE;
		if(GetKeyState(VK_CONTROL) < 0)
			key_ctrl=TRUE;

	}
	return i&0xFF;

}

LRESULT CALLBACK WndProc( HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam )
{
	RECT rect;

	switch(msg){
	case WM_INITDIALOG:
		break;
	case WM_CTLCOLOREDIT:
		break;
	case WM_MENUSELECT:
		break;
    case WM_CREATE:
		{
			HWND htmp;
			int style;
			htmp=CreateWindow(TEXT("BUTTON"),TEXT("BUTTON"),WS_VISIBLE|WS_CHILD|BS_PUSHBUTTON,0,0,100,100,hwnd,2000,hinstance,NULL);
			htmp=CreateWindow(TEXT("EDIT"),TEXT("EDIT"),WS_VISIBLE|WS_CHILD|ES_READONLY,0,100,100,100,hwnd,2000,hinstance,NULL);
			style=GetWindowLong(hwnd,GWL_STYLE);
			style=style;
		}
        break;
	case WM_TIMER:
		break;
	case WM_USER:
		break;
    case WM_DESTROY:
        PostQuitMessage(0);
		break;
	case WM_KEYDOWN:
        break;
	case WM_ENDSESSION:
		return 0;
	case WM_QUERYENDSESSION:
		return TRUE;
		break;
	case WM_COMMAND:
		switch(LOWORD(wparam)){
		case IDOK:
		case IDCANCEL:
			PostQuitMessage(0);
			break;
		}
		break;
	}
	//return FALSE;
	return DefWindowProc(hwnd, msg, wparam, lparam);
}

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
				   LPSTR lpCmdLine, int nCmdShow )
{
	
	MSG msg;    
	WNDCLASS wc={0};
	const TCHAR *class_name=TEXT("TEST");
	HWND hwnd;
	int style;
	hinstance=hInstance;
	InitCommonControls();	
	wc.lpszClassName = class_name;
	wc.hInstance     = hInstance ;
	wc.lpfnWndProc   = WndProc ;
	RegisterClass(&wc);
	hwnd=CreateWindow(class_name,class_name,WS_OVERLAPPEDWINDOW|WS_VISIBLE,0,0,500,500,NULL,NULL,hinstance,NULL);
	style=GetWindowLong(hwnd,GWL_STYLE);
	
	
//	open_console();
//	move_console();
	while( GetMessage(&msg, NULL, 0, 0)) {
		if(!IsDialogMessage(hwnd,&msg)){
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	return 0;
}

