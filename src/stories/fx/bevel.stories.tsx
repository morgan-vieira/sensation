import type { Meta, StoryObj } from "@storybook/react-vite"
import { vars } from "../../theme"
import { Bevel } from "../../fx/bevel"

const meta: Meta<typeof Bevel> = {
	title: "FX/Bevel",
	component: Bevel,
}

export default meta
type Story = StoryObj<typeof meta>

function Surface({
	children,
	label,
}: {
	children: React.ReactNode
	label: string
}) {
	return (
		<div
			style={{
				display: "flex",
				flexDirection: "column",
				gap: 4,
				alignItems: "flex-start",
			}}
		>
			<span style={{ fontSize: 11, opacity: 0.5 }}>{label}</span>
			<div
				style={{
					position: "relative",
					width: 120,
					height: 32,
					background: vars.bg,
					borderRadius: 4,
				}}
			>
				{children}
			</div>
		</div>
	)
}

export const Raised: Story = {
	render: () => (
		<div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
			<Surface label="height 1 (full)">
				<Bevel height={1} borderRadius={4} />
			</Surface>
			<Surface label="height 0.5">
				<Bevel height={0.5} borderRadius={4} />
			</Surface>
			<Surface label="height 0 (none)">
				<Bevel height={0} borderRadius={4} />
			</Surface>
		</div>
	),
}

export const Sunken: Story = {
	render: () => (
		<div style={{ display: "flex", gap: 24, flexWrap: "wrap" }}>
			<Surface label="height -0.5">
				<Bevel height={-0.5} borderRadius={4} />
			</Surface>
			<Surface label="height -1 (full)">
				<Bevel height={-1} borderRadius={4} />
			</Surface>
		</div>
	),
}

export const Dark: Story = {
	globals: { colorScheme: "dark" },
	render: () => (
		<div style={{ display: "flex", gap: 24 }}>
			<Surface label="raised">
				<Bevel height={1} borderRadius={4} />
			</Surface>
			<Surface label="sunken">
				<Bevel height={-1} borderRadius={4} />
			</Surface>
		</div>
	),
}
