/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <sourcemod>
#include <readyup>

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
