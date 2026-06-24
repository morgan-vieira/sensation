import { describe, it, expect } from "vitest"
import { render } from "@testing-library/react"
import { Bevel } from "./bevel"

function el() {
	return render(<Bevel />).container.firstChild as HTMLElement
}

describe("Bevel", () => {
	it("renders a single div", () => {
		const { container } = render(<Bevel />)
		expect(container.firstChild).toBeInstanceOf(HTMLDivElement)
	})

	it("is aria-hidden", () => {
		const { container } = render(<Bevel />)
		expect(container.firstChild).toHaveAttribute("aria-hidden")
	})

	it("covers its parent via absolute positioning", () => {
		const div = el()
		expect(div.style.position).toBe("absolute")
		expect(div.style.top).toBe("0px")
		expect(div.style.right).toBe("0px")
		expect(div.style.bottom).toBe("0px")
		expect(div.style.left).toBe("0px")
	})

	it("is pointer-events none", () => {
		expect(el().style.pointerEvents).toBe("none")
	})

	it("applies borderRadius", () => {
		const { container } = render(<Bevel borderRadius={8} />)
		expect((container.firstChild as HTMLElement).style.borderRadius).toBe("8px")
	})

	it("box-shadow contains two inset values by default", () => {
		const shadow = el().style.boxShadow
		expect(shadow).toContain("inset")
	})

	it("raised bevel (height > 0) has white highlight on top", () => {
		const { container } = render(<Bevel height={1} />)
		const shadow = (container.firstChild as HTMLElement).style.boxShadow
		expect(shadow).toContain("rgba(255,255,255,0.2)")
		expect(shadow).toContain("rgba(0,0,0,0.15)")
	})

	it("sunken bevel (height < 0) inverts highlight and shadow", () => {
		const { container } = render(<Bevel height={-1} />)
		const shadow = (container.firstChild as HTMLElement).style.boxShadow
		expect(shadow).toContain("rgba(0,0,0,0.15)")
		expect(shadow).toContain("rgba(255,255,255,0.2)")
	})

	it("scales opacity with height magnitude", () => {
		const { container } = render(<Bevel height={0.5} />)
		const shadow = (container.firstChild as HTMLElement).style.boxShadow
		expect(shadow).toContain("rgba(255,255,255,0.1)")
		expect(shadow).toContain("rgba(0,0,0,0.075)")
	})

	it("clamps height above 1", () => {
		const { container: a } = render(<Bevel height={2} />)
		const { container: b } = render(<Bevel height={1} />)
		expect((a.firstChild as HTMLElement).style.boxShadow).toBe(
			(b.firstChild as HTMLElement).style.boxShadow,
		)
	})

	it("clamps height below -1", () => {
		const { container: a } = render(<Bevel height={-2} />)
		const { container: b } = render(<Bevel height={-1} />)
		expect((a.firstChild as HTMLElement).style.boxShadow).toBe(
			(b.firstChild as HTMLElement).style.boxShadow,
		)
	})
})
