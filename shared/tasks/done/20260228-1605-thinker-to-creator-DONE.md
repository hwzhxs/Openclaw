# Task Handoff — Video Hover Feature

- **From:** Thinker 🧠
- **To:** Creator 🎨
- **Priority:** normal
- **Created:** 2026-02-28T16:05:00Z
- **Slack Thread:** 1772289713.698919

## Task
Add hover-to-play video feature on agent image containers in the role intro (agents scroll) section.

## Behavior Spec

### Interaction
1. **Default state:** Static agent image displayed (current behavior, unchanged)
2. **On hover (mouseenter on image container):** Immediately replace the static image with the corresponding agent video. Video plays automatically, looped, muted (no audio).
3. **On unhover (mouseleave on image container):** Stop video playback, hide video, show static image again instantly.
4. **No click required** — hover triggers everything.

### Technical Requirements

1. **Video element:** Add a `<video>` element inside each agent's image container, overlaying the `<img>`. 
   - Attributes: `muted`, `loop`, `playsInline`, `preload="metadata"` (or `"auto"` if files are small enough — they're ~4MB each)
   - No controls visible
2. **Show/hide logic:**
   - Default: video hidden (`opacity: 0` or `display: none`), image visible
   - On hover: hide image, show video, call `video.play()`
   - On unhover: call `video.pause()`, reset `video.currentTime = 0`, hide video, show image
3. **Transition:** Crossfade is nice-to-have but not required. Instant swap is fine — avoid flicker.
4. **Performance:** 
   - Use `preload="metadata"` to avoid loading all 4 videos (~17MB total) upfront
   - On first hover, video may take a moment to buffer — acceptable
   - Consider `preload="auto"` if the page already loads fast enough
5. **Video files:** Need to be added to the project's public/assets directory. Xiaosong provided 4 files:
   - `admin.mp4` → Popo (Admin)
   - `creator.mp4` → Tyler (Creator)  
   - `thinker.mp4` → Kanye (Thinker)
   - `gatekeeper.mp4` → Rocky (Gatekeeper)

### Data Model Change
Add a `video` field to each agent in `agents.ts`:
```ts
{
  name: "Popo",
  // ... existing fields
  video: "/videos/admin.mp4",  // or wherever assets live
}
```

### Component Change (AgentsScroll.tsx / AgentImage)
- Add `onMouseEnter` / `onMouseLeave` handlers to the image container
- Manage a `isHovered` state per agent card
- Render both `<img>` and `<video>` in the container, toggle visibility based on hover state
- Video ref needed to call `.play()` and `.pause()` imperatively

### Scope
- **ONLY** the agent image container in the role intro / agents scroll section
- Do NOT change layout, text, navigation, or any other section
- Do NOT add video anywhere else on the page

### Video Source Files (to copy into project)
| Agent | Source file |
|---|---|
| Admin (Popo) | `C:\Users\azureuser\.openclaw-agent2\media\inbound\7cea538e-49a9-4776-8e69-554f700ead93.mp4` |
| Creator (Tyler) | `C:\Users\azureuser\.openclaw-agent2\media\inbound\02e92764-eccb-45f8-9499-ff17e122aa87.mp4` |
| Thinker (Kanye) | `C:\Users\azureuser\.openclaw-agent2\media\inbound\64367d38-2824-4cce-a4a0-636dc18b6938.mp4` |
| Gatekeeper (Rocky) | `C:\Users\azureuser\.openclaw-agent2\media\inbound\672b28ad-69d1-4576-aadd-0c519f2a4b57.mp4` |

Copy these to the project's public directory (e.g., `public/videos/`) with clean names (`admin.mp4`, `creator.mp4`, `thinker.mp4`, `gatekeeper.mp4`).

## Deliverable
Updated agent card with hover-to-play video. Deploy via trycloudflare, hand off to Gatekeeper.
