import { useState, useEffect, useCallback } from 'react'
import stockService from '../services/stockService'

export function useStockMovements() {
  const [movements, setMovements] = useState([])
  const [loading, setLoading]     = useState(true)
  const [error, setError]         = useState(null)

  const load = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await stockService.getAll()
      setMovements(data)
    } catch (e) {
      setError(e.response?.data?.message || 'Erreur de chargement')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  return { movements, loading, error, reload: load }
}
