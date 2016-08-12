#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include "resource.h"

#include "file_list.h"

int populate_flist(HWND hlview,TCHAR *path)
{
	return 0;
}