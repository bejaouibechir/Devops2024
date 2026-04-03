import { useState, useEffect } from 'react'
import reportService from '../services/reportService'
import { useAuth } from '../hooks/useAuth'
import { useAlerts } from '../hooks/useAlerts'
import { formatCurrency } from '../utils/formatCurrency'
import LowStockAlert from '../components/product/LowStockAlert'
import LoadingSpinner from '../components/common/LoadingSpinner'
import { getAlertTypeBadge } from '../utils/stockUtils'

function KpiCard({ icon, label, value, color = 'blue' }) {
  const colors = {
    blue:   'from-blue-500 to-blue-600',
    green:  'from-green-500 to-green-600',
    yellow: 'from-yellow-400 to-yellow-500',
    red:    'from-red-500 to-red-600',
    indigo: 'from-indigo-500 to-indigo-600',
  }
  return (
    <div className={`rounded-xl bg-gradient-to-br ${colors[color]} text-white p-5 shadow-sm`}>
      <div className="text-3xl mb-3">{icon}</div>
      <div className="text-2xl font-bold">{value}</div>
      <div className="text-sm opacity-80 mt-1">{label}</div>
    </div>
  )
}

export default function Dashboard() {
  const { user }                      = useAuth()
  const { activeAlerts, loading: aL } = useAlerts()
  const [summary, setSummary]         = useState(null)
  const [loading, setLoading]         = useState(true)

  useEffect(() => {
    reportService.getSummary()
      .then(setSummary)
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      {/* Welcome */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-700 rounded-2xl p-6 text-white">
        <h2 className="text-xl font-semibold">Bonjour, {user?.username} 👋</h2>
        <p className="text-blue-100 text-sm mt-1">
          Rôle : <strong>{user?.role?.replace('_', ' ')}</strong> — {new Date().toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
        </p>
      </div>

      {/* KPIs */}
      {summary && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <KpiCard icon="📦" label="Total produits"     value={summary.totalProducts}            color="blue"   />
          <KpiCard icon="⚠️" label="Stock bas"          value={summary.lowStockProducts}         color="yellow" />
          <KpiCard icon="🚫" label="Ruptures de stock"  value={summary.outOfStockProducts}       color="red"    />
          <KpiCard icon="💰" label="Valeur totale"      value={formatCurrency(summary.totalStockValue)} color="green"  />
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Alertes actives */}
        <div className="card">
          <h3 className="font-semibold text-gray-800 mb-4">🔔 Alertes actives ({activeAlerts.length})</h3>
          {aL ? (
            <LoadingSpinner text="Chargement des alertes..." />
          ) : activeAlerts.length === 0 ? (
            <div className="text-center py-8 text-gray-400">
              <p className="text-3xl mb-2">✅</p>
              <p className="text-sm">Aucune alerte active</p>
            </div>
          ) : (
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {activeAlerts.slice(0, 8).map(a => {
                const b = getAlertTypeBadge(a.alertType)
                return (
                  <div key={a.id} className="flex items-center gap-3 p-2 bg-gray-50 rounded-lg">
                    <span>{b.icon}</span>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-700 truncate">{a.productName}</p>
                      <p className="text-xs text-gray-500">{a.message}</p>
                    </div>
                    <span className={b.cls}>{b.label}</span>
                  </div>
                )
              })}
              {activeAlerts.length > 8 && (
                <p className="text-xs text-center text-gray-400 pt-1">+ {activeAlerts.length - 8} autres alertes</p>
              )}
            </div>
          )}
        </div>

        {/* Stock bas */}
        <div className="card">
          <h3 className="font-semibold text-gray-800 mb-4">📉 Produits en stock bas</h3>
          <LowStockAlert />
          {summary?.outOfStockProducts > 0 && (
            <div className="mt-3 bg-red-50 border border-red-200 rounded-lg p-3 text-sm text-red-700">
              🚫 <strong>{summary.outOfStockProducts}</strong> produit(s) en rupture totale
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
