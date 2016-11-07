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
extern (Windows)
DWORD worker_thread(LPVOID param)
{
	return 0;
}
