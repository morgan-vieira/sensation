import { describe, it, expect } from "vitest"
import { render } from "@testing-library/react"
import { ThemeProvider, createLightPalette } from "../theme"
import { Bullet } from "./bullet"

function wrap(ui: React.ReactElement) {
	return render(
		<ThemeProvider palette={createLightPalette(240)}>{ui}</ThemeProvider>,
	)
}

describe("Bullet", () => {
	it("renders children", () => {
		const { getByText } = wrap(<Bullet>Hello</Bullet>)
		expect(getByText("Hello")).toBeInTheDocument()
	})

	it("renders a hidden dot element", () => {
		const { container } = wrap(<Bullet>Item</Bullet>)
		const dot = container.querySelector("[aria-hidden]") as HTMLElement

		expect(dot).toBeInTheDocument()
		expect(dot.style.width).toBe("4px")
		expect(dot.style.height).toBe("4px")
		expect(dot.style.borderRadius).toBe("50%")
	})

	it("offsets content from the left", () => {
		const { container } = render(<Bullet>Item</Bullet>)
		const outer = container.firstElementChild as HTMLElement

		expect(outer.style.paddingLeft).toBe("12px")
	})
})
