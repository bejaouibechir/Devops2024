import { HashRouter, Routes, Route, Navigate, Outlet } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import { ProtectedRoute, GuestRoute } from './routes'
import ErrorBoundary from './components/common/ErrorBoundary'
import Sidebar from './components/common/Sidebar'
import Navbar from './components/common/Navbar'

// Pages
import LoginPage          from './pages/LoginPage'
import Dashboard          from './pages/Dashboard'
import ProductsPage       from './pages/ProductsPage'
import StockMovementsPage from './pages/StockMovementsPage'
import SupplierOrdersPage from './pages/SupplierOrdersPage'
import CustomerOrdersPage from './pages/CustomerOrdersPage'
import AlertsPage         from './pages/AlertsPage'
import ReportsPage        from './pages/ReportsPage'

const PAGE_TITLES = {
  '/dashboard':       'Tableau de bord',
  '/products':        'Produits',
  '/stock-movements': 'Mouvements de stock',
  '/supplier-orders': 'Commandes fournisseurs',
  '/customer-orders': 'Commandes clients',
  '/alerts':          'Alertes',
  '/reports':         'Rapports',
}

function AppLayout() {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <Navbar title={PAGE_TITLES[window.location.hash.replace('#', '') || '/dashboard'] ?? 'StockMaster'} />
        <main className="flex-1 p-6 overflow-auto">
          <ErrorBoundary>
            <Outlet />
          </ErrorBoundary>
        </main>
      </div>
    </div>
  )
}

export default function App() {
  return (
    <AuthProvider>
      <HashRouter>
        <Routes>
          {/* Public */}
          <Route path="/login" element={
            <GuestRoute><LoginPage /></GuestRoute>
          } />

          {/* App */}
          <Route element={<ProtectedRoute><AppLayout /></ProtectedRoute>}>
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard"       element={<Dashboard />} />
            <Route path="/products"        element={
              <ProtectedRoute roles={['STOCK_MANAGER']}><ProductsPage /></ProtectedRoute>
            } />
            <Route path="/stock-movements" element={
              <ProtectedRoute roles={['STOCK_MANAGER']}><StockMovementsPage /></ProtectedRoute>
            } />
            <Route path="/supplier-orders" element={
              <ProtectedRoute roles={['BUYER', 'STOCK_MANAGER']}><SupplierOrdersPage /></ProtectedRoute>
            } />
            <Route path="/customer-orders" element={
              <ProtectedRoute roles={['SELLER', 'STOCK_MANAGER']}><CustomerOrdersPage /></ProtectedRoute>
            } />
            <Route path="/alerts"          element={<AlertsPage />} />
            <Route path="/reports"         element={
              <ProtectedRoute roles={['STOCK_MANAGER', 'ACCOUNTANT']}><ReportsPage /></ProtectedRoute>
            } />
          </Route>

          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </HashRouter>
    </AuthProvider>
  )
}
