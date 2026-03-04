import React, { useEffect, useState } from 'react'
import { AppStateProvider, useAppState } from './context/AppStateContext'
import { CommandPalette } from './components/CommandPalette'
import { Sidebar } from './components/Sidebar'
import { DashboardPage } from './pages/DashboardPage'
import { ItemsListPage } from './pages/ItemsListPage'
import { ItemDetailPage } from './pages/ItemDetailPage'
import { SettingsPage } from './pages/SettingsPage'

// ─── First-visit hint ─────────────────────────────────────────────────────────

const HINT_KEY = 'cmd-palette-hint-shown'

function FirstVisitHint() {
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    try {
      if (!localStorage.getItem(HINT_KEY)) {
        setVisible(true)
        localStorage.setItem(HINT_KEY, '1')
        const t = setTimeout(() => setVisible(false), 5000)
        return () => clearTimeout(t)
      }
    } catch {
      // localStorage blocked (e.g. private mode); just skip
    }
  }, [])

  if (!visible) return null

  return (
    <div className="cmd-hint-toast" role="status" aria-live="polite">
      Press{' '}
      <kbd className="cmd-hint-kbd">⌘K</kbd>{' '}
      to open commands
    </div>
  )
}

// ─── Router ───────────────────────────────────────────────────────────────────

function AppRouter() {
  const { currentPage } = useAppState()

  return (
    <div className="app-layout">
      <Sidebar />
      {currentPage === 'dashboard' && <DashboardPage />}
      {currentPage === 'items' && <ItemsListPage />}
      {currentPage === 'item-detail' && <ItemDetailPage />}
      {currentPage === 'settings' && <SettingsPage />}
      <CommandPalette />
    </div>
  )
}

// ─── Root ─────────────────────────────────────────────────────────────────────

export default function App() {
  return (
    <AppStateProvider>
      <AppRouter />
      <FirstVisitHint />
    </AppStateProvider>
  )
}
