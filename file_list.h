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
};
struct FILE_TAB{
	std::vector<FILE_DLG> ftabs;
	int current_tab;
	FILE_TAB():
		current_tab(0)
		{};
};
