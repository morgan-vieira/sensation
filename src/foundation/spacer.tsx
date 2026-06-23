export interface SpacerProps {
	size: number
}

export function Spacer({ size }: SpacerProps) {
	return (
		<div aria-hidden style={{ width: size, height: size, flexShrink: 0 }} />
	)
}
