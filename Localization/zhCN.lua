if GetLocale() == "zhCN" then

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)
	local L = DogTag_Unit.L
	
	-- races
	L["Blood Elf"] = "血精灵"
	L["Draenei"] = "德莱尼"
	L["Dwarf"] = "矮人"
	L["Gnome"] = "侏儒"
	L["Human"] = "人类"
	L["Night Elf"] = "暗夜精灵"
	L["Orc"] = "兽人"
	L["Tauren"] = "牛头人"
	L["Troll"] = "巨魔"
	L["Undead"] = "亡灵"

	-- short races
	L["Blood Elf_short"] = "血"
	L["Draenei_short"] = "德"
	L["Dwarf_short"] = "矮"
	L["Gnome_short"] = "侏"
	L["Human_short"] = "人"
	L["Night Elf_short"] = "暗"
	L["Orc_short"] = "兽"
	L["Tauren_short"] = "牛"
	L["Troll_short"] = "巨"
	L["Undead_short"] = "亡"

	-- classes
	L["Warrior"] = "战士"
	L["Priest"] = "牧师"
	L["Mage"] = "法师"
	L["Shaman"] = "萨满祭司"
	L["Paladin"] = "圣骑士"
	L["Warlock"] = "术士"
	L["Druid"] = "德鲁伊"
	L["Rogue"] = "潜行者"
	L["Hunter"] = "猎人"

	-- short classes
	L["Warrior_short"] = "战"
	L["Priest_short"] = "牧"
	L["Mage_short"] = "法"
	L["Shaman_short"] = "萨"
	L["Paladin_short"] = "圣"
	L["Warlock_short"] = "术"
	L["Druid_short"] = "德"
	L["Rogue_short"] = "贼"
	L["Hunter_short"] = "猎"

	-- Some strings below are set to GlobalStrings in enUS.lua and no need to be localized, commented out
	-- 下面部分字串已经在enUS.lua里面使用了GlobalStrings，不需要翻译，注释掉
	--L["Player"] = PLAYER
	--L["Target"] = TARGET
	--L["Focus-target"] = FOCUS
	L["Mouse-over"] = "鼠标目标"
	L["%s's pet"] = "%s的宠物"
	L["%s's target"] = "%s的目标"
	L["Party member #%d"] = "队伍成员#%d"
	L["Raid member #%d"] = "团队成员#%d"

	-- classifications
	L["Rare"] = "稀有"
	L["Rare-Elite"] = "稀有" and ELITE and "稀有" .. "-" .. ELITE
	--L["Elite"] = ELITE
	--L["Boss"] = BOSS
	-- short classifications
	L["Rare_short"] = "稀"
	L["Rare-Elite_short"] = "稀+"
	L["Elite_short"] = "+"
	L["Boss_short"] = "首"

	L["Feigned Death"] = "假死"
	L["Stealthed"] = "潜行"
	L["Soulstoned"] = "灵魂已保存"

	--L["Dead"] = DEAD
	L["Ghost"] = "鬼魂"
	--L["Offline"] = PLAYER_OFFLINE
	L["Online"] = "在线"
	L["Combat"] = "战斗"
	L["Resting"] = "休息"
	L["Tapped"] = "已被攻击"
	L["AFK"] = "暂离"
	L["DND"] = "勿扰"

	--L["Rage"] = RAGE
	--L["Focus"] = FOCUS
	--L["Energy"] = ENERGY
	--L["Mana"] = MANA

	--L["PvP"] = PVP
	L["FFA"] = "自由PK"

	-- genders
	--L["Male"] = MALE
	--L["Female"] = FEMALE

	-- forms
	L["Bear"] = "熊"
	L["Cat"] = "猎豹"
	L["Moonkin"] = "枭兽"
	L["Aquatic"] = "水栖"
	L["Flight"] = "飞行"
	L["Travel"] = "旅行"
	L["Tree"] = "树"

	L["Bear_short"] = "熊"
	L["Cat_short"] = "豹"
	L["Moonkin_short"] = "枭"
	L["Aquatic_short"] = "水"
	L["Flight_short"] = "飞"
	L["Travel_short"] = "旅"
	L["Tree_short"] = "树"

	-- shortgenders
	L["Male_short"] = "男"
	L["Female_short"] = "女"

	L["Leader"] = "队长"
	
	-- dispel types
	L["Magic"] = "魔法"
	L["Curse"] = "诅咒"
	L["Poison"] = "中毒"
	L["Disease"] = "疾病"
end

end