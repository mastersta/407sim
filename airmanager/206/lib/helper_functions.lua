--helper functions
function numtobool(input)
  if input == 0 then return false
  else return true
  end
end

function booltonum(input)
  if input then return 1
  else return 0
  end
end

function bitread(value, bit)
  return ((value >> (bit - 1)) & 1)
end

function bitwrite(input, bit, write)
  if (write > 0) then
    return input | (1 << (bit - 1))
  else
    return input & ~(1 << (bit - 1))
  end
end

function array_compare(array1, array2)
  for i,v in pairs(array1) do
    if v ~= array2[i] then
      return false
    end
  end
  return true
end

function table.clone(input)
  return {table.unpack(input)}
end
