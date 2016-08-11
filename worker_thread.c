#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include "resource.h"
#include "cmd_list.h"

extern int worker_cmd;

int init_fviews()
{
	printf("234\n");
}

DWORD WINAPI worker_thread(VOID *arg)
{
	HANDLE hevent=arg;
	if(hevent==0)
		return -1;
	while(TRUE){
		DWORD event;
		int cmd=0;
		event=WaitForSingleObject(hevent,INFINITE);
		if(event!=WAIT_OBJECT_0){
			Sleep(1000);
			continue;
		}
		cmd=InterlockedExchange(&worker_cmd,0);
		switch(cmd){
		case CMD_INIT:
			init_fviews();
			break;
		}
		

	}
	return 0;
}