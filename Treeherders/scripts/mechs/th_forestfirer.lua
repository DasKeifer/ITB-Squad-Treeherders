local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local mechPath = resourcePath .. "img/mechs/"

local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()

local treeherdersColor = modApi:getPaletteImageOffset("treeherders_color")

local files = {
	"th_forestfirer.png",
	"th_forestfirer_a.png",
	"th_forestfirer_w.png",
	"th_forestfirer_w_broken.png",
	"th_forestfirer_broken.png",
	"th_forestfirer_ns.png",
	"th_forestfirer_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/" .. file, mechPath .. file)
end

local a = ANIMS
a.th_forestfirer =         a.MechUnit:new{Image = "units/player/th_forestfirer.png",          PosX = -13, PosY = 6 }
a.th_forestfirera =        a.MechUnit:new{Image = "units/player/th_forestfirer_a.png",        PosX = -13, PosY = 6, NumFrames = 8, Lengths = { 0.1, 0.15, 0.3, 0.15, 0.1, 0.15, 0.3, 0.15 }, }
a.th_forestfirerw =        a.MechUnit:new{Image = "units/player/th_forestfirer_w.png",        PosX = -13, PosY = 6 }
a.th_forestfirer_broken =  a.MechUnit:new{Image = "units/player/th_forestfirer_broken.png",   PosX = -13, PosY = 6 }
a.th_forestfirerw_broken = a.MechUnit:new{Image = "units/player/th_forestfirer_w_broken.png", PosX = -13, PosY = 6 }
a.th_forestfirer_ns =      a.MechIcon:new{Image = "units/player/th_forestfirer_ns.png" }


truelch_SupportMech = Pawn:new{	
	Name = "Forest Firer",
	Class = "Ranged",
	Health = 3,
	MoveSpeed = 3,
	Image = "th_forestfirer",
	ImageOffset = treeherdersColor,
	SkillList = { "Eplanum_TH_ForestFire" },
	SoundLocation = "/mech/distance/artillery/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}