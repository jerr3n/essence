local Math = require("../src/shared/essence/math/math")

local vectorMeta = {}

local function vector(x, y, z)
	return setmetatable({ X = x, Y = y, Z = z }, vectorMeta)
end

function vectorMeta.__add(a, b)
	return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

function vectorMeta.__sub(a, b)
	return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function vectorMeta.__mul(v, s)
	return vector(v.X * s, v.Y * s, v.Z * s)
end

function vectorMeta.__div(v, s)
	return vector(v.X / s, v.Y / s, v.Z / s)
end

local function close(actual, expected, tolerance)
	assert(math.abs(actual - expected) <= tolerance, `{actual} is not within {tolerance} of {expected}`)
end

local function vectorClose(actual, expected, tolerance)
	close(actual.X, expected.X, tolerance)
	close(actual.Y, expected.Y, tolerance)
	close(actual.Z, expected.Z, tolerance)
end

assert(Math.max(2, 3) == 3)
assert(Math.min(2, 3) == 2)
assert(Math.clamp(4, 1, 3) == 3)
assert(not pcall(Math.clamp, 1, 3, 2))
assert(Math.abs(-4) == 4)
assert(Math.isNan(0 / 0))
assert(Math.isInf(math.huge))
assert(Math.isInf(-math.huge))
assert(not Math.isInf(0))
assert(not Math.isInf(0 / 0))
assert(Math.isNan(Math.NaN))
assert(Math.Sqrt2 == math.sqrt(2))
close(Math.pow(4, -0.5), 0.5, 1e-15)
assert(Math.factorial(0) == 1)
assert(Math.factorial(5) == 120)
assert(not pcall(Math.factorial, -1))
assert(not pcall(Math.factorial, 1.5))

close(
	Math.sum(1, 4, function(n)
		return n
	end),
	10,
	0
)
close(
	Math.product(1, 4, function(n)
		return n
	end),
	24,
	0
)
close(
	Math.integrate(function(n)
		return n ^ 2
	end, 0, 1, 100),
	1 / 3,
	1e-4
)
close(
	Math.derive(function(n)
		return n ^ 2
	end, 3),
	6,
	1e-9
)

for _, n in { 5e-324, 1e-300, 0.25, 0.5, 1, 2, 4, 9, 1e300, 2 ^ 1023, 1.7976931348623157e308 } do
	close(Math.sqrt(n), math.sqrt(n), math.sqrt(n) * 2e-15)
end
assert(Math.sqrt(0) == 0)
assert(1 / Math.sqrt(-0) == -math.huge)
assert(Math.sqrt(math.huge) == math.huge)
assert(Math.isNan(Math.sqrt(-1)))
assert(Math.isNan(Math.sqrt(-math.huge)))
assert(Math.isNan(Math.sqrt(0 / 0)))

assert(Math.floor(1.9) == 1)
assert(Math.floor(-1.2) == -2)
assert(Math.floor(math.huge) == math.huge)
assert(Math.floor(-math.huge) == -math.huge)

for _, n in { -Math.Pi, -2, -1, -0.25, 0, 0.25, 1, 2, Math.Pi } do
	close(Math.sin(n), math.sin(n), 1.1e-11)
	close(Math.cos(n), math.cos(n), 1.1e-11)
	close(Math.atan(n), math.atan(n), 3e-16)
end
close(Math.atan(1e100), math.atan(1e100), 3e-16)
close(Math.atan(-1e100), math.atan(-1e100), 3e-16)
assert(Math.isNan(Math.atan(0 / 0)))
local frexpInputs = { 8, 0.25, 1, -3.5, 2 ^ 66, -2 ^ 66, 2 ^ 67, 5e-324, 1e-310 }
-- 2^1023 and above made the loop that normalizes the mantissa run forever.
table.insert(frexpInputs, 2 ^ 1023)
table.insert(frexpInputs, -2 ^ 1023)
table.insert(frexpInputs, 1.7976931348623157e308)
table.insert(frexpInputs, 1.5e308)
for _, n in frexpInputs do
	local m, e = Math.frexp(n)
	local rm, re = math.frexp(n)
	assert(m == rm and e == re, `frexp({n}) returned {m}, {e} instead of {rm}, {re}`)
end
do
	local m, e = Math.frexp(0)
	assert(m == 0 and e == 0)
	m, e = Math.frexp(math.huge)
	assert(m == math.huge and e == 0)
	m, e = Math.frexp(-math.huge)
	assert(m == -math.huge and e == 0)
	m, e = Math.frexp(0 / 0)
	assert(Math.isNan(m) and e == 0)
end

