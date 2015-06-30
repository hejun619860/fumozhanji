
if Event == nil then
	Event = class({})
end

function Event:Init()
	--监听游戏进度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(Event,"OnGameRulesStateChange"), self)

	--监听单位重生或者出生
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(Event, "OnNPCSpawned"), self)

	--实体被击杀
	ListenToGameEvent("entity_killed", Dynamic_Wrap(Event, "OnNPCKilled"), self)
	
	--玩家英雄等级提升
	ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(Event, "OnHeroLevelUp"), self)

	--UI事件
	--购买技能
	CustomGameEventManager:RegisterListener( "pay_abilities", OnPayAbilities )
	CustomGameEventManager:RegisterListener( "pay_abilities_open", OnPayAbilitiesOpen )
	CustomGameEventManager:RegisterListener( "pay_abilities_close", OnPayAbilitiesClose )
	--升级和删除技能
	CustomGameEventManager:RegisterListener( "change_abilities_remove", OnChangeAbilitiesRemove )
	CustomGameEventManager:RegisterListener( "change_abilities_open", OnChangeAbilitiesOpen )
	CustomGameEventManager:RegisterListener( "change_abilities_close", OnChangeAbilitiesClose )
	CustomGameEventManager:RegisterListener( "change_abilities_info", OnChangeAbilitiesInfo )
	CustomGameEventManager:RegisterListener( "change_abilities_lvlup", OnChangeAbilitiesLvlup )
	--选择难度
	CustomGameEventManager:RegisterListener( "difficulty_select", OnDifficultySelect )
	--复活英雄
	CustomGameEventManager:RegisterListener( "player_hero_respawn", OnPlayerHeroRespawn )
end

---------------------------------------------------------------------------------------------
function Event:OnGameRulesStateChange()
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		CustomUI:DynamicHud_Create(-1,"ButtonPayAbilities","file://{resources}/layout/custom_game/buttons.xml",nil)
		CustomUI:DynamicHud_Create(-1,"Message","file://{resources}/layout/custom_game/Message.xml",nil)

		CreateUnitByName("npc_box_1",Vector(0,0,0),true,nil,nil,DOTA_TEAM_BADGUYS)
		for i=1,4 do
			local unit = CreateUnitByName("npc_dota_neutral_centaur_khan",Vector(0,0,0),true,nil,nil,DOTA_TEAM_BADGUYS)
			unit:SetControllableByPlayer(0,true)
			unit:Hold()
		end
	elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		for i=0,9 do
			local player = PlayerResource:GetPlayer(i)

			if player then
				PlayerResource:SetGold(i,80000,true)
				PlayerResource:SetGold(i,0,false)
			end
			
		end
	end
end

function Event:OnNPCSpawned( keys )
	local unit = EntIndexToHScript(keys.entindex)

	--判断英雄第一次创建
	if unit:IsHero() and unit:GetTeamNumber()==DOTA_TEAM_GOODGUYS and unit.firstSpawn==nil then
		unit.firstSpawn = true
		unit:SetAbilityPoints(0)
		AbilityPoint:Init( unit )
		AbilitySystem.AbilityCount:Init( unit )

		for i=0,5 do
			local ability = unit:GetAbilityByIndex(i)
			if ability then
				ability:SetLevel(1)
			end
		end
	end
end

function Event:OnHeroLevelUp( keys )
	local player = PlayerResource:GetPlayer(keys.player-1)

	if not IsValidEntity(player) then
		return
	end

	local hero = player:GetAssignedHero()

	if not IsValidEntity(hero) then
		return
	end

	hero:SetAbilityPoints(0)

	--test
	AbilityPoint:Add( hero,50 )
end

function Event:OnNPCKilled( keys )
	local entity = EntIndexToHScript(keys.entindex_killed)

	if entity.IsHero ~= nil then
		if entity:IsHero() and entity:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			CustomGameEventManager:Send_ServerToPlayer( entity:GetPlayerOwner(), "player_hero_death", {heroname=entity:GetUnitName()} )
		end
	end
end

