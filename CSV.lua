
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






-- takes the converted CSV table and tries to turn it into a valid table of attacks
function ParseAttackTable(t, fighter)
	-- we don't actually uses "stances" anymore...
	
	--[[
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
	--]]
	
	-- TODO: ReqStateFlags?

	-- function for parsing basic shit with defaults
	local defSet = function (atk, line, key, def)
		if(def == nil) then
			def = 0
		end
		if(line[key] ~= "") then
			atk[key] = line[key]
		else
			atk[key] = def
		end
	end

	-- now we get to the attacks
	for row, line in ipairs(t) do
		if(line.Name ~= "" and line.Animation ~= "") then

			local button = ButtonByName[string.lower(line.ButtonHeld)]
			local attackLevel = AttackLevelByName[string.lower(line.Level)]
			if(attackLevel == nil) then
				print("No attack level...")
				print(line.Level)
				print(tostring(AttackLevelByName["light"]))
			end

			--print(string.lower(line.Level))
			--print(attackLevel)
			local atk = AddAttack(fighter, line.Name, line.Animation, ButtonByName[string.lower(line.ButtonPressed)], 
				button, line.Power, attackLevel, {})

			defSet(atk, line, "Startup")
			defSet(atk, line, "Active")
			defSet(atk, line, "Recovery")

			-- todo: parse if trigger is an array in csv and then use it for tstart,tend

			local tArgs = stringsplit(line.Trigger, ":", true)
			
			atk.Trigger = tArgs[1]
			atk.TriggerStart = tArgs[2] or 0
			atk.TriggerEnd = tArgs[3] or -1
			
			atk.TriggerFrom = line.TriggerFrom


			

			-- todo: parse stances


			
			
			defSet(atk, line, "AnimLoop", false)
			defSet(atk, line, "AnimSpeed", 1)
			defSet(atk, line, "AnimStart", 0)
			defSet(atk, line, "AnimEnd", -1)

			--[[
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
			--]]

			defSet(atk, line, "StepStart", 1)
			defSet(atk, line, "StepDistance")
			defSet(atk, line, "JumpHeight")

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