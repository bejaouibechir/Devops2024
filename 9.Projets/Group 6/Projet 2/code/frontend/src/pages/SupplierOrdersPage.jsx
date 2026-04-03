import { useState, useEffect, useCallback } from 'react'
import orderService from '../services/orderService'
import SupplierOrderForm from '../components/order/SupplierOrderForm'
import OrderList from '../components/order/OrderList'
import AlertBanner from '../components/common/AlertBanner'

export default function SupplierOrdersPage() {
  const [orders, setOrders]   = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError]     = useState('')
  const [tab, setTab]         = useState('list') // 'list' | 'create'

  const load = useCallback(async () => {
    try {
      setLoading(true)
      const data = await orderService.getByType('SUPPLIER')
      setOrders(data)
    } catch (e) {
      setError(e.response?.data?.message || 'Erreur de chargement')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  const handleUpdateStatus = async (id, status) => {
    try {
      await orderService.updateStatus(id, status)
      load()
    } catch (e) {
      setError(e.response?.data?.message || 'Erreur de mise à jour')
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-800">Commandes fournisseurs</h2>
          <p className="text-sm text-gray-500">{orders.length} commande(s)</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setTab('list')}
            className={tab === 'list' ? 'btn-primary' : 'btn-secondary'}
          >
            📋 Liste
          </button>
          <button
            onClick={() => setTab('create')}
            className={tab === 'create' ? 'btn-primary' : 'btn-secondary'}
          >
            + Nouvelle commande
          </button>
        </div>
      </div>

      {error && <AlertBanner type="error" message={error} onClose={() => setError('')} />}

      {tab === 'list' ? (
        <div className="card">
          <OrderList
            orders={orders}
            loading={loading}
            onUpdateStatus={handleUpdateStatus}
            canUpdateStatus
          />
        </div>
      ) : (
        <div className="card max-w-3xl">
          <h3 className="font-semibold text-gray-700 mb-4">Nouvelle commande fournisseur</h3>
          <SupplierOrderForm onSuccess={() => { load(); setTab('list') }} />
        </div>
      )}
    </div>
  )
}
