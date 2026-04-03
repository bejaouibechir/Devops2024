export default function AlertBanner({ type = 'error', message, onClose }) {
  if (!message) return null

  const styles = {
    error:   'bg-red-50 border-red-200 text-red-800',
    success: 'bg-green-50 border-green-200 text-green-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
    info:    'bg-blue-50 border-blue-200 text-blue-800',
  }
  const icons = { error: '❌', success: '✅', warning: '⚠️', info: 'ℹ️' }

  return (
    <div className={`flex items-center gap-3 px-4 py-3 border rounded-lg text-sm ${styles[type]}`}>
      <span>{icons[type]}</span>
      <span className="flex-1">{message}</span>
      {onClose && (
        <button onClick={onClose} className="ml-auto font-bold opacity-60 hover:opacity-100">×</button>
      )}
    </div>
  )
}
