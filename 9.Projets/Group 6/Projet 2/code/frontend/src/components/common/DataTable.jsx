export default function DataTable({ columns, data, loading, emptyText = 'Aucune donnée' }) {
  if (loading) {
    return (
      <div className="animate-pulse space-y-3">
        {[1,2,3,4,5].map(i => (
          <div key={i} className="h-12 bg-gray-100 rounded" />
        ))}
      </div>
    )
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm text-left">
        <thead>
          <tr className="border-b border-gray-200 bg-gray-50">
            {columns.map(col => (
              <th key={col.key} className="px-4 py-3 font-semibold text-gray-600 whitespace-nowrap">
                {col.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="px-4 py-10 text-center text-gray-400">
                {emptyText}
              </td>
            </tr>
          ) : (
            data.map((row, i) => (
              <tr key={row.id ?? i} className="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                {columns.map(col => (
                  <td key={col.key} className="px-4 py-3 whitespace-nowrap">
                    {col.render ? col.render(row) : row[col.key] ?? '-'}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  )
}
