#include <sourcemod>
#include "readyup.inc"

public OnPluginStart()
{
	RegConsoleCmd("sm_test", Test_Cmd);
}

public Action:Test_Cmd(client, args)
{
	decl String:buffer[65];
	GetCmdArg(1, buffer, sizeof(buffer));
	PrintToChat(client, "ret: %s", AddStringToReadyFooter(buffer) ? "true" : "false");
}
