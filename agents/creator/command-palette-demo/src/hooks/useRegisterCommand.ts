import { useEffect } from 'react'
import { useAppState } from '../context/AppStateContext'
import type { Command } from '../types'

export function useRegisterCommand(cmd: Command) {
  const { registerCommand, unregisterCommand } = useAppState()

  useEffect(() => {
    registerCommand(cmd)
    return () => {
      unregisterCommand(cmd.id)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cmd.id])
}
