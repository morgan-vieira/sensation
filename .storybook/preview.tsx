import type { Preview, Decorator } from "@storybook/react-vite"
import {
	ThemeProvider,
	createLightPalette,
	createDarkPalette,
	vars,
} from "../src/theme"
import "../src/style.css"

function hexToHue(hex: string): number {
	const r = parseInt(hex.slice(1, 3), 16) / 255
	const g = parseInt(hex.slice(3, 5), 16) / 255
	const b = parseInt(hex.slice(5, 7), 16) / 255
	const max = Math.max(r, g, b)
	const min = Math.min(r, g, b)
	const d = max - min
	if (d === 0) return 0
	let h = 0
	if (max === r) h = ((g - b) / d) % 6
	else if (max === g) h = (b - r) / d + 2
	else h = (r - g) / d + 4
	return (h * 60 + 360) % 360
}

function ThemedCanvas({ children }: { children: React.ReactNode }) {
	return (
		<div style={{ minHeight: "100vh", background: vars.bg, color: vars.fg }}>
			{children}
		</div>
	)
}

const withTheme: Decorator = (Story, context) => {
	const scheme = (context.globals.colorScheme ?? "light") as "light" | "dark"
	const accentColor =
		(context.args.accentColor as string | undefined) ?? "#4060ff"
	const hue = hexToHue(accentColor)
	const palette =
		scheme === "dark" ? createDarkPalette(hue) : createLightPalette(hue)

	return (
		<ThemeProvider palette={palette}>
			<ThemedCanvas>
				<Story />
			</ThemedCanvas>
		</ThemeProvider>
	)
}

const preview: Preview = {
	globalTypes: {
		colorScheme: {
			description: "Color scheme",
			toolbar: {
				title: "Color scheme",
				icon: "mirror",
				items: [
					{ value: "light", title: "Light" },
					{ value: "dark", title: "Dark" },
				],
				dynamicTitle: true,
			},
		},
	},
	initialGlobals: {
		colorScheme: "light",
	},
	args: {
		accentColor: "#4060ff",
	},
	argTypes: {
		accentColor: {
			control: { type: "color" },
			description: "Accent colour",
		},
	},
	decorators: [withTheme],
	parameters: {
		layout: "centered",
	},
}

export default preview
