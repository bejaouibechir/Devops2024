import { useState, useEffect } from 'react'
import productService from '../../services/productService'
import orderService from '../../services/orderService'
import AlertBanner from '../common/AlertBanner'
import { formatCurrency } from '../../utils/formatCurrency'

const EMPTY_ITEM = { productId: '', quantity: 1, unitPrice: '' }

export default function CustomerOrderForm({ onSuccess }) {
  const [items, setItems]       = useState([{ ...EMPTY_ITEM }])
  const [notes, setNotes]       = useState('')
  const [products, setProducts] = useState([])
  const [loading, setLoading]   = useState(false)
  const [error, setError]       = useState('')

  useEffect(() => {
    productService.getAll().then(setProducts).catch(() => {})
  }, [])

  const addItem    = () => setItems(i => [...i, { ...EMPTY_ITEM }])
  const removeItem = (idx) => setItems(i => i.filter((_, n) => n !== idx))
  const changeItem = (idx, field, value) => {
    setItems(i => i.map((item, n) => {
      if (n !== idx) return item
      const updated = { ...item, [field]: value }
      if (field === 'productId') {
        const prod = products.find(p => p.id === parseInt(value))
        if (prod) updated.unitPrice = prod.unitPrice
      }
      return updated
    }))
  }

  const total = items.reduce((sum, i) => sum + (parseFloat(i.unitPrice)||0) * (parseInt(i.quantity)||0), 0)

  const submit = async (e) => {
    e.preventDefault()
    setError('')
    if (items.some(i => !i.productId || !i.quantity || !i.unitPrice)) {
      setError('Veuillez compléter tous les articles')
      return
    }
    setLoading(true)
    try {
      await orderService.create({
        type: 'CUSTOMER',
        notes,
        items: items.map(i => ({
          productId: parseInt(i.productId),
          quantity: parseInt(i.quantity),
          unitPrice: parseFloat(i.unitPrice),
        })),
      })
      setItems([{ ...EMPTY_ITEM }])
      setNotes('')
      onSuccess?.()
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de la création')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={submit} className="space-y-4">
      {error && <AlertBanner type="error" message={error} />}

      <h3 className="font-semibold text-gray-700">Articles vendus</h3>

      {items.map((item, idx) => (
        <div key={idx} className="grid grid-cols-12 gap-2 items-end p-3 bg-gray-50 rounded-lg">
          <div className="col-span-5">
            {idx === 0 && <label className="label">Produit</label>}
            <select value={item.productId} onChange={e => changeItem(idx, 'productId', e.target.value)} className="input-field" required>
              <option value="">-- Produit --</option>
              {products.map(p => (
                <option key={p.id} value={p.id} disabled={p.currentStock === 0}>
                  {p.name} — Stock : {p.currentStock}
                </option>
              ))}
            </select>
          </div>
          <div className="col-span-2">
            {idx === 0 && <label className="label">Qté</label>}
            <input type="number" min="1" value={item.quantity} onChange={e => changeItem(idx, 'quantity', e.target.value)} className="input-field" required />
          </div>
          <div className="col-span-3">
            {idx === 0 && <label className="label">Prix unit.</label>}
            <input type="number" step="0.001" value={item.unitPrice} onChange={e => changeItem(idx, 'unitPrice', e.target.value)} className="input-field" required />
          </div>
          <div className="col-span-1 text-xs text-gray-500 pb-2">
            {formatCurrency((parseFloat(item.unitPrice)||0) * (parseInt(item.quantity)||0))}
          </div>
          <div className="col-span-1">
            {items.length > 1 && (
              <button type="button" onClick={() => removeItem(idx)} className="text-red-400 hover:text-red-600 text-xl pb-1">×</button>
            )}
          </div>
        </div>
      ))}

      <button type="button" onClick={addItem} className="btn-secondary text-sm w-full">
        + Ajouter un article
      </button>

      <div className="flex items-center justify-between bg-green-50 px-4 py-2 rounded-lg">
        <span className="font-medium text-gray-700">Total vente</span>
        <span className="font-bold text-green-700 text-lg">{formatCurrency(total)}</span>
      </div>

      <div>
        <label className="label">Notes / Client</label>
        <textarea value={notes} onChange={e => setNotes(e.target.value)} rows={2} className="input-field" placeholder="Nom du client, remarques..." />
      </div>

      <button type="submit" disabled={loading} className="btn-success w-full">
        {loading ? 'Création...' : '🛍️ Créer la commande client'}
      </button>
    </form>
  )
}
