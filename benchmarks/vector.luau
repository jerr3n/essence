-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
The Math.Vector operations, and the Math.sqrt call inside them.

Vector.magnitude calls Math.sqrt. Vector.sqmagnitude does not, which is why the
module tells you to compare squared lengths. Vector.normalize divides by the
magnitude, and its two profiler scopes show how much of it is the square root.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Math = require(ReplicatedStorage.essence.math.math)
local Vector = Math.Vector

local COUNT = 256
local inputs = table.create(COUNT)
local magnitudes = table.create(COUNT)

return {
	ParameterGenerator = function()
		return inputs
	end,

	Functions = {
		["Vector.magnitude"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Vector.magnitude(values[index])
			end
			return total
		end,

		["Vector.sqmagnitude"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Vector.sqmagnitude(values[index])
			end
			return total
		end,

		["Vector3.Magnitude"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += values[index].Magnitude
			end
			return total
		end,

		["Vector.normalize"] = function(Profiler, values)
			-- The two scopes are separate loops, and not one loop with two
			-- scopes. One pair of Profiler calls for every vector would cost
			-- more than the work it measures.
			Profiler.Begin("magnitude")
			for index = 1, COUNT do
				magnitudes[index] = Vector.magnitude(values[index])
			end
			Profiler.End()

			Profiler.Begin("divide")
			local total = 0
			for index = 1, COUNT do
				total += Vector.sDiv(magnitudes[index], values[index]).X
			end
			Profiler.End()

			return total
		end,

		["Vector3.Unit"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += values[index].Unit.X
			end
			return total
		end,

		["Vector.dot"] = function(_, values)
			local total = 0
			for index = 2, COUNT do
				total += Vector.dot(values[index - 1], values[index])
			end
			return total
		end,

		["Math.cross"] = function(_, values)
			local total = 0
			for index = 2, COUNT do
				total += Math.cross(values[index - 1], values[index]).X
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-vector",
		Name = "Math.Vector",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			local random = Random.new(20260912)
			for index = 1, COUNT do
				inputs[index] = Vector3.new(
					random:NextNumber(-1000, 1000),
					random:NextNumber(-1000, 1000),
					random:NextNumber(-1000, 1000)
				)
			end
		end,
	},
}
