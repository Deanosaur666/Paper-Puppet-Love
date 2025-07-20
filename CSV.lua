
function SplitCSVLine(line)
	local values = {}

	--[[
	for value in line:gmatch("[^,]+") do -- Note: We won't match empty values.
		-- Convert the value string to other Lua types in a "smart" way.
		if     tonumber(value)  then  table.insert(values, tonumber(value)) -- Number.
		elseif value == "true"  then  table.insert(values, true)            -- Boolean.
		elseif value == "false" then  table.insert(values, false)           -- Boolean.
		else                          table.insert(values, value)           -- String.
		end
	end
	]]
	local startIndex = 1
	local nextComma = nil
	repeat
		nextComma = string.find(line, ",", startIndex+1 or 1)
		print("Next Comma" .. tostring(nextComma))

		if(nextComma ~= nil and nextComma > startIndex) then
			local str = string.sub(line, startIndex, nextComma-1)
			if (tonumber(str))  then 
				table.insert(values, tonumber(str)) -- Number.
			elseif (str == "true")  then
				table.insert(values, true)            -- Boolean.
			elseif (str == "false") then
				table.insert(values, false)           -- Boolean.
			elseif(str == "") then
				table.insert(values, nil)
			elseif(str == ",") then
				table.insert(values, nil)
				--startIndex = startIndex - 1
			else
				table.insert(values, str)           -- String.
			end

			startIndex = nextComma + 1
		else
			nextComma = nil
		end

	until nextComma == nil

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