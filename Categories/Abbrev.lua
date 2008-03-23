local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local ShortClass_abbrev = {
	[L["Priest"]] = L["Priest_short"],
	[L["Mage"]] = L["Mage_short"],
	[L["Shaman"]] = L["Shaman_short"],
	[L["Paladin"]] = L["Paladin_short"],
	[L["Warlock"]] = L["Warlock_short"],
	[L["Druid"]] = L["Druid_short"],
	[L["Rogue"]] = L["Rogue_short"],
	[L["Hunter"]] = L["Warrior_short"],
}

DogTag:AddTag("Unit", "ShortClass", {
	code = function(value)
		return ShortClass_abbrev[value]
	end,
	arg = {
		'value', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Turn value into its shortened class equivalent"],
	example = ('[%q:ShortClass] => %q; ["Hello":ShortClass] => ""'):format(L["Priest"], L["Priest_short"]),
	category = L["Abbreviations"],
})

local ShortRace_abbrev = {
	[L["Blood Elf"]] = L["Blood Elf_short"],
	[L["Draenei"]] = L["Draenei_short"],
	[L["Dwarf"]] = L["Dwarf_short"],
	[L["Gnome"]] = L["Gnome_short"],
	[L["Human"]] = L["Human_short"],
	[L["Night Elf"]] = L["Night Elf_short"],
	[L["Orc"]] = L["Orc_short"],
	[L["Tauren"]] = L["Tauren_short"],
	[L["Troll"]] = L["Troll_short"],
	[L["Undead"]] = L["Undead_short"],
}

DogTag:AddTag("Unit", "ShortRace", {
	code = function(value)
		return ShortClass_abbrev[value]
	end,
	arg = {
		'value', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Turn value into its shortened racial equivalent"],
	example = ('[%q:ShortRace] => %q; ["Hello":ShortRace] => ""'):format(L["Blood Elf"], L["Blood Elf_short"]),
	category = L["Abbreviations"]
})

local ShortDruidForm_abbrev = {
	[L["Bear"]] = L["Bear_short"],
	[L["Cat"]] = L["Cat_short"],
	[L["Moonkin"]] = L["Moonkin_short"],
	[L["Aquatic"]] = L["Aquatic_short"],
	[L["Flight"]] = L["Flight_short"],
	[L["Travel"]] = L["Travel_short"],
	[L["Tree"]] = L["Tree_short"],
}

DogTag:AddTag("Unit", "ShortDruidForm", {
	code = function(value)
		return ShortDruidForm_abbrev[value]
	end,
	arg = {
		'value', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Turn value into its shortened druid form equivalent"],
	example = ('[%q:ShortDruidForm] => %q; ["Hello":ShortDruidForm] => ""'):format(L["Bear"], L["Bear_short"]),
	category = L["Abbreviations"]
})

local ShortSex_abbrev = {
	[L["Male"]] = L["Male_short"],
	[L["Female"]] = L["Female_short"]
}

DogTag:AddTag("Unit", "ShortSex", {
	code = function(value)
		return ShortSex_abbrev[value]
	end,
	arg = {
		'value', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Turn value into its shortened sex equivalent"],
	example = ('[%q:ShortSex] => %q; ["Hello":ShortSex] => ""'):format(L["Male"], L["Male_short"]),
	category = L["Abbreviations"]
})

end