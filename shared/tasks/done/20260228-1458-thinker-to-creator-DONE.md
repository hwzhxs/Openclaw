# Task Handoff

- **From:** Thinker 🧠
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-28T14:58:00Z
- **Slack Thread:** 1772289713.698919

## Task
Update the Squad landing page agent card component to match the target design (Screenshot 2). **Only** the items listed below — do not touch other sections of the page.

## UI Update Spec: Agent Card → Target Design

### 1. Image Container Card
| Property | Current (Screenshot 1) | Target (Screenshot 2) |
|---|---|---|
| Aspect ratio | Wider, roughly 4:5 | Taller/narrower, roughly 3:5 portrait |
| Corner brackets | Thin L-shaped brackets at all 4 corners, subtle | Same corner brackets but tighter to edges, more visible |
| Bottom badge | None | "🚔 COORDINATOR" pill/badge centered at bottom of card, inside the frame |
| Glow effect | Small atom/orbit icon to the right of character | Glowing cyan/blue orb on the character's chest/torso area, more prominent |
| Character sizing | Character fills less of the card, more padding | Character fills more vertical space, crops closer to edges |

### 2. Typography & Text Hierarchy
| Property | Current (Screenshot 1) | Target (Screenshot 2) |
|---|---|---|
| Index number | None | "01" with a horizontal rule/line to the right, positioned above the name |
| Title | "Popo" only (large, serif) | "Popo" (large, serif) + subtitle "The Police" below in blue/lighter color |
| Role tags | Two inline tags: `ADMIN` pill + `< coordinator />` code-style text | Single pill: `• Admin` with dot indicator, minimal style |
| Description text | "Orchestrates the team. Assigns tasks, coordinates handoffs, keeps the rhythm." | "Orchestrates the entire operation. Assigns missions, coordinates handoffs, maintains order across the squad. The law of the land." |
| Code snippet | None visible | Faint/ghost text below description: `<agent-role="coordinator" status="online" />` — this appears intentional as a design flourish but verify with Xiaosong if it should be visible or hidden |

### 3. Dot Navigation (right side)
| Property | Current | Target |
|---|---|---|
| Style | Solid dots, uniform | One larger active dot (top) + smaller inactive dots below — clearer active state |

### 4. Specific CSS/Layout Changes Needed
1. **Reduce card width / increase card height** to achieve the taller portrait ratio (~3:5)
2. **Add numbered index** (`01 ———`) above each agent name — presumably sequential per agent
3. **Add subtitle line** below agent name in accent blue color
4. **Replace dual role tags** with single minimal `• Role` pill
5. **Add bottom badge** inside image frame: role-specific label (e.g., "🚔 COORDINATOR")
6. **Add glowing orb** effect on character image (CSS radial-gradient or overlay)
7. **Update description copy** per agent to be more detailed/characterful
8. **Fix dot nav** active state styling
9. **Add decorative code snippet** below description (low opacity, monospace)

## Context
- Xiaosong requested this specifically — match Screenshot 2 exactly on these details
- Do NOT change other page sections (hero, How We Work, Under the Hood, CTA, etc.)
- Current live URL: https://analyst-suggests-assets-wto.trycloudflare.com

## Deliverable
Updated agent card component matching the target design. Deploy via trycloudflare and hand off to Gatekeeper for review.
