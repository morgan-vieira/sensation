--!strict
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local peek = Fusion.peek
local Children = Fusion.Children

type RenderedItem<ScopeMethods> = {
	scope: Fusion.Scope<any>, -- code is too complex to typecheck
	index: Fusion.Value<number>
}

local function VirtualList<ScopeMethods>(
	scope: Fusion.Scope<ScopeMethods & typeof(Fusion)>,
	props: {
		ScrollPosition: Fusion.StateObject<Vector2?>,
		ScrollWindowSize: Fusion.StateObject<Vector2?>,
	
		NumItems: Fusion.UsedAs<number>,
		ItemHeight: Fusion.UsedAs<number>,
		RenderItem: (
			scope: Fusion.Scope<ScopeMethods>,
			index: Fusion.UsedAs<number>
		) -> any,
	
		Padding: Fusion.UsedAs<{
			Before: Fusion.UsedAs<number>, 
			After: Fusion.UsedAs<number>
		}>?,
	}
)

	local virtualList = scope:New "Frame" {
		Name = "VirtualList",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}

	local function makeRenderedItem(
		scope: Fusion.Scope<ScopeMethods & typeof(Fusion)>,
		initialIndex: number
	): RenderedItem<ScopeMethods>
		local index = scope:Value(initialIndex)
		
		scope:New "Frame" {
			Name = "VirtualItem",
			Parent = virtualList,
			
			Position = scope:Computed(function(use)
				return UDim2.new(0, 0, 0, use(props.ItemHeight) :: number * (use(index) - 1))
			end),
			Size = scope:Computed(function(use)
				return UDim2.new(1, 0, 0, use(props.ItemHeight))
			end),
			BackgroundTransparency = 1,

			[Children] = props.RenderItem(scope, index)
		}

		return {
			scope = scope,
			index = index
		} 
	end

	local firstItemInWindow = scope:Computed(function(use): number?
		local numItems = use(props.NumItems)
		if numItems < 1 then
			return nil
		end
		local scrollPosition = use(props.ScrollPosition) or Vector2.zero
		local firstItem = math.floor(scrollPosition.Y / use(props.ItemHeight))
		local padding = use(props.Padding)
		if padding ~= nil then
			firstItem -= use(padding.Before)
		end
		firstItem = math.clamp(firstItem, 1, numItems)
		return firstItem
	end)
	local lastItemInWindow = scope:Computed(function(use): number?
		local numItems = use(props.NumItems)
		local firstItemInWindow = use(firstItemInWindow)
		if numItems < 1 or firstItemInWindow == nil then
			return nil
		end
		local scrollWindowSize = use(props.ScrollWindowSize) or Vector2.zero
		local visibleItemCount = math.ceil(scrollWindowSize.Y / use(props.ItemHeight))
		local padding = use(props.Padding)
		if padding ~= nil then
			visibleItemCount += use(padding.Before) :: number + use(padding.After)
		end
		local lastItem = visibleItemCount + firstItemInWindow
		lastItem = math.clamp(lastItem, 1, numItems)
		return lastItem
	end)

	local renderedItemMap: {[number]: RenderedItem<ScopeMethods>} = {}
	local prevFirstItemInWindow: number? = nil
	local prevLastItemInWindow: number? = nil
	local recycleStack: {RenderedItem<ScopeMethods>} = {}
	local recycleCount: number = 0

	local function reconcile()
		local firstItemInWindow = peek(firstItemInWindow)
		local lastItemInWindow = peek(lastItemInWindow)
		if firstItemInWindow == nil or lastItemInWindow == nil then
			for index, renderedItem in renderedItemMap do
				renderedItemMap[index] = nil
				recycleCount += 1
				recycleStack[recycleCount] = renderedItem
			end
		else
			if prevFirstItemInWindow ~= nil then
				for index = prevFirstItemInWindow, firstItemInWindow do
					local offscreenItem = renderedItemMap[index]
					if offscreenItem ~= nil then
						renderedItemMap[index] = nil
						recycleCount += 1
						recycleStack[recycleCount] = offscreenItem
					end
				end
			end
			if prevLastItemInWindow ~= nil then
				for index = lastItemInWindow, prevLastItemInWindow do
					local offscreenItem = renderedItemMap[index]
					if offscreenItem ~= nil then
						renderedItemMap[index] = nil
						recycleCount += 1
						recycleStack[recycleCount] = offscreenItem
					end
				end
			end
			for index = firstItemInWindow, lastItemInWindow do
				local onscreenItem = renderedItemMap[index]
				if onscreenItem ~= nil then
					continue
				elseif recycleCount > 0 then
					local recycledItem = recycleStack[recycleCount]
					recycleStack[recycleCount] = nil
					recycleCount -= 1
					recycledItem.index:set(index)
					renderedItemMap[index] = recycledItem
				else
					local generatedItem = makeRenderedItem(scope:innerScope(), index)
					renderedItemMap[index] = generatedItem
				end
			end
		end
		for _, renderedItem in recycleStack do
			renderedItem.scope:doCleanup()
		end
		recycleCount = 0
		prevFirstItemInWindow = firstItemInWindow
		prevLastItemInWindow = lastItemInWindow
	end

	reconcile()
	scope:Observer(firstItemInWindow):onChange(reconcile)
	scope:Observer(lastItemInWindow):onChange(reconcile)
	table.insert(scope, function()
		for _, renderedItem in renderedItemMap do
			renderedItem.scope:doCleanup()
		end
		for _, renderedItem in recycleStack do
			renderedItem.scope:doCleanup()
		end
		table.clear(renderedItemMap)
		table.clear(recycleStack)
	end)

	return virtualList
end

return VirtualList