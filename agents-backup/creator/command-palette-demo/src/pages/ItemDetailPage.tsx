import React from 'react'
import { useAppState } from '../context/AppStateContext'
import { useRegisterCommand } from '../hooks/useRegisterCommand'
import { mockItems } from '../data/mockData'
import { EditIcon, TrashIcon, CheckIcon, CloseIcon, ListIcon } from '../components/Icons'
import type { AppContext } from '../types'

// Context filter: only show when on item-detail page
const onItemDetail = (ctx: AppContext) => ctx.currentPage === 'item-detail'

export function ItemDetailPage() {
  const {
    selectedItemId,
    setCurrentPage,
    setSelectedItemId,
    setSelectedItemType,
    showToast,
  } = useAppState()

  const item = mockItems.find((i) => i.id === selectedItemId)

  useRegisterCommand({
    id: 'nav-back-to-items',
    label: 'Back to Items List',
    keywords: ['back', 'list', 'items', 'return', 'all'],
    icon: <ListIcon />,
    category: 'navigation',
    contextFilter: onItemDetail,
    handler: () => setCurrentPage('items'),
  })

  useRegisterCommand({
    id: 'action-edit-item',
    label: 'Edit This Item',
    keywords: ['edit', 'modify', 'update', 'change', 'rename'],
    icon: <EditIcon />,
    shortcut: '⌘E',
    category: 'action',
    contextFilter: onItemDetail,
    handler: (ctx) => showToast(`Editing ${ctx.selectedItemId ?? 'item'} (mock)`, 'info'),
  })

  useRegisterCommand({
    id: 'action-mark-done-item',
    label: 'Mark Item as Done',
    keywords: ['done', 'complete', 'finish', 'resolve', 'close', 'mark done'],
    icon: <CheckIcon />,
    shortcut: '⌘D',
    category: 'action',
    contextFilter: onItemDetail,
    handler: (ctx) => showToast(`${ctx.selectedItemId} marked as done (mock)`, 'success'),
  })

  useRegisterCommand({
    id: 'action-cancel-item',
    label: 'Cancel Item',
    keywords: ['cancel', 'dismiss', 'skip', 'wont fix', "won't fix"],
    icon: <CloseIcon />,
    category: 'action',
    contextFilter: onItemDetail,
    handler: (ctx) => showToast(`${ctx.selectedItemId} cancelled (mock)`, 'warning'),
  })

  useRegisterCommand({
    id: 'action-delete-item',
    label: 'Delete This Item',
    keywords: ['delete', 'remove', 'trash', 'destroy', 'drop'],
    icon: <TrashIcon />,
    category: 'action',
    contextFilter: onItemDetail,
    isDangerous: true,
    handler: (ctx) => {
      showToast(`${ctx.selectedItemId} deleted (mock)`, 'error')
      setSelectedItemId(null)
      setSelectedItemType(null)
      setCurrentPage('items')
    },
  })

  if (!item) {
    return (
      <main className="app-main">
        <div style={{ color: '#666', fontSize: 14 }}>Item not found.</div>
      </main>
    )
  }

  const statusLabel: Record<string, string> = {
    'todo': 'Todo',
    'in-progress': 'In Progress',
    'done': 'Done',
    'cancelled': 'Cancelled',
  }

  return (
    <main className="app-main" aria-label={`Item detail: ${item.id}`}>
      {/* Breadcrumb */}
      <nav className="breadcrumb" aria-label="Breadcrumb">
        <button onClick={() => setCurrentPage('items')}>Items</button>
        <span aria-hidden="true">›</span>
        <span>{item.id}</span>
      </nav>

      <div className="page-header">
        <h1 className="page-title">{item.title}</h1>
      </div>

      <div className="detail-card">
        <div className="detail-meta">
          <span className={`item-status status-${item.status}`}>{statusLabel[item.status]}</span>
          <span
            style={{
              fontSize: '12px',
              color: '#555',
              display: 'flex',
              alignItems: 'center',
              gap: 4,
            }}
          >
            <span className={`item-priority priority-${item.priority}`} style={{ width: 7, height: 7, borderRadius: '50%', display: 'inline-block' }} />
            {item.priority.charAt(0).toUpperCase() + item.priority.slice(1)} priority
          </span>
          <span style={{ fontSize: '12px', color: '#555', marginLeft: 'auto' }}>
            Assigned to <strong style={{ color: '#aaa' }}>{item.assignee}</strong>
          </span>
        </div>

        <div style={{ fontSize: 12, color: '#555', marginBottom: 16 }}>
          Type: <span style={{ color: '#888', textTransform: 'capitalize' }}>{item.type}</span>
          &nbsp;·&nbsp; Created: {item.createdAt}
          &nbsp;·&nbsp; ID: <code style={{ fontFamily: 'monospace', color: '#7c6dfa' }}>{item.id}</code>
        </div>

        <p className="detail-description">{item.description}</p>

        <div className="detail-actions">
          <button
            className="btn btn-primary"
            onClick={() => showToast(`Editing ${item.id} (mock)`, 'info')}
          >
            Edit
          </button>
          <button
            className="btn btn-ghost"
            onClick={() => showToast(`${item.id} marked as done (mock)`, 'success')}
          >
            Mark Done
          </button>
          <button
            className="btn btn-danger"
            onClick={() => showToast(`${item.id} deleted (mock)`, 'error')}
          >
            Delete
          </button>
        </div>
      </div>

      <div
        style={{
          marginTop: 20,
          padding: '14px 18px',
          background: 'rgba(124,109,250,0.05)',
          borderRadius: 8,
          border: '1px solid rgba(124,109,250,0.12)',
          fontSize: 12,
          color: '#666',
          maxWidth: 700,
        }}
      >
        💡 Context-aware: Open the command palette here to see item-specific commands (Edit, Delete,
        Mark Done, Cancel) ranked higher.
      </div>
    </main>
  )
}
