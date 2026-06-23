import { describe, it, expect } from "vitest"
import {
	createPalette,
	createLightPalette,
	createDarkPalette,
	MIN_Z,
	MAX_Z,
	depthIndex,
} from "./palette"

describe("createPalette", () => {
	it("produces an entry for every z-depth level", () => {
		const palette = createPalette(0.5, 240)
		const expectedCount = MAX_Z - MIN_Z + 1

		expect(palette.bg).toHaveLength(expectedCount)
		expect(palette.fg).toHaveLength(expectedCount)
		expect(palette.accent).toHaveLength(expectedCount)
		expect(palette.shouldInvert).toHaveLength(expectedCount)
	})

	it("outputs valid CSS oklch() strings", () => {
		const palette = createPalette(0.5, 240)
		const oklch = /^oklch\(.+ .+ .+\)$/

		for (const color of palette.bg) {
			expect(color).toMatch(oklch)
		}
	})

	it("inverts fg on light backgrounds", () => {
		// baseLightness 0.92 at z=0 → light bg → should invert (dark text)
		const palette = createLightPalette(240)
		const i = depthIndex(0)

		expect(palette.shouldInvert[i]).toBe(true)
	})

	it("does not invert fg on dark backgrounds", () => {
		// baseLightness 0.3 at z=0 → dark bg → should not invert (light text)
		const palette = createDarkPalette(240)
		const i = depthIndex(0)

		expect(palette.shouldInvert[i]).toBe(false)
	})

	it("clamps z-depth within bounds", () => {
		const palette = createPalette(0.5, 240)

		expect(depthIndex(MIN_Z - 5)).toBe(depthIndex(MIN_Z))
		expect(depthIndex(MAX_Z + 5)).toBe(depthIndex(MAX_Z))
	})

	it("produces different bg colors at different z-depths", () => {
		const palette = createLightPalette(240)

		expect(palette.bg[depthIndex(0)]).not.toBe(palette.bg[depthIndex(1)])
		expect(palette.bg[depthIndex(0)]).not.toBe(palette.bg[depthIndex(-1)])
	})
})
