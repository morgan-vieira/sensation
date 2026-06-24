import { useState, useRef, useCallback, type PointerEvent } from "react"

export interface GestureSurfaceProps {
	color?: string
	borderRadius?: number
	enabled?: boolean
	onActivated?: () => void
	onHoverChange?: (hovering: boolean) => void
}

export function GestureSurface({
	color = "rgba(255,255,255,1)",
	borderRadius = 0,
	enabled = true,
	onActivated,
	onHoverChange,
}: GestureSurfaceProps) {
	const [hoverPos, setHoverPos] = useState<{ x: number; y: number } | null>(
		null,
	)
	const [pressed, setPressed] = useState(false)
	const ref = useRef<HTMLDivElement>(null)

	const resolvePos = useCallback((e: PointerEvent<HTMLDivElement>) => {
		const rect = ref.current?.getBoundingClientRect() ?? { left: 0, top: 0 }
		return { x: e.clientX - rect.left, y: e.clientY - rect.top }
	}, [])

	const isActive = enabled && hoverPos !== null
	const opacity = isActive && !pressed ? 0.5 : 0

	return (
		<div
			ref={ref}
			style={{
				position: "absolute",
				top: 0,
				right: 0,
				bottom: 0,
				left: 0,
				borderRadius,
				cursor: enabled ? "pointer" : "default",
				background:
					isActive && hoverPos !== null
						? `radial-gradient(circle farthest-corner at ${hoverPos.x}px ${hoverPos.y}px, ${color}, transparent)`
						: undefined,
				opacity,
				transition: "opacity 0.15s ease",
			}}
			onPointerEnter={(e) => {
				if (!enabled) return
				setHoverPos(resolvePos(e))
				onHoverChange?.(true)
			}}
			onPointerMove={(e) => {
				if (!enabled || hoverPos === null) return
				setHoverPos(resolvePos(e))
			}}
			onPointerLeave={() => {
				setHoverPos(null)
				setPressed(false)
				if (enabled) onHoverChange?.(false)
			}}
			onPointerDown={(e) => {
				if (!enabled) return
				e.currentTarget.setPointerCapture?.(e.pointerId)
				setPressed(true)
			}}
			onPointerUp={() => {
				setPressed(false)
			}}
			onClick={() => {
				if (enabled) onActivated?.()
			}}
		/>
	)
}
