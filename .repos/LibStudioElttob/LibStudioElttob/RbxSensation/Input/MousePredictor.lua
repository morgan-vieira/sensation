--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek

export type Predictor = {
	predict: (
		scope: Fusion.Scope<typeof(Fusion)>,
		lookahead: Fusion.UsedAs<number>
	) -> Fusion.StateObject<Vector2>
}

-- local MIN_DELTA_FOR_PREDICTION = 4.0
-- local NORMAL_DELTA_FOR_PREDICTION = 12.0
-- local MAX_DELTA_FOR_PREDICTION = 200.0

local MousePredictor = {}

MousePredictor.DEFAULT_PARAMS = {
	timeWindow = 4 / 60,
	latencyCompensation = 0 / 60
}

function MousePredictor.predict(
	scope: Fusion.Scope<typeof(Fusion)>,
	rawPosition: Fusion.StateObject<Vector2>,
	params: {
		timeWindow: number,
		latencyCompensation: number
	}
): Predictor
	return MousePredictor.predictDan(scope, rawPosition, params)
end

function MousePredictor.predictDan(
	scope: Fusion.Scope<typeof(Fusion)>,
	rawPosition: Fusion.StateObject<Vector2>,
	params: {
		timeWindow: number,
		latencyCompensation: number
	}
): Predictor

	type Sample = {
		time: number,
		position: Vector2
	}
	local rawSamples
	do
		local prevBuffer = {}
		local nextBuffer = {}
		rawSamples = scope:Value(prevBuffer)
		table.insert(
			scope,
			RunService.RenderStepped:Connect(function()
				local currentTime = os.clock()
				local currentPosition = peek(rawPosition)
				-- find the max index with an outdated time
				local maxOutdatedIndex = 0
				while maxOutdatedIndex < #prevBuffer do
					local sample = prevBuffer[maxOutdatedIndex + 1]
					if currentTime - sample.time < params.timeWindow then
						break
					end
					maxOutdatedIndex += 1
				end
				-- prepare next buffer with only up-to-date samples (but include one beyond the end)
				table.clear(nextBuffer)
				if maxOutdatedIndex < #prevBuffer then
					table.move(prevBuffer, math.max(maxOutdatedIndex, 1), #prevBuffer, 1, nextBuffer)
				end

				table.insert(nextBuffer, {
					time = currentTime,
					position = currentPosition
				})
				rawSamples:set(nextBuffer)
				prevBuffer, nextBuffer = nextBuffer, prevBuffer
			end)
		)
	end

	-- local latestSampleTime = scope:Computed(function(use)
	-- 	local rawSamples = use(rawSamples)
	-- 	return if #rawSamples == 0 then 0 else rawSamples[#rawSamples].time
	-- end)

	local function predict(
		scope: Fusion.Scope<typeof(Fusion)>,
		lookahead: Fusion.UsedAs<number>
	): Fusion.StateObject<Vector2>
		local averageVelocity = scope:Computed(function(use)
			local rawSamples = use(rawSamples)
			local average = Vector2.zero
			local totalWeight = 0
			for index = 2, #rawSamples do
				local leftSample = rawSamples[index - 1]
				local rightSample = rawSamples[index]
				local deltaPosition = rightSample.position - leftSample.position
				local deltaTime = rightSample.time - leftSample.time
				local velocity = deltaPosition / deltaTime
				local weight = deltaTime
				average += velocity * weight
				totalWeight += weight
			end
			return average / totalWeight
		end)

		local averageAcceleration = scope:Computed(function(use)
			local rawSamples = use(rawSamples)
			local average = Vector2.zero
			local totalWeight = 0
			for index = 3, #rawSamples do
				local leftSample = rawSamples[index - 2]
				local midSample = rawSamples[index - 1]
				local rightSample = rawSamples[index]

				local deltaPositionLeft = midSample.position - leftSample.position
				local deltaTimeLeft = midSample.time - leftSample.time
				local velocityLeft = deltaPositionLeft / deltaTimeLeft

				local deltaPositionRight = rightSample.position - midSample.position
				local deltaTimeRight = rightSample.time - midSample.time
				local velocityRight = deltaPositionRight / deltaTimeRight

				local modifiedValue1 = (3*velocityLeft - velocityRight)/2
				local modifiedValue2 = (velocityLeft + velocityRight)/2
				local modifiedValue3 = (3*velocityRight - velocityLeft)/2

				local deltaModValueLeft = modifiedValue2 - modifiedValue1
				local deltaModValueRight = modifiedValue3 - modifiedValue2

				local accelerationLeft = deltaModValueLeft / deltaTimeLeft
				local accelerationRight = deltaModValueRight / deltaTimeRight
				
				if index == 1 then
					local weight = deltaTimeLeft
					average += accelerationLeft * weight
					totalWeight += weight
				end
				local weight = deltaTimeRight
				average += accelerationRight * weight
				totalWeight += weight
			end
			return average / totalWeight
		end)

		return scope:Computed(function(use)
			local currentPosition = use(rawPosition)
			local averageVelocity = use(averageVelocity)
			local averageAcceleration = use(averageAcceleration)
			local lookahead = use(lookahead) :: number
			local timestep = lookahead + params.latencyCompensation
			-- s = ut + 1/2 at^2
			local prediction = currentPosition + averageVelocity * timestep + 0.5 * averageAcceleration * timestep^2
			if prediction ~= prediction then
				return currentPosition
			else
				return prediction
			end
		end)
	end

	return {
		predict = predict
	}
end

-- function MousePredictor.predictTrey(
-- 	scope: Fusion.Scope<typeof(Fusion)>,
-- 	rawPosition: Fusion.StateObject<Vector2>,
-- 	params: {
-- 		timeWindow: number,
-- 		latencyCompensation: number
-- 	}
-- ): Predictor

-- 	type Sample = {
-- 		time: number,
-- 		position: Vector2
-- 	}
-- 	local rawSamples
-- 	do
-- 		local prevBuffer = {}
-- 		local nextBuffer = {}
-- 		rawSamples = scope:Value(prevBuffer)
-- 		table.insert(
-- 			scope,
-- 			RunService.RenderStepped:Connect(function()
-- 				local currentTime = os.clock()
-- 				local currentPosition = peek(rawPosition)
-- 				-- find the max index with an outdated time
-- 				local maxOutdatedIndex = 0
-- 				while maxOutdatedIndex < #prevBuffer do
-- 					local sample = prevBuffer[maxOutdatedIndex + 1]
-- 					if currentTime - sample.time < params.timeWindow then
-- 						break
-- 					end
-- 					maxOutdatedIndex += 1
-- 				end
-- 				-- prepare next buffer with only up-to-date samples
-- 				table.clear(nextBuffer)
-- 				if maxOutdatedIndex < #prevBuffer then
-- 					table.move(prevBuffer, maxOutdatedIndex + 1, #prevBuffer, 1, nextBuffer)
-- 				end

-- 				table.insert(nextBuffer, {
-- 					time = currentTime,
-- 					position = currentPosition
-- 				})
-- 				rawSamples:set(nextBuffer)
-- 				prevBuffer, nextBuffer = nextBuffer, prevBuffer
-- 			end)
-- 		)
-- 	end

-- 	-- l [ d  u  0 ]     [ x ]   [ y ]
-- 	--   [ l  d  u ]   . [ x ] = [ y ]
-- 	--   [ 0  l  d ] u   [ x ]   [ y ]
-- 	-- y is transformed into x
-- 	local function solveTridiagonal(
-- 		d: {number},
-- 		l: {number},
-- 		u: {number},
-- 		y: {any}
-- 	): ()
-- 		local n = #d
-- 		for i = 1, n - 1 do
-- 			u[i] /= d[i]
-- 			y[i] /= d[i]
-- 			d[i + 1] -= l[i + 1]*u[i]
-- 			y[i + 1] -= l[i + 1]*y[i]
-- 		end
-- 		y[n] /= d[n]
	
-- 		for i = n - 1, 1, -1 do
-- 			y[i] -= u[i]*y[i + 1]
-- 		end
-- 	end
	
	
-- 	local d, l, u = {}, {}, {}
-- 	local function fillVelocities(
-- 		times: {number},
-- 		positions: {any},
-- 		velocities: {any}
-- 	)
-- 		-- clear out duplicate times
-- 		for i = #times, 1, -1 do
-- 			if times[i] == times[i - 1] then
-- 				table.remove(times, i)
-- 				table.remove(positions, i)
-- 				table.remove(velocities, i)
-- 			end
-- 		end
	
-- 		table.clear(d)
-- 		table.clear(l)
-- 		table.clear(u)
-- 		local y = velocities
	
-- 		l[1] = 0 -- uh maybe this makes it faster
	
-- 		local n = #times
-- 		for i = 2, n - 1 do
-- 			if y[i] then
-- 				-- it's already solved
-- 				d[i] = 1
-- 				l[i] = 0
-- 				u[i] = 0
-- 			else
-- 				local t0, p0 = times[i - 1], positions[i - 1]
-- 				local t1, p1 = times[i    ], positions[i    ]
-- 				local t2, p2 = times[i + 1], positions[i + 1]
		
-- 				d[i] = 2*(t2 - t0)
-- 				l[i] = t2 - t1
-- 				u[i] = t1 - t0
-- 				y[i] = 3*((t2 - t1)/(t1 - t0)*(p1 - p0) + (t1 - t0)/(t2 - t1)*(p2 - p1))
-- 			end
-- 		end
	
-- 		-- fill boundary
-- 		if y[1] then
-- 			d[1] = 1
-- 			u[1] = 0
-- 		else
-- 			local t0, p0 = times[1], positions[1]
-- 			local t1, p1 = times[2], positions[2]
-- 			d[1] = 2
-- 			u[1] = 1
-- 			y[1] = 3/(t1 - t0)*(p1 - p0)
-- 		end
	
-- 		if y[n] then
-- 			d[n] = 1
-- 			l[n] = 0
-- 		else
-- 			local t0, p0 = times[n - 1], positions[n - 1]
-- 			local t1, p1 = times[n    ], positions[n    ]
-- 			d[n] = 2
-- 			l[n] = 1
-- 			y[n] = 3/(t1 - t0)*(p1 - p0)
-- 		end
	
-- 		solveTridiagonal(d, l, u, y)
-- 	end

-- 	local outgoingVelocity = scope:Computed(function(use)
-- 		local rawSamples = use(rawSamples)
-- 		if #rawSamples <= 2 then
-- 			return Vector2.zero
-- 		end
-- 		local times = {}
-- 		local positions = {}
-- 		for index = 1, #rawSamples do
-- 			times[index] = rawSamples[index].time
-- 			positions[index] = rawSamples[index].position
-- 		end
-- 		local velocities = {}
-- 		fillVelocities(times, positions, velocities)
-- 		return velocities[#velocities]
-- 	end)
	
-- 	local function predict(
-- 		scope: Fusion.Scope<typeof(Fusion)>,
-- 		lookahead: Fusion.UsedAs<number>
-- 	): Fusion.StateObject<Vector2>
-- 		return scope:Computed(function(use)
-- 			local currentPosition = use(rawPosition)
-- 			local outgoingVelocity = use(outgoingVelocity)
-- 			local lookahead = use(lookahead) :: number
-- 			local timestep = lookahead + params.latencyCompensation
-- 			-- s = ut + 1/2 at^2
-- 			local prediction = currentPosition + outgoingVelocity * timestep
-- 			if prediction ~= prediction then
-- 				return currentPosition
-- 			else
-- 				return prediction
-- 			end
-- 		end)
-- 	end

-- 	return {
-- 		predict = predict
-- 	}
-- end

return MousePredictor