-- Generated from template

if CFuMoZhanJi == nil then
	CFuMoZhanJi = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	PrecacheResource( "particle", "particles/units/heroes/hero_chen/chen_holy_persuasion_a.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chen.vsndevts", context )

	GameRules.AbilityModifierNote = {}
	local kv = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	for k,v in pairs(kv) do
		if type(v) == "table" then
			if v.CustomPrecache then
				for key,value in pairs(v.CustomPrecache) do

					if string.find(key,"particle")>0 then
						PrecacheResource( "particle", value, context )
					elseif string.find(key,"particle_folder")>0 then
						PrecacheResource( "particle_folder", value, context )
					end
				end
			end
			if v.Modifiers then
				GameRules.AbilityModifierNote[k]={}
				for key,value in pairs(v.Modifiers) do
					table.insert(GameRules.AbilityModifierNote[k],key)
				end
			end
		end
	end
end

function Activate()
	GameRules.FuMoZhanJi = CFuMoZhanJi()
	GameRules.FuMoZhanJi:InitGameMode()
end

function CFuMoZhanJi:InitGameMode()
	print( "FuMoZhanJi addon is loaded." )

	--require
	require("event")
	require("constant")
	require("AbilityPoint")
	require("AbilitySystem")
	require("amhc_library/amhc")

	--init
	AMHCInit()
	Event:Init()

	--设置玩家
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 8 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )

	--隐藏dota2的一些UI
	HideGameHud()
	
	--设置游戏准备时间
	GameRules:SetPreGameTime( 10.0)

	-- 设定选择英雄时间
	GameRules:SetHeroSelectionTime(30)

	-- 设定是否可以选择相同英雄
	GameRules:SetSameHeroSelectionEnabled( false )

	-- 是否使用自定义的英雄经验
  	GameRules:SetUseCustomHeroXPValues ( true )
  	
  	-- 设定每秒工资数
  	GameRules:SetGoldPerTick(0)

  	-- 隐藏击杀信息
  	GameRules:SetHideKillMessageHeaders(true)

  	-- 允许自定义英雄等级
  	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)

  	--设置树木重生时间
  	GameRules:SetTreeRegrowTime( 10.0 )

  	--禁止重生
  	GameRules:SetHeroRespawnEnabled(false)

  	--不允许买活
  	GameRules:GetGameModeEntity():SetBuybackEnabled(false)

  	--最大等级
  	MaxLevel = 50

  	--升级所需经验
	XpTable = {}
	for i=1,MaxLevel do
		table.insert(XpTable,200+(i-1)*(i*100))
	end
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(MaxLevel)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XpTable)
end

function HideGameHud( )
	local mode = GameRules:GetGameModeEntity()
	mode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_HEROES, false)
	mode:SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_SHOP, false)

	Convars:SetInt("dota_render_crop_height", 0)
	Convars:SetInt("dota_render_y_inset", 0)
end