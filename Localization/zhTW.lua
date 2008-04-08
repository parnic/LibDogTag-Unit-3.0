local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

if GetLocale() == "zhTW" then

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)
	local L = DogTag_Unit.L
	
	-- races
	L["Blood Elf"] = "血精靈"
	L["Draenei"] = "德萊尼"
	L["Dwarf"] = "矮人"
	L["Gnome"] = "地精"
	L["Human"] = "人類"
	L["Night Elf"] = "夜精靈"
	L["Orc"] = "獸人"
	L["Tauren"] = "牛頭人"
	L["Troll"] = "食人妖"
	L["Undead"] = "不死族"

	-- short races
	L["Blood Elf_short"] = "血"
	L["Draenei_short"] = "德"
	L["Dwarf_short"] = "矮"
	L["Gnome_short"] = "地"
	L["Human_short"] = "人"
	L["Night Elf_short"] = "夜"
	L["Orc_short"] = "獸"
	L["Tauren_short"] = "牛"
	L["Troll_short"] = "食"
	L["Undead_short"] = "不"

	-- classes
	L["Warrior"] = "戰士"
	L["Priest"] = "牧師"
	L["Mage"] = "法師"
	L["Shaman"] = "薩滿"
	L["Paladin"] = "聖騎士"
	L["Warlock"] = "術士"
	L["Druid"] = "德魯伊"
	L["Rogue"] = "盜賊"
	L["Hunter"] = "獵人"

	-- short classes
	L["Warrior_short"] = "戰"
	L["Priest_short"] = "牧"
	L["Mage_short"] = "法"
	L["Shaman_short"] = "薩"
	L["Paladin_short"] = "聖"
	L["Warlock_short"] = "術"
	L["Druid_short"] = "德"
	L["Rogue_short"] = "賊"
	L["Hunter_short"] = "獵"

	-- Some strings below are set to GlobalStrings in enUS.lua and no need to be localized, commented out
	-- 下面部分字串已經在enUS.lua裏面使用了GlobalStrings，不需要翻譯，注釋掉
	--L["Player"] = PLAYER
	--L["Target"] = TARGET
	--L["Focus-target"] = FOCUS
	L["Mouse-over"] = "滑鼠目標"
	L["%s's pet"] = "%s的寵物"
	L["%s's target"] = "%s的目標"
	L["Party member #%d"] = "隊伍成員#%d"
	L["Raid member #%d"] = "團隊成員#%d"

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
	L["Stealthed"] = "潛行"
	L["Soulstoned"] = "靈魂已保存"

	--L["Dead"] = DEAD
	L["Ghost"] = "鬼魂"
	--L["Offline"] = PLAYER_OFFLINE
	L["Online"] = "線上"
	L["Combat"] = "戰鬥"
	L["Resting"] = "休息"
	L["Tapped"] = "已被攻擊"
	L["AFK"] = "暫離"
	L["DND"] = "請勿打擾"

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
	L["Cat"] = "獵豹"
	L["Moonkin"] = "梟獸"
	L["Aquatic"] = "水棲"
	L["Flight"] = "飛行"
	L["Travel"] = "旅行"
	L["Tree"] = "樹"

	L["Bear_short"] = "熊"
	L["Cat_short"] = "豹"
	L["Moonkin_short"] = "梟"
	L["Aquatic_short"] = "水"
	L["Flight_short"] = "飛"
	L["Travel_short"] = "旅"
	L["Tree_short"] = "樹"

	-- shortgenders
	L["Male_short"] = "男"
	L["Female_short"] = "女"

	L["Leader"] = "隊長"
	
	-- dispel types
	L["Magic"] = "魔法"
	L["Curse"] = "詛咒"
	L["Poison"] = "中毒"
	L["Disease"] = "疾病"
	
	L["True"] = "True"
	
	-- Categories
	L["Abbreviations"] = "縮寫"
	L["Auras"] = "法術效果"
	L["Casting"] = "施法"
	-- Spell names
	L["Holy Light"] = "聖光術"
	-- Docs
	-- Auras
	L["Return True if unit has the aura argument"] = "如果單位身上有參數指定的法術效果，則返回True"
	L["Return the number of auras on the unit"] = "返回參數指定的法術效果在單位身上所存在的數量"
	L["Return the shapeshift form the unit is in if unit is a druid"] = "假如單位是德魯伊，則返回其變形形態的名稱"
	L["Return a shortened druid form of unit, or shorten a druid form"] = "返回單位的德魯伊形態縮寫，或者縮寫一個德魯伊形態"
	L["Return the total number of debuffs that unit has"] = "返回單位身上的Debuff數量"
	L["Return the duration until the aura for unit is finished"] = "返回參數指定的法術效果在失效前還有多少時間"
	L["Return True if the unit has the shadowform buff"] = "如果目標擁有暗影形態Buff則返回True"
	L["Return True if the unit is stealthed in some way"] = "如果目標以某種形式潛行則返回True"
	L["Return True if the unit has the Shield Wall buff"] = "如果目標擁有盾牆Buff則返回True"
	L["Return True if the unit has the Last Stand buff"] = "如果目標擁有破釜沉舟Buff則返回True"
	L["Return True if the unit has the Soulstone buff"] = "如果目標擁有靈魂石復活Buff則返回True"
	L["Return True if the unit has the Misdirection buff"] = "如果目標擁有誤導Buff則返回True"
	L["Return True if the unit has the Ice Block buff"] = "如果目標擁有寒冰屏障Buff則返回True"
	L["Return True if the unit has the Invisibility buff"] = "如果目標擁有隱形術Buff則返回True"
	L["Return True if the unit has the Divine Intervention buff"] = "如果目標擁有神聖干涉Buff則返回True"
	L["Return True if friendly unit is has a debuff of type"] = "如果友好目標身上有指定系別的Debuff則返回True"
	L["Return True if the unit has a Magic debuff"] = "如果友好目標身上有魔法系的Debuff則返回True"
	L["Return True if the unit has a Curse debuff"] = "如果友好目標身上有詛咒系的Debuff則返回True"
	L["Return True if the unit has a Poison debuff"] = "如果友好目標身上有毒系的Debuff則返回True"
	L["Return True if the unit has a Disease debuff"] = "如果友好目標身上有病系的Debuff則返回True"
	-- Cast
	L["Return the current or last spell to be cast"] = "返回當前或者最後一次施放的法術名"
	L["Return the current cast target name"] = "返回當前施法所作用於的目標名字"
end

end
