#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include "resource.h"
#include "cmd_list.h"

extern int worker_cmd,worker_target;
extern HWND ghfileview1,ghfileview2;

int add_tab(HWND htab,int index,TCHAR *txt)
{
	TC_ITEM tci={0};
	tci.mask=TCIF_TEXT;
	tci.pszText=txt;
	return TabCtrl_InsertItem(htab,index,&tci);
}

int init_fviews()
{
	extern HWND ghfileview1,ghfileview2;
	HWND *hlist[]={&ghfileview1,&ghfileview2};
	int i,drives;
	drives=GetLogicalDrives();
	for(i=0;i<sizeof(hlist)/sizeof(HWND *);i++){
		int j;
		HWND htmp,hdlg;
		hdlg=*hlist[i];
		htmp=GetDlgItem(hdlg,IDC_COMBO_DRIVE);
		SendMessage(htmp,CB_RESETCONTENT,0,0);
		for(j=0;j<26;j++){
			char tmp[20]={0};
			if(drives&(1<<j)){
				_snprintf(tmp,sizeof(tmp),"%c:\\",'A'+j);
				SendMessage(htmp,CB_ADDSTRING,0,tmp);
			}
		}
	}
}
int get_fview(int target,HWND *hout)
{
	if(target==TARGET_LEFT)
		*hout=ghfileview1;
	else
		*hout=ghfileview2;
	return *hout!=0;
}
int cmd_add_tab(int target)
{
	HWND hfview=0;
	get_fview(target,&hfview);
	add_ftab(target);
	populate_ftab(target,0);

}
DWORD WINAPI worker_thread(VOID *arg)
{
	HANDLE hevent=arg;
	if(hevent==0)
		return -1;
	while(TRUE){
		DWORD event;
		int cmd,target;
		event=WaitForSingleObject(hevent,INFINITE);
		if(event!=WAIT_OBJECT_0){
			Sleep(1000);
			continue;
		}
		cmd=InterlockedExchange(&worker_cmd,0);
		target=InterlockedExchange(&worker_target,0);
		switch(cmd){
		case CMD_INIT:
			init_fviews();
			break;
		case CMD_NEWTAB:
			cmd_add_tab(target);
			break;
		}
		

	}
	return 0;
}