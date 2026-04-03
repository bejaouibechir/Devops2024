export function getStockStatusBadge(status) {
  const map = {
    NORMAL:     { label: 'Normal',     cls: 'badge-green'  },
    LOW_STOCK:  { label: 'Stock bas',  cls: 'badge-yellow' },
    OUT_OF_STOCK:{ label: 'Rupture',   cls: 'badge-red'    },
    OVERSTOCK:  { label: 'Surstock',   cls: 'badge-blue'   },
  }
  return map[status] || { label: status, cls: 'badge-gray' }
}

export function getOrderStatusBadge(status) {
  const map = {
    PENDING:    { label: 'En attente',  cls: 'badge-yellow' },
    CONFIRMED:  { label: 'Confirmée',   cls: 'badge-blue'   },
    DELIVERED:  { label: 'Livrée',      cls: 'badge-green'  },
    CANCELLED:  { label: 'Annulée',     cls: 'badge-red'    },
  }
  return map[status] || { label: status, cls: 'badge-gray' }
}

export function getAlertTypeBadge(type) {
  const map = {
    LOW_STOCK:   { label: 'Stock bas',  cls: 'badge-yellow', icon: '⚠️' },
    OUT_OF_STOCK:{ label: 'Rupture',    cls: 'badge-red',    icon: '🚫' },
    OVERSTOCK:   { label: 'Surstock',   cls: 'badge-blue',   icon: '📦' },
  }
  return map[type] || { label: type, cls: 'badge-gray', icon: '❓' }
}

export function getMovementTypeBadge(type) {
  const map = {
    ENTRY:      { label: 'Entrée',      cls: 'badge-green'  },
    EXIT:       { label: 'Sortie',      cls: 'badge-red'    },
    ADJUSTMENT: { label: 'Ajustement',  cls: 'badge-blue'   },
  }
  return map[type] || { label: type, cls: 'badge-gray' }
}