---------------------------------------------------------------------------------------------
--UI
function OnPayAbilities( Index,keys )
	if keys['type'] == 1 then
		AbilitySystem:AddAbilityForDefense( PlayerResource:GetPlayer(keys.PlayerID) )
	end
	OnPayAbilitiesClose( Index,keys )
end

function OnPayAbilitiesOpen( Index,keys )
	CustomUI:DynamicHud_Create(keys.PlayerID,"PayAbilitiesMainWin","file://{resources}/layout/custom_game/pay_abilities.xml",nil)
end

function OnPayAbilitiesClose( Index,keys )
	CustomUI:DynamicHud_Destroy(keys.PlayerID,"PayAbilitiesMainWin")
end

function OnChangeAbilitiesOpen( Index,keys )
	CustomUI:DynamicHud_Create(keys.PlayerID,"ChangeAbilitiesWin","file://{resources}/layout/custom_game/change_abilities.xml",nil)
end

function OnChangeAbilitiesClose( Index,keys )
	CustomUI:DynamicHud_Destroy(keys.PlayerID,"ChangeAbilitiesWin")
end

function OnChangeAbilitiesRemove( Index,keys )
	AbilitySystem:RemoveAbility( keys.PlayerID,keys.AbilityIndex )
	OnChangeAbilitiesClose( Index,keys )
end

function OnChangeAbilitiesInfo( Index,keys )
	local data = {}
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if not IsValidEntity(player) then
		return
	end

	local hero = player:GetAssignedHero()

	if not IsValidEntity(hero) then
		return
	end

	for i=0,5 do
		local ability = hero:GetAbilityByIndex(i)
		local point = 0
		local gold = 0
		if ability then
			local lvl = ability:GetLevel()
			point = LEVELUP_ABILITY_BASE_XP[lvl] + DIFFICULTY_LEVELUP_ABILITY_XP * DifficultyCurrent
			gold = LEVELUP_ABILITY_BASE_GOLD[lvl] + DIFFICULTY_LEVELUP_ABILITY_GOLD * DifficultyCurrent
		end
		table.insert(data,{point=point,gold=gold})
	end
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "change_abilities_info_back", data )
end

function OnChangeAbilitiesLvlup( Index,keys )
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if not IsValidEntity(player) then
		return
	end

	local hero = player:GetAssignedHero()

	if not IsValidEntity(hero) then
		return
	end

	local g = PlayerResource:GetReliableGold(keys.PlayerID)
	local p = AbilityPoint:Get( hero )
	if g<keys.info.gold then
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "MessageShow", {msg="#ChangeAbilities_gold"} )
		return
	end
	if p<keys.info.point then
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "MessageShow", {msg="#ChangeAbilities_point"} )
		return
	end

	local ability = hero:GetAbilityByIndex(keys.AbilityIndex)
	if ability then
		if ability:GetLevel() < ability:GetMaxLevel() then
			ability:SetLevel(ability:GetLevel()+1)

			PlayerResource:SetGold(keys.PlayerID,g-keys.info.gold,true)
			AbilityPoint:Low( hero, keys.info.point )
		else
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "MessageShow", {msg="#ChangeAbilities_lvl_max"} )
		end
	end

	OnChangeAbilitiesClose( Index,keys )
end

function OnDifficultySelect( Index,keys )
	DifficultyCurrent = keys.lvl - 1
	ShowCustomHeaderMessage("#DifficultyMsg_"..tostring(DifficultyCurrent+1),keys.PlayerID,0,10)
end

function OnPlayerHeroRespawn( Index,keys )
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	if not IsValidEntity(player) then
		return
	end

	local hero = player:GetAssignedHero()

	if not IsValidEntity(hero) then
		return
	end

	local g = PlayerResource:GetReliableGold(keys.PlayerID)
	if g < RespawnHeroGold then
		Event:OnNPCKilled( {entindex_killed=hero:GetEntityIndex()} )
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "MessageShow", {msg="#PlayerHeroRespawnGold"} )
		return
	end
	local vec = hero:GetAbsOrigin()
	AMHC:RespawnHero( hero,vec+Vector(RandomFloat(-1000,1000),RandomFloat(-1000,1000),0) )
end