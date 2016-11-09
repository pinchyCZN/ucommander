module worker_thread_module;

import core.runtime;
import core.sys.windows.windows;
import core.sys.windows.commctrl;
import std.string;
import winmain;

enum COMMAND{
	CMD_RENAME_FILE
};
struct WORK_TASK{
	COMMAND cmd;
	string param1,param2;
}
struct WORKER_CONTROL{
	HANDLE hevent;
	int cancel;
	int exit;
	CRITICAL_SECTION cs;
	WORK_TASK[] tasks;
}
int add_work_task(ref WORKER_CONTROL wc,COMMAND cmd,string param1,string param2)
{
	EnterCriticalSection(&wc.cs);
	wc.tasks~=WORK_TASK(cmd,param1,param2);
	LeaveCriticalSection(&wc.cs);
	return 0;
}
int get_work_task(WORKER_CONTROL *wc,ref WORK_TASK wt)
{
	int result=FALSE;
	EnterCriticalSection(&wc.cs);
	if(wc.tasks.length>0){
		wt=wc.tasks[0];
		wc.tasks=wc.tasks[1..wc.tasks.length];
		result=TRUE;
	}
	LeaveCriticalSection(&wc.cs);
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
	if(!get_work_task(wc,wt))
		return result;
	switch(wt.cmd){
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
