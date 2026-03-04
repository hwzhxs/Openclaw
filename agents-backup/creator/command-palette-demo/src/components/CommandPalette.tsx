import React, {
  useEffect,
  useRef,
  useState,
  useCallback,
  useMemo,
} from 'react'
import { Command as CmdkRoot } from 'cmdk'
import { useAppState } from '../context/AppStateContext'
import { rankCommands } from '../utils/ranking'
import type { Command, AppContext } from '../types'

// ─── Icons ────────────────────────────────────────────────────────────────────

function SearchIcon({ size = 20 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 20 20"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M13 8.5a4.5 4.5 0 11-9 0 4.5 4.5 0 019 0zm-1.197 4.51 3.344 3.344a.75.75 0 11-1.06 1.06l-3.344-3.343A6 6 0 1111.803 13z"
        fill="currentColor"
        fillRule="evenodd"
        clipRule="evenodd"
      />
    </svg>
  )
}

function TriangleAlertIcon() {
  return (
    <svg
      width={16}
      height={16}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
      <line x1="12" y1="9" x2="12" y2="13" />
      <line x1="12" y1="17" x2="12.01" y2="17" />
    </svg>
  )
}

// ─── Types ────────────────────────────────────────────────────────────────────

interface ConfirmState {
  commandId: string
  label: string
  cmd: Command
}

// ─── Animation hook ───────────────────────────────────────────────────────────

function useOpenAnimation(isOpen: boolean) {
  const [visible, setVisible] = useState(false)
  const [phase, setPhase] = useState<'closed' | 'opening' | 'open' | 'closing'>('closed')

  useEffect(() => {
    if (isOpen) {
      setVisible(true)
      // Next frame: trigger opening keyframe
      requestAnimationFrame(() => {
        requestAnimationFrame(() => setPhase('opening'))
      })
      const t = setTimeout(() => setPhase('open'), 160)
      return () => clearTimeout(t)
    } else {
      if (phase === 'closed') return
      setPhase('closing')
      const t = setTimeout(() => {
        setPhase('closed')
        setVisible(false)
      }, 110)
      return () => clearTimeout(t)
    }
  }, [isOpen]) // eslint-disable-line react-hooks/exhaustive-deps

  return { visible, phase }
}

// ─── Component ────────────────────────────────────────────────────────────────

