import { useState, useEffect } from 'react'
import categoryService from '../../services/categoryService'
import supplierService from '../../services/supplierService'
import AlertBanner from '../common/AlertBanner'

const EMPTY = {
  code: '', name: '', description: '', unitPrice: '',
  unit: '', currentStock: '', minStock: '', maxStock: '',
  categoryId: '', supplierId: '', photoUrl: '',
}

export default function ProductForm({ initial, onSubmit, onCancel, loading }) {
  const [form, setForm]         = useState(initial ? {
    ...initial,
    categoryId: initial.categoryId ?? '',
    supplierId: initial.supplierId ?? '',
  } : EMPTY)
  const [categories, setCategories] = useState([])
  const [suppliers, setSuppliers]   = useState([])
  const [error, setError]           = useState('')

  useEffect(() => {
    Promise.all([
      categoryService.getAll(),
      supplierService.getAll(),
    ]).then(([cats, sups]) => {
      setCategories(cats)
      setSuppliers(sups)
    }).catch(() => {})
  }, [])

  const change = (e) => {
    const { name, value } = e.target
    setForm(f => ({ ...f, [name]: value }))
  }

  const submit = async (e) => {
    e.preventDefault()
    setError('')
    try {
      await onSubmit({
        ...form,
        unitPrice: parseFloat(form.unitPrice),
        currentStock: parseInt(form.currentStock),
        minStock: parseInt(form.minStock),
        maxStock: parseInt(form.maxStock),
        categoryId: parseInt(form.categoryId) || null,
        supplierId: parseInt(form.supplierId) || null,
      })
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de l\'enregistrement')
    }
  }

  return (
    <form onSubmit={submit} className="space-y-4">
      {error && <AlertBanner type="error" message={error} />}

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="label">Code *</label>
          <input name="code" value={form.code} onChange={change} required className="input-field" placeholder="PROD-001" />
        </div>
        <div>
          <label className="label">Nom *</label>
          <input name="name" value={form.name} onChange={change} required className="input-field" placeholder="Nom du produit" />
        </div>
      </div>

      <div>
        <label className="label">Description</label>
        <textarea name="description" value={form.description} onChange={change} rows={2} className="input-field" />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="label">Prix unitaire *</label>
          <input name="unitPrice" type="number" step="0.001" value={form.unitPrice} onChange={change} required className="input-field" placeholder="0.000" />
        </div>
        <div>
          <label className="label">Unité</label>
          <input name="unit" value={form.unit} onChange={change} className="input-field" placeholder="pièce, kg, L..." />
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div>
          <label className="label">Stock actuel *</label>
          <input name="currentStock" type="number" value={form.currentStock} onChange={change} required className="input-field" placeholder="0" />
        </div>
        <div>
          <label className="label">Stock min *</label>
          <input name="minStock" type="number" value={form.minStock} onChange={change} required className="input-field" placeholder="5" />
        </div>
        <div>
          <label className="label">Stock max *</label>
          <input name="maxStock" type="number" value={form.maxStock} onChange={change} required className="input-field" placeholder="100" />
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="label">Catégorie</label>
          <select name="categoryId" value={form.categoryId} onChange={change} className="input-field">
            <option value="">-- Sélectionner --</option>
            {categories.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </div>
        <div>
          <label className="label">Fournisseur</label>
          <select name="supplierId" value={form.supplierId} onChange={change} className="input-field">
            <option value="">-- Sélectionner --</option>
            {suppliers.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
          </select>
        </div>
      </div>

      <div>
        <label className="label">URL photo</label>
        <input name="photoUrl" value={form.photoUrl} onChange={change} className="input-field" placeholder="https://..." />
      </div>

      <div className="flex gap-3 pt-2">
        <button type="submit" disabled={loading} className="btn-primary flex-1">
          {loading ? 'Enregistrement...' : initial ? 'Modifier' : 'Créer le produit'}
        </button>
        <button type="button" onClick={onCancel} className="btn-secondary">
          Annuler
        </button>
      </div>
    </form>
  )
}
