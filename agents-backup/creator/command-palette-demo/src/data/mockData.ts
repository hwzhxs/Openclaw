export interface Item {
  id: string
  title: string
  description: string
  status: 'todo' | 'in-progress' | 'done' | 'cancelled'
  priority: 'urgent' | 'high' | 'medium' | 'low'
  assignee: string
  createdAt: string
  type: 'bug' | 'feature' | 'task'
}

export const mockItems: Item[] = [
  {
    id: 'CP-001',
    title: 'Implement command palette keyboard navigation',
    description: 'Add full arrow key navigation, enter to select, and escape to close. Ensure focus is properly managed and screen readers are notified of selection changes.',
    status: 'done',
    priority: 'urgent',
    assignee: 'Alex Chen',
    createdAt: '2026-02-10',
    type: 'feature',
  },
  {
    id: 'CP-002',
    title: 'Add fuzzy search ranking algorithm',
    description: 'Implement weighted scoring: exact match > prefix match > substring match. Include recency boost for recently used commands.',
    status: 'in-progress',
    priority: 'high',
    assignee: 'Jordan Kim',
    createdAt: '2026-02-12',
    type: 'feature',
  },
  {
    id: 'CP-003',
    title: 'Fix search input lag on slower devices',
    description: 'Profiling shows the search filter runs synchronously on every keystroke. Needs debouncing or a web worker approach.',
    status: 'in-progress',
    priority: 'high',
    assignee: 'Sam Park',
    createdAt: '2026-02-15',
    type: 'bug',
  },
  {
    id: 'CP-004',
    title: 'Context-aware command filtering',
    description: 'Commands registered by the Item Detail page should only appear when viewing an item. Global commands always visible.',
    status: 'done',
    priority: 'medium',
    assignee: 'Alex Chen',
    createdAt: '2026-02-18',
    type: 'feature',
  },
  {
    id: 'CP-005',
    title: 'Dangerous command confirmation UX',
    description: 'When a command is marked isDangerous, show a confirmation prompt before executing. Two-step: first press selects, second press confirms.',
    status: 'todo',
    priority: 'medium',
    assignee: 'Jordan Kim',
    createdAt: '2026-02-20',
    type: 'feature',
  },
  {
    id: 'CP-006',
    title: 'ARIA accessibility audit',
    description: 'Run axe-core against the palette, fix all A and AA violations. Add live region for result count announcements.',
    status: 'todo',
    priority: 'high',
    assignee: 'Sam Park',
    createdAt: '2026-02-22',
    type: 'task',
  },
  {
    id: 'CP-007',
    title: 'Command palette close animation',
    description: 'Add smooth fade + scale down animation when closing the palette. Should respect prefers-reduced-motion.',
    status: 'todo',
    priority: 'low',
    assignee: 'Alex Chen',
    createdAt: '2026-02-24',
    type: 'feature',
  },
  {
    id: 'CP-008',
    title: 'Persist recent commands across sessions',
    description: 'Store the last 10 used command IDs in localStorage. Load on mount so recency ranking works across page reloads.',
    status: 'cancelled',
    priority: 'low',
    assignee: 'Jordan Kim',
    createdAt: '2026-02-25',
    type: 'feature',
  },
]
