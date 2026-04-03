import api from './api'

const orderService = {
  getAll:         ()            => api.get('/orders').then(r => r.data),
  getById:        (id)          => api.get(`/orders/${id}`).then(r => r.data),
  getByType:      (type)        => api.get(`/orders/type/${type}`).then(r => r.data),
  create:         (data)        => api.post('/orders', data).then(r => r.data),
  updateStatus:   (id, status)  => api.patch(`/orders/${id}/status?status=${status}`).then(r => r.data),
}

export default orderService
