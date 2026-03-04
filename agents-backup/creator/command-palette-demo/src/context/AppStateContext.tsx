import React, {
  createContext,
  useContext,
  useState,
  useCallback,
  useEffect,
  useRef,
} from 'react'
import type { Command, AppContext, PageName } from '../types'

interface AppState extends AppContext {
  setCurrentPage: (page: PageName) => void
  setSelectedItemId: (id: string | null) => void
  setSelectedItemType: (type: string | null) => void

  // Command palette
  commands: Command[]
  registerCommand: (cmd: Command) => void
  unregisterCommand: (id: string) => void
  isOpen: boolean
  openPalette: () => void
  closePalette: () => void
  /** Increments on every open/re-invoke — lets CommandPalette clear+refocus on re-invoke */
  openSignal: number

  // Recent commands
  recentCommandIds: string[]
  recordUsage: (id: string) => void

  // Toast
  showToast: (message: string, type?: 'success' | 'warning' | 'error' | 'info') => void
}

const AppStateContext = createContext<AppState | null>(null)

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const [currentPage, setCurrentPage] = useState<PageName>('dashboard')
  const [selectedItemId, setSelectedItemId] = useState<string | null>(null)
  const [selectedItemType, setSelectedItemType] = useState<string | null>(null)
  const [commands, setCommands] = useState<Command[]>([])
  const [isOpen, setIsOpen] = useState(false)
  const [recentCommandIds, setRecentCommandIds] = useState<string[]>([])
  const [toasts, setToasts] = useState<{ id: string; message: string; type: string }[]>([])
  const [openSignal, setOpenSignal] = useState(0)
  const openCountRef = useRef(0)

  const registerCommand = useCallback((cmd: Command) => {
    setCommands((prev) => {
      if (prev.find((c) => c.id === cmd.id)) return prev
      return [...prev, cmd]
    })
  }, [])

  const unregisterCommand = useCallback((id: string) => {
    setCommands((prev) => prev.filter((c) => c.id !== id))
  }, [])

  const closePalette = useCallback(() => setIsOpen(false), [])

  const recordUsage = useCallback((id: string) => {
    setRecentCommandIds((prev) => {
      const filtered = prev.filter((r) => r !== id)
      return [id, ...filtered].slice(0, 5)
    })
  }, [])

  const showToast = useCallback(
    (message: string, type: 'success' | 'warning' | 'error' | 'info' = 'info') => {
      const id = Math.random().toString(36).slice(2)
      setToasts((prev) => [...prev, { id, message, type }])
      setTimeout(() => {
        setToasts((prev) => prev.filter((t) => t.id !== id))
      }, 3000)
    },
    []
  )

  // openPalette: always opens; if already open, bumps openSignal so CommandPalette
  // can clear query and re-focus (re-invoke while open).
  const openPalette = useCallback(() => {
    openCountRef.current += 1
    setOpenSignal(openCountRef.current)
    setIsOpen(true)
  }, [])

  // Global Ctrl+K / Cmd+K
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        openPalette()
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [openPalette])

  return (
    <AppStateContext.Provider
      value={{
        currentPage,
        setCurrentPage,
        selectedItemId,
        setSelectedItemId,
        selectedItemType,
        setSelectedItemType,
        commands,
        registerCommand,
        unregisterCommand,
        isOpen,
        openPalette,
        closePalette,
        openSignal,
        recentCommandIds,
        recordUsage,
        showToast,
      }}
    >
      {children}
      {/* Toast container */}
      <div className="toast-container" role="status" aria-live="polite" aria-atomic="true">
        {toasts.map((t) => (
          <div key={t.id} className={`toast ${t.type}`}>
            {t.message}
          </div>
        ))}
      </div>
    </AppStateContext.Provider>
  )
}

export function useAppState() {
  const ctx = useContext(AppStateContext)
  if (!ctx) throw new Error('useAppState must be used within AppStateProvider')
  return ctx
}
