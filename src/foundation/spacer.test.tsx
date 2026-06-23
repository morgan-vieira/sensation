import { describe, it, expect } from "vitest"
import { render } from "@testing-library/react"
import { Spacer } from "./spacer"

describe("Spacer", () => {
	it("renders a hidden div with the given size", () => {
		const { container } = render(<Spacer size={16} />)
		const el = container.firstElementChild as HTMLElement

		expect(el.getAttribute("aria-hidden")).toBe("true")
		expect(el.style.width).toBe("16px")
		expect(el.style.height).toBe("16px")
	})

	it("does not shrink in flex layouts", () => {
		const { container } = render(<Spacer size={8} />)
		const el = container.firstElementChild as HTMLElement

		expect(el.style.flexShrink).toBe("0")
	})
})
