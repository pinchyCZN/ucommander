module winmain;

import core.runtime;
import core.sys.windows.windows;
import std.string;

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result;

    try
    {
        Runtime.initialize();

        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);

        Runtime.terminate();
    }
    catch (Throwable o) // catch any uncaught exceptions
    {

        MessageBoxA(null, cast(char *)o.toString(), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }

    return result;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	array string[] s;
	s[0]="132132";
	MessageBoxA(null,s[1].toStringz,"qwewqewqe",MB_OK);
    return 0;
}
