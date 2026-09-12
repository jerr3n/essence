-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.sin and Math.cos against the Luau builtins.

Math.sin sums eleven Taylor terms. Each term calls Math.pow twice and
Math.factorial once, and Math.factorial multiplies up to 21 values on each
call. Math.cos adds π/2 and calls Math.sin, so the two cases differ by one
addition.

The count is smaller than in the other suites, because these cases are slower.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Math = require(ReplicatedStorage.essence.math.math)

local COUNT = 64
local inputs = table.create(COUNT)

return {
	ParameterGenerator = function()
		return inputs
	end,

	Functions = {
		["Math.sin"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.sin(values[index])
			end
			return total
		end,

		["math.sin"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += math.sin(values[index])
			end
			return total
		end,

		["Math.cos"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.cos(values[index])
			end
			return total
		end,

		["math.cos"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += math.cos(values[index])
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-trig",
		Name = "Math.sin and Math.cos",
		Runs = 300,
		WarmupRuns = 25,
		BeforeAll = function()
			-- The inputs stay in [-π,π], which is the range where the module
			-- gives its error bound. A larger input adds range reduction.
			local random = Random.new(20260912)
			for index = 1, COUNT do
				inputs[index] = random:NextNumber(-Math.Pi, Math.Pi)
			end
		end,
	},
}
