-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Info

$r$ stands for result.
]]
local Math = {}
local Vector = {}
local Matrix = {}
Math.Vector = Vector
Math.Matrix = Matrix

--[[
$\sqrt{n}=r$
√n=r
This is the only function where we do evil floating bit hacking. We promise.
https://en.wikipedia.org/wiki/Fast_inverse_square_root#Overview_of_the_code
]]
function Math.sqrt(n)
    local scratch = buffer.create(8)
    buffer.writef64(scratch, 0, n)
	local i = buffer.readu32(scratch, 4)
	buffer.writeu32(scratch, 4, 0x5FE6EB50 - bit32.rshift(i, 1))
	local y = buffer.readf64(scratch, 0)
	return 1/(y * (1.5 - 0.5 * n * y * y))
end

--- Constants

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
Math.Tau = 2*Math.Pi
--[[
$\frac{\pi}{2}$
π/2
]]
Math.HalfPi = 0.5*Math.Pi
--[[
$\frac{\pi}{4}$
π/4
]]
Math.QuarterPi = 0.5*Math.HalfPi
--[[
$\frac{1}{\tau}$
1/τ
]]
Math.InverseTau = 1/Math.Tau
--[[
$\sqrt{3}$
√3
]]
Math.RootThree = Math.sqrt(3)
---
function Math.max(a, b)
    if a > b then
        return a 
    end
    if a < b then
        return b 
    end
    return a
end
function Math.min(a, b)
    if a > b then
        return b
    end
    if a < b then
        return a
    end
    return a

