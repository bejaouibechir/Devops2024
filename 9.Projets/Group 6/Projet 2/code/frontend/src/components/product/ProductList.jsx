import { useState } from 'react'
import ProductCard from './ProductCard'
import LoadingSpinner from '../common/LoadingSpinner'
import AlertBanner from '../common/AlertBanner'

export default function ProductList({ products, loading, error, onEdit, onDelete, canEdit }) {
  const [search, setSearch]   = useState('')
  const [filter, setFilter]   = useState('ALL')

  const filtered = products.filter(p => {
    const matchSearch = !search ||
      p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.code.toLowerCase().includes(search.toLowerCase())
    const matchFilter = filter === 'ALL' || p.stockStatus === filter
    return matchSearch && matchFilter
  })

  if (loading) return <LoadingSpinner />
  if (error)   return <AlertBanner type="error" message={error} />

  return (
    <div className="space-y-4">
      {/* Filtres */}
      <div className="flex flex-wrap gap-3">
        <input
          type="text"
          placeholder="Rechercher un produit..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="input-field max-w-xs"
        />
        <select value={filter} onChange={e => setFilter(e.target.value)} className="input-field w-auto">
          <option value="ALL">Tous les statuts</option>
          <option value="NORMAL">Normal</option>
          <option value="LOW_STOCK">Stock bas</option>
          <option value="OUT_OF_STOCK">Rupture</option>
          <option value="OVERSTOCK">Surstock</option>
        </select>
        <span className="text-sm text-gray-500 self-center">{filtered.length} produit(s)</span>
      </div>

      {/* Grille */}
      {filtered.length === 0 ? (
        <div className="text-center py-16 text-gray-400">
          <p className="text-4xl mb-3">📦</p>
          <p>Aucun produit trouvé</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filtered.map(p => (
            <ProductCard
              key={p.id}
              product={p}
              onEdit={onEdit}
              onDelete={onDelete}
              canEdit={canEdit}
            />
          ))}
        </div>
      )}
    </div>
  )
}
