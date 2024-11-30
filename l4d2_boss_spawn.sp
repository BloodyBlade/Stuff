#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define DEBUG 0

#define PLUGIN_VERSION "1.3.1"

ConVar  cvarPluginEnable,
        cvarTotalTanks,
        cvarTotalTanksRandom,
        cvarTanks,
        cvarTanksRandom,
        cvarTanksChance,
        cvarCheckTanks,
        cvarStartTanks,
        cvarFinaleTanks,
        cvarRangeMinTank,
        cvarRangeMaxTank,
        cvarTotalWitches,
        cvarTotalWitchesRandom,
        cvarWitches,
        cvarWitchesRandom,
        cvarWitchesChance,
        cvarCheckWitches,
        cvarStartWitches,
        cvarFinaleWitches,
        cvarRangeMinWitch,
        cvarRangeMaxWitch,
        cvarRangeRandom,
        cvarInterval;

bool    g_bPluginEnable,
        g_bCheckTanks,
        g_bCheckWitches,
        g_bStartTanks,
        g_bStartWitches,
        g_bRangeRandom,
        g_bFinaleStarts,
        g_bAllowSpawnTanks,
        g_bAllowSpawnWitches,
        g_bChekingFlow;		

int     g_iFinaleTanks,
        g_iFinaleWitches,
        g_iTanks,
        g_iTanksRandom,
        g_iTanksChance,
        g_iWitches,
        g_iWitchesRandom,
        g_iWitchesChance,
        g_iTotalTanks,
        g_iTotalTanksRandom,
        g_iTotalWitches,
        g_iTotalWitchesRandom,
        g_iTankCounter,
        g_iWitchCounter,
        g_iMaxTanks,
        g_iMaxWitches,
        g_iPlayerHighestFlow;

float   g_fFlowMaxMap,
        g_fFlowPlayers,
        g_fFlowRangeMinTank,
        g_fFlowRangeMinWitch,
        g_fFlowRangeMaxWitch,
        g_fFlowRangeMaxTank,
        g_fFlowRangeSpawnTank,
        g_fFlowRangeSpawnWitch,
        g_fFlowSpawnTank,
        g_fFlowSpawnWitch,
        g_fFlowCanSpawnTank,
        g_fFlowCanSpawnWitch,
        g_fFlowPercentMinTank,
        g_fFlowPercentMaxTank,
        g_fFlowPercentMinWitch,
        g_fFlowPercentMaxWitch,
        g_fInterval;

Handle  g_hTimerCheckFlow;

public Plugin myinfo =
{
	name = "[L4D2] Boss Spawn",
	author = "xZk",
	description = "Spawn bosses (Tank or Witch) depending on the progress of the map.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=323402"
}

