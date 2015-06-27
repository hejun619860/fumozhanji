
if AbilitySystem == nil then
	AbilitySystem = class({})
end

function AbilitySystem:AddAbility( hero,abilityName,gold )

	if hero._AbilitySystem_AbilityCount == nil then
		hero._AbilitySystem_AbilityCount = 0
	end

	if hero._AbilitySystem_AbilityCount >= 6 then
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
				hero._AbilitySystem_AbilityCount = hero._AbilitySystem_AbilityCount + 1

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

function AbilitySystem:RemoveAbility( playerId,abilityIndex )
	local player = PlayerResource:GetPlayer(playerId)

	if AMHC:IsAlive(player) == nil then
		return
	end

	local hero = player:GetAssignedHero()

	if AMHC:IsAlive(player) == nil then
		return
	end

	if hero._AbilitySystem_AbilityCount == nil then
		hero._AbilitySystem_AbilityCount = 0
	end

	if hero._AbilitySystem_AbilityCount <=0 then
		return
	end

	local ability = hero:GetAbilityByIndex(abilityIndex)
	local abilityName = ability:GetAbilityName()

	if string.find(abilityName,"empty_ability") then
		return
	end

	hero:RemoveAbility(abilityName)
	hero:AddAbility("empty_ability"..tostring(abilityIndex+1))
	hero._AbilitySystem_AbilityCount = hero._AbilitySystem_AbilityCount - 1

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

	local g = PlayerResource:GetReliableGold(player:GetPlayerID())
	if g < DefenseAbilitiesGold then
		CustomGameEventManager:Send_ServerToPlayer( player, "MessageShow", {msg="#AbilitySystem_PayFail_gold"} )
		return
	end
	PlayerResource:SetGold(player:GetPlayerID(),g-DefenseAbilitiesGold,true)

	AbilitySystem:AddAbility( hero,AbilitySystem.DefenesAbilities[RandomInt(1,#AbilitySystem.DefenesAbilities)],DefenseAbilitiesGold )
end