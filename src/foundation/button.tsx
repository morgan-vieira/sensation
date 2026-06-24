import { useState } from "react"
import { useSurface, vars } from "../theme"
import { Bevel } from "../fx/bevel"
import { GestureSurface } from "../input/gesture-surface"
import { Text, type TextStyle } from "./text"

export interface ButtonProps {
	children?: string
	illuminated?: boolean
	flat?: boolean
	subtle?: boolean
	align?: "left" | "center"
	enabled?: boolean
	onActivated?: () => void
}

export function Button({
	children,
	illuminated = false,
	flat = false,
	subtle = false,
	align = "center",
	enabled = true,
	onActivated,
}: ButtonProps) {
	const [isHovering, setIsHovering] = useState(false)
	const isSubtle = subtle && !isHovering
	const isRaised = !flat && !isSubtle

	const { style: elevatedStyle } = useSurface(1)

	const backgroundColor = illuminated
		? vars.accent
		: isRaised
			? vars.bg
			: "transparent"

	const textStyle: TextStyle = illuminated
		? "atopAccent"
		: isSubtle
			? "grey"
			: "normal"

	const gestureColor = illuminated ? vars.pureOnAccent : vars.pure

	return (
		<div
			role="button"
			tabIndex={enabled ? 0 : -1}
			aria-disabled={!enabled}
			onClick={() => {
				if (enabled) onActivated?.()
			}}
			onPointerEnter={() => {
				if (enabled) setIsHovering(true)
			}}
			onPointerLeave={() => setIsHovering(false)}
			onKeyDown={(e) => {
				if ((e.key === "Enter" || e.key === " ") && enabled) {
					e.preventDefault()
					onActivated?.()
				}
			}}
			style={{
				...(isRaised ? elevatedStyle : {}),
				position: "relative",
				display: "inline-flex",
				alignItems: "center",
				justifyContent: align === "left" ? "flex-start" : "center",
				height: 24,
				paddingLeft: 8,
				paddingRight: 8,
				borderRadius: 4,
				backgroundColor,
				transition: "background-color 0.15s ease",
				boxSizing: "border-box",
				cursor: enabled ? "pointer" : "default",
				userSelect: "none",
			}}
		>
			<Bevel height={isRaised ? 1 : 0} borderRadius={4} />
			<GestureSurface color={gestureColor} borderRadius={4} enabled={enabled} />
			<div style={{ position: "relative", zIndex: 1, pointerEvents: "none" }}>
				{children != null && children.length > 0 && (
					<Text style={textStyle}>{children}</Text>
				)}
			</div>
		</div>
	)
}
