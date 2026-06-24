import type { Meta, StoryObj } from "@storybook/react-vite"
import { Panel } from "../../foundation/panel"
import { Text } from "../../foundation/text"

const meta: Meta<typeof Panel> = {
	title: "Foundation/Panel",
	component: Panel,
}

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
	render: () => (
		<Panel>
			<div style={{ padding: 16 }}>
				<Text>Content inside a panel</Text>
			</div>
		</Panel>
	),
}

export const Nested: Story = {
	render: () => (
		<Panel>
			<div
				style={{
					padding: 16,
					display: "flex",
					flexDirection: "column",
					gap: 8,
				}}
			>
				<Text style="heading">Outer panel</Text>
				<Panel>
					<div style={{ padding: 12 }}>
						<Text style="grey">Nested panel steps z-depth again</Text>
					</div>
				</Panel>
			</div>
		</Panel>
	),
}

export const Dark: Story = {
	globals: { colorScheme: "dark" },
	render: () => (
		<Panel>
			<div style={{ padding: 16 }}>
				<Text>Dark theme panel</Text>
			</div>
		</Panel>
	),
}
