import core.sys.windows.windows;


@nogc
{
	HWND CreateDialogParamA(
							HINSTANCE hInstance,
							LPCSTR lpTemplateName,
							HWND hWndParent ,
							DLGPROC lpDialogFunc,
							LPARAM dwInitParam);
}
@nogc
{
	HWND
	CreateDialogParamW(
					   HINSTANCE hInstance,
					   LPCWSTR lpTemplateName,
					   HWND hWndParent ,
					   DLGPROC lpDialogFunc,
					   LPARAM dwInitParam);
}

int replace_with_panel(HINSTANCE hinstance,
					   int idd,
					   int idc,
					   HWND hparent,
					   ref HWND hpanel,
					   DLGPROC dlg_proc)
{
	int result=FALSE;
	HWND htmp;
	htmp=GetDlgItem(hparent,idc);
	if(htmp!=NULL){
		RECT rect;
		GetClientRect(htmp,&rect);
		MapWindowPoints(htmp,hparent,cast(POINT*)&rect,2);
		DestroyWindow(htmp);
		hpanel=CreateDialogParam(hinstance,MAKEINTRESOURCE(idd),hparent,dlg_proc,0);
		if(hpanel!=NULL){
			int x,y,w,h;
			SetWindowLong(hpanel,GWL_ID,idc);
			x=rect.left;
			y=rect.top;
			w=rect.right-rect.left;
			h=rect.bottom-rect.top;
			SetWindowPos(hpanel,NULL,x,y,w,h,SWP_NOZORDER);
			result=TRUE;
		}
	}
	return result;
}

void print_rect(HWND hwnd,string prefix)
{
	import std.stdio;
	RECT wrect,mrect,rect;
	string tab="";
	GetClientRect(hwnd,&rect);
	GetWindowRect(hwnd,&wrect);

	if(prefix.length>0){
		writeln(prefix);
	}
	writef("\tx=%.4s winx=%.4s\n",rect.left,wrect.left);
	writef("\ty=%.4s winy=%.4s\n",rect.top,wrect.top);
	writef("\tw=%.4s winw=%.4s\n",rect.right-rect.left,wrect.right-wrect.left);
	writef("\th=%.4s winh=%.4s\n",rect.bottom-rect.top,wrect.bottom-wrect.top);
}