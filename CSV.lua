
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

			print("Index: " .. tableHeader[column] .. "; Value: "  .. tostring(value))
        end
    end

    return tableData
end


-- takes the converted CSV table and tries to turn it into a valid table of attacks
function ParseAttackTable(table, fighter)
	local stances = {}
	local lastFighterRow = nil

	local myAttacks = {}

	
	
	for row, line in ipairs(table) do
		if(line.FighterIndex == fighter and lastFighterRow == nil) then
			lastFighterRow = line.FighterIndex
		elseif(line.FighterIndex ~= nil) then

		end

	end
end