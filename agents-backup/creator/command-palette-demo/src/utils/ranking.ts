import type { Command, AppContext } from '../types'

function matchScore(query: string, cmd: Command): number {
  if (!query) return 0
  const q = query.toLowerCase().trim()
  const label = cmd.label.toLowerCase()
  const keywords = cmd.keywords.map((k) => k.toLowerCase())
  const allText = [label, ...keywords]

  for (const text of allText) {
    if (text === q) return 100 // exact
    if (text.startsWith(q)) return 80 // prefix
  }
  for (const text of allText) {
    if (text.includes(q)) return 50 // substring / fuzzy
  }
  // Multi-word fuzzy: all words must appear somewhere
  const words = q.split(/\s+/)
  if (words.length > 1) {
    const combined = allText.join(' ')
    if (words.every((w) => combined.includes(w))) return 50
  }
  return 0
}

function recencyBoost(id: string, recentIds: string[]): number {
  const idx = recentIds.indexOf(id)
  if (idx === -1) return 0
  // decay: pos 0 = 100, pos 1 = 80, pos 2 = 60, pos 3 = 40, pos 4 = 20
  return 100 - idx * 20
}

function contextBoost(cmd: Command, ctx: AppContext): number {
  if (!cmd.contextFilter) return 0
  return cmd.contextFilter(ctx) ? 100 : 0
}

export function rankCommands(
  commands: Command[],
  query: string,
  recentIds: string[],
  ctx: AppContext
): Command[] {
  const q = query.trim()

  return commands
    .filter((cmd) => {
      // Context filter: hide if returns false (but only if filter exists)
      if (cmd.contextFilter && !cmd.contextFilter(ctx)) return false
      // If no query, show all (will be sorted by recency/context)
      if (!q) return true
      return matchScore(q, cmd) > 0
    })
    .map((cmd) => {
      const ms = q ? matchScore(q, cmd) : 0
      const rb = recencyBoost(cmd.id, recentIds)
      const cb = contextBoost(cmd, ctx)
      const score = ms * 1.0 + rb * 0.3 + cb * 0.2
      return { cmd, score }
    })
    .sort((a, b) => b.score - a.score)
    .map((r) => r.cmd)
}
