const HIGH_CONTRAST = 0.7
const FG_SWITCH = 0.65

export const MIN_Z = -10
export const MAX_Z = 10

type Oklch = readonly [l: number, c: number, h: number]

function clamp(n: number, lo: number, hi: number) {
	return Math.min(hi, Math.max(lo, n))
}

function inverts(bgL: number) {
	return bgL > FG_SWITCH
}

function bounceL(base: number, z: number): number {
	let l = base + z * 0.04
	while (l < 0 || l > 1) {
		if (l > 1) l = 1.95 - l
		if (l < 0) l = 0.05 - l
	}
	return l
}

function fgColor(bgL: number): Oklch {
	return inverts(bgL)
		? [clamp(bgL - HIGH_CONTRAST, 0, 1), 0, 0]
		: [clamp(bgL + HIGH_CONTRAST, 0, 1), 0, 0]
}

function accentColor(bgL: number, hue: number): Oklch {
	const l =
		bgL > FG_SWITCH
			? clamp(0.55 + (bgL - 0.94) / 2, 0, 1)
			: clamp(0.8 + (bgL - 0.24) / 2, 0, 1)
	return [l, 0.15, hue]
}

function greyColor(bgL: number): Oklch {
	const l =
		bgL > FG_SWITCH
			? clamp(0.55 + (bgL - 0.94) / 2, 0, 1)
			: clamp(0.8 + (bgL - 0.24) / 2, 0, 1)
	return [l, 0, 0]
}

function pureColor(bgL: number): Oklch {
	return inverts(bgL) ? [0.05, 0, 0] : [1, 0, 0]
}

function css([l, c, h]: Oklch): string {
	return `oklch(${l} ${c} ${h})`
}

export function depthIndex(z: number): number {
	return clamp(z, MIN_Z, MAX_Z) - MIN_Z
}

export type ThemePalette = {
	bg: string[]
	fg: string[]
	accent: string[]
	grey: string[]
	fgOnAccent: string[]
	accentOnAccent: string[]
	greyOnAccent: string[]
	fgOnGrey: string[]
	pure: string[]
	pureOnAccent: string[]
	pureOnGrey: string[]
	shouldInvert: boolean[]
}

export function createPalette(
	baseLightness: number,
	accentHue: number,
): ThemePalette {
	const count = MAX_Z - MIN_Z + 1
	const p: ThemePalette = {
		bg: Array(count),
		fg: Array(count),
		accent: Array(count),
		grey: Array(count),
		fgOnAccent: Array(count),
		accentOnAccent: Array(count),
		greyOnAccent: Array(count),
		fgOnGrey: Array(count),
		pure: Array(count),
		pureOnAccent: Array(count),
		pureOnGrey: Array(count),
		shouldInvert: Array(count),
	}

	for (let z = MIN_Z; z <= MAX_Z; z++) {
		const i = z - MIN_Z
		const bgL = bounceL(baseLightness, z)
		const ac = accentColor(bgL, accentHue)
		const gr = greyColor(bgL)

		p.bg[i] = css([bgL, 0, 0])
		p.fg[i] = css(fgColor(bgL))
		p.accent[i] = css(ac)
		p.grey[i] = css(gr)
		p.fgOnAccent[i] = css(fgColor(ac[0]))
		p.accentOnAccent[i] = css(accentColor(ac[0], accentHue))
		p.greyOnAccent[i] = css(greyColor(ac[0]))
		p.fgOnGrey[i] = css(fgColor(gr[0]))
		p.pure[i] = css(pureColor(bgL))
		p.pureOnAccent[i] = css(pureColor(ac[0]))
		p.pureOnGrey[i] = css(pureColor(gr[0]))
		p.shouldInvert[i] = inverts(bgL)
	}

	return p
}

export const createLightPalette = (accentHue: number) =>
	createPalette(0.92, accentHue)

export const createDarkPalette = (accentHue: number) =>
	createPalette(0.3, accentHue)
