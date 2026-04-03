import { useStockMovements } from '../hooks/useStockMovements'
import StockMovementForm from '../components/stock/StockMovementForm'
import StockHistoryTable from '../components/stock/StockHistoryTable'

export default function StockMovementsPage() {
  const { movements, loading, error, reload } = useStockMovements()

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      {/* Formulaire */}
      <div className="lg:col-span-1">
        <div className="card sticky top-6">
          <h2 className="text-base font-semibold text-gray-800 mb-4">📝 Nouveau mouvement</h2>
          <StockMovementForm onSuccess={reload} />
        </div>
      </div>

      {/* Historique */}
      <div className="lg:col-span-2">
        <div className="card">
          <h2 className="text-base font-semibold text-gray-800 mb-4">
            Historique des mouvements
            <span className="ml-2 text-sm font-normal text-gray-400">({movements.length})</span>
          </h2>
          <StockHistoryTable movements={movements} loading={loading} />
        </div>
      </div>
    </div>
  )
}
