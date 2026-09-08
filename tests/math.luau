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

for _, n in { 5e-324, 1e-300, 0.25, 0.5, 1, 2, 4, 9, 1e300 } do
	close(Math.sqrt(n), math.sqrt(n), math.sqrt(n) * 2e-15)
end
assert(Math.sqrt(0) == 0)
assert(Math.sqrt(math.huge) == math.huge)
assert(Math.isNan(Math.sqrt(-1)))

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
