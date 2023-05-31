Treeherders_ForestFire = ArtilleryDefault:new{
	Name = "Forest Fire",
	Description = "Fire dead trees from any conjoint forest, pushing attacked tiles. Creates a forest behind this mech",
	Class = "Ranged",
	Icon = "weapons/ranged_th_forestFirer.png",
	Rarity = 1,
	Damage = 1,
	PowerCost = 1,
	LaunchSound = "/weapons/artillery_volley",
	ImpactSound = "/impact/generic/explosion",	
	UpShot = "effects/shotup_th_deadtree.png",
	Explosion = "",
	BounceAmount = forestUtils.floraformBounce,
	Upgrades = 2,
	UpgradeCost = { 1, 3 },
	
	-- Range
	ArtilleryStart = 2,
	ArtillerySize = 4,
	
	-- Custom
	DamageOuter = 1,
	BounceOuterAmount = 2,
	BuildingDamage = true,
	AdaptiveRecoilFlora = false,
	
	--TipImage
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy = Point(2,1),
		Building = Point(3,1),
		Forest = Point(3,3),
		Forest2 = Point(2,4),
	},
}

Weapon_Texts.Treeherders_ForestFire_Upgrade1 = "Building Immune"
Treeherders_ForestFire_A = Treeherders_ForestFire:new
{
	UpgradeDescription = "Buildings do not take damage from this attack",
	BuildingDamage = false,
}

--TODO make increase based on adjacent forests?
Weapon_Texts.Treeherders_ForestFire_Upgrade2 = "+2 Damage"
Treeherders_ForestFire_B = Treeherders_ForestFire:new
{
	UpgradeDescription = "The target takes two more damage",
	UpShot = "effects/shotup_th_deadtree_3.png",
	Damage = 3,
	DamageOuter = 1,
}

Treeherders_ForestFire_AB = Treeherders_ForestFire_B:new
{
	BuildingDamage = false,
}

-- TODO: Rework to instead allow mech to move to any forest space?
function Treeherders_ForestFire:GetTargetArea(point)
	--Get all spaces in the grouping
	local forestGroup = forestUtils:getGroupingOfSpaces(point, forestUtils.isAForest)
	
	local ret = PointList()
	--cant attack next to us
	local points = {}
	points[forestUtils:getSpaceHash(point)] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[0])] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[1])] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[2])] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[3])] = 0
		
	for k, v in pairs(forestGroup.group) do
		for dir = 0, 3 do
			for i = self.ArtilleryStart, self.ArtillerySize do
				local curr = Point(v + DIR_VECTORS[dir] * i)
				if not Board:IsValid(curr) then
					break
				end
				
				if not points[forestUtils:getSpaceHash(curr)] then
					points[forestUtils:getSpaceHash(curr)] = 0
					ret:push_back(curr)
				end
			end
		end
	end
	
	return ret
end

function Treeherders_ForestFire:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
	
	--floraform space around the mech
	local pBack = p1 + DIR_VECTORS[(attackDir + 2) % 4]
	if Board:IsValid(pBack) and forestUtils.isSpaceFloraformable(pBack) then
		forestUtils:floraformSpace(ret, pBack)
	end

	local damage = forestUtils:getFloraformSpaceDamage(p2, self.Damage, attackDir, false, not self.BuildingDamage)
	ret:AddBounce(p1, 1)
	ret:AddArtillery(damage, self.UpShot)
	ret:AddBounce(p2, 1)
	
	local dirs = {attackDir + 1, attackDir - 1}
	for _, dir in pairs(dirs) do
		dir = dir % 4
		local currP = p2 + DIR_VECTORS[dir]
		local sideDamage = forestUtils:getSpaceDamageWithoutSettingFire(currP, self.DamageOuter, dir, false, not self.BuildingDamage)
		sideDamage.sAnimation = self.OuterAnimation..dir
		
		ret:AddDamage(sideDamage)
		if self.BounceOuterAmount ~= 0 then	
			ret:AddBounce(currP, self.BounceOuterAmount) 
		end  
	end
	
	return ret
end