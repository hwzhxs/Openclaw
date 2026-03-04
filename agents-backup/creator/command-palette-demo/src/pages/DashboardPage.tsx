import React from 'react'
import { useAppState } from '../context/AppStateContext'
import { useRegisterCommand } from '../hooks/useRegisterCommand'
import { HomeIcon, ListIcon, GearIcon, PlusIcon, StarIcon } from '../components/Icons'

export function DashboardPage() {
  const { setCurrentPage, showToast, openPalette } = useAppState()

  // Register page-specific commands
  useRegisterCommand({
    id: 'nav-items',
    label: 'Go to Items',
    keywords: ['items', 'list', 'issues', 'tasks', 'work'],
    icon: <ListIcon />,
    shortcut: '⌘1',
    category: 'navigation',
    handler: () => setCurrentPage('items'),
  })

  useRegisterCommand({
    id: 'nav-settings',
    label: 'Go to Settings',
    keywords: ['settings', 'preferences', 'config', 'options'],
    icon: <GearIcon />,
    shortcut: '⌘,',
    category: 'navigation',
    handler: () => setCurrentPage('settings'),
  })

  useRegisterCommand({
    id: 'action-new-item',
    label: 'Create New Item',
    keywords: ['new', 'create', 'add', 'issue', 'task', '+'],
    icon: <PlusIcon />,
    shortcut: '⌘N',
    category: 'action',
    handler: (ctx) => {
      showToast('New item created (mock)', 'success')
    },
  })

  useRegisterCommand({
    id: 'action-star-dashboard',
    label: 'Star Dashboard',
    keywords: ['star', 'favourite', 'favorite', 'bookmark', 'pin'],
    icon: <StarIcon />,
    category: 'action',
    handler: () => showToast('Dashboard starred!', 'success'),
  })

  const stats = [
    { label: 'Total Items', value: '8', delta: '+2 this week' },
    { label: 'In Progress', value: '2', delta: 'Active' },
    { label: 'Done', value: '2', delta: '25% complete' },
    { label: 'Blocked', value: '0', delta: 'All clear ✓' },
  ]

  return (
    <main className="app-main" aria-label="Dashboard">
      <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
        <p className="page-subtitle">Overview of your workspace activity</p>
      </div>

      <div className="dashboard-grid">
        {stats.map((s) => (
          <div key={s.label} className="stat-card">
            <div className="stat-card-label">{s.label}</div>
            <div className="stat-card-value">{s.value}</div>
            <div className="stat-card-delta">{s.delta}</div>
          </div>
        ))}
      </div>

      <div className="page-header" style={{ marginTop: 24 }}>
        <h2
          style={{ fontSize: '16px', fontWeight: 600, color: '#ccc', margin: '0 0 8px', letterSpacing: '-0.01em' }}
        >
          Quick Actions
        </h2>
      </div>

      <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
        <button className="btn btn-primary" onClick={() => showToast('New item created (mock)', 'success')}>
          + New Item
        </button>
        <button className="btn btn-ghost" onClick={() => setCurrentPage('items')}>
          View All Items
        </button>
        <button className="btn btn-ghost" onClick={openPalette}>
          Open Command Palette
        </button>
      </div>

      <div
        style={{
          marginTop: 40,
          padding: '20px',
          background: 'rgba(124,109,250,0.05)',
          borderRadius: 10,
          border: '1px solid rgba(124,109,250,0.15)',
          maxWidth: 500,
        }}
      >
        <div style={{ fontSize: 13, fontWeight: 600, color: '#9d91f8', marginBottom: 8 }}>
          💡 Try the Command Palette
        </div>
        <div style={{ fontSize: 13, color: '#777', lineHeight: 1.6 }}>
          Press <kbd style={{ background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.12)', borderRadius: 4, padding: '1px 6px', fontSize: 12, color: '#aaa' }}>Ctrl+K</kbd>{' '}
          (or <kbd style={{ background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.12)', borderRadius: 4, padding: '1px 6px', fontSize: 12, color: '#aaa' }}>⌘K</kbd> on Mac)
          to open the command palette. Navigate pages, create items, change settings — all from your keyboard.
        </div>
      </div>
    </main>
  )
}
