import { useState, useEffect, useCallback } from 'react'
import productService from '../services/productService'

export function useProducts() {
  const [products, setProducts]   = useState([])
  const [loading, setLoading]     = useState(true)
  const [error, setError]         = useState(null)

  const load = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await productService.getAll()
      setProducts(data)
    } catch (e) {
      setError(e.response?.data?.message || 'Erreur de chargement')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  return { products, loading, error, reload: load }
}
