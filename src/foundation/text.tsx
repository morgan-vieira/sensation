import { vars } from "../theme"

export type TextStyle = "normal" | "grey" | "heading" | "accent" | "atopAccent"

export interface TextProps {
	children: string
	style?: TextStyle
	align?: {
		x?: "start" | "mid" | "end"
		y?: "start" | "mid" | "end"
	}
	wrap?: boolean
	richText?: boolean
}

const TEXT_ALIGN = {
	start: "left",
	mid: "center",
	end: "right",
} as const

const ALIGN_SELF = {
	start: "flex-start",
	mid: "center",
	end: "flex-end",
} as const

function colorFor(style: TextStyle | undefined): string {
	if (style === "accent") return vars.accent
	if (style === "atopAccent") return vars.fgOnAccent
	if (style === "grey") return vars.grey
	return vars.fg
}

export function Text({
	children,
	style,
	align,
	wrap = false,
	richText = false,
}: TextProps) {
	const spanStyle = {
		display: "block",
		color: colorFor(style),
		fontSize: style === "heading" ? 21 : 14,
		textAlign: TEXT_ALIGN[align?.x ?? "start"],
		...(align?.y !== undefined ? { alignSelf: ALIGN_SELF[align.y] } : {}),
		whiteSpace: wrap ? undefined : ("nowrap" as const),
		overflowWrap: wrap ? ("break-word" as const) : undefined,
		paddingLeft: 2,
		paddingRight: 2,
	}

	if (richText) {
		return (
			<span style={spanStyle} dangerouslySetInnerHTML={{ __html: children }} />
		)
	}

	return <span style={spanStyle}>{children}</span>
}
