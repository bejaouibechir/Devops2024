import api from './api'

const authService = {
  login: (credentials) =>
    api.post('/auth/login', credentials).then(r => r.data),

  register: (data) =>
    api.post('/auth/register', data).then(r => r.data),
}

export default authService
