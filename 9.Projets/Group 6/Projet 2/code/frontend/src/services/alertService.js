import api from './api'

const alertService = {
  getAll:    ()     => api.get('/alerts').then(r => r.data),
  resolve:   (id)   => api.patch(`/alerts/${id}/resolve`).then(r => r.data),
}

export default alertService
