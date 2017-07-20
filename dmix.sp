/*

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks.inc>

public Plugin:myinfo = {
	name = "Mix/Dmix Plugin",
	author = "Capu",
	description = "Automatically choose medics for mixes/dmixes",
	version = "0.1",
	url = "http://www.sourcemod.net/"
};

public OnPluginStart() {
	RegAdminCmd("sm_dmix", ChooseMedics, ADMFLAG_KICK, "Chooses medics for a dmix.");
	RegAdminCmd("sm_mix", ChooseMedic, ADMFLAG_KICK, "Chooses medic for a mix.");
}

public Handle GetAllPlayers() {
	new Handle:players = CreateArray(32, 0);

	for (new id = 1; id <= GetMaxClients(); id++) {
		if (IsClientInGame(id) && !IsClientSourceTV(id)) {
			PushArrayCell(players, id);
		}
	}

	return players;
}

public MoveToMedic(clientId) {
	TF2_SetPlayerClass(clientId, TFClass_Medic, true, true);
	TF2_RespawnPlayer(clientId);
	
	new String:clientname[32];
	GetClientName(clientId, clientname, 32);
	PrintToChatAll("%s, get rekt", clientname);	
}


public Action:ChooseMedic(client, args) {
	new Handle:players = GetAllPlayers();
	new Handle:team = CreateArray(32, 0);

	//Only players from the team that executed the command
	for (new i = 0; i < GetArraySize(players); i++) {
		if (GetClientTeam(GetArrayCell(players, i)) == GetClientTeam(client)) {
			PushArrayCell(team, GetArrayCell(players, i));
		}
	}

	new medicId = GetArrayCell(players, GetRandomInt(0, GetArraySize(players) - 1));

	MoveToMedic(medicId);
}

public Action:ChooseMedics(client, args) {
	new Handle:players = GetAllPlayers();
	new Handle:medics = CreateArray(32, 0);

	if (GetArraySize(players) < 2) {
		return;
	}

	//Choose two players at random, remove them from the players array and add them to medics
	for (new i = 0; i < 2; i++) {
		new medic = GetRandomInt(0, GetArraySize(players) - 1);
		new clientId = GetArrayCell(players, medic);

		PushArrayCell(medics, clientId);
		RemoveFromArray(players, medic);
	}

	//Move everyone who isn't a medic to spectator
	for (new i = 0; i < GetArraySize(players); i++) {
		ChangeClientTeam(GetArrayCell(players, i), 1);
	}

	for (new i = 0; i < GetArraySize(medics); i++) {
		new clientId = GetArrayCell(medics, i);
		MoveToMedic(clientId);

		//Move one medic to BLU and the other one to RED
		ChangeClientTeam(clientId, i == 0 ? 2 : 3);
	}
}