import { useState, useEffect } from 'react'
import productService from '../../services/productService'
import { useNavigate } from 'react-router-dom'

export default function LowStockAlert() {
  const [items, setItems]   = useState([])
  const navigate            = useNavigate()

  useEffect(() => {
    productService.getLowStock().then(setItems).catch(() => {})
  }, [])

  if (items.length === 0) return null

  return (
    <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
      <div className="flex items-center gap-2 mb-2">
        <span>⚠️</span>
        <span className="font-semibold text-yellow-800 text-sm">
          {items.length} produit(s) en stock bas
        </span>
      </div>
      <div className="space-y-1">
        {items.slice(0, 5).map(p => (
          <div key={p.id} className="flex items-center justify-between text-xs text-yellow-700">
            <span>{p.name}</span>
            <span className="font-mono">{p.currentStock} / {p.minStock} min</span>
          </div>
        ))}
      </div>
      {items.length > 5 && (
        <button
          onClick={() => navigate('/products')}
          className="text-xs text-yellow-600 underline mt-2"
        >
          Voir tous les {items.length} produits →
        </button>
      )}
    </div>
  )
}
