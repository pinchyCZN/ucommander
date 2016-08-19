#include <list>
#include <algorithm>
#include <vector>
#include <string>

struct FILE_ENTRY{
	std::string fname;
	WIN32_FILE_ATTRIBUTE_DATA attributes;
};
struct FILE_LIST{
	std::vector<FILE_ENTRY> files;
};
struct FILE_DLG{
	std::vector<FILE_LIST> fdlg;
	std::string filter;
	int tab_index;
};
struct FILE_TABS{
	std::vector<FILE_DLG> fdlgs;
	int current_tab;
	HWND *_hfview;
	HWND hfview(){
		if(_hfview!=0)
			return *_hfview;
		else
			return NULL;
	}
	FILE_TABS(HWND *hwnd):
		current_tab(0),
		_hfview(hwnd)
		{};
};
