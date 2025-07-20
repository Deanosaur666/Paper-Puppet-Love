
function SplitCSVLine(line)
	local values = {}

	values = stringsplit3(line, ",", true)

	return values
end

function stringsplit3(line, sep, parse)
	local front = 1
	local back = nil

	sep = sep or "%s"
	local t = {}

	parse = parse or false

	local index = 1

	repeat
		back = string.find(line, sep, front or 1)

		local str = string.sub(line, front, (back or 0)-1)
		local val = str
		--table.insert(t, str)
		if(parse) then
			if(tonumber(str)) then
				val = tonumber(str)
			elseif(str == "") then
				val = nil
			elseif(string.lower(str) == "false") then
				val = false
			elseif(string.lower(str) == "true") then
				val = true
			end
		end

		t[index] = val

		front = (back or front) + 1

		index = index + 1
	until back == nil

	return t
end

function LoadCSVFile(filename)
	local csv = {}
	for line in love.filesystem.lines(filename) do
        
		table.insert(csv, SplitCSVLine(line))
		--table.insert(csv, stringsplit2(line, ","))
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