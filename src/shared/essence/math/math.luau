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
$\frac{\pi}{4}$
π/2
]]
Math.QuarterPi = 0.7853981633974483
--[[
$\frac{1}{\tau}$
1/τ
]]
Math.InverseTau = 0.15915494309189535
Math.PiLo = 1.2246467991473531772e-16
--[[
A value that is not equal to itself. Use Math.isNan to test for it.
]]
Math.NaN = 0 / 0
--[[
$\sqrt{2}$
√2
]]
Math.Sqrt2 = 1.4142135623730951

local atanhi = {
	4.63647609000806093515e-01,
	7.85398163397448278999e-01,
	9.82793723247329054082e-01,
	1.57079632679489655800e+00,
}

local atanlo = {
	2.26987774529616870924e-17,
	3.06161699786838301793e-17,
	1.39033110312309984516e-17,
	6.12323399573676603587e-17,
}

local aT = {
	3.33333333333329318027e-01,
	-1.99999999998764832476e-01,
	1.42857142725034663711e-01,
	-1.11111104054623557880e-01,
	9.09088713343650656196e-02,
	-7.69187620504482999495e-02,
	6.66107313738753120669e-02,
	-5.83357013379057348645e-02,
	4.97687799461593236017e-02,
	-3.65315727442169155270e-02,
	1.62858201153657823623e-02,
}

Math.Inf = 1/0

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
	assert(a <= b, "minimum must be less than or equal to maximum")
	return Math.min(Math.max(n, a), b)
end
--[[
$\lvert n \rvert = r$
|n|=r
]]
function Math.abs(n)
	if n > 0 then
		return n
	end
	return n * -1
end

--[[
Returns true when n is NaN.
]]
function Math.isNan(n)
	return n ~= n
end

--[[
Returns true when n is positive or negative infinity.
]]
function Math.isInf(n)
	return n == Math.Inf or n == -Math.Inf
end

--[[
$x^{n} = r$
xⁿ=r
]]
function Math.pow(x, n)
	return x ^ n
end
--[[
$n! = r$
n!=r
]]
function Math.factorial(n)
	assert(n >= 0 and n % 1 == 0, "n must be a non-negative integer")
	local r = 1
	for i = 1, n do
		r = r * i
	end
	return r
end
--[[
$\int_{a}^{b} f(x)\,dx=r$
ₐ∫ᵇ f(x) dx = r
Uses n equal-width midpoint samples. If f is twice differentiable, the absolute
error is at most |b-a|³ max|f''(x)|/(24n²) on the interval between a and b.
https://en.wikipedia.org/wiki/Midpoint_method
]]
function Math.integrate(f, a, b, n)
	assert(n > 0 and n % 1 == 0, "n must be a positive integer")
	local w = (b - a) / n
	return w * Math.sum(1, n, function(i)
		return f(a + (i - 0.5) * w)
	end)
