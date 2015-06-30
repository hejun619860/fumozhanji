
if AbilityPoint == nil then
	AbilityPoint = class({})
	AbilityPoint.data={}
end

function AbilityPoint:Init( hero )

	if AbilityPoint.data[hero:GetEntityIndex()] == nil then
		AbilityPoint.data[hero:GetEntityIndex()] = 0
	end
	
end

function AbilityPoint:Add( hero,count )
	if AMHC:IsAlive(hero)==nil then return end

	AbilityPoint.data[hero:GetEntityIndex()] = AbilityPoint.data[hero:GetEntityIndex()] + count
	CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "ability_point_change", {point=AbilityPoint.data[hero:GetEntityIndex()]} )
end

function AbilityPoint:Low( hero,count )
	if AMHC:IsAlive(hero)==nil then return end

	AbilityPoint.data[hero:GetEntityIndex()] = AbilityPoint.data[hero:GetEntityIndex()] - count
	if AbilityPoint.data[hero:GetEntityIndex()]<0 then
		AbilityPoint.data[hero:GetEntityIndex()] = 0
	end
	CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "ability_point_change", {point=AbilityPoint.data[hero:GetEntityIndex()]} )
end

function AbilityPoint:Get( hero )
	return AbilityPoint.data[hero:GetEntityIndex()]
end