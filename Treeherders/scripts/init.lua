local mod = {
	id = "eplanum_treeherders",
	name = "Treeherders",
	icon = "img/mod_icon.png",
	version = "0.10.0",
	modApiVersion = "2.9.2",
	gameVersion = "1.2.88",
--    dependencies = {
--        modApiExt = "1.17", NEEDED
--		memedit = "1.0.1",
--    }
--	requirements = { "kf_ModUtils" },
}

function mod:init()	
	-- Assets
	require(self.scriptPath .. "images")
	require(self.scriptPath .. "palettes")

	-- Achievements... TBD
	-- require(self.scriptPath .. "achievements")

	-- Libs
	require(self.scriptPath .. "libs/passiveEffect")
	require(self.scriptPath .. "libs/predictableRandom")
	
	require(self.scriptPath.. "forestUtils")
		
	-- Pawns
	require(self.scriptPath .. "mechs/th_arbiformer")
	require(self.scriptPath .. "mechs/th_entborg")
	require(self.scriptPath .. "mechs/th_forestfirer")

	-- Weapons
	require(self.scriptPath .. "weapons/th_forestfire")
	require(self.scriptPath .. "weapons/th_treevenge")
	require(self.scriptPath .. "weapons/th_violentgrowth")
	require(self.scriptPath .. "weapons/th_waketheforest")
	
	-- Shop... TBD
	-- modApi:addWeaponDrop("truelch_M10THowitzerArtillery")
	
	--Tutorial tips... TBD
	--require(self.scriptPath .. "tips")
	
	Treeherders_ResourcePath = self.resourcePath
	require(self.scriptPath.."images")

	--Appears we have to load mod api after the images or else they work sporadically
	--TBD Needed? treeherders_modApiExt = require(self.scriptPath.."modApiExt/modApiExt"):init()
end

function mod:load(options, version)

local function load(self, options, version)
	modApi:addSquad(
		{
			id = "treeherders",
			"Treeherders",
			"Treeherders_EntborgMech",
			"Treeherders_ForestFirerMech",
			"Treeherders_ArbiformerMech",
		},
		"Treeherders",
		"One with the forests, these mechs harness natures power to defend earth from the vek onslaught",
		self.resourcePath .. "img/squad_icon.png"
	)
	
	--todo remove when pulled into modUtils
	predictableRandom:registerAutoRollHook()
	passiveEffect:addHooks()
	passiveEffect:autoSetWeaponsPassiveFields()
end

return mod