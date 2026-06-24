export interface BevelProps {
	height?: number
	borderRadius?: number
}

export function Bevel({ height = 1, borderRadius = 0 }: BevelProps) {
	const h = Math.max(-1, Math.min(1, height))
	const intensity = Math.abs(h)
	const raised = h >= 0

	const topOpacity = raised ? intensity * 0.2 : intensity * 0.15
	const bottomOpacity = raised ? intensity * 0.15 : intensity * 0.2
	const topColor = raised
		? `rgba(255,255,255,${topOpacity})`
		: `rgba(0,0,0,${topOpacity})`
	const bottomColor = raised
		? `rgba(0,0,0,${bottomOpacity})`
		: `rgba(255,255,255,${bottomOpacity})`

	return (
		<div
			aria-hidden
			style={{
				position: "absolute",
				top: 0,
				right: 0,
				bottom: 0,
				left: 0,
				borderRadius,
				boxShadow: `inset 0 1px 0 ${topColor}, inset 0 -1px 0 ${bottomColor}`,
				transition: "box-shadow 0.15s ease",
				pointerEvents: "none",
			}}
		/>
	)
}
