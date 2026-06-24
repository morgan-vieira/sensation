import { describe, it, expect } from "vitest"
import { render } from "@testing-library/react"
import { ThemeProvider, createLightPalette, vars } from "../theme"
import { Text } from "./text"

function wrap(ui: React.ReactElement) {
	return render(
		<ThemeProvider palette={createLightPalette(240)}>{ui}</ThemeProvider>,
	)
}

describe("Text", () => {
	it("renders children", () => {
		const { getByText } = wrap(<Text>Hello</Text>)
		expect(getByText("Hello")).toBeInTheDocument()
	})

	it("defaults to fg color and 14px font size", () => {
		const { getByText } = wrap(<Text>Hello</Text>)
		const el = getByText("Hello") as HTMLElement
		expect(el.style.color).toBe(vars.fg)
		expect(el.style.fontSize).toBe("14px")
	})

	it("uses accent color for accent style", () => {
		const { getByText } = wrap(<Text style="accent">Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.color).toBe(vars.accent)
	})

	it("uses fgOnAccent color for atopAccent style", () => {
		const { getByText } = wrap(<Text style="atopAccent">Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.color).toBe(
			vars.fgOnAccent,
		)
	})

	it("uses grey color for grey style", () => {
		const { getByText } = wrap(<Text style="grey">Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.color).toBe(vars.grey)
	})

	it("uses 21px font size for heading style", () => {
		const { getByText } = wrap(<Text style="heading">Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.fontSize).toBe("21px")
	})

	it("applies textAlign from align.x", () => {
		const { getByText } = wrap(<Text align={{ x: "mid" }}>Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.textAlign).toBe("center")
	})

	it("applies nowrap by default", () => {
		const { getByText } = wrap(<Text>Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.whiteSpace).toBe("nowrap")
	})

	it("allows wrapping when wrap is true", () => {
		const { getByText } = wrap(<Text wrap>Hello</Text>)
		expect((getByText("Hello") as HTMLElement).style.whiteSpace).toBe("")
	})

	it("renders rich text via innerHTML when richText is true", () => {
		const { container } = wrap(
			<Text richText>{"Hello <strong>world</strong>"}</Text>,
		)
		expect(container.querySelector("strong")).toBeInTheDocument()
	})

	it("applies 2px horizontal padding", () => {
		const { getByText } = wrap(<Text>Hello</Text>)
		const el = getByText("Hello") as HTMLElement
		expect(el.style.paddingLeft).toBe("2px")
		expect(el.style.paddingRight).toBe("2px")
	})
})
