import { describe, it, expect, vi } from "vitest"
import { render, fireEvent } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { ThemeProvider, createLightPalette, vars } from "../theme"
import { Button } from "./button"

const palette = createLightPalette(240)

function wrap(ui: React.ReactElement) {
	return render(<ThemeProvider palette={palette}>{ui}</ThemeProvider>)
}

describe("Button", () => {
	it("renders children as text", () => {
		const { getByText } = wrap(<Button>Click me</Button>)
		expect(getByText("Click me")).toBeInTheDocument()
	})

	it("has role=button", () => {
		const { getByRole } = wrap(<Button>Label</Button>)
		expect(getByRole("button")).toBeInTheDocument()
	})

	it("is 24px tall", () => {
		const { getByRole } = wrap(<Button>Label</Button>)
		expect(getByRole("button").style.height).toBe("24px")
	})

	it("has border-radius 4px", () => {
		const { getByRole } = wrap(<Button>Label</Button>)
		expect(getByRole("button").style.borderRadius).toBe("4px")
	})

	it("is inline-flex", () => {
		const { getByRole } = wrap(<Button>Label</Button>)
		expect(getByRole("button").style.display).toBe("inline-flex")
	})

	it("default background is vars.bg (elevated)", () => {
		const { getByRole } = wrap(<Button>Label</Button>)
		expect(getByRole("button").style.backgroundColor).toBe(vars.bg)
	})

	it("flat button has transparent background", () => {
		const { getByRole } = wrap(<Button flat>Label</Button>)
		expect(getByRole("button").style.backgroundColor).toBe("transparent")
	})

	it("illuminated button uses accent background", () => {
		const { getByRole } = wrap(<Button illuminated>Label</Button>)
		expect(getByRole("button").style.backgroundColor).toBe(vars.accent)
	})

	it("subtle button has transparent background when not hovering", () => {
		const { getByRole } = wrap(<Button subtle>Label</Button>)
		expect(getByRole("button").style.backgroundColor).toBe("transparent")
	})

	it("text style is normal by default", () => {
		const { getByText } = wrap(<Button>Label</Button>)
		expect((getByText("Label") as HTMLElement).style.color).toBe(vars.fg)
	})

	it("text style is grey when subtle", () => {
		const { getByText } = wrap(<Button subtle>Label</Button>)
		expect((getByText("Label") as HTMLElement).style.color).toBe(vars.grey)
	})

	it("text style is atopAccent when illuminated", () => {
		const { getByText } = wrap(<Button illuminated>Label</Button>)
		expect((getByText("Label") as HTMLElement).style.color).toBe(
			vars.fgOnAccent,
		)
	})

	it("aligns content to center by default", () => {
		const { getByRole } = wrap(<Button>Label</Button>)
		expect(getByRole("button").style.justifyContent).toBe("center")
	})

	it("aligns content to flex-start when align is left", () => {
		const { getByRole } = wrap(<Button align="left">Label</Button>)
		expect(getByRole("button").style.justifyContent).toBe("flex-start")
	})

	it("calls onActivated on click", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { getByRole } = wrap(<Button onActivated={onActivated}>Click</Button>)
		await user.click(getByRole("button"))
		expect(onActivated).toHaveBeenCalledOnce()
	})

	it("calls onActivated on Enter key", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { getByRole } = wrap(<Button onActivated={onActivated}>Click</Button>)
		getByRole("button").focus()
		await user.keyboard("{Enter}")
		expect(onActivated).toHaveBeenCalledOnce()
	})

	it("calls onActivated on Space key", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { getByRole } = wrap(<Button onActivated={onActivated}>Click</Button>)
		getByRole("button").focus()
		await user.keyboard(" ")
		expect(onActivated).toHaveBeenCalledOnce()
	})

	it("does not call onActivated when disabled", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { getByRole } = wrap(
			<Button enabled={false} onActivated={onActivated}>
				Click
			</Button>,
		)
		await user.click(getByRole("button"))
		expect(onActivated).not.toHaveBeenCalled()
	})

	it("has aria-disabled when not enabled", () => {
		const { getByRole } = wrap(<Button enabled={false}>Label</Button>)
		expect(getByRole("button")).toHaveAttribute("aria-disabled", "true")
	})

	it("subtle button raises on hover", async () => {
		const user = userEvent.setup()
		const { getByRole } = wrap(<Button subtle>Label</Button>)
		const btn = getByRole("button")
		await user.hover(btn)
		expect(btn.style.backgroundColor).toBe(vars.bg)
	})

	it("renders nothing when children is empty string", () => {
		const { container } = wrap(<Button>{""}</Button>)
		expect(container.querySelector("span")).toBeNull()
	})

	it("is not focusable when disabled", () => {
		const { getByRole } = wrap(<Button enabled={false}>Label</Button>)
		expect(getByRole("button").tabIndex).toBe(-1)
	})

	it("fires onActivated only once per click", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { getByRole } = wrap(<Button onActivated={onActivated}>Click</Button>)
		await user.click(getByRole("button"))
		expect(onActivated).toHaveBeenCalledTimes(1)
	})
})
