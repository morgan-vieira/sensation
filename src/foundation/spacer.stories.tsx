import type { Meta, StoryObj } from "@storybook/react-vite"
import { Spacer } from "./spacer"

const meta: Meta<typeof Spacer> = {
	title: "Foundation/Spacer",
	component: Spacer,
	args: { size: 32 },
	argTypes: {
		size: { control: { type: "range", min: 0, max: 200, step: 4 } },
	},
}

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
	render: (args) => (
		<div className="flex items-center">
			<div className="size-8 rounded bg-current opacity-20" />
			<Spacer {...args} />
			<div className="size-8 rounded bg-current opacity-20" />
		</div>
	),
}
