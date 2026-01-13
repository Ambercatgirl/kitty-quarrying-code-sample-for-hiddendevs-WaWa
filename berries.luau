local Rand = Random.new(tick()*(math.random(1,1000)/555))
local RunService = game:GetService("RunService")
local BuffApplier = require(script.Parent.Parent.BuffApplier)

local module = {}

module.BerryId = 0

module.Berries = {
	[1] = {
		Chance = 50;
		Buffs = {
			["AllRate"] = 250;
			["LayerLuck"] = 100;
		};
		Duration = 30;
	};
	[2] = {
		Chance = 40;
		Buffs = {
			["PickaxeRate"] = 400;
			["CaveExclusiveLuck"] = 200;
		};
		Duration = 30;
	};
	[3] = {
		Chance = 30;
		Buffs = {
			["CaveOreLuck"] = 200;
			["CaveTypeLuck"] = 200;
		};
		Duration = 45;
	};
	[4] = {
		Chance = 20;
		Buffs = {
			["AllRate"] = 50;
			["LayerLuck"] = 25;
		};
		Duration = 60;
	};
	[5] = {
		Chance = 15;
		Buffs = {
			["AddedWalkSpeed"] = 10;
			["AddedJumpPower"] = 10;
			["LayerLuck"] = 50;
		};
		Duration = 20;
	};
	[6] = {
		Chance = 10;
		Buffs = {
			["CaveExclusiveLuck"] = 50;
			["CaveTypeLuck"] = 50;
		};
		Duration = 20;
	};
	[7] = {
		Chance = 5;
		Buffs = {
			["AddedWalkSpeed"] = 5;
			["AddedJumpPower"] = 5;
			["GearRate"] = 100;
		};
		Duration = 25;
	};
	[8] = {
		Chance = 1;
		Buffs = {
			["AllRate"] = 50;
			["LayerLuck"] = 50;
			["AddedWalkSpeed"] = 3;
			["AddedJumpPower"] = 3;
		};
		Duration = 15;
	};
}

function module.GetBerry()
	for _,Berry in pairs(module.Berries) do
		if Rand:NextInteger(1,Berry.Chance) == Berry.Chance then
			return Berry
		end
	end
	
end

function module.BerryMined(Player : Player, BuffService)
	local Berry = module.GetBerry()
	
	module.BerryId += 1
	local ThisId =`ChertBerry_{tostring(module.BerryId)}`
	
	local Character = Player.Character
	local Humanoid : Humanoid = Character and Character:FindFirstChild("Humanoid")
	
	if not Humanoid then
		return
	end
	
	local HDC
	HDC = Humanoid.Died:Once(function()
		BuffService:RemoveNormalBuff(ThisId,{
			["AddedJumpPower"] = true;
			["AddedWalkSpeed"] = true;
		})
	end)
	
	local NewBerryTable = {
		Duration = Berry.Duration;
		Buffs = table.clone(Berry.Buffs);
		BuffService = BuffService;
		TickedTime = 0;
		DeathConnection = HDC;
	}
	
	BuffService:ApplyNormalBuff(ThisId,NewBerryTable.Buffs)
	BuffApplier.ActiveBuffs[ThisId] = NewBerryTable
end

return module
