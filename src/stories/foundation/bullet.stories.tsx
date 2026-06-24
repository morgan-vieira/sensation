import type { Meta, StoryObj } from "@storybook/react-vite"
import { Bullet } from "../../foundation/bullet"

const meta: Meta<typeof Bullet> = {
	title: "Foundation/Bullet",
	component: Bullet,
}

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
	render: () => (
		<div className="flex flex-col gap-1">
			<Bullet>First item in the list</Bullet>
			<Bullet>Second item, a bit longer to show wrapping behaviour</Bullet>
			<Bullet>Third item</Bullet>
		</div>
	),
}

export const Nested: Story = {
	render: () => (
		<div className="flex flex-col gap-1">
			<Bullet>Top level item</Bullet>
			<Bullet>
				<span>Item with nested bullets</span>
				<div className="mt-1 flex flex-col gap-1">
					<Bullet>Nested one</Bullet>
					<Bullet>Nested two</Bullet>
				</div>
			</Bullet>
			<Bullet>Another top level item</Bullet>
		</div>
	),
}
