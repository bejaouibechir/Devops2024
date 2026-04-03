import ReportDashboard from '../components/report/ReportDashboard'

export default function ReportsPage() {
  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-lg font-semibold text-gray-800">Rapports & Analyses</h2>
        <p className="text-sm text-gray-500">État des stocks et historique des mouvements</p>
      </div>
      <ReportDashboard />
    </div>
  )
}
