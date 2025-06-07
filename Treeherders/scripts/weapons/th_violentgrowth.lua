Treeherders_ViolentGrowth = Skill:new
{
	Name = "Violent Growth",
    Class = "Science",
    Description = "Grows a forest in an unforested tile otherwise cancels target's attack. Expands connected forest one tile towards the closest enemy or closest spot to current position. Forest growth damages enemies",
	Icon = "weapons/science_th_violentGrowth.png",
	Rarity = 1,
	
	Explosion = "",
	--TODO sounds
--	LaunchSound = "/weapons/titan_fist",
--	ImpactSound = "/impact/generic/tractor_beam",
	
	Range = 1,
	PathSize = 1,
    Damage = 1,
	
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 1, 2 },
	
	TwoClick = true,
	
	-- custom options
	ForestDamageBounce = -2,
	NonForestBounce = 2,
	ForestGenBounce = forestUtils.floraformBounce,
	
	SeekVek = true,
	
	ForestToExpand = 0,
	SlowEnemy = false,
	SlowEnemyAmount = 3,
	MinEnemyMove = 1,
	
    TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(1,1),
		Forest = Point(2,2),
		Forest2 = Point(1,2),
		Target = Point(2,2),
		Second_Click = Point(1,1),
	},
}

Weapon_Texts.Treeherders_ViolentGrowth_Upgrade1 = "Ensnare"
Treeherders_ViolentGrowth_A = Treeherders_ViolentGrowth:new
{
	UpgradeDescription = "For one turn all vek in the targetted forest lose three movement (minmum of 1)",
	SlowEnemy = true,
}

Weapon_Texts.Treeherders_ViolentGrowth_Upgrade2 = "+2 Expansion"
Treeherders_ViolentGrowth_B = Treeherders_ViolentGrowth:new
{
	UpgradeDescription = "Expand the targeted forest two extra tiles",
	ForestToExpand = 2,
}

Treeherders_ViolentGrowth_AB = Treeherders_ViolentGrowth_B:new
{	
	SlowEnemy = true,
}

function Treeherders_ViolentGrowth:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		ret:push_back(point + DIR_VECTORS[dir])
	end
	return ret
end

function Treeherders_ViolentGrowth:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
		
	--if it is a forest, cancel the target's attack
	if forestUtils.isAForest(p2) then
		ret:AddDamage(forestUtils:getSpaceDamageWithoutSettingFire(p2, self.Damage, nil, true, true))
		forestUtils:addCancelEffect(p2, ret)
		ret:AddBounce(p2, self.NonForestBounce)
	
	--if it can be floraformed, do so
	elseif forestUtils.isSpaceFloraformable(p2) then
		forestUtils:floraformSpace(ret, p2, self.Damage, nil, true, true)
		
	--otherwise just damage it
	else
		ret:AddDamage(SpaceDamage(p2, self.Damage))
		ret:AddBounce(p2, self.NonForestBounce)
	end
	return ret
end

function Treeherders_ViolentGrowth:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	
	local forestGroup = forestUtils:getGroupingOfSpaces(p2, forestUtils.isAForest)
	for k, v in pairs(forestGroup.group) do
		if Point(v) ~= p2 and forestUtils.isSpaceFloraformable(v) then
			ret:push_back(Point(v))
		end
	end
	for k, v in pairs(forestGroup.boardering) do
		if Point(v) ~= p2 and forestUtils.isSpaceFloraformable(v) then
			ret:push_back(Point(v))
		end
	end
	return ret
end

function Treeherders_ViolentGrowth:GetFinalEffect(p1, p2, p3)
	-- Start with the previous partial effect, add a pause and build on it
	local ret = self:GetSkillEffect(p1, p2)
	
	--small break to make the animation and move make more sense
	ret:AddDelay(0.4)
	
	--any enemy in the forest, slow down temporarily if the powerup is enabled
	if self.SlowEnemy then
		local slowed = false
		local forestGroup = forestUtils:getGroupingOfSpaces(p2, forestUtils.isAForest)
		for _, v in pairs(forestGroup.group) do
			local pawn = Board:GetPawn(v)
			if pawn and pawn:IsEnemy() then
				local slow = -self.SlowEnemyAmount
				
				if (pawn:GetMoveSpeed() - self.SlowEnemyAmount) < self.MinEnemyMove then
					slow = self.MinEnemyMove - pawn:GetMoveSpeed()
				end 
				
				ret:AddScript([[Board:GetPawn(]]..pawn:GetId()..[[):AddMoveBonus(]]..slow..[[)]])
				slowed = true
			end
		end
		if slowed then
			ret:AddDelay(0.2)
		end
	end
	
	if forestUtils.isSpaceFloraformable(p3) then
		forestUtils:floraformSpace(ret, p3, self.Damage, nil, true, true)
	end
	
	local numLeft = self.ForestToExpand
	local selectedSpaced = {}
	local attackDir = GetDirection(p2 - p1)
	local dirPreferences = { (attackDir + 2) % 4, attackDir, (attackDir - 1) % 4, (attackDir + 1) % 4 }
	
	for _, dir in pairs(dirPreferences) do
		if numLeft <= 0 then
			break
		end
		local p = p3 + DIR_VECTORS[dir]
		if Board:IsValid(p) and p ~= p2 and not forestUtils.isAForest(p) and forestUtils.isSpaceFloraformable(p) and not selectedSpaced[forestUtils:getSpaceHash(p)] then
			selectedSpaced[forestUtils:getSpaceHash(p)] = p
			numLeft = numLeft - 1
		end 
	end
	
	for _, dir in pairs(dirPreferences) do
		if numLeft <= 0 then
			break
		end
		local p = p2 + DIR_VECTORS[dir]
		if Board:IsValid(p) and p ~= p3 and not forestUtils.isAForest(p) and forestUtils.isSpaceFloraformable(p) and not selectedSpaced[forestUtils:getSpaceHash(p)] then
			selectedSpaced[forestUtils:getSpaceHash(p)] = p
			numLeft = numLeft - 1
		end 
	end
	
	for _, v in pairs(selectedSpaced) do
		forestUtils:floraformSpace(ret, v, self.Damage, nil, true, true)
	end
	return ret
end