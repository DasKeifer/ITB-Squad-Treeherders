Treeherders_ForestFire = Skill:new{
	Name = "Forest Fire",
	Description = "Move to any space in the forect then fire dead logs, pushing attacked tiles. Creates a forest behind this mech",
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
	
	TwoClick = true,
	
	-- Range
	ArtilleryStart = 2,
	ArtillerySize = 4,
	
	-- Custom
	PushOuter = false,
	DamageOuter = 0,
	BounceOuterAmount = 2,
	BuildingDamage = true,
	
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

Weapon_Texts.Treeherders_ForestFire_Upgrade1 = "Splash"
Treeherders_ForestFire_A = Treeherders_ForestFire:new
{
	UpgradeDescription = "Adds splash damage and push to the sides of the attack",
	DamageOuter = 1,
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
	DamageOuter = 1,
}

--function azure_zordai_sword:GetTargetArea(p1)
--function azure_zordai_sword:GetSkillEffect(p1,p2)
--function azure_zordai_sword:GetSecondTargetArea(p1,p2)
--function azure_zordai_sword:GetFinalEffect(p1,p2,p3)

-- First action is to move to any space in the forest
function Treeherders_ForestFire:GetTargetArea(point)
	local ret = PointList()
	
	-- if we aren't on a forest then return the point we are attack
	-- this is needed with how getGroupingOfSpaces works since it consideres the
	-- point to be of the right type or as part of the boarder
	if not forestUtils.isAForest(point) then
		ret:push_back(point)
	else
		local forestGroup = forestUtils:getGroupingOfSpaces(point, forestUtils.isAForest)
		for k, v in pairs(forestGroup.group) do
			ret:push_back(Point(v))
		end
	end 
	return ret
end

function Treeherders_ForestFire:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	if p1 ~= p2 then
		ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), FULL_DELAY)
	else
		ret:AddDamage(SpaceDamage(p1,0))
	end
	return ret
end

function Treeherders_ForestFire:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	
	-- Since we aren't inheriting from the artillery class,
	-- we reimplement the logic for our need
	for dir = DIR_START, DIR_END do
		for i = self.ArtilleryStart, self.ArtillerySize do
			local curr = Point(p2 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			ret:push_back(curr)
		end
	end
	
	return ret
end

function Treeherders_ForestFire:GetFinalEffect(p1,p2,p3)
	-- Start with the previous partial effect, add a pause and build on it
	local ret = self:GetSkillEffect(p1, p2)
	ret:AddDelay(0.2)
	
	local attackDir = GetDirection(p3 - p2)
	
	local pBack = p2 + DIR_VECTORS[(attackDir + 2) % 4]
	if Board:IsValid(pBack) and forestUtils.isSpaceFloraformable(pBack) then
		forestUtils:floraformSpace(ret, pBack)
	end

	-- For some reason it seems like using this as a two stage weapons causes forests to
	-- disappear on the second target tile so we manually reset it after the attack
	-- TODO check how this works with fires/forest fires
	local wasForest = forestUtils.isAForest(p3)
		
	local damage = forestUtils:getFloraformSpaceDamage(p3, self.Damage, attackDir, false, not self.BuildingDamage)
	ret:AddBounce(p2, 1)
	ret:AddArtillery(damage, self.UpShot)
	if wasForest then
		local backToForest = SpaceDamage(p3, 0)
		backToForest.iTerrain = TERRAIN_FOREST
		ret:AddDamage(backToForest)
	end
	
	ret:AddBounce(p3, 1)
	
	if self.DamageOuter > 0 then
		local dirs = {attackDir + 1, attackDir - 1}
		for _, dir in pairs(dirs) do
			dir = dir % 4
			local currP = p3 + DIR_VECTORS[dir]
			local sideDamage = forestUtils:getSpaceDamageWithoutSettingFire(currP, self.DamageOuter, attackDir, false, not self.BuildingDamage)
			sideDamage.sAnimation = self.OuterAnimation..attackDir
			
			ret:AddDamage(sideDamage)
			if self.BounceOuterAmount ~= 0 then	
				ret:AddBounce(currP, self.BounceOuterAmount) 
			end  
		end
	end
	
	return ret
end