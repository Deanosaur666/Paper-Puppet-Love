
function SplitCSVLine(line)
	local values = {}

	for value in line:gmatch("[^,]+") do -- Note: We won't match empty values.
		-- Convert the value string to other Lua types in a "smart" way.
		if     tonumber(value)  then  table.insert(values, tonumber(value)) -- Number.
		elseif value == "true"  then  table.insert(values, true)            -- Boolean.
		elseif value == "false" then  table.insert(values, false)           -- Boolean.
		else                          table.insert(values, value)           -- String.
		end
	end

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
        end
    end

    return tableData
end