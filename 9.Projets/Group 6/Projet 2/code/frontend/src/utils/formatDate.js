export function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('fr-FR', {
    day: '2-digit', month: '2-digit', year: 'numeric',
  })
}

export function formatDateTime(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('fr-FR', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  })
}

export function toIsoLocal(date) {
  const d = new Date(date)
  const offset = d.getTimezoneOffset()
  const adjusted = new Date(d.getTime() - offset * 60000)
  return adjusted.toISOString().slice(0, 19)
}
