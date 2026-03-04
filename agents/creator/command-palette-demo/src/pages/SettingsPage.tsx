import React, { useState } from 'react'
import { useAppState } from '../context/AppStateContext'
import { useRegisterCommand } from '../hooks/useRegisterCommand'
import { SunIcon, GearIcon } from '../components/Icons'

export function SettingsPage() {
  const { showToast, setCurrentPage } = useAppState()
  const [darkMode, setDarkMode] = useState(true)
  const [notifications, setNotifications] = useState(true)
  const [compactMode, setCompactMode] = useState(false)
  const [autoSave, setAutoSave] = useState(true)

  useRegisterCommand({
    id: 'settings-toggle-dark-mode',
    label: darkMode ? 'Disable Dark Mode' : 'Enable Dark Mode',
    keywords: ['dark', 'light', 'theme', 'mode', 'appearance', 'color scheme'],
    icon: <SunIcon />,
    category: 'settings',
    handler: () => {
      setDarkMode((v) => !v)
      showToast('Theme updated (mock)', 'success')
    },
  })

  useRegisterCommand({
    id: 'settings-toggle-notifications',
    label: notifications ? 'Disable Notifications' : 'Enable Notifications',
    keywords: ['notifications', 'alerts', 'push', 'notify', 'mute', 'unmute'],
    icon: <GearIcon />,
    category: 'settings',
    handler: () => {
      setNotifications((v) => !v)
      showToast('Notification preference saved (mock)', 'info')
    },
  })

  useRegisterCommand({
    id: 'settings-toggle-compact',
    label: compactMode ? 'Disable Compact Mode' : 'Enable Compact Mode',
    keywords: ['compact', 'dense', 'display', 'view', 'layout'],
    icon: <GearIcon />,
    category: 'settings',
    handler: () => {
      setCompactMode((v) => !v)
      showToast('Compact mode toggled (mock)', 'info')
    },
  })

  useRegisterCommand({
    id: 'settings-reset',
    label: 'Reset All Settings to Defaults',
    keywords: ['reset', 'default', 'clear', 'restore', 'factory', 'wipe settings'],
    icon: <GearIcon />,
    category: 'settings',
    isDangerous: true,
    handler: () => {
      setDarkMode(true)
      setNotifications(true)
      setCompactMode(false)
      setAutoSave(true)
      showToast('Settings reset to defaults', 'warning')
    },
  })

  const ToggleRow = ({
    label,
    desc,
    value,
    onChange,
    id,
  }: {
    label: string
    desc?: string
    value: boolean
    onChange: () => void
    id: string
  }) => (
    <div className="settings-row">
      <div>
        <div className="settings-row-label">{label}</div>
        {desc && <div className="settings-row-desc">{desc}</div>}
      </div>
      <button
        id={id}
        className={`toggle ${value ? 'on' : ''}`}
        onClick={onChange}
        role="switch"
        aria-checked={value}
        aria-label={label}
      />
    </div>
  )

  return (
    <main className="app-main" aria-label="Settings">
      <div className="page-header">
        <h1 className="page-title">Settings</h1>
        <p className="page-subtitle">Configure your workspace preferences</p>
      </div>

      <div className="settings-section">
        <div className="settings-section-title">Appearance</div>
        <ToggleRow
          id="dark-mode"
          label="Dark Mode"
          desc="Use a dark color scheme throughout the app"
          value={darkMode}
          onChange={() => {
            setDarkMode((v) => !v)
            showToast('Theme updated (mock)', 'success')
          }}
        />
        <ToggleRow
          id="compact-mode"
          label="Compact Mode"
          desc="Reduce spacing for more information density"
          value={compactMode}
          onChange={() => {
            setCompactMode((v) => !v)
            showToast('Compact mode toggled (mock)', 'info')
          }}
        />
      </div>

      <div className="settings-section">
        <div className="settings-section-title">Notifications</div>
        <ToggleRow
          id="notifications"
          label="Push Notifications"
          desc="Receive notifications for activity in your workspace"
          value={notifications}
          onChange={() => {
            setNotifications((v) => !v)
            showToast('Notification preference saved (mock)', 'info')
          }}
        />
        <ToggleRow
          id="auto-save"
          label="Auto Save"
          desc="Automatically save changes as you type"
          value={autoSave}
          onChange={() => {
            setAutoSave((v) => !v)
            showToast('Auto save preference saved (mock)', 'info')
          }}
        />
      </div>

      <div className="settings-section">
        <div className="settings-section-title">Danger Zone</div>
        <div className="settings-row">
          <div>
            <div className="settings-row-label">Reset All Settings</div>
            <div className="settings-row-desc">Restore all settings to their factory defaults</div>
          </div>
          <button
            className="btn btn-danger"
            onClick={() => {
              setDarkMode(true)
              setNotifications(true)
              setCompactMode(false)
              setAutoSave(true)
              showToast('Settings reset to defaults', 'warning')
            }}
          >
            Reset
          </button>
        </div>
      </div>

      <div
        style={{
          marginTop: 16,
          padding: '14px 18px',
          background: 'rgba(124,109,250,0.05)',
          borderRadius: 8,
          border: '1px solid rgba(124,109,250,0.12)',
          fontSize: 12,
          color: '#666',
          maxWidth: 600,
        }}
      >
        💡 Try the command palette here — settings-specific commands like "Enable Dark Mode" and "Reset All Settings" (dangerous!) are available.
      </div>
    </main>
  )
}
