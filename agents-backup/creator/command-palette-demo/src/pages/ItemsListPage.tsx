import React from 'react'
import { useAppState } from '../context/AppStateContext'
import { useRegisterCommand } from '../hooks/useRegisterCommand'
import { mockItems } from '../data/mockData'
import { PlusIcon, CheckIcon, ListIcon } from '../components/Icons'

export function ItemsListPage() {
  const { setCurrentPage, setSelectedItemId, setSelectedItemType, showToast } = useAppState()

  useRegisterCommand({
    id: 'nav-dashboard-from-items',
    label: 'Go to Dashboard',
    keywords: ['dashboard', 'home', 'overview', 'main'],
    icon: <ListIcon />,
    shortcut: '⌘0',
    category: 'navigation',
    handler: () => setCurrentPage('dashboard'),
  })

  useRegisterCommand({
    id: 'action-new-item-from-list',
    label: 'Create New Item',
    keywords: ['new', 'create', 'add', 'issue', 'task'],
    icon: <PlusIcon />,
    shortcut: '⌘N',
    category: 'action',
    handler: () => showToast('New item created (mock)', 'success'),
  })

  useRegisterCommand({
    id: 'action-mark-all-done',
    label: 'Mark All Items Done',
    keywords: ['done', 'complete', 'finish', 'all', 'mark', 'resolve', 'close all'],
    icon: <CheckIcon />,
    category: 'action',
    isDangerous: true,
    handler: () => showToast('All items marked as done (mock)', 'success'),
  })

  const handleItemClick = (id: string, type: string) => {
    setSelectedItemId(id)
    setSelectedItemType(type)
    setCurrentPage('item-detail')
  }

  const statusLabel: Record<string, string> = {
    'todo': 'Todo',
    'in-progress': 'In Progress',
    'done': 'Done',
    'cancelled': 'Cancelled',
  }

  return (
    <main className="app-main" aria-label="Items list">
      <div className="page-header">
        <h1 className="page-title">Items</h1>
        <p className="page-subtitle">{mockItems.length} items in this workspace</p>
      </div>

      <div style={{ marginBottom: 16, display: 'flex', gap: 10 }}>
        <button className="btn btn-primary" onClick={() => showToast('New item created (mock)', 'success')}>
          + New Item
        </button>
      </div>

      <div className="items-list" role="list" aria-label="Items">
        {mockItems.map((item) => (
          <div
            key={item.id}
            className="item-row"
            role="listitem"
            tabIndex={0}
            onClick={() => handleItemClick(item.id, item.type)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') handleItemClick(item.id, item.type)
            }}
            aria-label={`${item.id}: ${item.title}, ${statusLabel[item.status]}, ${item.priority} priority`}
          >
            <div className={`item-priority priority-${item.priority}`} aria-hidden="true" />
            <div className="item-id">{item.id}</div>
            <div className="item-title">{item.title}</div>
            <div className="item-status" style={{ marginLeft: 'auto' }}>
              <span className={`item-status status-${item.status}`}>
                {statusLabel[item.status]}
              </span>
            </div>
          </div>
        ))}
      </div>
    </main>
  )
}
