import type { Meta, StoryObj } from "@storybook/react-vite"
import { useState } from "react"
import { vars } from "../../theme"
import { GestureSurface } from "../../input/gesture-surface"
import { Text } from "../../foundation/text"

const meta: Meta<typeof GestureSurface> = {
	title: "Input/GestureSurface",
	component: GestureSurface,
}

export default meta
type Story = StoryObj<typeof meta>

function DemoButton({
	label,
	color,
	enabled = true,
}: {
	label: string
	color?: string
	enabled?: boolean
}) {
	const [clicks, setClicks] = useState(0)
	return (
		<div
			style={{
				display: "flex",
				flexDirection: "column",
				gap: 4,
				alignItems: "flex-start",
			}}
		>
			<div
				style={{
					position: "relative",
					backgroundColor: vars.bg,
					borderRadius: 4,
					padding: "6px 12px",
					minWidth: 120,
				}}
			>
				<GestureSurface
					color={color ?? vars.pure}
					borderRadius={4}
					enabled={enabled}
					onActivated={() => setClicks((n) => n + 1)}
				/>
				<div style={{ position: "relative", pointerEvents: "none" }}>
					<Text>{label}</Text>
				</div>
			</div>
			<Text style="grey">{clicks > 0 ? `clicked ${clicks}×` : "hover me"}</Text>
		</div>
	)
}

export const Default: Story = {
	render: () => (
		<div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
			<DemoButton label="Hover & click" />
			<DemoButton label="Disabled" enabled={false} />
		</div>
	),
}

export const Dark: Story = {
	globals: { colorScheme: "dark" },
	render: () => (
		<div style={{ display: "flex", gap: 24 }}>
			<DemoButton label="Hover & click" />
			<DemoButton label="Disabled" enabled={false} />
		</div>
	),
}
