module file_list;

import std.string;
import core.sys.windows.windows;

class FileEntry{
	string fname,ext;
	WIN32_FILE_ATTRIBUTE_DATA attributes;
}