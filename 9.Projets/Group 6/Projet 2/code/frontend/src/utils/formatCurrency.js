export function formatCurrency(amount) {
  if (amount == null) return '-'
  return new Intl.NumberFormat('fr-TN', {
    style: 'currency',
    currency: 'TND',
    minimumFractionDigits: 2,
  }).format(amount)
}
