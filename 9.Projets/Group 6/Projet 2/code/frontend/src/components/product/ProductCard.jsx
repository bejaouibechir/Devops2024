import { formatCurrency } from '../../utils/formatCurrency'
import { getStockStatusBadge } from '../../utils/stockUtils'

export default function ProductCard({ product, onEdit, onDelete, canEdit }) {
  const badge = getStockStatusBadge(product.stockStatus)

  return (
    <div className="card hover:shadow-md transition-shadow">
      {/* Image */}
      <div className="h-32 bg-gray-100 rounded-lg mb-4 flex items-center justify-center overflow-hidden">
        {product.photoUrl
          ? <img src={product.photoUrl} alt={product.name} className="h-full w-full object-cover rounded-lg" />
          : <span className="text-4xl">📦</span>
        }
      </div>

      {/* Info */}
      <div className="space-y-1">
        <div className="flex items-start justify-between gap-2">
          <h3 className="font-semibold text-gray-800 text-sm leading-tight">{product.name}</h3>
          <span className={badge.cls}>{badge.label}</span>
        </div>
        <p className="text-xs text-gray-400 font-mono">{product.code}</p>
        <p className="text-base font-bold text-blue-600">{formatCurrency(product.unitPrice)}</p>
        <div className="flex items-center justify-between text-xs text-gray-500 pt-1">
          <span>Stock : <strong className="text-gray-700">{product.currentStock}</strong> {product.unit}</span>
          <span>Min : {product.minStock} | Max : {product.maxStock}</span>
        </div>
        {product.categoryName && (
          <p className="text-xs text-gray-400">📁 {product.categoryName}</p>
        )}
      </div>

      {/* Actions */}
      {canEdit && (
        <div className="flex gap-2 mt-4 pt-3 border-t border-gray-100">
          <button onClick={() => onEdit(product)} className="btn-secondary text-xs py-1.5 flex-1">
            ✏️ Modifier
          </button>
          <button onClick={() => onDelete(product)} className="btn-danger text-xs py-1.5 px-3">
            🗑️
          </button>
        </div>
      )}
    </div>
  )
}
