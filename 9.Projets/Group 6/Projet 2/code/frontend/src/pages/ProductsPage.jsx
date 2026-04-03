import { useState } from 'react'
import { useProducts } from '../hooks/useProducts'
import { useAuth } from '../hooks/useAuth'
import productService from '../services/productService'
import ProductList from '../components/product/ProductList'
import ProductForm from '../components/product/ProductForm'
import Modal from '../components/common/Modal'
import AlertBanner from '../components/common/AlertBanner'

export default function ProductsPage() {
  const { products, loading, error, reload } = useProducts()
  const { isStockManager }                   = useAuth()
  const [modal, setModal]   = useState(null) // null | 'create' | {edit: product}
  const [saving, setSaving] = useState(false)
  const [toast, setToast]   = useState(null)

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type })
    setTimeout(() => setToast(null), 3000)
  }

  const handleCreate = async (data) => {
    setSaving(true)
    try {
      await productService.create(data)
      setModal(null)
      reload()
      showToast('Produit créé avec succès')
    } finally {
      setSaving(false)
    }
  }

  const handleUpdate = async (data) => {
    setSaving(true)
    try {
      await productService.update(modal.edit.id, data)
      setModal(null)
      reload()
      showToast('Produit modifié avec succès')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async (product) => {
    if (!confirm(`Supprimer "${product.name}" ?`)) return
    try {
      await productService.delete(product.id)
      reload()
      showToast('Produit supprimé')
    } catch (e) {
      showToast(e.response?.data?.message || 'Suppression impossible (mouvements liés)', 'error')
    }
  }

  return (
    <div className="space-y-4">
      {/* En-tête */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-800">Catalogue produits</h2>
          <p className="text-sm text-gray-500">{products.length} produit(s) au total</p>
        </div>
        {isStockManager() && (
          <button onClick={() => setModal('create')} className="btn-primary">
            + Nouveau produit
          </button>
        )}
      </div>

      {toast && <AlertBanner type={toast.type} message={toast.msg} onClose={() => setToast(null)} />}

      <ProductList
        products={products}
        loading={loading}
        error={error}
        onEdit={(p) => setModal({ edit: p })}
        onDelete={handleDelete}
        canEdit={isStockManager()}
      />

      {/* Modal Création */}
      <Modal title="Nouveau produit" open={modal === 'create'} onClose={() => setModal(null)}>
        <ProductForm
          onSubmit={handleCreate}
          onCancel={() => setModal(null)}
          loading={saving}
        />
      </Modal>

      {/* Modal Édition */}
      <Modal title="Modifier le produit" open={!!modal?.edit} onClose={() => setModal(null)}>
        {modal?.edit && (
          <ProductForm
            initial={modal.edit}
            onSubmit={handleUpdate}
            onCancel={() => setModal(null)}
            loading={saving}
          />
        )}
      </Modal>
    </div>
  )
}
