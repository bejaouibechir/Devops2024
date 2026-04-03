import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'
import authService from '../services/authService'
import AlertBanner from '../components/common/AlertBanner'

export default function LoginPage() {
  const [form, setForm]     = useState({ username: '', password: '' })
  const [loading, setLoading] = useState(false)
  const [error, setError]   = useState('')
  const { login }           = useAuth()
  const navigate            = useNavigate()

  const change = (e) => setForm(f => ({ ...f, [e.target.name]: e.target.value }))

  const submit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const data = await authService.login(form)
      login(data)
      navigate('/dashboard')
    } catch (err) {
      setError(err.response?.data?.message || 'Identifiants incorrects')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-white/10 rounded-2xl mb-4 backdrop-blur">
            <span className="text-3xl">📦</span>
          </div>
          <h1 className="text-3xl font-bold text-white">StockMaster</h1>
          <p className="text-blue-200 text-sm mt-1">Plateforme de gestion de stock</p>
        </div>

        {/* Card */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-xl font-semibold text-gray-800 mb-6">Connexion</h2>

          {error && <div className="mb-4"><AlertBanner type="error" message={error} /></div>}

          <form onSubmit={submit} className="space-y-4">
            <div>
              <label className="label">Nom d'utilisateur</label>
              <input
                name="username"
                value={form.username}
                onChange={change}
                required
                autoFocus
                className="input-field"
                placeholder="admin"
              />
            </div>

            <div>
              <label className="label">Mot de passe</label>
              <input
                name="password"
                type="password"
                value={form.password}
                onChange={change}
                required
                className="input-field"
                placeholder="••••••••"
              />
            </div>

            <button type="submit" disabled={loading} className="btn-primary w-full py-3 text-base mt-2">
              {loading ? 'Connexion...' : 'Se connecter'}
            </button>
          </form>

          <div className="mt-6 p-3 bg-gray-50 rounded-lg text-xs text-gray-500 text-center">
            Admin : <strong>admin</strong> / <strong>Admin123!</strong>
          </div>
        </div>

        <p className="text-center text-blue-300 text-xs mt-6">
          StockMaster MVP — Bootcamp DevOps
        </p>
      </div>
    </div>
  )
}
