import { useState, useEffect, useCallback } from 'react'
import alertService from '../services/alertService'

export function useAlerts() {
  const [alerts, setAlerts]   = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError]     = useState(null)

  const load = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await alertService.getAll()
      setAlerts(data)
    } catch (e) {
      setError(e.response?.data?.message || 'Erreur de chargement')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  const activeAlerts = alerts.filter(a => !a.resolved)
  return { alerts, activeAlerts, loading, error, reload: load }
}
