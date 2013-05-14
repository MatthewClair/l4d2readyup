#include <sourcemod>
#include "readyup.inc"

public OnPluginStart()
{
	RegAdminCmd("sm_rdy_addstring", AddString_Cmd, ADMFLAG_BAN);
	RegAdminCmd("sm_rdy_isinready", IsInReady_Cmd, ADMFLAG_BAN);
	RegAdminCmd("sm_rdy_isclientcaster", IsClientCaster_Cmd, ADMFLAG_BAN);
}

public Action:AddString_Cmd(client, args)
{
	decl String:buffer[65];
	GetCmdArg(1, buffer, sizeof(buffer));
	PrintToChat(client, "native bool:AddStringToReadyFooter(%s) = %s", buffer, AddStringToReadyFooter(buffer) ? "true" : "false");
}

public Action:IsInReady_Cmd(client, args)
{
	PrintToChat(client, "native bool:IsInready() = %s", IsInReady() ? "true" : "false");
}

public Action:IsClientCaster_Cmd(client, args)
{
	decl String:buffer[65];
	GetCmdArg(1, buffer, sizeof(buffer));
	new target = FindTarget(client, buffer, false, false);
	GetClientAuthString(target, buffer, sizeof(buffer));
	PrintToChat(client, "native bool:IsClientCaster(%N) = %s", target, IsClientCaster(target) ? "true" : "false");
	PrintToChat(client, "native bool:IsBufferCaster(%s) = %s", buffer, IsIDCaster(buffer) ? "true" : "false");
}

public OnRoundIsLive()
{
	PrintToChatAll("foward OnRoundIsLive()");
}
