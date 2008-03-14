local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

DogTag:AddTag("Unit", "HP", {
	code = [=[return UnitHealth(${unit})]=],
	arg = {
		'unit', 'string', '@req',
	},
	ret = 'number',
	events = "UNIT_HEALTH#unit;UNIT_MAXHEALTH#unit",
	globals = "UnitHealth",
	doc = L["Return the current health of unit, will use MobHealth if found"],
	example = ('[HP] => "%d"'):format(UnitHealthMax("player")*.758),
	category = L["Health"],
})

DogTag:AddTag("Unit", "MaxHP", {
	code = [=[return UnitHealthMax(${unit})]=],
	arg = {
		'unit', 'string', '@req',
	},
	ret = 'number',
	events = "UNIT_HEALTH#unit;UNIT_MAXHEALTH#unit",
	globals = "UnitHealthMax",
	doc = L["Return the maximum health of unit, will use MobHealth if found"],
	example = ('[MaxHP] => "%d"'):format(UnitHealthMax("player")),
	category = L["Health"],
})

end