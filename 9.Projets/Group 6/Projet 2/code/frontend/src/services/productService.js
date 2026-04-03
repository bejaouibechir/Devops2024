import api from './api'

const productService = {
  getAll:       ()       => api.get('/products').then(r => r.data),
  getById:      (id)     => api.get(`/products/${id}`).then(r => r.data),
  create:       (data)   => api.post('/products', data).then(r => r.data),
  update:       (id, d)  => api.put(`/products/${id}`, d).then(r => r.data),
  delete:       (id)     => api.delete(`/products/${id}`).then(r => r.data),
  getLowStock:  ()       => api.get('/products/low-stock').then(r => r.data),
  getOutOfStock:()       => api.get('/products/out-of-stock').then(r => r.data),
}

export default productService
