import type { Meta, StoryObj } from "@storybook/react-vite"
import {
	ThemeProvider,
	SurfaceTheme,
	createLightPalette,
	createDarkPalette,
	vars,
} from "./index"

type PaletteArgs = { accentColor: string }

const meta: Meta<PaletteArgs> = {
	title: "Theme/Palette",
	parameters: { layout: "fullscreen" },
	args: { accentColor: "#4060ff" },
}

export default meta
type Story = StoryObj<typeof meta>

function Swatch({ label }: { label: string }) {
	return (
		<div
			className="flex flex-col items-center gap-1"
			style={{ minWidth: "5rem" }}
		>
			<div
				className="size-10 rounded-md border border-black/10"
				style={{ background: label }}
			/>
			<span className="text-center font-mono" style={{ fontSize: "0.6rem" }}>
				{label.replace("var(", "").replace(")", "")}
			</span>
		</div>
	)
}

const slots = [
	vars.bg,
	vars.fg,
	vars.accent,
	vars.grey,
	vars.pure,
	vars.fgOnAccent,
	vars.accentOnAccent,
	vars.greyOnAccent,
	vars.fgOnGrey,
	vars.pureOnAccent,
	vars.pureOnGrey,
]

function ZDepthRow({ depth }: { depth: number }) {
	return (
		<div className="flex items-center gap-4 px-4 py-3">
			<span className="w-6 shrink-0 font-mono text-xs opacity-50">
				{depth > 0 ? `+${depth}` : depth}
			</span>
			<div className="flex flex-wrap gap-3">
				{slots.map((v) => (
					<Swatch key={v} label={v} />
				))}
			</div>
		</div>
	)
}

function PaletteGrid({ hue }: { hue: number }) {
	return (
		<div className="flex flex-col divide-y">
			<ThemeProvider palette={createLightPalette(hue)}>
				<ZDepthRow depth={0} />
				<SurfaceTheme zOffset={1}>
					<ZDepthRow depth={1} />
					<SurfaceTheme zOffset={1}>
						<ZDepthRow depth={2} />
					</SurfaceTheme>
				</SurfaceTheme>
				<SurfaceTheme zOffset={-1}>
					<ZDepthRow depth={-1} />
				</SurfaceTheme>
			</ThemeProvider>
			<ThemeProvider palette={createDarkPalette(hue)}>
				<ZDepthRow depth={0} />
				<SurfaceTheme zOffset={1}>
					<ZDepthRow depth={1} />
					<SurfaceTheme zOffset={1}>
						<ZDepthRow depth={2} />
					</SurfaceTheme>
				</SurfaceTheme>
				<SurfaceTheme zOffset={-1}>
					<ZDepthRow depth={-1} />
				</SurfaceTheme>
			</ThemeProvider>
		</div>
	)
}

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

export const Default: Story = {
	render: (args) => <PaletteGrid hue={hexToHue(args.accentColor)} />,
}
