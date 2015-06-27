
function YingHuaPiFu( keys )
	local attacker = keys.attacker
	local target = keys.target

	if attacker._YingHuaPiFu_AttackCount == nil then
		attacker._YingHuaPiFu_AttackCount = 0
	end

	--记录攻击次数
	attacker._YingHuaPiFu_AttackCount = attacker._YingHuaPiFu_AttackCount + 1

	if attacker._YingHuaPiFu_AttackCount >= keys.AttackCount then
		attacker._YingHuaPiFu_AttackCount = 0
		target:Damage(attacker,keys.Damage,AMHC:DamageType(keys.DamageType),keys.ReboundNum)
	end
end


function ShuangDongHuJia( keys )
	local target = keys.target
	local attacker = keys.attacker
	local ability = keys.ability

	local count = attacker:GetModifierStackCount("modifier_ShuangDongHuJia_effect",ability)

	if count>=keys.MaxCount-1 then
		attacker:RemoveModifierByName("modifier_ShuangDongHuJia_effect")
		ability:ApplyDataDrivenModifier(target,attacker,"modifier_ShuangDongHuJia_frozen",nil)
	else
		ability:ApplyDataDrivenModifier(target,attacker,"modifier_ShuangDongHuJia_effect",nil)
		attacker:SetModifierStackCount("modifier_ShuangDongHuJia_effect",ability,count+1)
	end
end
