import api from './api'

const reportService = {
  getSummary:    ()             => api.get('/reports/summary').then(r => r.data),
  getStockReport:()             => api.get('/reports/stock').then(r => r.data),
  getMovements:  (start, end)   => api.get(`/reports/movements?start=${start}&end=${end}`).then(r => r.data),
}

export default reportService
