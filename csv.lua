-- CSV  Functions 

-- keys is a list of the values, in order, for the table's values. Saving/loading should use the same list of keys
-- If you don't provide a key in the list of keys, that value isn't getting saved!!
function WriteCSVStructs(structs, keys, fileName)
    
    local file = love.filesystem.newFile(fileName)
    file:open("w")

    for _, s in pairs(structs) do
        local line = ""
        for _, k in ipairs(keys) do
            line = line .. tostring(s[k]) .. ","
        end
        file:write(line .. "\n")
    end

    --file:write(FILE_END_STRING)
    
    file:close()
end

function ReadCSV_Structs(keys, fileName)
    local csv = LoadCSVFile(fileName)
    local structs = {}
    for _,line in ipairs(csv) do
        local struct = {}
        for index,value in ipairs(line) do
            struct[keys[index]] = value
        end
        table.insert(structs, struct)
    end

    return structs
end

function SplitCSVLine(line)
	local values = {}

	for value in line:gmatch("[^,]+") do -- Note: We won't match empty values.
		-- Convert the value string to other Lua types in a "smart" way.
		if tonumber(value) then
            table.insert(values, tonumber(value)) -- Number.
		elseif value == "true"  then
            table.insert(values, true)            -- Boolean.
		elseif value == "false" then
            table.insert(values, false)           -- Boolean.
		else
            table.insert(values, value)           -- String.
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
