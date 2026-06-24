import type { Meta, StoryObj } from "@storybook/react-vite"
import {
	ThemeProvider,
	createLightPalette,
	createDarkPalette,
	vars,
} from "../../theme"
import { Panel } from "../../foundation/panel"
import { Text } from "../../foundation/text"

const meta: Meta<typeof Panel> = {
	title: "Foundation/Panel",
	component: Panel,
	decorators: [
		(Story) => (
			<ThemeProvider palette={createLightPalette(240)}>
				<div style={{ padding: 32, background: vars.bg }}>
					<Story />
				</div>
			</ThemeProvider>
		),
	],
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
	decorators: [
		(Story) => (
			<ThemeProvider palette={createDarkPalette(240)}>
				<div style={{ padding: 32, background: vars.bg }}>
					<Story />
				</div>
			</ThemeProvider>
		),
	],
	render: () => (
		<Panel>
			<div style={{ padding: 16 }}>
				<Text>Dark theme panel</Text>
			</div>
		</Panel>
	),
}
