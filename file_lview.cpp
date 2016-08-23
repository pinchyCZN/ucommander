#if WINVER<0x500
	#define _WIN32_WINNT 0x500
#endif
#include <windows.h>
#include <Commctrl.h>
#include <stdio.h>
#include "resource.h"

#include "file_list.h"

extern "C" {
	extern HWND ghfileview1,ghfileview2;
	int populate_ftab(int side,int tab);
	int add_ftab(int side);
};

int stop_thread=0;

struct FILE_DLG fdlg_left(&ghfileview1),fdlg_right(&ghfileview1);
int check_filter(TCHAR *in,TCHAR *filter)
{
	return TRUE;
}
int populate_flist(TCHAR *path,TCHAR *filter,FILE_TAB *ftab)
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
				ftab->flist.push_back(fe);
			}
			if(0==FindNextFile(hfd,&wfd))
				break;
			if(stop_thread)
				break;
		}
	}
	return 0;
}

int add_lview_item(HWND hlview,std::string str)
{
	LV_ITEM lvitem={0};
	lvitem.mask=LVIF_TEXT;
	lvitem.pszText=(TCHAR*)str.c_str();
	ListView_SetItem(hlview,&lvitem);
	return 0;
}
int populate_ftab(int side,int tab)
{
	int result=FALSE;
	FILE_DLG *fdlg;
	FILE_TAB *ftab;
	if(0==side)
		fdlg=&fdlg_left;
	else
		fdlg=&fdlg_right;

	if(tab<0 || tab>fdlg->ftab.size() || 0==fdlg->ftab.size())
		return result;

	ftab=&fdlg->ftab[tab];
	populate_flist("C:\\*.*","*",ftab);
	printf("size=%i\n",ftab->flist.size());
	int i;
	HWND hlview=GetDlgItem(fdlg->hfview(),IDC_LVIEW);
	for(i=0;i<ftab->flist.size();i++){
		add_lview_item(hlview,ftab->flist[i].fname);
	}
	return result;
}
int add_ftab(int side)
{
	FILE_DLG *fdlg;
	FILE_TAB ftab;
	if(0==side)
		fdlg=&fdlg_left;
	else
		fdlg=&fdlg_right;
	fdlg->ftab.push_back(ftab);
	return fdlg->ftab.size()-1;
}