export function CommandPalette() {
  const {
    commands,
    isOpen,
    closePalette,
    recentCommandIds,
    recordUsage,
    currentPage,
    selectedItemId,
    selectedItemType,
    openSignal,
  } = useAppState()

  const [query, setQuery] = useState('')
  const [confirmState, setConfirmState] = useState<ConfirmState | null>(null)
  const [activeIndex, setActiveIndex] = useState(0)
  const [announceText, setAnnounceText] = useState('')

  const inputRef = useRef<HTMLInputElement>(null)
  const listRef = useRef<HTMLDivElement>(null)
  const activeItemRef = useRef<HTMLDivElement>(null)
  const cancelBtnRef = useRef<HTMLButtonElement>(null)
  const previousFocusRef = useRef<HTMLElement | null>(null)

  const { visible, phase } = useOpenAnimation(isOpen)

  const ctx: AppContext = useMemo(
    () => ({ currentPage, selectedItemId, selectedItemType }),
    [currentPage, selectedItemId, selectedItemType]
  )

  const ranked = useMemo(
    () => rankCommands(commands, query, recentCommandIds, ctx),
    [commands, query, recentCommandIds, ctx]
  )

  // Flat ordered list for keyboard nav
  const groups = useMemo(() => {
    if (!query && recentCommandIds.length > 0) {
      const recentCmds = recentCommandIds
        .map((id) => ranked.find((c) => c.id === id))
        .filter(Boolean) as Command[]
      const nonRecent = ranked.filter((c) => !recentCommandIds.includes(c.id))
      const result: { label: string; commands: Command[] }[] = []
      if (recentCmds.length > 0) result.push({ label: 'Recent', commands: recentCmds })
      const nav = nonRecent.filter((c) => c.category === 'navigation')
      const action = nonRecent.filter((c) => c.category === 'action')
      const settings = nonRecent.filter((c) => c.category === 'settings')
      if (nav.length > 0) result.push({ label: 'Navigation', commands: nav })
      if (action.length > 0) result.push({ label: 'Actions', commands: action })
      if (settings.length > 0) result.push({ label: 'Settings', commands: settings })
      return result
    }
    const nav = ranked.filter((c) => c.category === 'navigation')
    const action = ranked.filter((c) => c.category === 'action')
    const settings = ranked.filter((c) => c.category === 'settings')
    const result: { label: string; commands: Command[] }[] = []
    if (nav.length > 0) result.push({ label: 'Navigation', commands: nav })
    if (action.length > 0) result.push({ label: 'Actions', commands: action })
    if (settings.length > 0) result.push({ label: 'Settings', commands: settings })
    return result
  }, [ranked, query, recentCommandIds])

  const flatCommands = useMemo(
    () => groups.flatMap((g) => g.commands),
    [groups]
  )

  // Reset active index on query change or open, reset scroll
  useEffect(() => {
    setActiveIndex(0)
    if (listRef.current) listRef.current.scrollTop = 0
  }, [query, isOpen])

  // Scroll active item into view
  useEffect(() => {
    activeItemRef.current?.scrollIntoView({ block: 'nearest' })
  }, [activeIndex])

  // Announce results
  useEffect(() => {
    if (isOpen && query) {
      setAnnounceText(`${ranked.length} result${ranked.length !== 1 ? 's' : ''} for "${query}"`)
    }
  }, [ranked.length, query, isOpen])

  // On open: save focused element, reset state, focus input
  useEffect(() => {
    if (isOpen) {
      previousFocusRef.current = document.activeElement as HTMLElement
      setQuery('')
      setConfirmState(null)
      setAnnounceText('Command palette opened. Type to search commands.')
      setTimeout(() => inputRef.current?.focus(), 20)
    } else {
      // Return focus
      setTimeout(() => {
        if (previousFocusRef.current && typeof previousFocusRef.current.focus === 'function') {
          previousFocusRef.current.focus()
        }
      }, 120)
      setAnnounceText('Command palette closed.')
    }
  }, [isOpen])

  // Re-invoke while open: clear query + refocus input (Ctrl+K pressed again)
  useEffect(() => {
    if (openSignal > 0 && isOpen) {
      setQuery('')
      setConfirmState(null)
      setTimeout(() => inputRef.current?.focus(), 10)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [openSignal])

  // Focus Cancel button when confirm state appears
  useEffect(() => {
    if (confirmState) {
      setTimeout(() => cancelBtnRef.current?.focus(), 20)
    }
  }, [confirmState])

  const handleSelect = useCallback(
    (cmd: Command) => {
      if (cmd.isDangerous) {
        setConfirmState({ commandId: cmd.id, label: cmd.label, cmd })
        setAnnounceText(`Confirm deletion: ${cmd.label}? Press Escape to cancel.`)
        return
      }
      recordUsage(cmd.id)
      closePalette()
      cmd.handler(ctx)
    },
    [ctx, closePalette, recordUsage]
  )

  const handleConfirmDelete = useCallback(() => {
    if (!confirmState) return
    const { cmd } = confirmState
    recordUsage(cmd.id)
    closePalette()
    setConfirmState(null)
    cmd.handler(ctx)
  }, [confirmState, ctx, closePalette, recordUsage])

  const handleCancelConfirm = useCallback(() => {
    setConfirmState(null)
    setTimeout(() => inputRef.current?.focus(), 20)
  }, [])

  const handleClose = useCallback(() => {
    if (confirmState) {
      setConfirmState(null)
      setTimeout(() => inputRef.current?.focus(), 20)
      return
    }
    closePalette()
  }, [confirmState, closePalette])

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault()
        handleClose()
        return
      }

      // If confirm is showing, Enter = cancel (safe default)
      if (confirmState) {
        if (e.key === 'Enter') {
          e.preventDefault()
          handleCancelConfirm()
        }
        return
      }

      if (e.key === 'ArrowDown') {
        e.preventDefault()
        setActiveIndex((i) => Math.min(i + 1, flatCommands.length - 1))
      } else if (e.key === 'ArrowUp') {
        e.preventDefault()
        setActiveIndex((i) => Math.max(i - 1, 0))
      } else if (e.key === 'Enter') {
        e.preventDefault()
        const cmd = flatCommands[activeIndex]
        if (cmd) handleSelect(cmd)
      }
    },
    [confirmState, flatCommands, activeIndex, handleSelect, handleClose, handleCancelConfirm]
  )

  // Backdrop styles
  const backdropStyle: React.CSSProperties = {
    opacity: phase === 'opening' || phase === 'open' ? 1 : 0,
    transition:
      phase === 'closing'
        ? 'opacity 100ms ease'
        : 'opacity 150ms cubic-bezier(0.16, 1, 0.3, 1)',
  }

  // Container styles
  const containerStyle: React.CSSProperties = {
    opacity: phase === 'opening' || phase === 'open' ? 1 : 0,
    transform:
      phase === 'opening' || phase === 'open' ? 'scale(1)' : 'scale(0.95)',
    transition:
      phase === 'closing'
        ? 'opacity 100ms ease'
        : 'opacity 150ms cubic-bezier(0.16, 1, 0.3, 1), transform 150ms cubic-bezier(0.16, 1, 0.3, 1)',
  }

  if (!visible) return null

  return (
    <>
      {/* ARIA live region */}
      <div aria-live="polite" aria-atomic="true" className="sr-only" role="status">
        {announceText}
      </div>

      {/* Backdrop */}
      <div
        className="cmd-overlay"
        style={backdropStyle}
        role="dialog"
        aria-modal="true"
        aria-label="Command Palette"
        onClick={(e) => {
          if (e.target === e.currentTarget) handleClose()
        }}
      >
        {/* Palette container */}
        <div className="cmd-container" style={containerStyle} onKeyDown={handleKeyDown}>
          {/* Input row */}
          <div className="cmd-input-row">
            <span className="cmd-search-icon">
              <SearchIcon size={16} />
            </span>
            <input
              ref={inputRef}
              className="cmd-input"
              placeholder="Search commands…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              aria-label="Search commands"
              aria-autocomplete="list"
              autoComplete="off"
              spellCheck={false}
            />
            <span className="cmd-kbd-badge">⌘K</span>
          </div>

          {/* Body: confirm view OR results */}
          {confirmState ? (
            <div className="cmd-confirm-view">
              <div className="cmd-confirm-icon">
                <TriangleAlertIcon />
              </div>
              <p className="cmd-confirm-question">
                Delete{' '}
                <span className="cmd-confirm-name">"{confirmState.label}"</span>?
              </p>
              <div className="cmd-confirm-actions">
                <button
                  ref={cancelBtnRef}
                  className="cmd-btn cmd-btn-cancel"
                  onClick={handleCancelConfirm}
                >
                  Cancel
                </button>
                <button
                  className="cmd-btn cmd-btn-delete"
                  onClick={handleConfirmDelete}
                >
                  Yes, delete
                </button>
              </div>
            </div>
          ) : (
            <div className="cmd-list" ref={listRef} role="listbox" aria-label="Commands">
              {flatCommands.length === 0 ? (
                <div className="cmd-empty">
                  <span className="cmd-empty-icon">
                    <SearchIcon size={32} />
                  </span>
                  <p className="cmd-empty-title">No results for "{query}"</p>
                  <p className="cmd-empty-hint">Try a different search term</p>
                </div>
              ) : (
                groups.map((group, gi) => (
                  <div key={group.label} className={`cmd-group${gi > 0 ? ' cmd-group--separator' : ''}`}>
                    <div className="cmd-group-heading">{group.label}</div>
                    {group.commands.map((cmd) => {
                      const globalIndex = flatCommands.indexOf(cmd)
                      const isActive = globalIndex === activeIndex
                      const isRecent = recentCommandIds.includes(cmd.id)

                      return (
                        <div
                          key={cmd.id}
                          ref={isActive ? activeItemRef : undefined}
                          role="option"
                          aria-selected={isActive}
                          className={[
                            'cmd-item',
                            isActive ? 'cmd-item--active' : '',
                            cmd.isDangerous ? 'cmd-item--dangerous' : '',
                          ]
                            .filter(Boolean)
                            .join(' ')}
                          style={{ opacity: 1, transition: 'opacity 80ms ease, background 0.12s ease' }}
                          onClick={() => handleSelect(cmd)}
                          onMouseEnter={() => setActiveIndex(globalIndex)}
                        >
                          {cmd.icon ? (
                            <span className="cmd-item-icon">{cmd.icon}</span>
                          ) : cmd.isDangerous ? (
                            <span className="cmd-item-icon cmd-item-icon--danger">
                              <TriangleAlertIcon />
                            </span>
                          ) : (
                            <span className="cmd-item-icon cmd-item-icon--placeholder" />
                          )}

                          <span className="cmd-item-label">{cmd.label}</span>

                          {isRecent && !query && (
                            <span className="cmd-recent-badge">recent</span>
                          )}

                          {cmd.shortcut && (
                            <span className="cmd-shortcut">
                              <kbd>{cmd.shortcut}</kbd>
                            </span>
                          )}
                        </div>
                      )
                    })}
                  </div>
                ))
              )}
            </div>
          )}

          {/* Footer */}
          <div className="cmd-footer">
            ↩ Enter to run&nbsp;&nbsp;•&nbsp;&nbsp;Esc to close
          </div>
        </div>
      </div>
    </>
  )
}