end
function Math.clamp(n, a, b)
    return Math.min(Math.max(n,a),b)
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
$\sum_{i=0}^{N} c_{i}n^{i} = r$
ᵢ₌₀Σᴺ cᵢnⁱ = r
Horner's method: c₀+n(c₁+n(c₂+⋯)). c ascends, so c[1] is the constant term.
https://en.wikipedia.org/wiki/Horner%27s_method
]]
function Math.horner(n, c)
	local r = c[#c]
	for i = #c - 1, 1, -1 do
		r = c[i] + n*r
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
--[[
$\cos(\Theta)=\sin(\Theta+\frac{\pi}{2})$
cos(Θ)=cos(Θ+(π/2))
]]
function Math.cos(n)
    return Math.sin(n+Math.HalfPi)
end
--[[
$\tan(\Theta)=\frac{\sin(\Theta)}{\cos(\Theta)}$
tan(Θ)=(sin(Θ)/cos(Θ))
]]
function Math.tan(n)
    return Math.sin(n)/Math.cos(n)
end
--[[
$\csc(\Theta)=\frac{1}{\sin(\Theta)}$
csc(Θ)=1/sin(Θ)
]]
function Math.csc(n)
    return 1/Math.sin(n)
end
--[[
$\cot(\Theta)=\frac{1}{\tan(\Theta)}$
cot(Θ)=1/tan(Θ)
]]
function Math.cot(n)
    return 1/Math.tan(n)
end
--[[
Coefficients for atan's Gregory series on |n| ≤ 0.4375: aT[i] = (-1)ⁱ/(2i+3),
where aT[i] multiplies z^(i+1). They are split into the even- and odd-indexed
halves so that each is a polynomial in w = z², which is how the sum is evaluated
below. 20 terms is the floor for 1 ulp — 17 gives 22 ulp, 14 gives 3654.
fdlibm reaches the same accuracy in 11 terms, but only by using fitted minimax
coefficients, which have no closed form and so cannot be built at runtime.
]]
local AtanEven, AtanOdd = {}, {}
for i = 0, 19 do
    if i % 2 == 0 then
        table.insert(AtanEven, Math.pow(-1, i)/(2*i + 3))
    else
        table.insert(AtanOdd, Math.pow(-1, i)/(2*i + 3))
    end
end
--[[
$\arctan(n)=r$ for $\lvert n \rvert \leq \frac{7}{16}$
arctan(n)=r for |n|≤7/16
The series evaluated directly, with no argument reduction. Subtracting from n
before anything larger is added is what keeps the whole function under 1 ulp:
the two nearly equal terms cancel first.
]]
local function atanCore(n)
    local z = n*n
    local w = z*z
    return n - n*(z*Math.horner(w, AtanEven) + w*Math.horner(w, AtanOdd))
end
--[[
Reduction endpoints: arctan of 1/2, 1, 3/2, ∞. atan's addition formula,
$\arctan(a)+\arctan(b)=\arctan(\frac{a+b}{1-ab})$, reaches the first and
third from arguments below 7/16:
    arctan(1/2) = arctan(1/3) + arctan(1/7)
    arctan(3/2) = arctan(1)   + arctan(1/5)
Those arguments are served by atanCore, which never consults this table, so
there is no circularity. Both land on the correctly rounded double.
]]
local AtanHi = {
    atanCore(1/3) + atanCore(1/7),
    Math.QuarterPi,
    Math.QuarterPi + atanCore(1/5),
    Math.HalfPi,
}
--[[
$\arctan(n)=r$
arctan(n)=r
Accurate to 1 ulp over all finite n, measured against a correctly rounded
reference. n is reduced onto [0,7/16] by atan's addition formula, then the
series is summed there. The interval scheme and its breakpoints follow fdlibm's
s_atan.c; its minimax coefficients are not used here.
https://svnweb.freebsd.org/base/head/lib/msun/src/s_atan.c?view=markup
]]
function Math.atan(n)
    if Math.isNan(n) then
        return n
    end

    local x = Math.abs(n)
    local id
    if x >= 2^66 then
        -- -1/n underflows past here, so the reduction is exactly arctan(∞).
        return Math.sign(n)*Math.HalfPi
    elseif x < 0.4375 then
        if x < 2^-27 then
            return n -- arctan(n) rounds to n
        end
        return atanCore(n) -- the signed value is used directly
    elseif x < 0.6875 then
        id, x = 1, (2*x - 1)/(2 + x)
    elseif x < 1.1875 then
        id, x = 2, (x - 1)/(x + 1)
    elseif x < 2.4375 then
        id, x = 3, (x - 1.5)/(1 + 1.5*x)
    else
        id, x = 4, -1/x
    end

    local r = AtanHi[id] + atanCore(x)
    if n < 0 then
        return -r
    end
    return r
end

function Math.sign(n) 
    if n == 0 then
        return 0
    end
    if n > 0 then
        return 1
    end
    return -1
end
function Math.isNan(n)
    return n ~= n
end

function Vector.add(a, b)
    return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)
end

function Vector.subtract(a, b)
    return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)
end

function Vector.sMult(s, v)
    return Vector3.new(s*v.X,s*v.Y,s*v.Z)
end

function Vector.sDiv(s, v)
    return Vector3.new(v.X/s,v.Y/s,v.Z/s)
end

function Vector.dot(a, b)
    return (a.X*b.X)+(a.Y*b.Y)+(a.Z*b.Z)
end
function Vector.magnitude(v)
    return Math.sqrt((v.X^2)+(v.Y^2)+(v.Z^2))
end
function Vector.normalize(v)
    return Vector.sDiv(v, Vector.magnitude(v))
end
--[[
$\operatorname{proj}_n(v)=\frac{v \cdot n}{n \cdot n}n$
proj_n(v)=((v·n)/(n·n))n
]]
function Vector.project(v, n)
    return Vector.sMult(Vector.dot(v, n) / Vector.dot(n, n), n)
end
--[[
$\operatorname{rej}_n(v)=v-\operatorname{proj}_n(v)$
rej_n(v)=v-proj_n(v)
]]
function Vector.reject(v, n)
    return Vector.subtract(v, Vector.project(v, n))
end
return Math