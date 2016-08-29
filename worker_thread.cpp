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
				SendMessage(htmp,CB_ADDSTRING,0,(LPARAM)tmp);
			}
		}
	}
	return TRUE;
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
	void *fdlg=0;
	get_fview(target,&hfview);
	return FALSE;
}
int get_next_command(struct WORKER_PARAMS *wparams,int *cmd,int *sub_cmd)
{
	extern CRITICAL_SECTION mutex;
	int i,count;
	*cmd=0;
	*sub_cmd=0;
	EnterCriticalSection(&mutex);
	*cmd=wparams->cmd_list[0].cmd;
	*sub_cmd=wparams->cmd_list[0].sub_cmd;
	count=sizeof(wparams->cmd_list)/sizeof(struct CMD_LIST);
	count-=1;
	for(i=0;i<count;i++){
		wparams->cmd_list[i].cmd=wparams->cmd_list[i+1].cmd;
		wparams->cmd_list[i].sub_cmd=wparams->cmd_list[i+1].sub_cmd;
	}
	wparams->cmd_list[count].cmd=0;
	wparams->cmd_list[count].sub_cmd=0;
	wparams->index--;
	if(wparams->index<0)
		wparams->index=0;
	LeaveCriticalSection(&mutex);
	return TRUE;
}
DWORD WINAPI worker_thread(VOID *arg)
{
	struct WORKER_PARAMS *wparams=(WORKER_PARAMS*)arg;
	HANDLE hevent;
	if(arg==0)
		return -1;
	hevent=wparams->hevent;
	if(hevent==0)
		return -1;
	while(TRUE){
		DWORD event;
		int cmd,sub_cmd;
		event=WaitForSingleObject(hevent,INFINITE);
		if(event!=WAIT_OBJECT_0){
			Sleep(1000);
			continue;
		}
		do{
			get_next_command(wparams,&cmd,&sub_cmd);
			switch(cmd){
			case CMD_INIT:
				init_fviews();
				break;
			case CMD_NEWTAB:
				cmd_add_tab(sub_cmd);
				break;
			}
		}while(cmd!=0);
		

	}
	return 0;
}