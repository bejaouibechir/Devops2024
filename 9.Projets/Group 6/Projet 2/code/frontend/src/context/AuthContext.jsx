import { createContext, useState, useEffect, useCallback } from 'react'

export const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('token')
    const username = localStorage.getItem('username')
    const role = localStorage.getItem('role')
    if (token && username && role) {
      setUser({ token, username, role })
    }
    setLoading(false)
  }, [])

  const login = useCallback((authData) => {
    localStorage.setItem('token', authData.token)
    localStorage.setItem('username', authData.username)
    localStorage.setItem('role', authData.role)
    setUser(authData)
  }, [])

  const logout = useCallback(() => {
    localStorage.removeItem('token')
    localStorage.removeItem('username')
    localStorage.removeItem('role')
    setUser(null)
  }, [])

  const hasRole = useCallback((...roles) => {
    return user && roles.includes(user.role)
  }, [user])

  const isAdmin        = useCallback(() => hasRole('ADMIN'), [hasRole])
  const isStockManager = useCallback(() => hasRole('ADMIN', 'STOCK_MANAGER'), [hasRole])
  const isBuyer        = useCallback(() => hasRole('ADMIN', 'BUYER', 'STOCK_MANAGER'), [hasRole])
  const isSeller       = useCallback(() => hasRole('ADMIN', 'SELLER', 'STOCK_MANAGER'), [hasRole])
  const isAccountant   = useCallback(() => hasRole('ADMIN', 'ACCOUNTANT', 'STOCK_MANAGER'), [hasRole])

  return (
    <AuthContext.Provider value={{ user, login, logout, loading, hasRole, isAdmin, isStockManager, isBuyer, isSeller, isAccountant }}>
      {children}
    </AuthContext.Provider>
  )
}
