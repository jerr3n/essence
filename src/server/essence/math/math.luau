-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Info

$r$ stands for result.
]]
local Math = {}

function Math.max(a, b)
    if a > b then
        return a 
    end
    if a < b then
        return b 
    end
end
function Math.min(a, b)
    if a > b then
        return b
    end
    if a < b then
        return a
    end
end
--[[
$\lvert n \rvert = r$
|n|=r
]]
function Math.abs(n)
    if n > 0 then
        return n
    end
    return n*-1
end
--[[
$x^{n} = r$
xⁿ=r
]]
function Math.pow(x, n)
    local r = 1
    for i = 1, n do
        r=r*x
    end
    return r
end
--[[
$n! = r$
n!=r
]]
function Math.factorial(n)
    local r = 1
    for i = 1, n do
        r=r*i
    end
    return r
end

--[[
$\int_{a}{b} x dx$
ₐ∫ᵇ f(x) dx = r
]]
function Math.integrate(f, a, b, n) 
    local w = (b-a)/n
    local r = 0
    for i = 1, n do
        r += f(b+((i+0.5)*w))
    end
    return r
end
--[[
$f'(n)=r$
f'(n)=r
]]
function Math.derive(f, n)
    local h = 6e-6 * Math.max(Math.abs(n), 1)
    return ((f(n+h)-f(n-h))/(2*h))
end
--[[
$\sqrt{n}$
√n
]]
function Math.sqrt(n)
    local scratch = buffer.create(8)
    buffer.writef64(scratch, 0, n)
	local i = buffer.readu32(scratch, 4) -- evil floating point bit level hacking
	buffer.writeu32(scratch, 4, 0x5FE6EB50 - bit32.rshift(i, 1)) -- what the funny?
	local y = buffer.readf64(scratch, 0)
	return y * (1.5 - 0.5 * n * y * y)
end

return Math