
if AbilitySystem == nil then
	AbilitySystem = class({})
	AbilitySystem.AbilityCount={}
	AbilitySystem.Hero={
		--坚盾
		defense={
			npc_dota_hero_beastmaster			=true,
			npc_dota_hero_dragon_knight			=true,
			npc_dota_hero_omniknight			=true,
			npc_dota_hero_elder_titan			=true,
			npc_dota_hero_axe					=true,
		},
		
		--利刃
		attack={
			npc_dota_hero_legion_commander		=true,
			npc_dota_hero_juggernaut			=true,
			npc_dota_hero_troll_warlord			=true,
			npc_dota_hero_antimage				=true,
			npc_dota_hero_terrorblade			=true,
		},
		
		--弓箭
		attack_range={
			npc_dota_hero_templar_assassin		=true,
			npc_dota_hero_windrunner			=true,
			npc_dota_hero_drow_ranger			=true,
			npc_dota_hero_queenofpain			=true,
			npc_dota_hero_clinkz				=true,
		},
		
		--魔法
		magician={
			npc_dota_hero_invoker				=true,
			npc_dota_hero_storm_spirit			=true,
			npc_dota_hero_crystal_maiden		=true,
			npc_dota_hero_dazzle				=true,
			npc_dota_hero_vengefulspirit		=true,
		},
			
	}
end

---------------------------------------------------------------------------------------------
--技能数量
function AbilitySystem.AbilityCount:Init( hero )
	AbilitySystem.AbilityCount[hero:GetEntityIndex()]=0
end

function AbilitySystem.AbilityCount:Get( hero )
	return AbilitySystem.AbilityCount[hero:GetEntityIndex()]
end

function AbilitySystem.AbilityCount:Add( hero )
	AbilitySystem.AbilityCount[hero:GetEntityIndex()] = AbilitySystem.AbilityCount[hero:GetEntityIndex()] + 1
end

function AbilitySystem.AbilityCount:Low( hero )
	AbilitySystem.AbilityCount[hero:GetEntityIndex()] = AbilitySystem.AbilityCount[hero:GetEntityIndex()] - 1
end

---------------------------------------------------------------------------------------------
--添加技能
function AbilitySystem:AddAbility( hero,abilityName,gold )

	if AbilitySystem.AbilityCount:Get( hero ) == nil then
		return
	end

	if AbilitySystem.AbilityCount:Get( hero ) >= 6 then
		CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "MessageShow", {msg="#AbilitySystem_PayFail_Max"} )
		return
	end

	local ability = hero:FindAbilityByName(abilityName)

	if ability then
		CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "MessageShow", {msg="#AbilitySystem_PayFail"} )
	else
		for i=1,6 do
			local name = "empty_ability"..tostring(i)
			local ability = hero:FindAbilityByName(name)
			if ability then
				hero:RemoveAbility(name)
				hero:AddAbility(abilityName)
				AbilitySystem.AbilityCount:Add( hero )

				local a = hero:FindAbilityByName(abilityName)
				if a then
					a:SetLevel(1)
				end

				hero:EmitSound("Hero_Chen.HandOfGodHealHero")
				local particleName = "particles/units/heroes/hero_chen/chen_holy_persuasion_a.vpcf"
				local p = AMHC:CreateParticle(particleName,PATTACH_CUSTOMORIGIN_FOLLOW,false,hero,3)
				ParticleManager:SetParticleControl(p,0,hero:GetOrigin())
				ParticleManager:SetParticleControl(p,1,hero:GetOrigin())
				ParticleManager:SetParticleControl(p,2,hero:GetOrigin())
				
				return
			end
		end
	end
end

--删除技能
function AbilitySystem:RemoveAbility( playerId,abilityIndex )
	local player = PlayerResource:GetPlayer(playerId)

	if AMHC:IsAlive(player) == nil then
		return
	end

	local hero = player:GetAssignedHero()

	if AMHC:IsAlive(player) == nil then
		return
	end

	if AbilitySystem.AbilityCount:Get( hero ) == nil then
		return
	end

	if AbilitySystem.AbilityCount:Get( hero ) <=0 then
		return
	end

	local ability = hero:GetAbilityByIndex(abilityIndex)
	local abilityName = ability:GetAbilityName()

	if string.find(abilityName,"empty_ability") then
		return
	end

	for k,v in pairs(GameRules.AbilityModifierNote[abilityName]) do
		hero:RemoveModifierByName(v)
	end

	hero:RemoveAbility(abilityName)
	hero:AddAbility("empty_ability"..tostring(abilityIndex+1))
	AbilitySystem.AbilityCount:Low( hero )

	local a = hero:FindAbilityByName("empty_ability"..tostring(abilityIndex+1))
	if a then
		a:SetLevel(1)
	end
	
end

---------------------------------------------------------------------------------------------
--添加防御技能
AbilitySystem.DefenesAbilities = {}
table.insert( AbilitySystem.DefenesAbilities, "JianCiWaiKe" )
table.insert( AbilitySystem.DefenesAbilities, "TianShenXiaFan" )
table.insert( AbilitySystem.DefenesAbilities, "ShanBi" )
table.insert( AbilitySystem.DefenesAbilities, "YingHuaPiFu" )
table.insert( AbilitySystem.DefenesAbilities, "MoFaHuDun" )
table.insert( AbilitySystem.DefenesAbilities, "ShuangDongHuJia" )

function AbilitySystem:AddAbilityForDefense( player )

	if AMHC:IsAlive(player) == nil then
		return
	end

	local hero = player:GetAssignedHero()

	if AMHC:IsAlive(hero) == nil then
		return
	end

	if not AbilitySystem.Hero.defense[hero:GetUnitName()] then
		CustomGameEventManager:Send_ServerToPlayer( player, "MessageShow", {msg="#AbilitySystem_PayFail_defense"} )
		return
	end

	local g = PlayerResource:GetReliableGold(player:GetPlayerID())
	if g < DefenseAbilitiesGold then
		CustomGameEventManager:Send_ServerToPlayer( player, "MessageShow", {msg="#AbilitySystem_PayFail_gold"} )
		return
	end
	PlayerResource:SetGold(player:GetPlayerID(),g-DefenseAbilitiesGold,true)

	AbilitySystem:AddAbility( hero,AbilitySystem.DefenesAbilities[RandomInt(1,#AbilitySystem.DefenesAbilities)],DefenseAbilitiesGold )
end