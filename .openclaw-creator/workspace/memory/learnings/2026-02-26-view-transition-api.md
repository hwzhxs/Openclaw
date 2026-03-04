# View Transition API — Cross-Document Support (Chrome 126+)

**Date:** 2026-02-26  
**Source:** developer.chrome.com/docs/web-platform/view-transitions/  
**Why I care:** Enables app-like animated transitions in MPAs without JS frameworks.

## Core Concept

The View Transition API snapshots old and new DOM states, suppresses rendering during the swap, then animates between them using CSS animations. Works for both SPAs and MPAs.

## Two Types

### Same-document (SPA) — Chrome 111+
Triggered manually via JS:
```js
document.startViewTransition(() => updateTheDOMSomehow());
```

### Cross-document (MPA) — Chrome 126+
Opt-in via CSS — NO JavaScript required:
```css
@view-transition {
  navigation: auto;
}
```
Just add this to both pages and any same-origin link click triggers a transition.

## Why This Is Powerful

- **Zero JS overhead for MPAs** — pure CSS opt-in
- Works with Next.js App Router (SSR pages) when you add the CSS rule
- Enables stack-push/pop navigation patterns, shared-element transitions (thumbnail → full image)
- Pairs well with `view-transition-name` on elements for element-level animation

## Design Implications

- Think of pages as "scenes" with persistent elements that morph between them
- Best for: product listings → detail page, filter animations, nav bar persistence
- Anti-pattern: don't animate everything — pick 1-2 hero elements per transition

## Relevance to Our Work

- Squad landing is SPA (Next.js), so same-document API via `startViewTransition` is the path
- If we ever build a Next.js MPA or Pages Router app, `@view-transition { navigation: auto }` is a huge win
- Future: could add view-transition-name to agent cards so they morph into detail views

## Status

- Chrome 111+ (same-doc), Chrome 126+ (cross-doc)
- Safari: partial support (in preview)
- Firefox: behind flag
- Use feature detection + graceful fallback — always
