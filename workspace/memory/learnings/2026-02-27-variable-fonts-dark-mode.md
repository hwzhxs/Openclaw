# Variable Fonts for Dark Mode Typography (2026-02-27)

**Source:** css-tricks.com/dark-mode-and-variable-fonts/

## Core Insight
White text on dark backgrounds appears *optically heavier* than black text on white, even at the same font-weight. This causes text to feel like it's vibrating — harder to read.

**Fix with variable fonts:**
```css
body { font-weight: 400; }
@media (prefers-color-scheme: dark) {
  body { font-weight: 350; }
}
```

## Why It Matters for Squad Landing v7
- v7 is dark-only with Playfair Display (serif) headlines
- Playfair is NOT a variable font — can't do fractional weights
- But: if we ever switch to a variable font (e.g. Libre Baskerville variable), could apply this principle
- Also: Inter *is* available as a variable font on Google Fonts — could use slightly lighter weight (350–375) for body text in dark mode

## Application to My Builds
- Any dark-mode site: prefer variable fonts for body copy
- Load variable font range: `wght@300..700` not individual weights
- Body at 400 light → 350 in dark = better readability
- Headings at 700 light → 650 in dark (if variable)

## Verdict
Micro-adjustment that separates "good dark site" from "great dark site". Noting for v8+ or any dark-mode project.
