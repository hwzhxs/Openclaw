# DESIGN-SYSTEM.md — Creator's Design Bible

Inspired by Apple Human Interface Guidelines. Read this before every build.

## Core Principles (Apple HIG)

### 1. Clarity
- Content is the priority. Design supports content, never competes with it.
- Use whitespace generously — it creates breathing room and focus
- Typography creates hierarchy: one font family, vary weight and size
- Icons should be instantly recognizable

### 2. Deference
- The UI should help people understand and interact with content, not compete with it
- Translucent backgrounds, subtle blurs — let content shine through
- Avoid heavy borders and boxes; use space and alignment instead

### 3. Depth
- Use layers, motion, and visual hierarchy to create a sense of space
- Elements at different depths communicate importance and context
- Shadows should be soft, natural, and consistent in direction

## Typography
- **System font stack:** `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif`
- **Heading scale:** Use a clear ratio (e.g. 1.25 or 1.333 modular scale)
- **Line height:** 1.4–1.6 for body text, 1.1–1.2 for headings
- **Letter spacing:** Slightly tight on large headings (-0.02em), normal on body
- **Max line width:** 65–75 characters for readability
- **Font weight pairs:** Regular (400) for body, Semibold (600) for emphasis, Bold (700) for headings

## Color
- **Start with neutrals.** Build the layout in grayscale first, add color for meaning.
- **Accent color:** One primary accent for CTAs and key interactions
- **Semantic colors:** Success (green), Warning (amber), Error (red), Info (blue)
- **Dark mode:** Not inverted — redesigned. Dark grays (#1C1C1E, #2C2C2E) not pure black. Elevated surfaces get lighter.
- **Contrast:** WCAG AA minimum (4.5:1 for text, 3:1 for large text)
- **Gradients:** Subtle, 2-3 colors max, low angle. Never rainbow.

## Spacing & Layout
- **Base unit:** 4px or 8px grid system
- **Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96, 128
- **Consistent padding:** Components use the same internal spacing
- **Responsive breakpoints:** 640, 768, 1024, 1280, 1536
- **Max content width:** 1200–1400px for most layouts
- **Card patterns:** Rounded corners (12–16px), subtle shadow or border, consistent padding

## Animation & Motion

### Timing
- **Micro-interactions:** 150–250ms (hover, toggle, button press)
- **Transitions:** 300–500ms (page transitions, modals, drawers)
- **Complex sequences:** 500–800ms (staggered lists, hero animations)
- **Never exceed 1s** for UI animations — it feels sluggish

### Easing
- **Default:** `ease-out` or `cubic-bezier(0.16, 1, 0.3, 1)` — fast start, gentle landing
- **Enter:** `ease-out` — element arrives and settles
- **Exit:** `ease-in` — element accelerates away
- **Spring physics:** For playful, natural-feeling motion (Framer Motion `spring`)
- **Never use `linear`** for UI animations — it feels robotic

### Principles
- Motion should feel **natural and physical** — things have weight and momentum
- **Stagger children:** Lists and grids animate in sequence (30–50ms delay per item)
- **Scroll-triggered:** Elements animate on enter, once. No repeat unless intentional.
- **Loading states:** Skeleton screens > spinners. Shimmer effect for loading.
- **Reduce motion:** Always respect `prefers-reduced-motion`

### Tools (in order of preference)
1. **CSS transitions/animations** — for simple hover, focus, state changes
2. **Framer Motion / Motion.dev** — for React component animations, gestures, layout
3. **GSAP** — for complex timelines, scroll-triggered sequences, SVG animation
4. **ReactBits** — for pre-built animated components (text, backgrounds, UI)
5. **Three.js / React Three Fiber** — for 3D scenes, WebGL effects

## Components

### Buttons
- Generous padding (12px 24px minimum)
- Rounded corners (8–12px for primary, full-round for icon buttons)
- Hover: subtle scale (1.02) + shadow lift or background shift
- Active: slight scale down (0.98)
- Disabled: reduced opacity (0.5), no hover effects

### Cards
- Rounded corners (12–16px)
- Soft shadow: `0 2px 8px rgba(0,0,0,0.08)` default, lift on hover
- Hover: translate-y -2px + shadow increase
- Consistent padding (16–24px)

### Inputs
- Height: 40–48px
- Border: 1px subtle gray, focus ring with accent color
- Rounded: 8px
- Labels above, not inside (floating labels optional)
- Clear error states with red border + message below

### Navigation
- Sticky/fixed when appropriate
- Blur background on scroll (`backdrop-filter: blur(12px)`)
- Clean, minimal — logo left, links right, no clutter
- Mobile: full-screen overlay or slide-in drawer

### Hero Sections
- Full-viewport or near-full
- Large bold heading, short subtitle, clear CTA
- Background: gradient, image with overlay, or animated (Three.js/ReactBits)
- Text enters with fade-up + slight delay between heading/subtitle/CTA

## Patterns to Default To

### Modern Landing Page
```
Hero (full viewport, animated bg, bold headline)
→ Social proof / logos bar
→ Feature grid (bento/cards with icons)
→ How it works (numbered steps, staggered animation)
→ Testimonials (carousel or grid)
→ Pricing (cards, highlighted recommended)
→ CTA section (gradient bg, centered)
→ Footer (minimal, organized columns)
```

### Dashboard
```
Sidebar nav (collapsible, icons + labels)
Top bar (search, notifications, avatar)
Content area (cards/widgets grid)
Charts with smooth data transitions
Tables with sort/filter, row hover highlight
```

## Anti-Patterns (Never Do These)
- ❌ Pure black (#000) backgrounds — use #0A0A0A or #111
- ❌ Box shadows that look like Photoshop drop shadows
- ❌ Animations longer than 1 second for UI
- ❌ Multiple competing accent colors
- ❌ Text on busy images without overlay
- ❌ Walls of text without visual breaks
- ❌ Carousel/slider as hero (unless explicitly requested)
- ❌ Generic stock photos
- ❌ Hover effects that change layout (cause reflow)
- ❌ Inconsistent border-radius across components

## Reference
- Apple HIG: https://developer.apple.com/design/human-interface-guidelines
- ReactBits: https://reactbits.dev
- Awwwards: https://www.awwwards.com
- Minimal Gallery: https://minimal.gallery
