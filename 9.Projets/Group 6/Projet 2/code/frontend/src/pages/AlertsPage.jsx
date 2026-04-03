import { useAlerts } from '../hooks/useAlerts'
import { getAlertTypeBadge } from '../utils/stockUtils'
import { formatDateTime } from '../utils/formatDate'
import LoadingSpinner from '../components/common/LoadingSpinner'
import AlertBanner from '../components/common/AlertBanner'
import DataTable from '../components/common/DataTable'
import { useState } from 'react'

export default function AlertsPage() {
  const { alerts, activeAlerts, loading, error, reload } = useAlerts()
  const [filter, setFilter] = useState('ACTIVE') // ACTIVE | ALL

  const displayed = filter === 'ACTIVE'
    ? alerts.filter(a => !a.resolved)
    : alerts

  const columns = [
    {
      key: 'alertType', label: 'Type',
      render: row => {
        const b = getAlertTypeBadge(row.alertType)
        return (
          <span className={`${b.cls} flex items-center gap-1`}>
            {b.icon} {b.label}
          </span>
        )
      }
    },
    { key: 'productName', label: 'Produit' },
    { key: 'message', label: 'Message' },
    {
      key: 'resolved', label: 'Statut',
      render: row => row.resolved
        ? <span className="badge-green">Résolue</span>
        : <span className="badge-red">Active</span>
    },
    {
      key: 'createdAt', label: 'Date',
      render: row => <span className="text-xs text-gray-500">{formatDateTime(row.createdAt)}</span>
    },
  ]

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-800">Alertes de stock</h2>
          <p className="text-sm text-gray-500">
            <span className="text-red-600 font-medium">{activeAlerts.length} active(s)</span>
            {' '}/ {alerts.length} total
          </p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setFilter('ACTIVE')} className={filter === 'ACTIVE' ? 'btn-primary' : 'btn-secondary'}>
            🔔 Actives ({activeAlerts.length})
          </button>
          <button onClick={() => setFilter('ALL')} className={filter === 'ALL' ? 'btn-primary' : 'btn-secondary'}>
            Toutes ({alerts.length})
          </button>
          <button onClick={reload} className="btn-secondary">🔄</button>
        </div>
      </div>

      {error && <AlertBanner type="error" message={error} />}

      {/* Résumé par type */}
      {activeAlerts.length > 0 && (
        <div className="grid grid-cols-3 gap-4">
          {['OUT_OF_STOCK', 'LOW_STOCK', 'OVERSTOCK'].map(type => {
            const count = activeAlerts.filter(a => a.alertType === type).length
            const b = getAlertTypeBadge(type)
            return (
              <div key={type} className="card text-center">
                <p className="text-3xl mb-1">{b.icon}</p>
                <p className="text-2xl font-bold text-gray-800">{count}</p>
                <p className="text-sm text-gray-500">{b.label}</p>
              </div>
            )
          })}
        </div>
      )}

      <div className="card">
        <DataTable columns={columns} data={displayed} loading={false} emptyText="Aucune alerte" />
      </div>
    </div>
  )
}
