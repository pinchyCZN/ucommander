module misc_tasks;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import std.format;
import winmain;
import file_pane;

int load_settings()
{
	int result=FALSE;
	FilePane fp;
	if(main_win is null || main_win.hwnd==NULL)
		return result;
	fp=main_win.fpanes[0];
	int i;
	for(i=0;i<5;i++){
		wstring s;
		s=format("pane%u"w,i);
		fp.add_tab(4,s);
	}
	return result;
}
