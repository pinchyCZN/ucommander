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
class FILE_DLG{
public:
		std::vector<FILE_LIST> flist;
};

