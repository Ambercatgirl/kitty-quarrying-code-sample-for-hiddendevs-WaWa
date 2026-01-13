local Rand = Random.new(tick()*(math.random(1,1000)/555))
local RunService = game:GetService("RunService")
local BuffApplier = require(script.Parent.Parent.BuffApplier)

local module = {}

module.StarId = 0

module.Stars = {
	[1] = {
		Chance = 25;
		Buffs = {
			["CaveExclusiveLuck"] = 200;
			["CaveOreLuck"] = 200;
			["CaveTypeLuck"] = 200;
		};
		Duration = 60;
	};
	[2] = {
		Chance = 20;
		Buffs = {
			["LayerLuck"] = 300;
			["CaveExclusiveLuck"] = 300;
		};
		Duration = 30;
	};
	[3] = {
		Chance = 15;
		Buffs = {
			["AllRate"] = 250;
			["CaveTypeLuck"] = 250;
		};
		Duration = 45;
	};
	[4] = {
		Chance = 10;
		Buffs = {
			["GearRate"] = 150;
			["LayerLuck"] = 150;
		};
		Duration = 60;
	};
	[5] = {
		Chance = 7;
		Buffs = {
			["AddedWalkSpeed"] = 5;
			["AddedJumpPower"] = 5;
			["LayerLuck"] = 100;
		};
		Duration = 25;
	};
	[6] = {
		Chance = 5;
		Buffs = {
			["AddedWalkSpeed"] = 4;
			["AddedJumpPower"] = 4;
			["CaveExclusiveLuck"] = 100;
		};
		Duration = 25;
	};
	[7] = {
		Chance = 3;
		Buffs = {
			["AddedWalkSpeed"] = 3;
			["AddedJumpPower"] = 3;
			["CaveOreLuck"] = 100;
		};
		Duration = 25;
	};
	[8] = {
		Chance = 1;
		Buffs = {
			["AddedWalkSpeed"] = 2;
			["AddedJumpPower"] = 2;
			["CaveTypeLuck"] = 100;
		};
		Duration = 25;
	};
}

function module.GetBerry()
	for _,Star in pairs(module.Stars) do
		if Rand:NextInteger(1,Star.Chance) == Star.Chance then
			return Star
		end
	end
	
end

function module.StarMined(Player : Player, BuffService)
	local Star = module.GetBerry()
	
	module.StarId += 1
	local ThisId = `SingularityStar_{tostring(module.StarId)}`
	
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
	
	local NewStarTable = {
		Duration = Star.Duration;
		Buffs = table.clone(Star.Buffs);
		BuffService = BuffService;
		TickedTime = 0;
		DeathConnection = HDC;
	}
	
	BuffService:ApplyNormalBuff(ThisId,NewStarTable.Buffs)
	BuffApplier.ActiveBuffs[ThisId] = NewStarTable
end

return module
