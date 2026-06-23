import { vars } from "../theme"

export interface DividerProps {
	direction?: "horizontal" | "vertical"
}

export function Divider({ direction = "horizontal" }: DividerProps) {
	return (
		<div
			role="separator"
			aria-orientation={direction}
			style={{
				width: direction === "horizontal" ? "100%" : 1,
				height: direction === "horizontal" ? 1 : "100%",
				background: vars.fg,
				opacity: 0.2,
				flexShrink: 0,
			}}
		/>
	)
}
