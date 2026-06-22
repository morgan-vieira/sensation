# Coverage

Status reflects whether the upstream RbxSensation component has been ported to
React in `@morgan-vieira/sensation`. 📌 marks components likely to see the most
use. Plan markers — ➕ Likely to port · ➖ Unlikely to port · 🔁 Revisit if
needed.

## Theme

| Component       | Description                                                                    | Status         | Plan | Notes                                                                          |
| --------------- | ------------------------------------------------------------------------------ | -------------- | ---- | ------------------------------------------------------------------------------ |
| 📌 ThemePalette | Oklab/Oklch color palette pre-computed across z-depth levels                   | ⏳ Planned     | ➕   | Color math ports directly to JS; output as CSS custom properties per elevation |
| 📌 ThemeContext | Per-component color context — bg, fg, accent, grey resolved at a given z-depth | ⏳ Planned     | ➕   | React Context; consumers read CSS vars rather than computed Color3 values      |
| makeIconTheme   | Icon-specific theme derivation (background/foreground slots for icon players)  | ⏳ Planned     | 🔁   | Only needed once an icon system is defined                                     |
| Plugin palette  | Light/dark detection from Roblox Studio's active theme                         | ❌ Not porting | ➖   | Replaced by `prefers-color-scheme` and/or a user-controlled toggle             |

## Foundation

| Component      | Description                                                                      | Status     | Plan | Notes                                                       |
| -------------- | -------------------------------------------------------------------------------- | ---------- | ---- | ----------------------------------------------------------- |
| 📌 Button      | Pressable button with illuminated, flat, and subtle variants; optional icon slot | ⏳ Planned | ➕   |                                                             |
| 📌 Text        | Text label with style variants: normal, grey, heading, accent, atopAccent        | ⏳ Planned | ➕   | `<span>` with theme-derived color; heading bumps font size  |
| 📌 TextField   | Single-line text input                                                           | ⏳ Planned | ➕   | `<input type="text">`                                       |
| 📌 Panel       | Background surface that steps up one z-depth level                               | ⏳ Planned | ➕   | `<div>` with elevation background color from ThemeContext   |
| Divider        | Thin horizontal or vertical separator                                            | ⏳ Planned | ➕   | `<hr>` or styled `<div>`                                    |
| Spacer         | Flexible empty space for filling a flex/grid gap                                 | ⏳ Planned | ➕   | `<div style={{ flex: 1 }}>`                                 |
| Bullet         | Small dot or marker for list-like layouts                                        | ⏳ Planned | ➕   |                                                             |
| Expander       | Collapsible section with animated open/close                                     | ⏳ Planned | ➕   | `<details>` or animated `<div>` via CSS transition          |
| LoadingSpinner | Animated loading indicator                                                       | ⏳ Planned | ➕   | CSS keyframe animation                                      |
| 📌 Switch      | Toggle switch (on/off)                                                           | ⏳ Planned | ➕   | Styled `<input type="checkbox">`                            |
| 📌 Scroller    | Scrollable container with themed custom scrollbar                                | ⏳ Planned | ➕   | CSS `overflow` + `::-webkit-scrollbar` or overlay scrollbar |
| ScrollCarousel | Horizontally scrollable carousel strip                                           | ⏳ Planned | 🔁   |                                                             |
| ScrollTrack    | Scroll thumb and track UI (used inside Scroller)                                 | ⏳ Planned | ➕   | Part of Scroller implementation                             |
| VirtualList    | Virtualized list for large datasets                                              | ⏳ Planned | 🔁   | May defer to TanStack Virtual rather than porting           |

## Compound

| Component   | Description                                      | Status     | Plan | Notes                              |
| ----------- | ------------------------------------------------ | ---------- | ---- | ---------------------------------- |
| 📌 Modal    | Centered dialog overlay with backdrop            | ⏳ Planned | ➕   | `<dialog>` element or React Portal |
| MultiButton | Row of related action buttons sharing a border   | ⏳ Planned | ➕   |                                    |
| EmptyState  | Illustration + message for empty or error states | ⏳ Planned | ➕   |                                    |
| Warning     | Inline warning/alert banner                      | ⏳ Planned | ➕   |                                    |

## FX

| Component         | Description                                     | Status     | Plan | Notes                                                                   |
| ----------------- | ----------------------------------------------- | ---------- | ---- | ----------------------------------------------------------------------- |
| 📌 Bevel          | Raised-edge highlight that conveys elevation    | ⏳ Planned | ➕   | CSS `box-shadow` inset highlight or `border-top`/`border-left` gradient |
| Halo              | Soft glow radiating from a surface              | ⏳ Planned | ➕   | CSS `box-shadow` with spread or `filter: drop-shadow`                   |
| Shadow            | Drop shadow beneath a surface                   | ⏳ Planned | ➕   | CSS `box-shadow`                                                        |
| LightweightCanvas | Minimal compositing surface for custom drawing  | ⏳ Planned | 🔁   | `<canvas>` or CSS `isolation: isolate` layer                            |
| OverlayPortal     | Renders children into a top-level overlay layer | ⏳ Planned | ➕   | `ReactDOM.createPortal` to a `#overlay` root                            |
| TransitionBox     | Container that animates content changes         | ⏳ Planned | ➕   | CSS transitions on opacity/transform                                    |
| FadeTransition    | Declarative fade in/out                         | ⏳ Planned | ➕   | CSS `opacity` transition                                                |
| ManualTransition  | Imperatively controlled transition              | ⏳ Planned | 🔁   | Exposed via a ref handle                                                |

## Input

| Component         | Description                                         | Status         | Plan | Notes                                                   |
| ----------------- | --------------------------------------------------- | -------------- | ---- | ------------------------------------------------------- |
| 📌 GestureSurface | Hover and press capture layer with themed highlight | ⏳ Planned     | ➕   | `onPointerEnter` / `onPointerLeave` / `onClick`         |
| OnHover           | Hover state subscription                            | ⏳ Planned     | ➕   | `useHover` hook                                         |
| OnDrag            | Pointer drag tracking with delta and position       | ⏳ Planned     | ➕   | `useDrag` hook using Pointer Events                     |
| MouseTracker      | Global pointer position tracking                    | ⏳ Planned     | 🔁   | `usePointerPosition` hook                               |
| MousePredictor    | Predictive pointer position to mask input latency   | ❌ Not porting | ➖   | A Roblox network-latency concern; not applicable on web |
