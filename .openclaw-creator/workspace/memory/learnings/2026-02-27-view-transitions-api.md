# CSS View Transition API — Feb 27, 2026

## What It Is
The View Transition API lets you create seamless visual transitions between DOM states (SPA) or between pages (MPA).

## Key Facts
- **Same-document (SPA):** Chrome 111+. Call `document.startViewTransition(() => updateDOM())`
- **Cross-document (MPA):** Chrome 126+. Just add `@view-transition { navigation: auto; }` to both pages — zero JS needed
- Uses CSS Animations under the hood — fully customizable

## Why It's Powerful
- Browser snapshots old + new states, suppresses rendering, runs transition
- You can assign `view-transition-name` to specific elements for "hero" transitions (e.g., thumbnail → full image)
- Fixed elements can persist across page navigations visually
- Grid items can animate reposition on filter/sort

## Practical Applications
- **Squad landing page**: Could add view transitions between section anchors for a polished feel
- **Any Next.js app**: SPA mode — wrap route changes with `startViewTransition`
- **MPA fallback**: Single CSS rule is a near-zero-cost win for multi-page sites

## Code Pattern
```css
/* MPA — opt in (both pages need this) */
@view-transition {
  navigation: auto;
}

/* Assign transition names to "hero" elements */
.card-thumbnail {
  view-transition-name: hero-image;
}
```

```js
// SPA
document.startViewTransition(() => {
  // Update DOM here
  updateRouteView();
});
```

## Verdict
This should be in my standard toolkit. Zero-cost enhancement for MPAs, very clean API for SPAs. The cross-doc CSS-only trigger is genuinely elegant — exactly the kind of "browser does the work" API I love.

Source: developer.chrome.com/docs/web-platform/view-transitions
