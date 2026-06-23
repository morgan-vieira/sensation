import type { Meta, StoryObj } from "@storybook/react-vite"
import { Divider } from "./divider"

const meta: Meta<typeof Divider> = {
	title: "Foundation/Divider",
	component: Divider,
	args: { direction: "horizontal" },
	argTypes: {
		direction: { control: "radio", options: ["horizontal", "vertical"] },
	},
}

export default meta
type Story = StoryObj<typeof meta>

export const Horizontal: Story = {
	args: { direction: "horizontal" },
	render: (args) => (
		<div className="flex w-64 flex-col gap-3">
			<span>Above</span>
			<Divider {...args} />
			<span>Below</span>
		</div>
	),
}

export const Vertical: Story = {
	args: { direction: "vertical" },
	render: (args) => (
		<div className="flex h-16 items-center gap-3">
			<span>Left</span>
			<Divider {...args} />
			<span>Right</span>
		</div>
	),
}
