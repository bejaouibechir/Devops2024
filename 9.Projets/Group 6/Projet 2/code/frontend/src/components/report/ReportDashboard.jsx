import { useState, useEffect } from 'react'
import reportService from '../../services/reportService'
import { formatCurrency } from '../../utils/formatCurrency'
import { getStockStatusBadge } from '../../utils/stockUtils'
import { formatDateTime, toIsoLocal } from '../../utils/formatDate'
import LoadingSpinner from '../common/LoadingSpinner'
import AlertBanner from '../common/AlertBanner'
import DataTable from '../common/DataTable'

function StatCard({ icon, label, value, sub, color = 'blue' }) {
  const colors = {
    blue:   'bg-blue-50 text-blue-600',
    green:  'bg-green-50 text-green-600',
    yellow: 'bg-yellow-50 text-yellow-600',
    red:    'bg-red-50 text-red-600',
  }
  return (
    <div className="card flex items-center gap-4">
      <div className={`w-12 h-12 rounded-xl flex items-center justify-center text-2xl ${colors[color]}`}>
        {icon}
      </div>
      <div>
        <p className="text-2xl font-bold text-gray-800">{value}</p>
        <p className="text-sm font-medium text-gray-600">{label}</p>
        {sub && <p className="text-xs text-gray-400">{sub}</p>}
      </div>
    </div>
  )
}

export default function ReportDashboard() {
  const [summary, setSummary]       = useState(null)
  const [stockReport, setStockReport] = useState([])
  const [movements, setMovements]   = useState([])
  const [loading, setLoading]       = useState(true)
  const [movLoading, setMovLoading] = useState(false)
  const [error, setError]           = useState('')
  const [tab, setTab]               = useState('summary')

  const now = new Date()
  const firstDay = new Date(now.getFullYear(), now.getMonth(), 1)
  const [startDate, setStartDate] = useState(toIsoLocal(firstDay).slice(0,16))
  const [endDate,   setEndDate]   = useState(toIsoLocal(now).slice(0,16))

  useEffect(() => {
    Promise.all([
      reportService.getSummary(),
      reportService.getStockReport(),
    ]).then(([s, r]) => {
      setSummary(s)
      setStockReport(r)
    }).catch(e => setError(e.response?.data?.message || 'Erreur de chargement'))
    .finally(() => setLoading(false))
  }, [])

  const loadMovements = async () => {
    setMovLoading(true)
    setError('')
    try {
      const data = await reportService.getMovements(
        startDate.replace('T', ' ') + ':00',
        endDate.replace('T', ' ')   + ':00'
      )
      setMovements(data)
    } catch (e) {
      setError(e.response?.data?.message || 'Erreur de chargement')
    } finally {
      setMovLoading(false)
    }
  }

  const stockColumns = [
    { key: 'code', label: 'Code', render: r => <span className="font-mono text-xs">{r.code}</span> },
    { key: 'name', label: 'Produit' },
    { key: 'currentStock', label: 'Stock', render: r => <span className="font-semibold">{r.currentStock}</span> },
    { key: 'minStock', label: 'Min' },
    { key: 'maxStock', label: 'Max' },
    { key: 'unitPrice', label: 'Prix', render: r => formatCurrency(r.unitPrice) },
    {
      key: 'stockStatus', label: 'Statut',
      render: r => { const b = getStockStatusBadge(r.stockStatus); return <span className={b.cls}>{b.label}</span> }
    },
  ]

  const movColumns = [
    { key: 'createdAt', label: 'Date', render: r => <span className="text-xs">{formatDateTime(r.createdAt)}</span> },
    { key: 'productName', label: 'Produit' },
    { key: 'type', label: 'Type' },
    { key: 'quantity', label: 'Qté', render: r => <span className="font-mono">{r.quantity}</span> },
    { key: 'reason', label: 'Motif' },
    { key: 'createdBy', label: 'Par' },
  ]

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      {error && <AlertBanner type="error" message={error} />}

      {/* Summary KPIs */}
      {summary && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard icon="📦" label="Total produits"   value={summary.totalProducts}      color="blue"   />
          <StatCard icon="⚠️" label="Stock bas"        value={summary.lowStockProducts}   color="yellow" />
          <StatCard icon="🚫" label="Ruptures"         value={summary.outOfStockProducts} color="red"    />
          <StatCard icon="💰" label="Valeur du stock"  value={formatCurrency(summary.totalStockValue)} color="green" />
        </div>
      )}

      {/* Tabs */}
      <div className="card">
        <div className="flex gap-4 border-b mb-6">
          {[
            { id: 'summary', label: '📋 État du stock' },
            { id: 'movements', label: '🔄 Historique mouvements' },
          ].map(t => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={`pb-3 text-sm font-medium border-b-2 transition-colors ${
                tab === t.id ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>

        {tab === 'summary' && (
          <DataTable columns={stockColumns} data={stockReport} loading={false} emptyText="Aucun produit" />
        )}

        {tab === 'movements' && (
          <div className="space-y-4">
            <div className="flex gap-3 flex-wrap items-end">
              <div>
                <label className="label">Du</label>
                <input type="datetime-local" value={startDate} onChange={e => setStartDate(e.target.value)} className="input-field" />
              </div>
              <div>
                <label className="label">Au</label>
                <input type="datetime-local" value={endDate} onChange={e => setEndDate(e.target.value)} className="input-field" />
              </div>
              <button onClick={loadMovements} disabled={movLoading} className="btn-primary">
                {movLoading ? 'Chargement...' : '🔍 Rechercher'}
              </button>
            </div>
            <DataTable columns={movColumns} data={movements} loading={movLoading} emptyText="Lancez une recherche" />
          </div>
        )}
      </div>
    </div>
  )
}
