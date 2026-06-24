import type { Meta, StoryObj } from "@storybook/react-vite"
import { Panel } from "../../foundation/panel"
import { Button } from "../../foundation/button"

const meta: Meta<typeof Button> = {
	title: "Foundation/Button",
	component: Button,
}

export default meta
type Story = StoryObj<typeof meta>

const row = {
	display: "flex",
	gap: 8,
	alignItems: "center",
	flexWrap: "wrap" as const,
}

export const Variants: Story = {
	render: () => (
		<div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
			<div style={row}>
				<Button onActivated={() => alert("clicked")}>Normal</Button>
				<Button flat onActivated={() => alert("clicked")}>
					Flat
				</Button>
				<Button subtle onActivated={() => alert("clicked")}>
					Subtle
				</Button>
				<Button enabled={false}>Disabled</Button>
			</div>
			<div style={row}>
				<Button illuminated onActivated={() => alert("clicked")}>
					Illuminated
				</Button>
				<Button illuminated flat onActivated={() => alert("clicked")}>
					Illuminated flat
				</Button>
				<Button illuminated enabled={false}>
					Illuminated disabled
				</Button>
			</div>
		</div>
	),
}

export const OnPanel: Story = {
	render: () => (
		<Panel>
			<div style={{ padding: 16, display: "flex", gap: 8 }}>
				<Button onActivated={() => alert("clicked")}>Action</Button>
				<Button flat onActivated={() => alert("clicked")}>
					Cancel
				</Button>
				<Button illuminated onActivated={() => alert("clicked")}>
					Confirm
				</Button>
			</div>
		</Panel>
	),
}

export const Dark: Story = {
	globals: { colorScheme: "dark" },
	render: () => (
		<div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
			<div style={row}>
				<Button onActivated={() => {}}>Normal</Button>
				<Button flat onActivated={() => {}}>
					Flat
				</Button>
				<Button subtle onActivated={() => {}}>
					Subtle
				</Button>
				<Button enabled={false}>Disabled</Button>
			</div>
			<div style={row}>
				<Button illuminated onActivated={() => {}}>
					Illuminated
				</Button>
				<Button illuminated flat onActivated={() => {}}>
					Illuminated flat
				</Button>
			</div>
		</div>
	),
}
