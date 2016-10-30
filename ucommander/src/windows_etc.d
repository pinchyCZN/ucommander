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
		RECT prect;
		GetClientRect(htmp,&rect);
		GetClientRect(hparent,&prect);
		//GetWindowRect(htmp,&rect);
		//MapWindowPoints(hparent,htmp,cast(POINT*)&rect,2);
		DestroyWindow(htmp);
		hpanel=CreateDialogParam(hinstance,MAKEINTRESOURCE(idd),hparent,dlg_proc,0);
		if(hpanel!=NULL){
			int x,y,w,h;
			SetWindowLong(hpanel,GWL_ID,idc);
			x=rect.left;
			y=rect.top;
			w=rect.right-rect.left;
			h=rect.bottom-rect.top;
			x-=prect.left;
			y-=prect.top;
			SetWindowPos(hpanel,NULL,x,y,w,h,SWP_NOZORDER);
			result=TRUE;
		}
	}
	return result;
}