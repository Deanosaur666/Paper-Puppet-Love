
function SplitCSVLine(line)
	local values = {}

	values = stringsplit(line, ",", true)

	return values
end

function LoadCSVFile(filename)
	local csv = {}
	for line in love.filesystem.lines(filename) do
        
		table.insert(csv, SplitCSVLine(line))
	end
	return csv
end

function LoadCSVTable(filename)
    local csv = LoadCSVFile(filename)
    local tables = CSVToTables(csv)

    return tables
end

function CSVToTables(csv)
    -- first line is assumed to be the header, and have names of table values

    -- fix this....

    local tableHeader = csv[1]
    local tableData = {}
    for i = 2, #csv, 1 do
		tableData[i-1] = {}
        for column, value in ipairs(csv[i]) do
            tableData[i-1][tableHeader[column]] = value

			--print("Index: " .. tableHeader[column] .. "; Value: "  .. tostring(value))
        end
    end

    return tableData
end


ButtonByName = {}
ButtonByName[""] = 0
ButtonByName["a"] = BUTTON_A
ButtonByName["b"] = BUTTON_B
ButtonByName["s"] = BUTTON_S

ButtonByName["up"] = BUTTON_UP
ButtonByName["upright"] = BUTTON_UPRIGHT
ButtonByName["right"] = BUTTON_RIGHT
ButtonByName["downright"] = BUTTON_DOWNRIGHT
ButtonByName["down"] = BUTTON_DOWN
ButtonByName["downleft"] = BUTTON_DOWNLEFT
ButtonByName["left"] = BUTTON_LEFT
ButtonByName["upleft"] = BUTTON_UPLEFT

AttackLevelByName = {}
AttackLevelByName["light"] = ATTACK_LIGHT
AttackLevelByName["medium"] = ATTACK_MEDIUM
AttackLevelByName["heavy"] = ATTACK_HEAVY
AttackLevelByName["superheavy"] = ATTACK_SUPERHEAVY
AttackLevelByName["special"] = ATTACK_SPECIAL
AttackLevelByName["ex"] = ATTACK_EX
AttackLevelByName["super"] = ATTACK_SUPER

-- takes the converted CSV table and tries to turn it into a valid table of attacks
function ParseAttackTable(t, fighter)
	local stances = {}

	local myAttacks = {}

	
	-- we run through and catalog every stance existing in the sheet
	for row, line in ipairs(t) do
		print(row)
		print(line.Name)
		if(line.ReqStances ~= nil and line.ReqStances ~= "") then
			print(line.ReqStances)
			local stanceFrom = stringsplit(line.ReqStances, ";", true, true)
			print(stanceFrom)
			for _, sf in ipairs(stanceFrom) do
				if(not tableContains(stances, sf)) then
					table.insert(stances, sf)
				end
			end
		end
		

		if(line.Stances ~= nil and line.Stances ~= "") then
			local stanceTo =  stringsplit(line.Stances, ";", true, true)
			for _, st in ipairs(stanceTo) do
				if(not tableContains(stances, st)) then
					table.insert(stances, st)
				end
			end
		end
		
	end

	print("Stances...")
	for index, value in ipairs(stances) do
		print("Stance: " .. value)
	end

	-- global "stances"
	local gStances = {}
	gStances["idle"] = STATE_IDLE

	
	-- TODO: ReqStateFlags?

	-- now we get to the attacks
	for row, line in ipairs(t) do
		if(line.Name ~= "" and line.Animation ~= "") then

			local button = ButtonByName[string.lower(line.ButtonHeld)]
			local attackLevel = AttackLevelByName[string.lower(line.AttackLevel)]

			local atk = AddAttack(fighter, line.Name, line.Animation, ButtonByName[string.lower(line.ButtonPressed)], 
				button, line.Power, attackLevel, {})

			atk.Startup = line.Startup
			atk.Active = line.Active
			atk.Recovery = line.Recovery

			atk.FollowupFrom = line.FollowupFrom

			-- todo: parse stances


			---------
			if(line.AnimLoop ~= "") then
				atk.AnimLoop = line.AnimLoop
			end
			if(line.AnimSpeed ~= "") then
				atk.AnimSpeed = line.AnimSpeed
			end
			if(line.AnimStart ~= "") then
				atk.AnimStart = line.AnimStart
			end
			if(line.AnimEnd ~= "") then
				atk.AnimEnd = line.AnimEnd
			end

			if(line.StepStart == "") then
				atk.StepStart = 1 -- frame 0 will be skipped...
			else
				atk.StepStart = line.StepStart
			end

			if(line.StepDistance == "") then
				atk.StepDistance = 0
			else
				atk.StepDistance = line.StepDistance
			end
		end
	end

	--[[
	local jab = AddAttack(kit, "Jab", "Punch", BUTTON_A, 0, 1, ATTACK_LIGHT, {
    StateFlags = SetStateAttackLevel(0, 1),
    ReqStateFlags = STATE_CANATTACK,
    Startup = 8,
    Active = 3,
    Recovery = 10, -- 3 fake recovery frames?
	})
]]
end

function tableContains(table, value)
  for i = 1,#table do
    if (table[i] == value) then
      return true
    end
  end
  return false
end