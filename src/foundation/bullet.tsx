import { vars } from "../theme"

export interface BulletProps {
	children: React.ReactNode
}

export function Bullet({ children }: BulletProps) {
	return (
		<div style={{ position: "relative", paddingLeft: 12 }}>
			<div
				aria-hidden
				style={{
					position: "absolute",
					left: 2,
					top: 8,
					transform: "translateY(-50%)",
					width: 4,
					height: 4,
					borderRadius: "50%",
					background: vars.fg,
					flexShrink: 0,
				}}
			/>
			{children}
		</div>
	)
}
