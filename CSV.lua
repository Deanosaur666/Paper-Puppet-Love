
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
        for column, value in ipairs(csv[i]) do
            tableData[i-1] = {}
            tableData[i-1][tableHeader[column]] = value

			--print("Index: " .. tableHeader[column] .. "; Value: "  .. tostring(value))
        end
    end

    return tableData
end


-- takes the converted CSV table and tries to turn it into a valid table of attacks
function ParseAttackTable(table, fighter)
	local stances = {}

	local myAttacks = {}

	
	-- we run through and catalog every stance existing in the sheet
	for row, line in ipairs(table) do
		if(line.ReqStances ~= nil and line.ReqStances ~= "") then
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
end

function tableContains(table, value)
  for i = 1,#table do
    if (table[i] == value) then
      return true
    end
  end
  return false
end