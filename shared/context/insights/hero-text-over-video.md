# Research: Slogan Text Over Hero Video/Image — Design Techniques

Requested by: Xiaosong (2026-02-27)
Context: How to design large hero text that works with a video/image background

---

## The Core Problem

Large text on a dynamic background (video/image) creates a legibility war:
- Background is busy and constantly changing
- Text needs to be readable at all sizes/scroll positions
- It needs to feel intentional, not like an afterthought

---

## Technique 1: Dark Overlay (Most Common, Often Boring)

### How it works
A semi-transparent dark layer sits between video and text.
```css
background: linear-gradient(to bottom, rgba(0,0,0,0.5), rgba(0,0,0,0.3));
```

### When it works
- Everyday marketing sites, product landing pages
- When the video mood matters less than readability
- Safe, functional, but not memorable

### The Problem
Everyone uses this. It dulls the video. The text and video feel disconnected.

---

## Technique 2: Text Blur / Frosted Glass Behind Text

### How it works
The text has a `backdrop-filter: blur()` behind it — the video shows through but blurred.
Creates a "frosted" panel that lets you feel the video without reading it.

### Notable examples
- Apple product pages, iOS-inspired sites
- Luxury brand sites (watches, perfume)

### Implementation
```css
.hero-text-container {
  backdrop-filter: blur(12px) saturate(0.7);
  background: rgba(0,0,0,0.15);
  border-radius: 2px;
}
```

### Visual effect
Video feels present, text is crisp, modern/premium feel.

---

## Technique 3: Full Blend — Text AS Part of the Video (Advanced)

### How it works
`mix-blend-mode: overlay` or `difference` on the text — the video actually changes how the letters look.

The text is invisible in dark areas, bold in light areas. It "lives inside" the video.

### Notable examples
- **Balenciaga**, **Rick Owens** fashion sites
- **Lusion.co** style — text that feels part of the visual fabric
- Awwwards-winning immersive sites

### Implementation
```css
.hero-headline {
  mix-blend-mode: overlay; /* or 'difference', 'screen', 'hard-light' */
  color: white;
}
```

### Visual effect
Extremely cinematic. Text doesn't sit ON the video — it inhabits it. Works best with large, bold, clean sans-serif.

### Caution
Hard to guarantee readability. Best for mood/impact, not information. Pair with a legible subtitle below.

---

## Technique 4: Cinematic Dark Base + Minimal Overlay + Maximum Type Scale (Recommended)

### How it works
- Reduce video brightness/saturation via CSS filter
- Use MASSIVE type (10vw–15vw) with low weight (200–300) so the video shows through the letterforms' negative space
- Minimal or no overlay

### Why this works
The type IS the design element. It's not fighting the video — they coexist. The negative space of the letters becomes a "window" to the video.

### Notable examples
- **landonorris.com** — "2025 McLaren Formula 1 Driver" against racing video. Type is oversized, the track shows through.
- **Mana Yerba Mate** hero — oversized product name at low opacity against full-bleed can photography
- **igloo.inc** style — dark background with large, thin type
- **Nike campaign sites** — "JUST DO IT" at massive scale over athlete video

### Implementation pattern
```css
.hero-headline {
  font-size: clamp(60px, 12vw, 180px);
  font-weight: 200;          /* Thin — less visual blocking */
  letter-spacing: 0.02em;
  color: rgba(255,255,255,0.9);
  mix-blend-mode: normal;
}

.hero-video {
  filter: brightness(0.5) saturate(0.8);  /* Tame the video */
}
```

---

## Technique 5: Knockout / Cut-Through Text

### How it works
The slogan is literally cut out of a dark overlay — like a stencil.
You see the video THROUGH the letterforms. The rest of the frame is dark.

### Notable examples
- **Coca-Cola "Taste the Feeling"** campaign sites
- Some luxury automotive sites (Porsche, BMW)
- **New York Times** magazine covers translated to web

### Implementation
```css
.hero-overlay {
  background: rgba(0,0,0,0.85);
  mix-blend-mode: multiply;
}
.hero-headline {
  mix-blend-mode: screen;
  color: white;
}
/* Or use CSS mask-composite / SVG clipping */
```

### Visual effect
Dramatic. The video only visible inside the letters. Feels cinematic, editorial.

---

## Technique 6: Kinetic Text — Text That Moves With / Against the Video

### How it works
Text moves in parallax (slower or faster than the video scroll), creating depth.

### Notable examples
- **Beagle/Podio** — text appears as scene transitions
- **Lando Norris** — "TAP TO LOCK" kinetic interaction
- Most scroll-driven narrative sites

### Implementation
Use Framer Motion `useScroll` + `useTransform`:
```tsx
const y = useTransform(scrollY, [0, 500], [0, -100])  // text moves up slower than scroll
```

---

## Design Rules That Apply to All Techniques

### 1. Choose ONE approach per hero — don't mix
Frosted glass + mix-blend-mode + overlay = chaos. Pick one.

### 2. Video and type must share tonal language
- Dark dramatic video → minimal white text (no gradient needed)
- Bright/colorful video → dark text or overlay required
- Monochrome video → color-accented text pops

### 3. Size matters more than weight for impact
A 200-weight font at 12vw has MORE presence than a 700-weight at 3vw.
Premium sites go BIG and THIN, not small and bold.

### 4. The slogan should be SHORT
3–7 words maximum. "Four AI agents. One shared mission." is perfect.
The eye needs to read it before the video changes.

### 5. Position matters
- Top-left: editorial, newspaper-like, strong
- Center: cinematic, immersive, classic
- Bottom-left: grounded, confident (like a movie poster)

---

## Best Examples by Aesthetic Direction

| Aesthetic | Example | Technique | Type style |
|---|---|---|---|
| Cinematic / Film | landonorris.com | Dark video + massive thin serif | Thin, large, white |
| Luxury / Fashion | Balenciaga, Celine | mix-blend-mode overlay | Clean caps, spaced |
| Tech / Startup | Linear, Vercel | Gradient overlay + bold sans | Medium weight, tight |
| Athletic / Energy | Nike campaigns | Full bleed + knockout | All caps, heavy |
| Immersive / Art | lusion.co, igloo | No overlay, type inhabits frame | Variable, animated |

---

## For DreamTeam Specifically

Current state: dark gradient overlay (works but generic)

Better directions to explore:
1. **Kinetic thin type** — reduce hero type weight to 200-300, increase to 10vw+ , remove/reduce overlay
2. **Mix-blend-mode: overlay** on the headline — let the hip-hop video bleed through the letters
3. **Bottom-left cinematic anchor** — move the slogan to bottom-left, movie-poster style
4. **Two-tier type** — Big ambient text (low opacity, huge) behind the real slogan