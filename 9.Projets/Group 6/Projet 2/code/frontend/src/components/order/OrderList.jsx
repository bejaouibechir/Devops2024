import DataTable from '../common/DataTable'
import { formatDate } from '../../utils/formatDate'
import { formatCurrency } from '../../utils/formatCurrency'
import { getOrderStatusBadge } from '../../utils/stockUtils'

const STATUS_OPTIONS = ['PENDING', 'CONFIRMED', 'DELIVERED', 'CANCELLED']

export default function OrderList({ orders, loading, onUpdateStatus, canUpdateStatus }) {
  const columns = [
    { key: 'id', label: '#', render: row => <span className="font-mono text-xs">#{row.id}</span> },
    { key: 'reference', label: 'Référence' },
    {
      key: 'status', label: 'Statut',
      render: row => {
        const b = getOrderStatusBadge(row.status)
        return <span className={b.cls}>{b.label}</span>
      }
    },
    {
      key: 'totalAmount', label: 'Montant',
      render: row => <span className="font-semibold">{formatCurrency(row.totalAmount)}</span>
    },
    { key: 'createdBy', label: 'Créée par' },
    {
      key: 'createdAt', label: 'Date',
      render: row => <span className="text-xs text-gray-500">{formatDate(row.createdAt)}</span>
    },
    ...(canUpdateStatus ? [{
      key: 'actions', label: 'Actions',
      render: row => (
        <select
          value={row.status}
          onChange={e => onUpdateStatus(row.id, e.target.value)}
          className="text-xs border border-gray-300 rounded px-2 py-1 focus:outline-none focus:ring-1 focus:ring-blue-500"
          disabled={row.status === 'DELIVERED' || row.status === 'CANCELLED'}
        >
          {STATUS_OPTIONS.map(s => {
            const b = getOrderStatusBadge(s)
            return <option key={s} value={s}>{b.label}</option>
          })}
        </select>
      )
    }] : [])
  ]

  return (
    <DataTable columns={columns} data={orders} loading={loading} emptyText="Aucune commande" />
  )
}
