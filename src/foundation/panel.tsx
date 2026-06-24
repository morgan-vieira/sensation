import type { ReactNode } from "react"
import { useSurface, vars } from "../theme"

export interface PanelProps {
	children?: ReactNode
	zOffset?: number
}

export function Panel({ children, zOffset = 1 }: PanelProps) {
	const { style, ThemeSlot } = useSurface(zOffset)
	return (
		<ThemeSlot>
			<div
				style={{
					...style,
					backgroundColor: vars.bg,
					borderRadius: 8,
				}}
			>
				{children}
			</div>
		</ThemeSlot>
	)
}
