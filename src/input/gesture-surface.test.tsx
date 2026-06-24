import { describe, it, expect, vi } from "vitest"
import { render, fireEvent } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { GestureSurface } from "./gesture-surface"

function el(props: React.ComponentProps<typeof GestureSurface> = {}) {
	return render(<GestureSurface {...props} />).container
		.firstChild as HTMLElement
}

describe("GestureSurface", () => {
	it("renders a single div", () => {
		expect(el()).toBeInstanceOf(HTMLDivElement)
	})

	it("covers its parent via absolute positioning", () => {
		const div = el()
		expect(div.style.position).toBe("absolute")
		expect(div.style.top).toBe("0px")
		expect(div.style.right).toBe("0px")
		expect(div.style.bottom).toBe("0px")
		expect(div.style.left).toBe("0px")
	})

	it("applies borderRadius", () => {
		expect(el({ borderRadius: 4 }).style.borderRadius).toBe("4px")
	})

	it("shows pointer cursor when enabled", () => {
		expect(el({ enabled: true }).style.cursor).toBe("pointer")
	})

	it("shows default cursor when disabled", () => {
		expect(el({ enabled: false }).style.cursor).toBe("default")
	})

	it("is opacity 0 before hover", () => {
		expect(el().style.opacity).toBe("0")
	})

	it("is opacity 0.5 while hovering", async () => {
		const user = userEvent.setup()
		const { container } = render(<GestureSurface />)
		const div = container.firstChild as HTMLElement
		await user.hover(div)
		expect(div.style.opacity).toBe("0.5")
	})

	it("is opacity 0 after hover leaves", async () => {
		const user = userEvent.setup()
		const { container } = render(<GestureSurface />)
		const div = container.firstChild as HTMLElement
		await user.hover(div)
		await user.unhover(div)
		expect(div.style.opacity).toBe("0")
	})

	it("shows radial-gradient background on hover", async () => {
		const user = userEvent.setup()
		const { container } = render(<GestureSurface color="white" />)
		const div = container.firstChild as HTMLElement
		await user.hover(div)
		expect(div.style.background).toContain("radial-gradient")
	})

	it("calls onHoverChange(true) on hover", async () => {
		const user = userEvent.setup()
		const onHoverChange = vi.fn()
		const { container } = render(
			<GestureSurface onHoverChange={onHoverChange} />,
		)
		await user.hover(container.firstChild as HTMLElement)
		expect(onHoverChange).toHaveBeenCalledWith(true)
	})

	it("calls onHoverChange(false) on unhover", async () => {
		const user = userEvent.setup()
		const onHoverChange = vi.fn()
		const { container } = render(
			<GestureSurface onHoverChange={onHoverChange} />,
		)
		const div = container.firstChild as HTMLElement
		await user.hover(div)
		await user.unhover(div)
		expect(onHoverChange).toHaveBeenCalledWith(false)
	})

	it("calls onActivated on click", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { container } = render(<GestureSurface onActivated={onActivated} />)
		await user.click(container.firstChild as HTMLElement)
		expect(onActivated).toHaveBeenCalledOnce()
	})

	it("does not call onActivated when disabled", async () => {
		const user = userEvent.setup()
		const onActivated = vi.fn()
		const { container } = render(
			<GestureSurface enabled={false} onActivated={onActivated} />,
		)
		await user.click(container.firstChild as HTMLElement)
		expect(onActivated).not.toHaveBeenCalled()
	})

	it("does not call onHoverChange when disabled", async () => {
		const user = userEvent.setup()
		const onHoverChange = vi.fn()
		const { container } = render(
			<GestureSurface enabled={false} onHoverChange={onHoverChange} />,
		)
		await user.hover(container.firstChild as HTMLElement)
		expect(onHoverChange).not.toHaveBeenCalled()
	})

	it("is opacity 0 when pressed", () => {
		const { container } = render(<GestureSurface />)
		const div = container.firstChild as HTMLElement
		fireEvent.pointerEnter(div)
		fireEvent.pointerDown(div)
		expect(div.style.opacity).toBe("0")
	})

	it("restores opacity 0.5 after pointer up", () => {
		const { container } = render(<GestureSurface />)
		const div = container.firstChild as HTMLElement
		fireEvent.pointerEnter(div)
		fireEvent.pointerDown(div)
		fireEvent.pointerUp(div)
		expect(div.style.opacity).toBe("0.5")
	})
})
