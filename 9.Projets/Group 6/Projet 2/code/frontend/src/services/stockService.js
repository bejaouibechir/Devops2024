import api from './api'

const stockService = {
  getAll:  ()     => api.get('/stock-movements').then(r => r.data),
  create:  (data) => api.post('/stock-movements', data).then(r => r.data),
}

export default stockService
