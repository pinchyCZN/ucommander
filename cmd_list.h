#define MAX_CMDS 5
struct CMD_LIST{
	int cmd;
	int sub_cmd;
};
struct WORKER_PARAMS{
	HANDLE hevent;
	int index;
	struct CMD_LIST cmd_list[MAX_CMDS];
};
enum ENUM_CMD{
	CMD_INIT=1,
	CMD_NEWTAB,
	CMD_CLOSETAB,
	CMD_NEXTTAB,
	CMD_PREVTAB,

};
enum ENUM_TARGET{
	TARGET_LEFT=0,
	TARGET_RIGHT,
};