import { useState, useEffect } from 'react'
import productService from '../../services/productService'
import stockService from '../../services/stockService'
import AlertBanner from '../common/AlertBanner'

const EMPTY = { productId: '', type: 'ENTRY', quantity: '', reason: '' }

export default function StockMovementForm({ onSuccess }) {
  const [form, setForm]       = useState(EMPTY)
  const [products, setProducts] = useState([])
  const [loading, setLoading]   = useState(false)
  const [error, setError]       = useState('')
  const [success, setSuccess]   = useState('')

  useEffect(() => {
    productService.getAll().then(setProducts).catch(() => {})
  }, [])

  const change = (e) => {
    const { name, value } = e.target
    setForm(f => ({ ...f, [name]: value }))
  }

  const submit = async (e) => {
    e.preventDefault()
    setError('')
    setSuccess('')
    setLoading(true)
    try {
      await stockService.create({
        productId: parseInt(form.productId),
        type: form.type,
        quantity: parseInt(form.quantity),
        reason: form.reason,
      })
      setSuccess('Mouvement enregistré avec succès')
      setForm(EMPTY)
      onSuccess?.()
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de l\'enregistrement')
    } finally {
      setLoading(false)
    }
  }

  const typeColors = {
    ENTRY:      'border-green-500 text-green-700 bg-green-50',
    EXIT:       'border-red-500 text-red-700 bg-red-50',
    ADJUSTMENT: 'border-blue-500 text-blue-700 bg-blue-50',
  }

  return (
    <form onSubmit={submit} className="space-y-4">
      {error   && <AlertBanner type="error"   message={error}   onClose={() => setError('')}   />}
      {success && <AlertBanner type="success" message={success} onClose={() => setSuccess('')} />}

      {/* Type de mouvement */}
      <div>
        <label className="label">Type de mouvement *</label>
        <div className="grid grid-cols-3 gap-3">
          {['ENTRY', 'EXIT', 'ADJUSTMENT'].map(t => (
            <label
              key={t}
              className={`border-2 rounded-lg p-3 text-center text-sm font-medium cursor-pointer transition-colors ${
                form.type === t ? typeColors[t] : 'border-gray-200 text-gray-600 hover:border-gray-300'
              }`}
            >
              <input
                type="radio" name="type" value={t}
                checked={form.type === t}
                onChange={change}
                className="sr-only"
              />
              {t === 'ENTRY' ? '📥 Entrée' : t === 'EXIT' ? '📤 Sortie' : '⚖️ Ajustement'}
            </label>
          ))}
        </div>
      </div>

      <div>
        <label className="label">Produit *</label>
        <select name="productId" value={form.productId} onChange={change} required className="input-field">
          <option value="">-- Sélectionner un produit --</option>
          {products.map(p => (
            <option key={p.id} value={p.id}>
              {p.name} ({p.code}) — Stock actuel : {p.currentStock}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label className="label">Quantité *</label>
        <input
          name="quantity" type="number" min="1"
          value={form.quantity} onChange={change}
          required className="input-field" placeholder="0"
        />
      </div>

      <div>
        <label className="label">Motif / Référence</label>
        <input
          name="reason" value={form.reason} onChange={change}
          className="input-field" placeholder="Réception commande, vente, inventaire..."
        />
      </div>

      <button type="submit" disabled={loading} className="btn-primary w-full">
        {loading ? 'Enregistrement...' : 'Enregistrer le mouvement'}
      </button>
    </form>
  )
}
