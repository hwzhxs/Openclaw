import React from 'react'

export type PageName = 'dashboard' | 'items' | 'item-detail' | 'settings'

export interface AppContext {
  currentPage: PageName
  selectedItemId: string | null
  selectedItemType: string | null
}

export interface Command {
  id: string
  label: string
  keywords: string[]
  icon?: React.ReactNode
  shortcut?: string
  category: 'navigation' | 'action' | 'settings'
  contextFilter?: (ctx: AppContext) => boolean
  isDangerous?: boolean
  handler: (ctx: AppContext) => void
}