close(Math.atan2(1, 1), Math.QuarterPi, 1e-15)
close(Math.atan2(1, -1), 3 * Math.QuarterPi, 1e-15)
close(Math.atan2(-1, -1), -3 * Math.QuarterPi, 1e-15)
close(Math.atan2(-1, 1), -Math.QuarterPi, 1e-15)
close(Math.atan2(3, 4), math.atan(3 / 4), 1e-15)
close(Math.atan2(1, 0), Math.HalfPi, 0)
close(Math.atan2(-1, 0), -Math.HalfPi, 0)
close(Math.atan2(0, -1), Math.Pi, 0)
close(Math.atan2(1, math.huge), 0, 0)
close(Math.atan2(math.huge, 1), Math.HalfPi, 0)
close(Math.atan2(math.huge, math.huge), Math.QuarterPi, 0)
assert(Math.isNan(Math.atan2(0 / 0, 1)))

for _, n in { 5e-324, 1e-300, 0.25, 0.5, 1, 2, math.exp(1), 10, 1e300, 1.7976931348623157e308 } do
	close(Math.log(n), math.log(n), math.abs(math.log(n)) * 3e-16)
end
assert(Math.log(1) == 0)
assert(Math.log(0) == -math.huge)
assert(Math.log(math.huge) == math.huge)
assert(Math.isNan(Math.log(-1)))
assert(Math.isNan(Math.log(-math.huge)))
assert(Math.isNan(Math.log(0 / 0)))

-- log1p keeps the low bits that log(1 + n) rounds away.
for _, n in { 1e-17, -1e-17, 1e-9, -1e-9, 1e-5, 0.25, -0.25, 0.5, -0.5, 3, 1e300 } do
	local reference = if math.abs(n) < 1e-4 then n - n ^ 2 / 2 + n ^ 3 / 3 - n ^ 4 / 4 else math.log(1 + n)
	close(Math.log1p(n), reference, math.abs(reference) * 3e-16)
end
assert(Math.log1p(0) == 0)
assert(1 / Math.log1p(-0) == -math.huge)
assert(Math.log1p(5e-324) == 5e-324)
assert(Math.log1p(-1) == -math.huge)
assert(Math.log1p(math.huge) == math.huge)
assert(Math.isNan(Math.log1p(-2)))
assert(Math.isNan(Math.log1p(-math.huge)))
assert(Math.isNan(Math.log1p(0 / 0)))

for _, n in { 1e-17, -1e-17, 1e-9, 1e-5, 0.25, -0.25, 0.5, -0.5, 0.9, -0.9, 0.999999 } do
	local reference = if math.abs(n) < 1e-4 then n + n ^ 3 / 3 else 0.5 * math.log((1 + n) / (1 - n))
	close(Math.atanh(n), reference, math.abs(reference) * 3e-16)
end
close(Math.atanh(0.5), 0.5493061443340549, 2e-16)
close(Math.atanh(-0.9), -1.4722194895832204, 1e-15)
assert(Math.atanh(0) == 0)
assert(1 / Math.atanh(-0) == -math.huge)
assert(Math.atanh(5e-324) == 5e-324)
assert(Math.atanh(1) == math.huge)
assert(Math.atanh(-1) == -math.huge)
assert(Math.isNan(Math.atanh(2)))
assert(Math.isNan(Math.atanh(math.huge)))
assert(Math.isNan(Math.atanh(0 / 0)))

close(Math.lerp(2, 4, 0.5), 3, 0)
close(Math.lerp(2, 4, 2), 6, 0)

assert(Math.sign(-10) == -1)
assert(Math.sign(0) == 0)
assert(Math.sign(10) == 1)
assert(Math.isNan(Math.sign(0 / 0)))

local Vector = Math.Vector
vectorClose(Vector.add(vector(1, 2, 3), vector(4, 5, 6)), vector(5, 7, 9), 0)
vectorClose(Vector.subtract(vector(4, 5, 6), vector(1, 2, 3)), vector(3, 3, 3), 0)
vectorClose(Vector.sMult(2, vector(1, 2, 3)), vector(2, 4, 6), 0)
vectorClose(Vector.sDiv(2, vector(2, 4, 6)), vector(1, 2, 3), 0)
close(Vector.dot(vector(1, 2, 3), vector(4, 5, 6)), 32, 0)
close(Vector.magnitude(vector(3, 0, 4)), 5, 1e-14)
vectorClose(Vector.normalize(vector(3, 0, 4)), vector(0.6, 0, 0.8), 1e-14)
assert(not pcall(Vector.normalize, vector(0, 0, 0)))
vectorClose(Vector.project(vector(2, 3, 0), vector(1, 0, 0)), vector(2, 0, 0), 1e-14)
vectorClose(Vector.reject(vector(2, 3, 0), vector(1, 0, 0)), vector(0, 3, 0), 1e-14)
assert(not pcall(Vector.project, vector(1, 1, 1), vector(0, 0, 0)))

print("math tests passed")
