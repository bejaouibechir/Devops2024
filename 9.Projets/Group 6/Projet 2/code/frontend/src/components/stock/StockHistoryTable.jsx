import DataTable from '../common/DataTable'
import { formatDateTime } from '../../utils/formatDate'
import { getMovementTypeBadge } from '../../utils/stockUtils'
import { useState } from 'react'

export default function StockHistoryTable({ movements, loading }) {
  const [search, setSearch] = useState('')

  const filtered = movements.filter(m =>
    !search ||
    m.productName?.toLowerCase().includes(search.toLowerCase()) ||
    m.reason?.toLowerCase().includes(search.toLowerCase())
  )

  const columns = [
    {
      key: 'date', label: 'Date',
      render: row => <span className="text-xs text-gray-500">{formatDateTime(row.createdAt)}</span>
    },
    { key: 'productName', label: 'Produit' },
    {
      key: 'type', label: 'Type',
      render: row => {
        const b = getMovementTypeBadge(row.type)
        return <span className={b.cls}>{b.label}</span>
      }
    },
    {
      key: 'quantity', label: 'Quantité',
      render: row => (
        <span className={`font-mono font-semibold ${
          row.type === 'ENTRY' ? 'text-green-600' :
          row.type === 'EXIT'  ? 'text-red-600'   : 'text-blue-600'
        }`}>
          {row.type === 'EXIT' ? '-' : '+'}{row.quantity}
        </span>
      )
    },
    { key: 'reason', label: 'Motif' },
    { key: 'createdBy', label: 'Opérateur' },
  ]

  return (
    <div className="space-y-4">
      <input
        type="text"
        placeholder="Filtrer les mouvements..."
        value={search}
        onChange={e => setSearch(e.target.value)}
        className="input-field max-w-xs"
      />
      <DataTable columns={columns} data={filtered} loading={loading} emptyText="Aucun mouvement de stock" />
    </div>
  )
}
