local Bin = {}

function Bin.fromWords(lo, hi)
    local buf = buffer.create(8)
    buffer.writeu32(buf, 0, lo)
    buffer.writeu32(buf, 4, hi)
    return buffer.readf64(buf, 0)
end

return Bin