public void OnPluginStart()
{
	CreateConVar("boss_spawn", PLUGIN_VERSION, "[L4D2] Boss Spawn plugin version.", FCVAR_NOTIFY | FCVAR_DONTRECORD);

	cvarPluginEnable       = CreateConVar("boss_spawn", "1", "0: Disable, 1: Enable Plugin", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarInterval           = CreateConVar("boss_spawn_interval", "1.0", "Set interval time check to spawn", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTanks              = CreateConVar("boss_spawn_tanks", "1", "Set Tanks to spawn simultaneously", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarTanksRandom        = CreateConVar("boss_spawn_tanks_rng", "0", "Set max random Tanks to spawn simultaneously, 0: Disable Random value", FCVAR_NOTIFY, true, 0.0, true, 10.0);
	cvarTanksChance        = CreateConVar("boss_spawn_tanks_chance", "100", "Setting chance (0-100)% to spawn Tanks", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarWitches            = CreateConVar("boss_spawn_witches", "1", "Set Witches to spawn simultaneously", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarWitchesRandom      = CreateConVar("boss_spawn_witches_rng", "0", "Set max random Witches to spawn simultaneously, 0: Disable Random value", FCVAR_NOTIFY, true, 0.0, true, 10.0);
	cvarWitchesChance      = CreateConVar("boss_spawn_witches_chance", "100", "Setting chance (0-100)% to spawn Witches", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarTotalTanks         = CreateConVar("boss_spawn_total_tanks", "2", "Set total Tanks to spawn on map", FCVAR_NOTIFY, true, 1.0, true, 10.0);
	cvarTotalTanksRandom   = CreateConVar("boss_spawn_total_tanks_rng", "0", "Set max random value total Tanks on map, 0: Disable Random value", FCVAR_NOTIFY, true, 0.0, true, 10.0);
	cvarTotalWitches       = CreateConVar("boss_spawn_total_witches", "2", "Set total Witches to spawn on map", FCVAR_NOTIFY, true, 1.0, true, 10.0);
	cvarTotalWitchesRandom = CreateConVar("boss_spawn_total_witches_rng", "0", "Set max random value total Witches on map, 0: Disable Random value", FCVAR_NOTIFY, true, 0.0, true, 10.0);
	cvarCheckTanks         = CreateConVar("boss_spawn_check_tanks", "0", "0: Checking any Tanks spawned on map, 1: Checking only boss spawn Tanks", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarCheckWitches       = CreateConVar("boss_spawn_check_witches", "0", "0: Checking any Witches spawned on map, 1: Checking only boss spawn Witches", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarStartTanks         = CreateConVar("boss_spawn_start_tanks", "1", "0: Disable Tanks in first map, 1: Allow Tanks in first map", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarFinaleTanks        = CreateConVar("boss_spawn_finale_tanks", "0", "0: Disable tanks in finale map, 1: Allow before finale starts, 2: Allow after finale starts, 3: Allow all finale map", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarStartWitches       = CreateConVar("boss_spawn_start_witches", "1", "0: Disable Witches in first map, 1: Allow Witches in first map", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarFinaleWitches      = CreateConVar("boss_spawn_finale_witches", "0", "0: Disable witches in finale map, 1: Allow before finale starts, 2: Allow after finale starts, 3: Allow all finale map", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarRangeMinTank       = CreateConVar("boss_spawn_range_min_tank", "11.0", "Set progress (0-100)% max of the distance map to can spawn Tank", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarRangeMaxTank       = CreateConVar("boss_spawn_range_max_tank", "97.0", "Set progress (0-100)% max of the distance map to can spawn Tank", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarRangeMinWitch      = CreateConVar("boss_spawn_range_min_witch", "5.0", "Set progress (0-100)% min of the distance map to can spawn Witch", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarRangeMaxWitch      = CreateConVar("boss_spawn_range_max_witch", "99.0", "Set progress (0-100)% max of the distance map to can spawn Witch", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarRangeRandom        = CreateConVar("boss_spawn_range_random", "1", "0: Set distribute spawning points evenly between each, 1: Set random range between spawning points", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "l4d2_boss_spawn");
	
	cvarPluginEnable.AddChangeHook(ConVarChanged_Allow);
	cvarInterval.AddChangeHook(ConVarChanged_Cvars);    
	cvarTanks.AddChangeHook(ConVarChanged_Cvars);        
	cvarTanksRandom.AddChangeHook(ConVarChanged_Cvars);
	cvarTanksChance.AddChangeHook(ConVarChanged_Cvars);
	cvarWitches.AddChangeHook(ConVarChanged_Cvars);        
	cvarWitchesRandom.AddChangeHook(ConVarChanged_Cvars);
	cvarWitchesChance.AddChangeHook(ConVarChanged_Cvars);
	cvarTotalTanks.AddChangeHook(ConVarChanged_Cvars);        
	cvarTotalTanksRandom.AddChangeHook(ConVarChanged_Cvars);  
	cvarCheckTanks.AddChangeHook(ConVarChanged_Cvars);   
	cvarTotalWitches.AddChangeHook(ConVarChanged_Cvars);      
	cvarTotalWitchesRandom.AddChangeHook(ConVarChanged_Cvars);
	cvarCheckWitches.AddChangeHook(ConVarChanged_Cvars);
	cvarStartTanks.AddChangeHook(ConVarChanged_Cvars);
	cvarFinaleTanks.AddChangeHook(ConVarChanged_Cvars);
	cvarStartWitches.AddChangeHook(ConVarChanged_Cvars);
	cvarFinaleWitches.AddChangeHook(ConVarChanged_Cvars);
	cvarRangeMinTank.AddChangeHook(ConVarChanged_Cvars);  
	cvarRangeMaxTank.AddChangeHook(ConVarChanged_Cvars);  
	cvarRangeMinWitch.AddChangeHook(ConVarChanged_Cvars); 
	cvarRangeMaxWitch.AddChangeHook(ConVarChanged_Cvars);
	cvarRangeRandom.AddChangeHook(ConVarChanged_Cvars);
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bRangeRandom = cvarRangeRandom.BoolValue;
	g_bCheckTanks = cvarCheckTanks.BoolValue;
	g_bCheckWitches = cvarCheckWitches.BoolValue;
	g_bStartTanks = cvarStartTanks.BoolValue;
	g_bStartWitches = cvarStartWitches.BoolValue;
	g_iTanks = cvarTanks.IntValue;
	g_iTanksRandom = cvarTanksRandom.IntValue;
	g_iTanksChance = cvarTanksChance.IntValue;
	g_iWitches = cvarWitches.IntValue;
	g_iWitchesRandom = cvarWitchesRandom.IntValue;
	g_iWitchesChance = cvarWitchesChance.IntValue;
	g_iTotalTanks = cvarTotalTanks.IntValue;
	g_iTotalTanksRandom = cvarTotalTanksRandom.IntValue;
	g_iTotalWitches = cvarTotalWitches.IntValue;
	g_iTotalWitchesRandom = cvarTotalWitchesRandom.IntValue;
	g_iFinaleTanks = cvarFinaleTanks.IntValue;
	g_iFinaleWitches = cvarFinaleWitches.IntValue;
	g_fFlowPercentMinTank = cvarRangeMinTank.FloatValue;
	g_fFlowPercentMaxTank = cvarRangeMaxTank.FloatValue;
	g_fFlowPercentMinWitch = cvarRangeMinWitch.FloatValue;
	g_fFlowPercentMaxWitch = cvarRangeMaxWitch.FloatValue;
	g_fInterval = cvarInterval.FloatValue;
}

void IsAllowed()
{
	bool bCvarAllow = cvarPluginEnable.BoolValue;
	GetCvars();
	if (g_bPluginEnable == false && bCvarAllow == true)
	{
		g_bPluginEnable = true;
		HookEvent("round_start", Event_RoundStart);
		HookEvent("round_end", Event_RoundEnd);
		HookEvent("player_left_checkpoint", Event_PlayerLeftCheckpoint);
		HookEvent("player_left_start_area", Event_PlayerLeftCheckpoint);
		//HookEvent("finale_start", Event_FinaleStart);//doesn't work all finales
		HookEvent("tank_spawn", Event_TankSpawn);
		HookEvent("witch_spawn", Event_WitchSpawn);
		HookEntityOutput("trigger_finale", "FinaleStart", EntityOutput_FinaleStart);
	}
	else if (g_bPluginEnable == true && bCvarAllow == false)
	{
		g_bPluginEnable = false;
		UnhookEvent("round_start", Event_RoundStart);
		UnhookEvent("round_end", Event_RoundEnd);
		UnhookEvent("player_left_checkpoint", Event_PlayerLeftCheckpoint);
		UnhookEvent("player_left_start_area", Event_PlayerLeftCheckpoint);
		//UnhookEvent("finale_start", Event_FinaleStart);
		UnhookEvent("tank_spawn", Event_TankSpawn);
		UnhookEvent("witch_spawn", Event_WitchSpawn);
		UnhookEntityOutput("trigger_finale", "FinaleStart", EntityOutput_FinaleStart);
		delete g_hTimerCheckFlow;
	}
}

public void OnMapEnd()
{
	delete g_hTimerCheckFlow;
	g_iTankCounter = 0;
	g_iWitchCounter = 0;
	g_fFlowSpawnTank = 0.0;
	g_fFlowSpawnWitch = 0.0;
	g_bFinaleStarts = false;
	g_bChekingFlow = false;
}

void EntityOutput_FinaleStart(const char[] output, int caller, int activator, float time)
{
	g_bFinaleStarts = true;
	g_bAllowSpawnTanks = (g_iFinaleTanks == 3 || g_bFinaleStarts && g_iFinaleTanks == 2);
	g_bAllowSpawnWitches = (g_iFinaleWitches == 3 || g_bFinaleStarts && g_iFinaleWitches == 2); 
}

void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bCheckTanks)
		g_iTankCounter++;
	#if DEBUG
	PrintToChatAll("[DEBUG] TankCounter: %d", g_iTankCounter);
	#endif
}

void Event_WitchSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bCheckWitches)
		g_iWitchCounter++;
	#if DEBUG
	PrintToChatAll("[DEBUG] WitchCounter: %d", g_iWitchCounter);
	#endif
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	delete g_hTimerCheckFlow;
	g_iTankCounter = 0;
	g_iWitchCounter = 0;
	g_fFlowSpawnTank = 0.0;
	g_fFlowSpawnWitch = 0.0;
	g_bFinaleStarts = false;
	g_bChekingFlow = false;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	delete g_hTimerCheckFlow;
	g_iTankCounter = 0;
	g_iWitchCounter = 0;
	g_fFlowSpawnTank = 0.0;
	g_fFlowSpawnWitch = 0.0;
	g_bFinaleStarts = false;
	g_bChekingFlow = false;
}

void Event_PlayerLeftCheckpoint(Event event, const char[] name, bool dontBroadcast)
{
	// Exit early if the flow-checking process is already active
	if (g_bChekingFlow) 
		return;
	// Check if spawning is disallowed on the first or final map
	bool isFirstMapNoSpawns = L4D_IsFirstMapInScenario() && !g_bStartTanks && !g_bStartWitches;
	bool isFinalMapNoSpawns = L4D_IsMissionFinalMap() && !g_iFinaleTanks && !g_iFinaleWitches;
	// If no spawning is allowed for the current map conditions, delete the timer and exit
	if (isFirstMapNoSpawns || isFinalMapNoSpawns) 
	{
		delete g_hTimerCheckFlow;
		return;
	}
	// Get the client ID based on the event's user ID
	int client = GetClientOfUserId(event.GetInt("userid"));
	// Ensure the client is a valid survivor before proceeding
	if (!IsValidSurvivor(client)) 
		return;
	// Determine whether tanks can spawn based on map conditions and settings
	bool isFirstMap = L4D_IsFirstMapInScenario();
	bool isFinalMap = L4D_IsMissionFinalMap();
	g_bAllowSpawnTanks = (g_bStartTanks && isFirstMap || !isFirstMap) && 
						 (g_iFinaleTanks == 3 || !isFinalMap || (!g_bFinaleStarts && g_iFinaleTanks == 1));
	// Determine whether witches can spawn based on map conditions and settings
	g_bAllowSpawnWitches = (g_bStartWitches && isFirstMap || !isFirstMap) && 
						   (g_iFinaleWitches == 3 || !isFinalMap || (!g_bFinaleStarts && g_iFinaleWitches == 1));
	// Start the flow-checking process by creating a timer
	CreateTimer(0.1, StartCheckFlow, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action StartCheckFlow(Handle timer)
{
	// Exit early if the flow-checking process is already active or no survivor has left the safe area
	if (g_bChekingFlow || !L4D_HasAnySurvivorLeftSafeArea()) 
		return Plugin_Continue;
	// Mark the flow-checking process as active
	g_bChekingFlow = true;
	g_bFinaleStarts = false;
	// Reset counters for tanks and witches
	g_iTankCounter = 0;
	g_iWitchCounter = 0;
	// Reset flow distances for tank and witch spawning
	g_fFlowSpawnTank = 0.0;
	g_fFlowSpawnWitch = 0.0;
	// Get the maximum flow distance for the current map
	g_fFlowMaxMap = L4D2Direct_GetMapMaxFlowDistance();
	// Determine the maximum number of tanks and witches based on settings and randomization
	g_iMaxTanks = g_iTotalTanksRandom ? GetRandomInt(g_iTotalTanks, g_iTotalTanksRandom) : g_iTotalTanks;
	g_iMaxWitches = g_iTotalWitchesRandom ? GetRandomInt(g_iTotalWitches, g_iTotalWitchesRandom) : g_iTotalWitches;
	// Calculate flow ranges for tank spawning
	g_fFlowRangeMinTank = g_fFlowMaxMap * (g_fFlowPercentMinTank / 100.0);
	g_fFlowRangeMaxTank = g_fFlowMaxMap * (g_fFlowPercentMaxTank / 100.0);
	g_fFlowRangeSpawnTank = (g_fFlowRangeMaxTank - g_fFlowRangeMinTank) / float(g_iMaxTanks);
	g_fFlowCanSpawnTank = g_fFlowRangeMinTank;
	// Calculate flow ranges for witch spawning
	g_fFlowRangeMinWitch = g_fFlowMaxMap * (g_fFlowPercentMinWitch / 100.0);
	g_fFlowRangeMaxWitch = g_fFlowMaxMap * (g_fFlowPercentMaxWitch / 100.0);
	g_fFlowRangeSpawnWitch = (g_fFlowRangeMaxWitch - g_fFlowRangeMinWitch) / float(g_iMaxWitches);
	g_fFlowCanSpawnWitch = g_fFlowRangeMinWitch;
	// Delete the previous timer if it exists and create a new repeating timer for flow-checking
	delete g_hTimerCheckFlow;
	g_hTimerCheckFlow = CreateTimer(g_fInterval, TimerCheckFlow, _, TIMER_REPEAT);
	return Plugin_Stop;
}

// Timer function to check flow and handle spawning logic
Action TimerCheckFlow(Handle timer)
{
	#if DEBUG
	PrintToChatAll("[DEBUG] TimerCheckFlow called.");
	#endif
	// Stop the timer if the maximum number of Tanks and Witches has been reached
	if (g_iTankCounter >= g_iMaxTanks && g_iWitchCounter >= g_iMaxWitches)
	{
		#if DEBUG
		PrintToChatAll("[DEBUG] Maximum Tanks and Witches reached. Stopping timer.");
		#endif
		g_hTimerCheckFlow = null;
		return Plugin_Stop;
	}
	// Update the highest flow survivor and calculate player flow
	g_iPlayerHighestFlow = L4D_GetHighestFlowSurvivor();
	g_fFlowPlayers = IsValidSurvivor(g_iPlayerHighestFlow) 
		? L4D2Direct_GetFlowDistance(g_iPlayerHighestFlow) 
		: L4D2_GetFurthestSurvivorFlow();
	// Handle spawning of Tanks
	if (g_bAllowSpawnTanks && g_iTankCounter < g_iMaxTanks 
		&& g_fFlowPlayers >= g_fFlowRangeMinTank && g_fFlowPlayers <= g_fFlowRangeMaxTank)
	{
		// Calculate the flow threshold for spawning Tanks if not already set
		if (!g_fFlowSpawnTank)
		{
			g_fFlowSpawnTank = g_bRangeRandom
				? GetRandomFloat(g_fFlowCanSpawnTank, g_fFlowCanSpawnTank + g_fFlowRangeSpawnTank)
				: g_fFlowCanSpawnTank + (g_iTankCounter ? g_fFlowRangeSpawnTank : float(0));
		}
		// Spawn Tanks if player flow meets the threshold
		if (g_fFlowPlayers >= g_fFlowSpawnTank)
		{
			int tanks = g_iTanksRandom ? GetRandomInt(g_iTanks, g_iTanksRandom) : g_iTanks;
			for (int i = 0; i < tanks; i++)
			{
				float spawnpos[3];
				if (GetSpawnPosition(8, 30, spawnpos, "tank") && g_iTanksChance >= GetRandomInt(1, 100))
				{
					if (SpawnEntity(spawnpos, "tank") > 0)
					{
						g_fFlowCanSpawnTank += g_fFlowRangeSpawnTank; // Update the flow range for the next spawn
						g_fFlowSpawnTank = 0.0;
						if (g_bCheckTanks)
							g_iTankCounter++; // Increment the Tank counter
						#if DEBUG
						PrintToChatAll("[DEBUG] Tank counter incremented to %d.", g_iTankCounter);
						#endif
					}
				}
			}
		}
	}
	// Handle spawning of Witches
	if (g_bAllowSpawnWitches && g_iWitchCounter < g_iMaxWitches 
		&& g_fFlowPlayers >= g_fFlowRangeMinWitch && g_fFlowPlayers <= g_fFlowRangeMaxWitch)
	{
		// Calculate the flow threshold for spawning Witches if not already set
		if (!g_fFlowSpawnWitch)
			g_fFlowSpawnWitch = GetRandomFloat(g_fFlowCanSpawnWitch, g_fFlowCanSpawnWitch + g_fFlowRangeSpawnWitch);
		// Spawn Witches if player flow meets the threshold
		if (g_fFlowPlayers >= g_fFlowSpawnWitch)
		{
			int witches = g_iWitchesRandom ? GetRandomInt(g_iWitches, g_iWitchesRandom) : g_iWitches;
			for (int i = 0; i < witches; i++)
			{
				float spawnpos[3];
				if (GetSpawnPosition(7, 30, spawnpos, "witch") && g_iWitchesChance >= GetRandomInt(1, 100))
				{
					if (SpawnEntity(spawnpos, "witch") > 0)
					{
						g_fFlowCanSpawnWitch += g_fFlowRangeSpawnWitch; // Update the flow range for the next spawn
						g_fFlowSpawnWitch = 0.0;
						if (g_bCheckWitches)
							g_iWitchCounter++; // Increment the Witch counter
						#if DEBUG
						PrintToChatAll("[DEBUG] Witch counter incremented to %d.", g_iWitchCounter);
						#endif
					}
				}
			}
		}
	}
	// Continue the timer to check again
	return Plugin_Continue;
}

// Function to get a valid spawn position within a specified range
bool GetSpawnPosition(int zombieClass, int attempts, float spawnpos[3], const char[] entityType)
{
	// Try to find a spawn position near the survivor with the highest flow
	if (IsValidClient(g_iPlayerHighestFlow))
	{
		if (L4D_GetRandomPZSpawnPosition(g_iPlayerHighestFlow, zombieClass, attempts, spawnpos))
			return true;
	}
	// If no position was found, iterate through all survivors
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidSurvivor(i) && L4D_GetRandomPZSpawnPosition(i, zombieClass, attempts, spawnpos))
			return true;
	}
	// Log a warning if no valid spawn position was found
	LogMessage("No valid spawn position found for %s.", entityType);
	return false;
}

// Function to spawn an entity (Tank or Witch) at the given position
int SpawnEntity(float spawnpos[3], const char[] entityType)
{
	if (StrEqual(entityType, "tank"))
		return L4D2_SpawnTank(spawnpos, NULL_VECTOR); // Spawn a tank
	else if (StrEqual(entityType, "witch"))
		return L4D2_SpawnWitch(spawnpos, NULL_VECTOR); // Spawn a witch
	// Log an error if an invalid entity type was passed
	#if DEBUG
	LogMessage("Invalid entity type: %s", entityType);
	#endif
	return 0; // Return 0 if the entity type is invalid
}

stock bool IsValidSpect(int client)
{ 
	return IsValidClient(client) && GetClientTeam(client) == 1;
}

stock bool IsValidSurvivor(int client)
{
	return IsValidClient(client) && GetClientTeam(client) == 2;
}

stock bool IsValidInfected(int client)
{
	return IsValidClient(client) && GetClientTeam(client) == 3;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

stock bool IsValidEnt(int entity)
{
	return entity > MaxClients && IsValidEntity(entity) && entity != INVALID_ENT_REFERENCE;
}