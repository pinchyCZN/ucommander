module worker_thread_module;

import core.runtime;
import core.sys.windows.windows;
import core.sys.windows.commctrl;
import std.string;
import std.stdio;
import winmain;
import misc_tasks;

enum COMMAND{
	CMD_LOAD_SETTINGS,
	CMD_RENAME_FILE
};
struct WORK_TASK{
	COMMAND cmd;
	string param1,param2;
}
struct WORKER_CONTROL{
	HANDLE hthread;
	HANDLE hevent;
	DWORD thread_id;
	int cancel;
	int exit;
	CRITICAL_SECTION cs;
	WORK_TASK[] tasks;
}
nothrow
int add_work_task(COMMAND cmd,string param1,string param2)
{
	alias mwin=main_win;
	int result=false;
	if(mwin is null)
		return result;
	EnterCriticalSection(&mwin.wctrl.cs);
	mwin.wctrl.tasks~=WORK_TASK(cmd,param1,param2);
	LeaveCriticalSection(&mwin.wctrl.cs);
	SetEvent(mwin.wctrl.hevent);
	result=true;
	return result;
}
int get_work_task(ref WORK_TASK wt)
{
	alias mwin=main_win;
	int result=false;

	if(main_win is null)
		return result;
	EnterCriticalSection(&mwin.wctrl.cs);
	if(mwin.wctrl.tasks.length>0){
		wt=mwin.wctrl.tasks[0];
		mwin.wctrl.tasks=mwin.wctrl.tasks[1..mwin.wctrl.tasks.length];
		result=TRUE;
	}
	LeaveCriticalSection(&mwin.wctrl.cs);
	return result;
}
int initialize_worker_control(ref WORKER_CONTROL wc)
{
	int result=FALSE;
	if(wc.hevent==NULL)
		wc.hevent=CreateEvent(NULL,FALSE,FALSE,"WORKER_THREAD_EVENT");
	InitializeCriticalSection(&wc.cs);
	if(wc.hevent!=NULL)
		result=TRUE;
	return result;
}
int process_task(WORKER_CONTROL *wc)
{
	int result=FALSE;
	WORK_TASK wt;
	if(!get_work_task(wt))
		return result;
	switch(wt.cmd){
	case COMMAND.CMD_LOAD_SETTINGS:
		load_settings();		
		break;
	default:
		break;
	}
	return result;
}

extern (Windows)
DWORD worker_thread(LPVOID param)
{
	WORKER_CONTROL *wc;
	wc=cast(WORKER_CONTROL *)param;
	if(wc==NULL)
		return 0;
	while(TRUE){
		DWORD id;
		id=WaitForSingleObject(wc.hevent,INFINITE);
		switch(id){
			case WAIT_OBJECT_0:
				process_task(wc);
				break;
			default:
				Sleep(100);
				break;
		}
		if(wc.exit)
			break;
	}
	return 0;
}