end
--[[
$f'(n)=r$
f'(n)=r
Uses a central difference with h=6×10⁻⁶ max(|n|,1). If f is three times
differentiable, the truncation error is at most h² max|f'''(x)|/6 on [n-h,n+h].
This bound does not include floating-point roundoff.
https://en.wikipedia.org/wiki/Finite_difference#Central_finite_difference
]]
function Math.derive(f, n)
	local h = 6e-6 * Math.max(Math.abs(n), 1)
	return (f(n + h) - f(n - h)) / (2 * h)
end
--[[
$\sqrt{n}=r$
√n=r
The relative error is at most 2×10⁻¹⁵ for positive, finite IEEE-754 doubles.
The function returns NaN for n<0. It supports zero, infinity, and subnormal values.
https://en.wikipedia.org/wiki/Methods_of_computing_square_roots
]]
function Math.sqrt(n)
	if Math.isNan(n) then
		return n
	end
	if n < 0 then
		return Math.NaN
	end
	if n == 0 or n == Math.Inf then
		return n
	end

	-- An even exponent keeps e//2 exact. It puts m in [0.5,2), and not in the
	-- [0.5,1) range that Math.frexp gives.
	local m, e = Math.frexp(n)
	if e % 2 ~= 0 then
		m *= 2
		e -= 1
	end

	-- The seed is the minimax quadratic fit of 1/√m on [0.5,2). Its relative
	-- error is at most 2.5×10⁻². See calculate-constants.py.
	local y = 1.88856581 + m * (-1.16154897 + m * 0.28966061)
	-- Each Newton step for 1/√m squares the relative error, so four steps bring
	-- it to 4×10⁻¹⁶.
	for _ = 1, 4 do
		y = y * (1.5 - 0.5 * m * y * y)
	end

	-- m*y is √m. The last step is Newton for √m, and not for 1/√m, because the
	-- reciprocal form cannot remove the error of the multiplication by m.
	local r = m * y
	r = 0.5 * (r + m / r)

	return r * 2 ^ (e // 2)
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
	if n == 1 / 0 or n == -1 / 0 then
		return n
	end
	return n - n % 1
end
--[[
$\sin(z) = \sum_{j=0}^{N} \frac{(-1)^{j} z^{2j+1}}{(2j+1)!}$
sin(z) = ᵢ₌₀Σᴺ ((-1)ʲ z²ʲ⁺¹)/(2j+1)!
For |n|≤π, the absolute error is at most 1.1×10⁻¹¹. Range reduction
causes more floating-point error as |n| increases. The input is in radians.
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
cos(Θ)=sin(Θ+(π/2))
For |n|≤π, the absolute error is at most 1.1×10⁻¹¹. Range reduction
causes more floating-point error as |n| increases. The input is in radians.
]]
function Math.cos(n)
	return Math.sin(n + Math.HalfPi)
end
--[[
$\tan(\Theta)=\frac{\sin(\Theta)}{\cos(\Theta)}$
tan(Θ)=(sin(Θ)/cos(Θ))
The input is in radians. No finite uniform error bound exists near the poles.
]]
function Math.tan(n)
	return Math.sin(n) / Math.cos(n)
end
--[[
$\csc(\Theta)=\frac{1}{\sin(\Theta)}$
csc(Θ)=1/sin(Θ)
The input is in radians. No finite uniform error bound exists near the poles.
]]
function Math.csc(n)
	return 1 / Math.sin(n)
end
--[[
$\cot(\Theta)=\frac{1}{\tan(\Theta)}$
cot(Θ)=1/tan(Θ)
The input is in radians. No finite uniform error bound exists near the poles.
]]
function Math.cot(n)
	return 1 / Math.tan(n)
end

local huge = 2 ^ 66
local tiny = 2 ^ -27

--[[
$\arctan(n)=r$
atan(n)=r
The absolute error is at most 3×10⁻¹⁶ radians for finite IEEE-754 doubles.
This implementation uses argument reduction and the fdlibm odd polynomial.
https://netlib.org/fdlibm/e_atan.c
]]
function Math.atan(n)
	local an = Math.abs(n)
	local id
	local t

	if Math.isNan(n) then
		return n
	end
	if an >= huge then
		local r = atanhi[4] + atanlo[4]
		if n < 0 then
			return -r
		else
			return r
		end
	end
	if an < 0.4375 then
		if an < tiny then
			return n
		end
		id = -1
		t = n
	elseif an < 0.6875 then
		id, t = 1, (2 * an - 1) / (2 + an)
	elseif an < 1.1875 then
		id, t = 2, (an - 1) / (an + 1)
	elseif an < 2.4375 then
		id, t = 3, (an - 1.5) / (1 + 1.5 * an)
	else
		id, t = 4, -1 / an
	end
	local z = t * t
	local w = z * z
	local s1 = z * (aT[1] + w * (aT[3] + w * (aT[5] + w * (aT[7] + w * (aT[9] + w * aT[11])))))
	local s2 = w * (aT[2] + w * (aT[4] + w * (aT[6] + w * (aT[8] + w * aT[10]))))
	if id < 0 then
		return t - t * (s1 + s2)
	end
	z = atanhi[id] - ((t * (s1 + s2) - atanlo[id]) - t)
	if n < 0 then
		return -z
	end
	return z
end

function Math.atan2(y, x)
	if Math.isNan(x) or Math.isNan(y) then
		return x + y
	end

	if x == 1 then
		return Math.atan(y)
	end

	local m = (if y < 0 then 1 else 0) + (if x < 0 then 2 else 0)

	if y == 0 then
		if m == 0 or m == 1 then
			return y
		elseif m == 2 then
			return Math.Pi
		else
			return -Math.Pi
		end
	end

	if x == 0 then
		return if y < 0 then -Math.HalfPi else Math.HalfPi
	end

	if x == Math.Inf or x == -Math.Inf then
		if y == Math.Inf or y == -Math.Inf then
			if m == 0 then
				return Math.QuarterPi
			elseif m == 1 then
				return -Math.QuarterPi
			elseif m == 2 then
				return 3 * Math.QuarterPi
			else
				return -3 * Math.QuarterPi
			end
		else
			if m == 0 then
				return 0
			elseif m == 1 then
				return -0
			elseif m == 2 then
				return Math.Pi
			else
				return -Math.Pi
			end
		end
	end

	if y == Math.Inf or y == -Math.Inf then
		return if y<0 then -Math.HalfPi else Math.HalfPi
	end

	local _, ey = Math.frexp(y)
	local _, ex = Math.frexp(x)
	local k = ey - ex

	local z
	if k > 60 then
		z = Math.HalfPi + 0.5 * Math.PiLo
	elseif x<0 and k < -60 then
		z = 0
	else
		z = Math.atan(Math.abs(y / x))
	end

	if m == 0 then
		return z
	elseif m == 1 then
		return -z
	elseif m == 2 then
		return Math.Pi - (z - Math.PiLo)
	else
		return (z - Math.PiLo) - Math.Pi
	end
end

--[[
$a \times b = r$
a × b = r
Returns a Vector3. This is the only function that builds a Roblox value, so it
is the only function that Lune cannot run.
https://en.wikipedia.org/wiki/Cross_product
]]
function Math.cross(a, b)
	return Vector3.new(
		(a.Y * b.Z) - (a.Z * b.Y),
		(a.Z * b.X) - (a.X * b.Z),
		(a.X * b.Y) - (a.Y * b.X)
	)
end

--[[
$n = m \times 2^{e}$
n = m × 2ᵉ
Returns the mantissa m and the exponent e, where 0.5 <= |m| < 1.
Zero, NaN, and infinity return the input and an exponent of 0.
https://en.wikipedia.org/wiki/C_mathematical_functions#frexp
]]
function Math.frexp(n)
	-- The guard tests Math.Inf, and not the local huge. huge is 2^66, which is
	-- the argument reduction threshold of Math.atan, and a finite input here.
	if n == 0 or n ~= n or n == Math.Inf or n == -Math.Inf then
		return n, 0
	end

	local e = 0
	if Math.abs(n) < 2.2250738585072014e-308 then
		n *= 2 ^ 54
		e = -54
	end

	-- This calls math.log, and not Math.log. Math.log calls this function, so a
	-- call in that direction makes infinite recursion.
	local guess = math.floor(math.log(Math.abs(n), 2)) + 1
	-- The scale is a multiplication by 2^-guess, and not a division by 2^guess.
	-- guess is 1024 for the largest inputs, and 2^1024 is infinite, which makes
	-- m zero and stops the loops below from ever terminating. 2^-1024 is a
	-- subnormal power of two, so the multiplication stays exact.
	local m = n * 2 ^ -guess
	e += guess

	while Math.abs(m) >= 1 do
		m /= 2
		e += 1
	end
	while Math.abs(m) < 0.5 do
		m *= 2
		e -= 1
	end

	return m, e
end

local ln2hi = 6.93147180369123816490e-01
local ln2lo = 1.90821492927058770002e-10

local lg = {
	6.666666666666735130e-01,
	3.999999999940941908e-01,
	2.857142874366239149e-01,
	2.222219843214978396e-01,
	1.818357216161805012e-01,
	1.531383769920937332e-01,
	1.479819860511658591e-01,
}

--[[
$\ln(n)=r$
ln(n)=r
The relative error is at most 3×10⁻¹⁶ for positive, finite IEEE-754 doubles.
The function returns -inf for 0, and NaN for a negative n. ln2 is in two parts,
because one double cannot hold it.
https://netlib.org/fdlibm/e_log.c
]]
function Math.log(n)
	if Math.isNan(n) then
		return n
	end
	-- This test is before the test for infinity, because -inf gives NaN here.
	if n < 0 then
		return Math.NaN
	end
	if n == 0 then
		return -Math.Inf
	end
	if Math.isInf(n) then
		return n
	end

	-- The mantissa goes to [√2/2,√2), which keeps f small and symmetric.
	local m, e = Math.frexp(n)
	if m < Math.Sqrt2 / 2 then
		m *= 2
		e -= 1
	end

	local f = m - 1
	local s = f / (2 + f)
	local z = s * s
	local w = z * z
	local t1 = z * (lg[1] + w * (lg[3] + w * (lg[5] + w * lg[7])))
	local t2 = w * (lg[2] + w * (lg[4] + w * lg[6]))
	local p = t1 + t2
	local hfsq = 0.5 * f * f
	return e * ln2hi - ((hfsq - (s * (hfsq + p) + e * ln2lo)) - f)
end

--[[
$\ln(1+n)=r$
ln(1+n)=r
The relative error is at most 3×10⁻¹⁶ for n>-1. The function returns -inf for
n=-1, and NaN for n<-1. Math.log(1 + n) loses the low bits of a small n,
because the addition rounds them away. The quotient below puts them back.
https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html
]]
function Math.log1p(n)
	if Math.isNan(n) or n == Math.Inf then
		return n
	end

	local u = 1 + n
	if u == 1 then
		-- The addition rounds to 1, so n is the result to the last bit.
		return n
	end

	-- The quotient n/(u-1) is near 1, so it cannot overflow. The other grouping,
	-- Math.log(u) * n / (u - 1), multiplies two large values first, and it gives
	-- infinity for the largest inputs.
	return Math.log(u) * (n / (u - 1))
end

--[[
$\operatorname{artanh}(n)=\frac{1}{2}\ln\frac{1+n}{1-n}$
artanh(n)=½ln((1+n)/(1-n))
The relative error is at most 3×10⁻¹⁶ for |n|<1. The function returns ±inf for
n=±1, and NaN for |n|>1.
https://netlib.org/fdlibm/e_atanh.c
]]
function Math.atanh(n)
	if Math.isNan(n) then
		return n
	end

	local a = Math.abs(n)
	if a > 1 then
		return Math.NaN
	end
	if a == 1 then
		return n / 0
	end
	if a < tiny then
		-- artanh(n) is n + n³/3 + ..., and the cubic term is below half of the
		-- last bit of n here. tiny is 2^-27, where fdlibm uses 2^-28. Both are
		-- small enough, and this module already has the one.
		return n
	end

	-- Both branches give the same value. The first one keeps accuracy for a
	-- small a, where 2a/(1-a) loses the low bits.
	local r
	if a < 0.5 then
		local t = a + a
		r = 0.5 * Math.log1p(t + t * a / (1 - a))
	else
		r = 0.5 * Math.log1p((a + a) / (1 - a))
	end

	if n < 0 then
		return -r
	end
	return r
end

--[[
$\operatorname{lerp}(a,b,t)=a+t(b-a)$
lerp(a,b,t)=a+t(b-a)
The function does not limit t to [0,1]. A value outside that range extrapolates.
https://en.wikipedia.org/wiki/Linear_interpolation
]]
function Math.lerp(a, b, t)
	return a + t * (b - a)
end

--[[
$\operatorname{sign}(n)=r$
sign(n)=r
Returns NaN when n is NaN.
]]
function Math.sign(n)
	if Math.isNan(n) then
		return n
	end
	if n == 0 then
		return 0
	end
	if n > 0 then
		return 1
	end
	return -1
end

-- Vector
function Vector.add(a, b)
	return a + b
end

function Vector.subtract(a, b)
	return a - b
end

function Vector.sMult(s, v)
	return v * s
end

function Vector.sDiv(s, v)
	return v / s
end

function Vector.dot(a, b)
	return (a.X * b.X) + (a.Y * b.Y) + (a.Z * b.Z)
end

function Vector.magnitude(v)
	return Math.sqrt((v.X ^ 2) + (v.Y ^ 2) + (v.Z ^ 2))
end

function Vector.sqmagnitude(v)
	return (v.X ^ 2) + (v.Y ^ 2) + (v.Z ^ 2)
end

function Vector.normalize(v)
	local magnitude = Vector.magnitude(v)
	assert(magnitude ~= 0, "cannot normalize the zero vector")
	return Vector.sDiv(magnitude, v)
end
--[[
$\operatorname{proj}_n(v)=\frac{v \cdot n}{n \cdot n}n$
proj_n(v)=((v·n)/(n·n))n
]]
function Vector.project(v, n)
	local denominator = Vector.dot(n, n)
	assert(denominator ~= 0, "cannot project onto the zero vector")
	return Vector.sMult(Vector.dot(v, n) / denominator, n)
end
--[[
$\operatorname{rej}_n(v)=v-\operatorname{proj}_n(v)$
rej_n(v)=v-proj_n(v)
]]
function Vector.reject(v, n)
	return Vector.subtract(v, Vector.project(v, n))
end

return Math
