-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Info

$r$ stands for result.
]]
local Math = {}

--[[
$\pi$
π
You don't need more digits then this. Who do you think you are, NASA?
]]
Math.Pi = 3.141592653589793
--[[
$\tau$
τ
ibid.
]]
Math.Tau = 6.283185307179586
--[[
$\frac{\pi}{2}$
π/2
]]
Math.HalfPi = 1.5707963267948966
--[[
$\frac{1}{\tau}$
1/τ
]]
Math.InverseTau = 0.15915494309189535

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
	local w = (b - a) / n
	return w * Math.sum(1, n, function(i)
		return f(a + (i - 0.5) * w)
	end)
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
$\sqrt{n}=r$
√n=r
This is the only function where we do evil floating bit hacking. We promise.
]]
function Math.sqrt(n)
    local scratch = buffer.create(8)
    buffer.writef64(scratch, 0, n)
	local i = buffer.readu32(scratch, 4)
	buffer.writeu32(scratch, 4, 0x5FE6EB50 - bit32.rshift(i, 1)) -- what the fuck?
	local y = buffer.readf64(scratch, 0)
	return 1/(y * (1.5 - 0.5 * n * y * y))
end
--[[
$\sum_{i=a}^{b} f(i) = r$
ᵢ₌ₐΣᵇ f(i) = r
]]
function Math.sum(a, b, f)
	local r = 0
	for i = a, b do
		r += f(i)
	end
	return r
end
--[[
$\prod_{i=a}^{b} f(i) = r$
ᵢ₌ₐΠᵇ f(i) = r
]]
function Math.product(a, b, f)
	local r = 1
	for i = a, b do
		r *= f(i)
	end
	return r
end
--[[
$\lfloor n \rfloor = r$
⌊n⌋=r
]]
function Math.floor(n)
	return n - n % 1
end
--[[
$\sin(z) = \sum_{j=0}^{N} \frac{(-1)^{j} z^{2j+1}}{(2j+1)!}$
sin(z) = ᵢ₌₀Σᴺ ((-1)ʲ z²ʲ⁺¹)/(2j+1)!
https://en.wikipedia.org/wiki/Taylor_series#Trigonometric_functions
]]
function Math.sin(n)
	local t = n * Math.InverseTau
	local z = (t - Math.floor(t + 0.5)) * Math.Tau

	return Math.sum(0, 10, function(j)
		return Math.pow(-1, j) * Math.pow(z, 2 * j + 1) / Math.factorial(2 * j + 1)
	end)
end

return Math