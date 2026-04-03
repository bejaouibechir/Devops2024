import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../hooks/useAuth'
import { useAlerts } from '../../hooks/useAlerts'

export default function Navbar({ title }) {
  const { logout } = useAuth()
  const { activeAlerts } = useAlerts()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6">
      <h1 className="text-lg font-semibold text-gray-800">{title}</h1>
      <div className="flex items-center gap-4">
        {/* Badge alertes */}
        <button
          onClick={() => navigate('/alerts')}
          className="relative p-2 text-gray-500 hover:text-gray-700"
          title="Alertes actives"
        >
          🔔
          {activeAlerts.length > 0 && (
            <span className="absolute top-0.5 right-0.5 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
              {activeAlerts.length > 9 ? '9+' : activeAlerts.length}
            </span>
          )}
        </button>

        {/* Déconnexion */}
        <button onClick={handleLogout} className="btn-secondary text-sm py-1.5">
          Déconnexion
        </button>
      </div>
    </header>
  )
}
