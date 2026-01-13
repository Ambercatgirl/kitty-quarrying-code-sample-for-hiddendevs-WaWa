local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("ServerFiredEvents"):WaitForChild("BuffsChanged")

local BuffService = {}
BuffService.__index = BuffService

function BuffService.new(Player : Player, LayerService, Profile)
	local New = {
		["Player"] = Player;
		["PlayerProfile"] = Profile;
		["Layers"] = LayerService;
		["Buffs"] = {};
		["LayerLuck"] = 1000,
		["CaveExclusiveLuck"] = 1000,
		["CaveOreLuck"] = 1000,
		["CaveTypeLuck"] = 1000,
		["AddedWalkSpeed"] = 0,
		["AddedJumpPower"] = 0,
		["BuffCauses"] = {},
		["EnchantsBuffing"] = {},
		["PickaxeRate"] = 0,
		["GearRate"] = 0,
		["AllRate"] = 0,
		["ModulesSpawnable"] = false,
		["Version"] = 1,
		["TrackerRange"] = 0,
	}
	
	return setmetatable(New,BuffService)
end

function BuffService:CheckAssociatedValueInstances(BuffType : string, BuffAmount : number|boolean)
	local AssociatedFunctions = {
		["TrackerRange"] = function(NewValue)
			local Player : Player = self.Player
			local TrackerRange = Player:WaitForChild("TrackerRange")
			TrackerRange.Value += NewValue
			
			local UsedRange = Player:WaitForChild("Settings"):WaitForChild("RangeUsed")
			UsedRange.Value = math.clamp(UsedRange.Value,0,TrackerRange.Value)
			
			self.PlayerProfile.Data.Settings.RangeUsed = UsedRange.Value
		end,
	}
	
	if AssociatedFunctions[BuffType] then
		AssociatedFunctions[BuffType](BuffAmount)
	end
end

function BuffService:SendPlayerBuffs()
	local AcceptableArgs = {
		["LayerLuck"] = 1000,
		["CaveExclusiveLuck"] = 1000,
		["CaveOreLuck"] = 1000,
		["CaveTypeLuck"] = 1000,
		["AddedWalkSpeed"] = 0,
		["AddedJumpPower"] = 0,
		["PickaxeRate"] = 0,
		["GearRate"] = 0,
		["AllRate"] = 0,
		["ModulesSpawnable"] = false
	}
	
	local NewTable = {}
	for Arg,Default in pairs(AcceptableArgs) do
		NewTable[Arg] = self[Arg] or Default
	end
	
	self.Version += 1
	task.spawn(function()
		local Char = self.Player.Character or self.Player.CharacterAdded:Wait()
		Event:FireClient(self.Player,NewTable,self.Version)
	end)
end

function BuffService:ApplyBuff(Buff,Amount)
	local SpecialActionBuffs = {
		AddedWalkSpeed = true;
		AddedJumpPower = true;
	}
	
	local LayerRefreshBuffs = {
		LayerLuck = true;
	}
	
	assert(self[Buff] ~= nil,`Attempted to add buff [{Buff}], which does not exist.`)
	
	if typeof(Amount) == "number" then
		self[Buff] += Amount
	else
		self[Buff] = Amount
	end
	
	self:CheckAssociatedValueInstances(Buff,Amount)
	
	if SpecialActionBuffs[Buff] then
		if Buff == "AddedWalkSpeed" then
			local Character = self.Player.Character
			local Humanoid = Character and Character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.WalkSpeed += Amount
				return true
			else
				self[Buff] -= Amount
				return false
			end
		elseif Buff == "AddedJumpPower" then
			local Character = self.Player.Character
			local Humanoid = Character and Character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.JumpPower += Amount
				
				return true
			else
				self[Buff] -= Amount
				return false
			end
			
		end
	end
	
	if LayerRefreshBuffs[Buff] then
		self.Layers.PersonalLayers[self.Player] = self.Layers:CreatePersonalLayers(self.Player,self["LayerLuck"])
	end
	
	return true
end

function BuffService:RemoveNormalBuff(BuffCause,RemovingElements)
	local BuffTable = self.BuffCauses[BuffCause] or {}
	
	local Cloned = table.clone(BuffTable)
	
	for Buff,Amount in pairs(BuffTable) do
		if not RemovingElements[Buff] then
			continue
		end
		
		RemovingElements[Buff] = nil
		
		if typeof(Amount) == "number" then
			local Applied = self:ApplyBuff(Buff,Amount*-1)
			BuffTable[Buff] = nil
		elseif typeof(Amount) == "boolean" then
			local Applied = self:ApplyBuff(Buff,not Amount)
			BuffTable[Buff] = nil
		end
	end
	
	if not next(BuffTable) then
		self.BuffCauses[BuffCause] = nil
	end
	
	self:SendPlayerBuffs()
end

function BuffService:GetBuffTable(BuffCause)
	local Table = self.BuffCauses[BuffCause]
	return Table and table.clone(Table) or {}
end

function BuffService:ApplyNormalBuff(BuffCause,BuffTable)
	assert(self.BuffCauses[BuffCause] == nil, `Attempted to apply [{BuffCause}] buffs, but they already exist!`)
	
	self.BuffCauses[BuffCause] = {}

	for Buff,Amount in pairs(BuffTable) do
		if typeof(Amount) == "number" then
			local Applied = self:ApplyBuff(Buff,Amount)
			if Applied then
				self.BuffCauses[BuffCause][Buff] = Amount
			end
		elseif typeof(Amount) == "boolean" then
			local Applied = self:ApplyBuff(Buff,Amount)
			if Applied then
				self.BuffCauses[BuffCause][Buff] = Amount
			end
		end
	end
	
	self:SendPlayerBuffs()
end

function BuffService:HasNormalBuff(BuffCause)
	return self.BuffCauses[BuffCause] ~= nil
end

function BuffService:Clean()
	setmetatable(self,nil)
	self = nil
end

return BuffService
