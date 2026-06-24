import type { Meta, StoryObj } from "@storybook/react-vite"
import { Text } from "../../foundation/text"

const meta: Meta<typeof Text> = {
	title: "Foundation/Text",
	component: Text,
}

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
	render: () => (
		<div className="flex flex-col gap-2">
			<Text>Normal text</Text>
			<Text style="grey">Grey text</Text>
			<Text style="heading">Heading text</Text>
			<Text style="accent">Accent text</Text>
			<Text style="atopAccent">AtopAccent text</Text>
		</div>
	),
}

export const Alignment: Story = {
	render: () => (
		<div className="flex flex-col gap-2" style={{ width: 300 }}>
			<Text align={{ x: "start" }}>Align start</Text>
			<Text align={{ x: "mid" }}>Align mid</Text>
			<Text align={{ x: "end" }}>Align end</Text>
		</div>
	),
}

export const Wrapping: Story = {
	render: () => (
		<div className="flex flex-col gap-2" style={{ width: 200 }}>
			<Text wrap>
				This is a long sentence that should wrap across multiple lines when the
				container is narrow.
			</Text>
			<Text>This long sentence will not wrap and overflows instead.</Text>
		</div>
	),
}

export const RichText: Story = {
	render: () => (
		<Text richText>
			{"This has <strong>bold</strong> and <em>italic</em> content."}
		</Text>
	),
}
