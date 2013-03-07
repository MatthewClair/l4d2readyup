#include <sourcemod>

#define EXTRA_KEY_DELAY 1.0

public Plugin:myinfo =
{
	name = "Pause plugin",
	author = "CanadaRox",
	description = "Adds pause functionality without breaking pauses",
	version = "1",
	url = ""
};

enum L4D2Team
{
	L4D2Team_None = 0,
	L4D2Team_Spectator,
	L4D2Team_Survivor,
	L4D2Team_Infected
}

new String:teamString[L4D2Team][] =
{
	"None",
	"Spectator",
	"Survivor",
	"Infected"
}


new Handle:menuPanel;
new Handle:readyCountdownTimer;
new Handle:sv_pausable;
new bool:adminPause;
new bool:isPaused;
new bool:teamReady[L4D2Team];
new bool:was_pressing_IN_USE[MAXPLAYERS + 1];
new readyDelay;

public OnPluginStart()
{
	RegConsoleCmd("sm_pause", Pause_Cmd);
	RegConsoleCmd("sm_unpause", Unpause_Cmd);
	RegConsoleCmd("sm_ready", Unpause_Cmd);
	RegConsoleCmd("sm_unready", Unready_Cmd);

	RegAdminCmd("sm_forcepause", ForcePause_Cmd, ADMFLAG_BAN);
	RegAdminCmd("sm_forceunpause", ForceUnpause_Cmd, ADMFLAG_BAN);

	AddCommandListener(Say_Callback, "say");
	AddCommandListener(TeamSay_Callback, "say_team");

	sv_pausable = FindConVar("sv_pausable");
}

public OnClientPutInServer(client)
{
	if (isPaused)
	{
		PrintToChatAll("\x01[SM] \x03%N \x01is now fully loaded in game", client);
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!isPaused)
	{
		was_pressing_IN_USE[client] = !!(buttons & IN_USE);
	}
	else if (isPaused && was_pressing_IN_USE[client])
	{
		buttons |= IN_USE;
	}
}

public Action:Pause_Cmd(client, args)
{
	if (!isPaused && IsPlayer(client))
	{
		Pause();
	}
	return Plugin_Handled;
}

public Action:Unpause_Cmd(client, args)
{
	if (isPaused && IsPlayer(client))
	{
		teamReady[L4D2Team:GetClientTeam(client)] = true;
		if (CheckFullReady())
			InitiateLiveCountdown();

		UpdatePanel();
	}
	return Plugin_Handled;
}

public Action:Unready_Cmd(client, args)
{
	if (isPaused && IsPlayer(client) && !adminPause)
	{
		teamReady[L4D2Team:GetClientTeam(client)] = false;
		CancelFullReady();

		UpdatePanel();
	}
	return Plugin_Handled;
}

public Action:ForcePause_Cmd(client, args)
{
	if (isPaused)
	{
		adminPause = true;
		Pause();
	}
}

public Action:ForceUnpause_Cmd(client, args)
{
	if (isPaused)
	{
		InitiateLiveCountdown();
	}
}


Pause()
{
	for (new L4D2Team:team; team < L4D2Team; team++)
	{
		teamReady[team] = false;
	}

	isPaused = true;
	readyCountdownTimer = INVALID_HANDLE;

	UpdatePanel();
	CreateTimer(1.0, MenuRefresh_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);


	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SetConVarBool(sv_pausable, true);
			FakeClientCommand(client, "pause");
			SetConVarBool(sv_pausable, false);
			break;
		}
	}
}

Unpause()
{
	isPaused = false;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SetConVarBool(sv_pausable, true);
			FakeClientCommand(client, "unpause");
			SetConVarBool(sv_pausable, false);
			break;
		}
	}
}

public Action:MenuRefresh_Timer(Handle:timer)
{
	if (isPaused)
	{
		UpdatePanel();
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

UpdatePanel()
{
	if (menuPanel != INVALID_HANDLE)
	{
		CloseHandle(menuPanel);
		menuPanel = INVALID_HANDLE;
	}

	menuPanel = CreatePanel();

	DrawPanelText(menuPanel, "Team Status");
	DrawPanelText(menuPanel, teamReady[L4D2Team_Survivor] ? "->1. Survivors: Ready" : "->1. Survivors: Not ready");
	DrawPanelText(menuPanel, teamReady[L4D2Team_Infected] ? "->2. Infected: Ready" : "->2. Infected: Not ready");

	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			SendPanelToClient(menuPanel, client, DummyHandler, 1);
		}
	}
}

InitiateLiveCountdown()
{
	if (readyCountdownTimer == INVALID_HANDLE)
	{
		PrintToChatAll("Going live!\nSay !unready to cancel");
		readyDelay = 5;
		readyCountdownTimer = CreateTimer(1.0, ReadyCountdownDelay_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:ReadyCountdownDelay_Timer(Handle:timer)
{
	if (readyDelay == 0)
	{
		PrintToChatAll("Round is live!");
		Unpause();
		return Plugin_Stop;
	}
	else
	{
		PrintToChatAll("Live in: %d", readyDelay);
		readyDelay--;
	}
	return Plugin_Continue;
}

CancelFullReady()
{
	if (readyCountdownTimer != INVALID_HANDLE)
	{
		CloseHandle(readyCountdownTimer);
		readyCountdownTimer = INVALID_HANDLE;
		PrintToChatAll("Countdown Cancelled!");
	}
}

public Action:Say_Callback(client, const String:command[], argc)
{
	if (isPaused)
	{
		decl String:buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		StripQuotes(buffer);
		PrintToChatAll("\x04%N: \x01%s", client, buffer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:TeamSay_Callback(client, const String:command[], argc)
{
	if (isPaused)
	{
		decl String:buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		StripQuotes(buffer);
		Format(buffer, sizeof(buffer), "\x04(%s) %N: \x01%s", teamString[L4D2Team:GetClientTeam(client)], client, buffer);
		PrintToTeam(L4D2Team:GetClientTeam(client), buffer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

bool:CheckFullReady()
{
	return teamReady[L4D2Team_Survivor] && teamReady[L4D2Team_Infected];
}

stock IsPlayer(client)
{
	new L4D2Team:team = L4D2Team:GetClientTeam(client);
	return (client && (team == L4D2Team_Survivor || team == L4D2Team_Infected));
}

stock PrintToTeam(L4D2Team:team, const String:buffer[])
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && L4D2Team:GetClientTeam(client) == team)
		{
			PrintToChat(client, "%s", buffer);
		}
	}
}

public DummyHandler(Handle:menu, MenuAction:action, param1, param2) { }
