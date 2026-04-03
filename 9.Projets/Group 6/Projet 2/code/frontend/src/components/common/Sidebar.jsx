import { NavLink } from 'react-router-dom'
import { useAuth } from '../../hooks/useAuth'

const navItems = [
  { to: '/dashboard',       label: 'Tableau de bord',    icon: '📊', roles: null },
  { to: '/products',        label: 'Produits',            icon: '📦', roles: ['STOCK_MANAGER'] },
  { to: '/stock-movements', label: 'Mouvements',          icon: '🔄', roles: ['STOCK_MANAGER'] },
  { to: '/supplier-orders', label: 'Cmd. fournisseurs',   icon: '🛒', roles: ['BUYER', 'STOCK_MANAGER'] },
  { to: '/customer-orders', label: 'Cmd. clients',        icon: '🛍️', roles: ['SELLER', 'STOCK_MANAGER'] },
  { to: '/alerts',          label: 'Alertes',             icon: '🔔', roles: null },
  { to: '/reports',         label: 'Rapports',            icon: '📈', roles: ['STOCK_MANAGER', 'ACCOUNTANT'] },
]

export default function Sidebar() {
  const { user } = useAuth()

  const visible = navItems.filter(item =>
    !item.roles || item.roles.includes(user?.role)
  )

  return (
    <aside className="w-64 min-h-screen bg-gray-900 flex flex-col">
      {/* Logo */}
      <div className="px-6 py-5 border-b border-gray-700">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold text-lg">S</div>
          <div>
            <p className="font-bold text-white text-sm">StockMaster</p>
            <p className="text-gray-400 text-xs">Gestion de stock</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1">
        {visible.map(item => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800 hover:text-white'
              }`
            }
          >
            <span className="text-base">{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* User info */}
      <div className="px-4 py-4 border-t border-gray-700">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-gray-700 rounded-full flex items-center justify-center text-white text-sm font-bold">
            {user?.username?.charAt(0).toUpperCase()}
          </div>
          <div className="min-w-0">
            <p className="text-white text-sm font-medium truncate">{user?.username}</p>
            <p className="text-gray-400 text-xs truncate">{user?.role?.replace('_', ' ')}</p>
          </div>
        </div>
      </div>
    </aside>
  )
}
