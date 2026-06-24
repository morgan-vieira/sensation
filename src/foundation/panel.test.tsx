import { describe, it, expect } from "vitest"
import { render } from "@testing-library/react"
import { ThemeProvider, useTheme, createLightPalette, vars } from "../theme"
import { Panel } from "./panel"

const palette = createLightPalette(240)

function wrap(ui: React.ReactElement) {
	return render(<ThemeProvider palette={palette}>{ui}</ThemeProvider>)
}

function DepthReader() {
	const { zDepth } = useTheme()
	return <output>{zDepth}</output>
}

describe("Panel", () => {
	it("renders children", () => {
		const { getByText } = wrap(<Panel>hello</Panel>)
		expect(getByText("hello")).toBeInTheDocument()
	})

	it("steps z-depth up by 1 by default", () => {
		const { getByRole } = wrap(
			<Panel>
				<DepthReader />
			</Panel>,
		)
		expect(getByRole("status")).toHaveTextContent("1")
	})

	it("respects a custom zOffset", () => {
		const { getByRole } = wrap(
			<Panel zOffset={3}>
				<DepthReader />
			</Panel>,
		)
		expect(getByRole("status")).toHaveTextContent("3")
	})

	it("sets background to vars.bg", () => {
		const { getByText } = wrap(<Panel>inner</Panel>)
		const el = getByText("inner") as HTMLElement
		expect(el.style.backgroundColor).toBe(vars.bg)
	})

	it("sets border-radius to 8px", () => {
		const { getByText } = wrap(<Panel>inner</Panel>)
		const el = getByText("inner") as HTMLElement
		expect(el.style.borderRadius).toBe("8px")
	})

	it("sets CSS custom properties for the new depth on its div", () => {
		const { getByText } = wrap(<Panel>inner</Panel>)
		const el = getByText("inner") as HTMLElement
		expect(el.style.getPropertyValue("--sn-bg")).not.toBe("")
	})
})
