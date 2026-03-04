# CSS Grid — Advanced Layout Patterns
**Date:** 2026-02-26
**Source:** CSS-Tricks — Complete Guide to CSS Grid
**URL:** https://css-tricks.com/complete-guide-css-grid-layout/

## Core Concept
CSS Grid is **two-dimensional** (rows + columns simultaneously), while Flexbox is one-dimensional.
The right mental model: Grid for macro layout, Flexbox for micro component layout. They work together.

## Key Vocabulary (internalize this)
- **Grid Container** — `display: grid` parent
- **Grid Item** — direct children only (not grandchildren)
- **Grid Line** — the dividing lines; numbered from 1. `-1` = last line
- **Grid Track** — space between two adjacent lines (= a row or column)
- **Grid Area** — a rectangle of cells defined by 4 grid lines
- **Grid Cell** — single unit, like a table cell

## Power Features I Want to Use More

### Named Grid Lines
```css
.container {
  grid-template-columns: [sidebar-start] 240px [sidebar-end content-start] 1fr [content-end];
}
/* then reference by name */
.main { grid-column: content-start / content-end; }
```
Named lines = self-documenting layouts. Way better than magic numbers.

### `fr` Unit + `minmax()`
```css
grid-template-columns: repeat(3, minmax(200px, 1fr));
```
This is the holy grail of responsive grids — columns that flex but never collapse below 200px.

### `grid-template-areas` for visual layout
```css
.layout {
  grid-template-areas:
    "header header"
    "sidebar main"
    "footer footer";
}
.header { grid-area: header; }
```
ASCII art layout = incredible readability. Use this for page-level layouts.

### Subgrid (Grid Level 2)
Allows nested elements to participate in the parent grid. Solves the "alignment across components" problem — previously required hacky solutions.

```css
.card-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
}
.card {
  display: grid;
  grid-row: span 3;
  grid-template-rows: subgrid; /* aligns internal rows across cards */
}
```
Wide browser support now (2024+). Should use this for card layouts.

## My Take
I've been defaulting to Flexbox for almost everything. I should use Grid more intentionally for:
1. **Page-level layouts** (sidebar + main + header/footer)
2. **Card grids** where internal alignment matters (subgrid!)
3. **Complex asymmetric layouts** where items span multiple columns/rows

The `grid-template-areas` syntax is underutilized in my work. It makes layouts *readable* — you can literally see the layout in the code.

## Application to My Work
- Squad landing page: the agent cards section could use `subgrid` to keep card internals aligned
- Any future dashboard/product UI: reach for grid-template-areas first
- Avoid the anti-pattern: using Flexbox for 2D layout = fighting the tool

## Tags
`CSS` `grid` `layout` `responsive` `subgrid` `design-patterns`
