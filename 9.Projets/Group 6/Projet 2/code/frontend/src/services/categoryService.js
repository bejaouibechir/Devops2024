import api from './api'

const categoryService = {
  getAll:  ()      => api.get('/categories').then(r => r.data),
  create:  (data)  => api.post('/categories', data).then(r => r.data),
  update:  (id, d) => api.put(`/categories/${id}`, d).then(r => r.data),
  delete:  (id)    => api.delete(`/categories/${id}`).then(r => r.data),
}

export default categoryService
