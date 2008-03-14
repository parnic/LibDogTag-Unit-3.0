local old_dofile = dofile

function dofile(file)
	return old_dofile("../LibDogTag-3.0/" .. file)
end
old_dofile('../LibDogTag-3.0/test.lua')
dofile = old_dofile

local DogTag = LibStub("LibDogTag-3.0")

local units = {
	player = {
		hp = 1500,
		maxhp = 2000,
		exists = true,
	},
	target = {
		hp = 2500,
		maxhp = 2500,
		exists = true,
	},
	focus = {
		exists = false,
	}
}

local IsLegitimateUnit = { player = true, target = true, focus = true, pet = true, playerpet = true, mouseover = true, npc = true, NPC = true }
for i = 1, 4 do
	IsLegitimateUnit["party" .. i] = true
	IsLegitimateUnit["partypet" .. i] = true
	IsLegitimateUnit["party" .. i .. "pet"] = true
end
for i = 1, 40 do
	IsLegitimateUnit["raid" .. i] = true
	IsLegitimateUnit["raidpet" .. i] = true
	IsLegitimateUnit["raid" .. i .. "pet"] = true
end
setmetatable(IsLegitimateUnit, { __index = function(self, key)
	if type(key) ~= "string" then
		return false
	end
	if key:match("target$") then
		self[key] = self[key:sub(1, -7)]
		return self[key]
	end
	self[key] = false
	return false
end, __call = function(self, key)
	return self[key]
end})

function UnitExists(unit)
	if not IsLegitimateUnit(unit) then
		error(("Not a legitimate unit: %q"):format(unit), 2)
	end
	return units[unit] and units[unit].exists
end

function UnitHealth(unit)
	if not IsLegitimateUnit(unit) then
		error(("Not a legitimate unit: %q"):format(unit), 2)
	end
	return units[unit] and units[unit].hp
end

function UnitHealthMax(unit)
	if not IsLegitimateUnit(unit) then
		error(("Not a legitimate unit: %q"):format(unit), 2)
	end
	return units[unit] and units[unit].maxhp
end

MyUnit_data = "player"
DogTag:AddTag("Unit", "MyUnit", {
	code = [=[return _G.MyUnit_data]=],
	ret = "string",
})

MyValue_data = nil
DogTag:AddTag("Unit", "MyValue", {
	code = [=[return _G.MyValue_data]=],
	ret = "nil;number;string",
})

dofile("Localization/enUS.lua")
dofile("LibDogTag-Unit-3.0.lua")
dofile("Modules/Health.lua")
dofile("Cleanup.lua")

assert_equal(DogTag:Evaluate("[HP('player')]"), "Unknown tag HP")

assert_equal(DogTag:Evaluate("[HP('player')]", "Unit"), 1500)
assert_equal(DogTag:Evaluate("[HP(unit='player')]", "Unit"), 1500)
assert_equal(DogTag:Evaluate("[HP]", "Unit", { unit = 'player'}), 1500)
assert_equal(DogTag:Evaluate("[MaxHP('player')]", "Unit"), 2000)
assert_equal(DogTag:Evaluate("[MaxHP(unit='player')]", "Unit"), 2000)

assert_equal(DogTag:Evaluate("[HP('target')]", "Unit"), 2500)
assert_equal(DogTag:Evaluate("[MaxHP('target')]", "Unit"), 2500)
assert_equal(DogTag:Evaluate("[HP]", "Unit", { unit = 'target'}), 2500)
assert_equal(DogTag:Evaluate("[MaxHP]", "Unit", { unit = 'target'}), 2500)

assert_equal(DogTag:Evaluate("[HP('focus')]", "Unit"), nil)
assert_equal(DogTag:Evaluate("[MaxHP('focus')]", "Unit"), nil)
assert_equal(DogTag:Evaluate("[HP]", "Unit", { unit = 'focus'}), nil)
assert_equal(DogTag:Evaluate("[MaxHP]", "Unit", { unit = 'focus'}), nil)

assert_equal(DogTag:Evaluate("[HP('fakeunit')]", "Unit"), 'Bad unit: "fakeunit"')
assert_equal(DogTag:Evaluate("[HP(unit='fakeunit')]", "Unit"), 'Bad unit: "fakeunit"')
assert_equal(DogTag:Evaluate("[MaxHP('fakeunit')]", "Unit"), 'Bad unit: "fakeunit"')
assert_equal(DogTag:Evaluate("[MaxHP(unit='fakeunit')]", "Unit"), 'Bad unit: "fakeunit"')
assert_equal(DogTag:Evaluate("[HP]", "Unit", { unit = 'fakeunit'}), 'Bad unit: "fakeunit"')
assert_equal(DogTag:Evaluate("[MaxHP]", "Unit", { unit = 'fakeunit'}), 'Bad unit: "fakeunit"')

MyUnit_data = "player"
assert_equal(DogTag:Evaluate("[HP(MyUnit)]", "Unit"), 1500)
MyUnit_data = "target"
assert_equal(DogTag:Evaluate("[HP(MyUnit)]", "Unit"), 2500)
MyUnit_data = "focus"
assert_equal(DogTag:Evaluate("[HP(MyUnit)]", "Unit"), nil)
MyUnit_data = "fakeunit"
assert_equal(DogTag:Evaluate("[HP(MyUnit)]", "Unit"), 'Bad unit: "fakeunit"')
MyValue_data = "fakeunit"
assert_equal(DogTag:Evaluate("[HP(MyValue)]", "Unit"), 'Bad unit: "fakeunit"')
MyValue_data = 50
assert_equal(DogTag:Evaluate("[HP(MyValue)]", "Unit"), 'Bad unit: "50"')
MyValue_data = nil
assert_equal(DogTag:Evaluate("[HP(MyValue)]", "Unit"), 'Bad unit: "nil"')

print("LibDogTag-Unit-3.0: Tests succeeded")