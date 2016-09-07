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