import { describe, it, expect } from "vitest"
import { render, screen } from "@testing-library/react"
import { ThemeProvider, SurfaceTheme, useTheme } from "./context"
import { createLightPalette } from "./palette"

const palette = createLightPalette(240)

function ThemeInspector() {
	const { zDepth } = useTheme()
	return <output>{zDepth}</output>
}

describe("ThemeProvider", () => {
	it("renders children", () => {
		render(
			<ThemeProvider palette={palette}>
				<span>hello</span>
			</ThemeProvider>,
		)

		expect(screen.getByText("hello")).toBeInTheDocument()
	})

	it("sets z-depth to 0 at root", () => {
		render(
			<ThemeProvider palette={palette}>
				<ThemeInspector />
			</ThemeProvider>,
		)

		expect(screen.getByRole("status")).toHaveTextContent("0")
	})

	it("sets CSS custom properties on its wrapper div", () => {
		const { container } = render(
			<ThemeProvider palette={palette}>
				<span />
			</ThemeProvider>,
		)

		const wrapper = container.firstElementChild as HTMLElement
		expect(wrapper.style.getPropertyValue("--sn-bg")).not.toBe("")
		expect(wrapper.style.getPropertyValue("--sn-fg")).not.toBe("")
	})
})

describe("SurfaceTheme", () => {
	it("increments z-depth by 1 by default", () => {
		render(
			<ThemeProvider palette={palette}>
				<SurfaceTheme>
					<ThemeInspector />
				</SurfaceTheme>
			</ThemeProvider>,
		)

		expect(screen.getByRole("status")).toHaveTextContent("1")
	})

	it("respects a custom zOffset", () => {
		render(
			<ThemeProvider palette={palette}>
				<SurfaceTheme zOffset={3}>
					<ThemeInspector />
				</SurfaceTheme>
			</ThemeProvider>,
		)

		expect(screen.getByRole("status")).toHaveTextContent("3")
	})

	it("sets updated CSS custom properties at the new depth", () => {
		const { container } = render(
			<ThemeProvider palette={palette}>
				<SurfaceTheme zOffset={2}>
					<span />
				</SurfaceTheme>
			</ThemeProvider>,
		)

		// ThemeProvider wrapper → SurfaceTheme wrapper
		const surfaceWrapper = container.firstElementChild
			?.firstElementChild as HTMLElement
		expect(surfaceWrapper.style.getPropertyValue("--sn-bg")).not.toBe("")
	})
})

describe("useTheme", () => {
	it("throws outside of ThemeProvider", () => {
		// suppress the expected console.error from React
		const consoleError = console.error
		console.error = () => {}

		expect(() => render(<ThemeInspector />)).toThrow(
			"useTheme must be used within a ThemeProvider",
		)

		console.error = consoleError
	})
})
