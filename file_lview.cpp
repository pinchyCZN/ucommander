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
int get_first_line_len(const char *str)
{
	int i,len;
	len=0x10000;
	for(i=0;i<len;i++){
		if(str[i]=='\n' || str[i]=='\r' || str[i]==0)
			break;
	}
	return i;
}
int get_string_width_wc(HWND hwnd,const char *str,int wide_char)
{
	if(hwnd!=0 && str!=0){
		SIZE size={0};
		HDC hdc;
		hdc=GetDC(hwnd);
		if(hdc!=0){
			HFONT hfont;
			int len=get_first_line_len(str);
			hfont=(HFONT)SendMessage(hwnd,WM_GETFONT,0,0);
			if(hfont!=0){
				HGDIOBJ hold=0;
				hold=SelectObject(hdc,hfont);
				if(wide_char)
					GetTextExtentPoint32W(hdc,(WCHAR*)str,wcslen((WCHAR*)str),&size);
				else
					GetTextExtentPoint32(hdc,str,len,&size);
				if(hold!=0)
					SelectObject(hdc,hold);
			}
			else{
				if(wide_char)
					GetTextExtentPoint32W(hdc,(WCHAR*)str,wcslen((WCHAR*)str),&size);
				else
					GetTextExtentPoint32(hdc,str,len,&size);
			}
			ReleaseDC(hwnd,hdc);
			return size.cx;
		}
	}
	return 0;

}
int get_str_width(HWND hwnd,const char *str)
{
	return get_string_width_wc(hwnd,str,FALSE);
}
int lv_add_column(HWND hlistview,std::string &str,int index)
{
	LV_COLUMN col;
	if(hlistview!=0){
		HWND header;
		int width=0;
		header=(HWND)SendMessage(hlistview,LVM_GETHEADER,0,0);
		width=get_str_width(header,str.c_str());
		width+=14;
		if(width<40)
			width=40;
		col.mask = LVCF_WIDTH|LVCF_TEXT;
		col.cx = width;
		col.pszText = (TCHAR*)str.c_str();
		if(ListView_InsertColumn(hlistview,index,&col)>=0)
			return width;
	}
	return 0;
}
int lv_insert_data(HWND hlistview,int row,int col,std::string &str)
{
	if(hlistview!=0){
		LV_ITEM item;
		memset(&item,0,sizeof(item));
		if(col==0){
			item.mask=LVIF_TEXT|LVIF_PARAM;
			item.iItem=row;
			item.pszText=(TCHAR*)str.c_str();
			item.lParam=row;
			ListView_InsertItem(hlistview,&item);
		}
		else{
			item.mask=LVIF_TEXT;
			item.iItem=row;
			item.pszText=(TCHAR*)str.c_str();
			item.iSubItem=col;
			ListView_SetItem(hlistview,&item);
		}
		return TRUE;
	}
	return FALSE;
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
	lv_add_column(hlview,std::string("123"),0);
	for(i=0;i<ftab->flist.size();i++){
		lv_insert_data(hlview,i,0,ftab->flist[i].fname);
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