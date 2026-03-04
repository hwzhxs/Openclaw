import React from 'react'
import { useAppState } from '../context/AppStateContext'
import { ListIcon, GearIcon, CommandIcon } from './Icons'
import type { PageName } from '../types'

export function Sidebar() {
  const { currentPage, setCurrentPage, setSelectedItemId, setSelectedItemType } =
    useAppState()

  const nav: { page: PageName; label: string; icon: React.ReactNode }[] = [
    { page: 'dashboard', label: 'Dashboard', icon: <span>⌂</span> },
    { page: 'items', label: 'Items', icon: <ListIcon /> },
    { page: 'settings', label: 'Settings', icon: <GearIcon /> },
  ]

  const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0
  const shortcut = isMac ? '⌘K' : 'Ctrl K'

  const isActive = (page: PageName) => {
    if (currentPage === 'item-detail' && page === 'items') return true
    return currentPage === page
  }

  return (
    <aside className="app-sidebar" aria-label="Main navigation">
      <div className="sidebar-brand">⌘ CommandPal</div>

      <nav>
        {nav.map(({ page, label, icon }) => (
          <button
            key={page}
            className={`sidebar-nav-item ${isActive(page) ? 'active' : ''}`}
            onClick={() => {
              setCurrentPage(page)
              if (page !== 'item-detail') {
                setSelectedItemId(null)
                setSelectedItemType(null)
              }
            }}
            aria-current={isActive(page) ? 'page' : undefined}
          >
            <span className="nav-icon">{icon}</span>
            {label}
          </button>
        ))}
      </nav>

      <div className="sidebar-hint">
        <CommandIcon />
        <kbd>{shortcut}</kbd> to open palette
      </div>
    </aside>
  )
}
