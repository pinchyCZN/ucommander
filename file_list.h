#include <list>
#include <algorithm>
#include <vector>
#include <string>

struct FILE_ENTRY{
	std::string fname;
	WIN32_FILE_ATTRIBUTE_DATA attributes;
};
struct FILE_TAB{
	std::vector<FILE_ENTRY> flist;
	std::string path;
	std::string tab_name;
	std::string filter;
	int tab_index;
	int is_search_result;
};
struct FILE_DLG{
	std::vector<FILE_TAB> ftab;
	int current_tab;
	HWND *_hfview;
	HWND hfview(){
		if(_hfview!=0)
			return *_hfview;
		else
			return NULL;
	}
	FILE_DLG(HWND *hwnd):
		current_tab(0),
		_hfview(hwnd)
		{};
	FILE_DLG():
		current_tab(0),
		_hfview(0)
		{};

};
