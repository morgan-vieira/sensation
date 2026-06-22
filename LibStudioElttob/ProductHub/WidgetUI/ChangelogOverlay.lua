--!strict
--!nolint LocalShadow
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local Package = script.Parent.Parent
local LibStudioElttob = Package.Parent
local LibOpen = LibStudioElttob.Parent.LibOpen

local Fusion = require(LibOpen.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek
local Children, Out = Fusion.Children, Fusion.Out
local Maybe = require(LibOpen.Maybe)
local Event = require(LibOpen.Event)
local whyhttp = require(LibOpen.whyhttp)
local Permissioned = require(LibOpen.Permissioned)
local Theme = require(LibStudioElttob.RbxSensation.Theme)
local LoadingSpinner = require(LibStudioElttob.RbxSensation.Foundation.LoadingSpinner)
local Text = require(LibStudioElttob.RbxSensation.Foundation.Text)
local Scroller = require(LibStudioElttob.RbxSensation.Foundation.Scroller)
local Divider = require(LibStudioElttob.RbxSensation.Foundation.Divider)
local EmptyState = require(LibStudioElttob.RbxSensation.Compound.EmptyState)
local Modal = require(LibStudioElttob.RbxSensation.Compound.Modal)
local TransitionBox = require(LibStudioElttob.RbxSensation.FX.TransitionBox)
local FadeTransition = require(LibStudioElttob.RbxSensation.FX.Transition.FadeTransition)
local ProductDiscovery = require(LibStudioElttob.ProductDiscovery)
local IconRamp = require(LibStudioElttob.IconRamp)

export type ChangelogTextResult = Permissioned.Permissioned<Maybe.Maybe<string>> | "pending"

export type CurrentChangelog = {
	productId: string,
	productInfo: ProductDiscovery.ProductInfo,
	changelogText: Fusion.UsedAs<ChangelogTextResult>,
}

local function ChangelogOverlay(
	outerScope: Fusion.Scope<{}>,
	props: {
		Theme: Theme.ThemeContext,
		CurrentChangelog: Fusion.StateObject<CurrentChangelog?>,
		CloseChangelog: () -> ()
	}
): Fusion.Child
	local scope = scoped(Fusion, {
		Text = Text,
		LoadingSpinner = LoadingSpinner,
		Scroller = Scroller,
		Divider = Divider,
		TransitionBox = TransitionBox,
		EmptyState = EmptyState,
		Modal = Modal
	})
	table.insert(outerScope, scope)

	local retainedChangelog = scope:Value(peek(props.CurrentChangelog))

	local changelogDisplay = scope:Computed(function(use)
		local changelog = use(retainedChangelog)
		if changelog == nil then
			return {
				type = "none"
			}
		else
			local text = use(changelog.changelogText)
			if text == "pending" then
				return {
					type = "pending"
				}
			elseif not text.allowed then
				return {
					type = "permission-denied"
				}
			elseif text.value.some then
				return {
					type = "read",
					text = text.value.value :: string
				}
			else
				return {
					type = "error",
					description = whyhttp.describeError(text.value.reason, {
						theNoun = "these release notes",
						verb = "download these release notes",
						verbed = "downloaded these release notes",
						verbing = "downloading these release notes"
					})
				}
			end
		end
	end)

	return scope:Modal {
		Theme = props.Theme,
		Title = "Release notes",
		Icon = scope:Computed(function(use)
			local currentChangelog = use(retainedChangelog) :: CurrentChangelog?
			if currentChangelog == nil then
				return ""
			end
			local icon = IconRamp.selectNearestSize(
				currentChangelog.productInfo.robloxIcons,
				16
			)
			return if icon == nil then "" else icon.variants["mono" :: "mono"]
		end),

		RequestClose = props.CloseChangelog,

		State = props.CurrentChangelog,
		OutRetainedState = retainedChangelog,

		[Children] = scope:TransitionBox {
			Name = "ChangelogContent",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,

			State = changelogDisplay,
			Transition = FadeTransition {
				Colour = props.Theme.bg,
				EntryDirection = Vector2.yAxis
			},
			Render = function(
				scope: typeof(scope),
				display: any
			): Fusion.Child
				if display.type == "none" then
					return {}
				elseif display.type == "pending" then
					return {
						scope:LoadingSpinner {
							Position = UDim2.fromScale(0.5, 0.5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Visible = true, 
							Colour = props.Theme.fgAtopBg
						}
					}
				elseif display.type == "read" then
					local contentSize = scope:Value(Vector2.zero)
					return scope:Scroller {
						Theme = props.Theme,
						CanvasSize = scope:Computed(function(use)
							return UDim2.fromOffset(0, use(contentSize).Y + 32)
						end),
						ScrollByY = "continuous",
						ScrollByX = "none",
						TrackPosition = "aside",
						Size = UDim2.fromScale(1, 1),

						[Children] = {
							scope:New "UIListLayout" {
								SortOrder = "LayoutOrder",
								Padding = UDim.new(0, 8),
								[Out "AbsoluteContentSize"] = contentSize
							},

							scope:New "UIPadding" {
								PaddingLeft = UDim.new(0, 16),
								PaddingRight = UDim.new(0, 8),
								PaddingTop = UDim.new(0, 16),
								PaddingBottom = UDim.new(0, 16)
							},

							scope:Text {
								LayoutOrder = 1,
								Theme = props.Theme,
								Text = scope:Computed(function(use)
									local currentChangelog = use(retainedChangelog) :: CurrentChangelog?
									if currentChangelog == nil then
										return "Release notes"
									end
									local versionNumber =
										currentChangelog.productInfo.version.major
										.. "." .. currentChangelog.productInfo.version.minor
										.. "." .. currentChangelog.productInfo.version.patch
									return `{currentChangelog.productInfo.displayName} {versionNumber}`
								end),
								Style = "heading"
							},

							scope:Divider {
								LayoutOrder = 2,
								Theme = props.Theme,
								Direction = "horizontal"
							},

							scope:Text {
								LayoutOrder = 3,
								Theme = props.Theme,
								Text = display.text or "",
								RichText = true,
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y
							},

							scope:Divider {
								LayoutOrder = 4,
								Theme = props.Theme,
								Direction = "horizontal"
							},

							scope:Text {
								LayoutOrder = 5,
								Theme = props.Theme,
								Text = "End of release notes.  ■",
								Style = "grey",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								Align = {
									X = "end"
								}
							}
						}
					}
				else
					local err = {
						icon = "octagonX",
						text = "Something unknown failed while trying to display these release notes.",
						tip = "Try again in a moment, and get in touch if the problem persists."
					}
					if display.type == "permission-denied" then
						err = {
							icon = "shieldX",
							text = "Permission to download these release notes was denied.",
							tip = "Check to ensure that you've granted the appropriate HTTP permissions."
						}
					elseif display.type == "error" then
						local desc = display.description :: whyhttp.Description
						err = {
							icon = "octagonX",
							text = desc.brief .. (if desc.details == nil then "" else `\n({desc.details})`),
							tip = desc.tip or "Check your internet connection and try again in a moment."
						}
					end

					local onAnimate, doAnimate: () -> () = Event()
					task.delay(0.1, doAnimate)

					return scope:EmptyState {
						Theme = props.Theme,
						Icon = err.icon,
						Text = err.text,
						Tip = err.tip,
						AnimateEvent = onAnimate,
						DoAnimate = doAnimate
					}
				end
			end
		}
	}
end

return ChangelogOverlay