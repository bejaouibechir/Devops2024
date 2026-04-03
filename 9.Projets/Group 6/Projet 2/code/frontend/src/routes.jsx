import { Navigate } from 'react-router-dom'
import { useAuth } from './hooks/useAuth'
import LoadingSpinner from './components/common/LoadingSpinner'

export function ProtectedRoute({ children, roles }) {
  const { user, loading } = useAuth()

  if (loading) return <LoadingSpinner />
  if (!user)   return <Navigate to="/login" replace />
  if (roles && !roles.includes(user.role)) return <Navigate to="/dashboard" replace />

  return children
}

export function GuestRoute({ children }) {
  const { user, loading } = useAuth()
  if (loading) return <LoadingSpinner />
  if (user)    return <Navigate to="/dashboard" replace />
  return children
}
