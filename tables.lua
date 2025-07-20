function stringsplit(inputstr, sep)
  sep = sep or "%s"
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function stringsplit2(line, sep)
  local front = 1
  local back = nil

  sep = sep or "%s"
  local t = {}

  repeat
      back = string.find(line, sep, front or 1)

      local str = string.sub(line, front, (back or 0)-1)
      table.insert(t, str)

      front = (back or front) + 1

  until back == nil

  return t
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

function stringjoin(t, sep)
    local str = ""
    for _, e in ipairs(t) do
        str = str .. tostring(e) .. sep
    end

    return string.sub(str, 1, -2)
end

function tableNextIndex(index, table)
  return (index % #table) + 1
end

function tablePrevIndex(index, table)
  return ((index - 2) % #table) + 1
end

function tableChangeIndex(index, table, d)
  return ((index - 1 + d) % #table) + 1
end

function fillArray(t, val, len)
  len = len or #t
  while(#t < len) do
    table.insert(t, val)
  end

  for i, _ in ipairs(t) do
    t[i] = val
  end
  return t
end

function tableMerge(t1, t2)
  t2 = t2 or {}
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

json = require "json"

function jsonDecodeFile(filename)
    if(love.filesystem.getInfo(filename) == nil) then
        return nil
    end
    local str = ""
    for line in love.filesystem.lines(filename) do
        str = str .. line
    end

    return json.decode(str)
end

function jsonEncodeFile(t, filename)
  local text = json.encode(t)
  local file = io.open(filename, "w")

  file:write(text)

  io.close(file)
end

-- doesn't handle recursive table, but why use those????
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end