-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.frexp against the Luau builtin.

Math.sqrt and Math.log both call Math.frexp, so its cost is part of theirs.
Math.frexp estimates the exponent with math.log, then corrects the mantissa in
two loops. The estimate is correct for almost every input, which makes the
loops short.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Math = require(ReplicatedStorage.essence.math.math)

local COUNT = 256
local inputs = table.create(COUNT)

return {
	ParameterGenerator = function()
		return inputs
	end,

	Functions = {
		["Math.frexp"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				local mantissa, exponent = Math.frexp(values[index])
				total += mantissa + exponent
			end
			return total
		end,

		["math.frexp"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				local mantissa, exponent = math.frexp(values[index])
				total += mantissa + exponent
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-frexp",
		Name = "Math.frexp",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			local random = Random.new(20260912)
			for index = 1, COUNT do
				local value = 2 ^ random:NextNumber(-1020, 1020)
				inputs[index] = if random:NextNumber() < 0.5 then -value else value
			end
		end,
	},
}
