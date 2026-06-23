import { describe, it, expect } from "vitest"
import { render } from "@testing-library/react"
import { ThemeProvider, createLightPalette } from "../theme"
import { Divider } from "./divider"

function wrap(ui: React.ReactElement) {
	return render(
		<ThemeProvider palette={createLightPalette(240)}>{ui}</ThemeProvider>,
	)
}

describe("Divider", () => {
	it("defaults to horizontal", () => {
		const { getByRole } = wrap(<Divider />)
		const el = getByRole("separator")

		expect(el.getAttribute("aria-orientation")).toBe("horizontal")
		expect(el.style.width).toBe("100%")
		expect(el.style.height).toBe("1px")
	})

	it("renders vertically when direction is vertical", () => {
		const { getByRole } = wrap(<Divider direction="vertical" />)
		const el = getByRole("separator")

		expect(el.getAttribute("aria-orientation")).toBe("vertical")
		expect(el.style.width).toBe("1px")
		expect(el.style.height).toBe("100%")
	})

	it("does not shrink in flex layouts", () => {
		const { getByRole } = wrap(<Divider />)
		expect(getByRole("separator").style.flexShrink).toBe("0")
	})
})
