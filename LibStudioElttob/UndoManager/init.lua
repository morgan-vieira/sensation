--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")

local Package = script
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local Maybe = require(LibOpen.Maybe)

local UndoManager = {}

type CurrentRecording = {
	recordingId: Maybe.Maybe<string>,
	scope: Fusion.Scope<typeof(Fusion)>
}

UndoManager.currentRecording = nil :: CurrentRecording?
UndoManager.preventCancel = false

function UndoManager.record<Methods>(
	outerScope: Fusion.Scope<Methods & typeof(Fusion)>,
	name: string,
	displayName: string,
	options: {
		othersCanCancel: boolean,
		cancelsOthers: boolean,
		runOnRobloxFailure: boolean,
		onRun: (
			scope: Fusion.Scope<Methods>,
			recordingId: Maybe.Maybe<string>
		) -> Enum.FinishRecordingOperation
	}
): Maybe.Maybe<() -> ()>
	if UndoManager.currentRecording ~= nil then
		if UndoManager.preventCancel or not options.cancelsOthers then
			return Maybe.None("a higher-priority action is still processing")
		end
		UndoManager.currentRecording.scope:doCleanup()
	end
	local maybeRecordingId
	do
		local ok, result = pcall(ChangeHistoryService.TryBeginRecording, ChangeHistoryService, name, displayName)
		maybeRecordingId =
			if not ok then
				Maybe.None("Roblox errored when recording the action")
			else
				if result ~= nil then
					Maybe.Some(result)
				else
					if ChangeHistoryService:IsRecordingInProgress() then
						Maybe.None("an undo-able action is still occuring")
					elseif RunService:IsRunning() then
						Maybe.None("the game is running")
					else
						Maybe.None("there was an unknown Roblox issue")
	end
		
	if not maybeRecordingId.some and not options.runOnRobloxFailure then
		return maybeRecordingId :: Maybe.None
	end
	
	local recordingScope = outerScope:innerScope()

	local finishRecordingOp = Enum.FinishRecordingOperation.Cancel
	table.insert(recordingScope, function()
		local index = table.find(outerScope, recordingScope)
		if index ~= nil then
			table.remove(outerScope, index)
		end
		UndoManager.currentRecording = nil
		UndoManager.preventCancel = false
		if maybeRecordingId.some then
			pcall(ChangeHistoryService.FinishRecording, ChangeHistoryService, maybeRecordingId.value, finishRecordingOp)
		end
	end)

	UndoManager.currentRecording = {
		recordingId = maybeRecordingId,
		scope = recordingScope
	}
	UndoManager.preventCancel = not options.othersCanCancel

	task.spawn(function()
		finishRecordingOp = options.onRun(recordingScope, maybeRecordingId)
	end)

	return Maybe.Some(function()
		recordingScope:doCleanup()
	end)
end

return UndoManager
