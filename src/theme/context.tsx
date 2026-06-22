import {
	createContext,
	useContext,
	useMemo,
	useSyncExternalStore,
	type CSSProperties,
	type ReactNode,
} from "react"
import { type ThemePalette, MIN_Z, MAX_Z, depthIndex } from "./palette"

declare module "react" {
	interface CSSProperties {
		[key: `--sn-${string}`]: string | undefined
	}
}

export const vars = {
	bg: "var(--sn-bg)",
	fg: "var(--sn-fg)",
	accent: "var(--sn-accent)",
	grey: "var(--sn-grey)",
	fgOnAccent: "var(--sn-fg-on-accent)",
	accentOnAccent: "var(--sn-accent-on-accent)",
	greyOnAccent: "var(--sn-grey-on-accent)",
	fgOnGrey: "var(--sn-fg-on-grey)",
	pure: "var(--sn-pure)",
	pureOnAccent: "var(--sn-pure-on-accent)",
	pureOnGrey: "var(--sn-pure-on-grey)",
} as const

export type ThemeValue = {
	palette: ThemePalette
	zDepth: number
}

const ThemeContext = createContext<ThemeValue | null>(null)

export function useTheme(): ThemeValue {
	const ctx = useContext(ThemeContext)
	if (ctx === null)
		throw new Error("useTheme must be used within a ThemeProvider")
	return ctx
}

function makeVars(palette: ThemePalette, zDepth: number): CSSProperties {
	const i = depthIndex(zDepth)
	return {
		"--sn-bg": palette.bg[i],
		"--sn-fg": palette.fg[i],
		"--sn-accent": palette.accent[i],
		"--sn-grey": palette.grey[i],
		"--sn-fg-on-accent": palette.fgOnAccent[i],
		"--sn-accent-on-accent": palette.accentOnAccent[i],
		"--sn-grey-on-accent": palette.greyOnAccent[i],
		"--sn-fg-on-grey": palette.fgOnGrey[i],
		"--sn-pure": palette.pure[i],
		"--sn-pure-on-accent": palette.pureOnAccent[i],
		"--sn-pure-on-grey": palette.pureOnGrey[i],
	}
}

type ThemeProviderProps = {
	palette: ThemePalette
	children: ReactNode
}

export function ThemeProvider({ palette, children }: ThemeProviderProps) {
	const value = useMemo<ThemeValue>(() => ({ palette, zDepth: 0 }), [palette])
	return (
		<ThemeContext.Provider value={value}>
			<div style={makeVars(palette, 0)}>{children}</div>
		</ThemeContext.Provider>
	)
}

export function useSurface(zOffset = 1): {
	style: CSSProperties
	value: ThemeValue
	ThemeSlot: (props: { children: ReactNode }) => ReactNode
} {
	const { palette, zDepth } = useTheme()
	const newDepth = Math.min(MAX_Z, Math.max(MIN_Z, zDepth + zOffset))
	const value = useMemo<ThemeValue>(
		() => ({ palette, zDepth: newDepth }),
		[palette, newDepth],
	)
	const style = makeVars(palette, newDepth)
	const ThemeSlot = useMemo(
		() =>
			({ children }: { children: ReactNode }) => (
				<ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
			),
		[value],
	)
	return { style, value, ThemeSlot }
}

type SurfaceThemeProps = {
	zOffset?: number
	children: ReactNode
}

export function SurfaceTheme({ zOffset = 1, children }: SurfaceThemeProps) {
	const { style, ThemeSlot } = useSurface(zOffset)
	return (
		<ThemeSlot>
			<div style={style}>{children}</div>
		</ThemeSlot>
	)
}

function subscribeDark(cb: () => void): () => void {
	const mq = window.matchMedia("(prefers-color-scheme: dark)")
	mq.addEventListener("change", cb)
	return () => mq.removeEventListener("change", cb)
}

export function usePrefersDark(): boolean {
	return useSyncExternalStore(
		subscribeDark,
		() => window.matchMedia("(prefers-color-scheme: dark)").matches,
		() => false,
	)
}
