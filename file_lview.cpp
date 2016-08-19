#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include "resource.h"

#include "file_list.h"

extern "C" HWND ghfileview1,ghfileview2;

struct FILE_TABS ftabs_left(&ghfileview1),ftabs_right(&ghfileview1);
int check_filter(TCHAR *in,TCHAR *filter)
{
	return TRUE;
}
int populate_flist(TCHAR *path,TCHAR *filter,FILE_LIST &flist)
{
	WIN32_FIND_DATA wfd={0};
	HANDLE hfd;
	hfd=FindFirstFile(path,&wfd);
	if(hfd!=0){
		while(TRUE){
			if(check_filter(wfd.cFileName,filter)){
				FILE_ENTRY fe;
				fe.fname=wfd.cFileName;
				GetFileAttributesEx(wfd.cFileName,GetFileExInfoStandard,&fe.attributes);
				flist.files.push_back(fe);
			}
			FindNextFile(hfd,&wfd);
		}
	}
	return 0;
}

int populate_ftab(int side,int tab)
{
	int result=FALSE;
	FILE_TABS *ftabs;
	FILE_DLG fdlg;
	if(0==side)
		ftabs=&ftabs_left;
	else
		ftabs=&ftabs_right;

	if(tab<0 || tab>ftabs->fdlgs.size() || 0==ftabs->fdlgs.size())
		return result;

	fdlg=ftabs->fdlgs[tab];

	return result;
}