import api from './api'

const supplierService = {
  getAll:  ()      => api.get('/suppliers').then(r => r.data),
  create:  (data)  => api.post('/suppliers', data).then(r => r.data),
  update:  (id, d) => api.put(`/suppliers/${id}`, d).then(r => r.data),
  delete:  (id)    => api.delete(`/suppliers/${id}`).then(r => r.data),
}

export default supplierService
