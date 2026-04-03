stockmaster-frontend/
├── public/
│   ├── index.html
│   └── favicon.ico
│
├── src/
│   ├── assets/
│   │   ├── images/
│   │   └── icons/
│   │
│   ├── components/
│   │   ├── common/
│   │   │   ├── Navbar.jsx
│   │   │   ├── Sidebar.jsx
│   │   │   ├── DataTable.jsx
│   │   │   ├── AlertBanner.jsx
│   │   │   ├── LoadingSpinner.jsx
│   │   │   └── ErrorBoundary.jsx       # ← ajout
│   │   │
│   │   ├── product/
│   │   │   ├── ProductList.jsx
│   │   │   ├── ProductForm.jsx
│   │   │   ├── ProductCard.jsx
│   │   │   └── LowStockAlert.jsx
│   │   │
│   │   ├── stock/
│   │   │   ├── StockMovementForm.jsx
│   │   │   └── StockHistoryTable.jsx
│   │   │
│   │   ├── order/
│   │   │   ├── SupplierOrderForm.jsx
│   │   │   ├── CustomerOrderForm.jsx
│   │   │   └── OrderList.jsx
│   │   │
│   │   └── report/
│   │       └── ReportDashboard.jsx
│   │
│   ├── pages/
│   │   ├── LoginPage.jsx               # ← ajout
│   │   ├── Dashboard.jsx
│   │   ├── ProductsPage.jsx
│   │   ├── StockMovementsPage.jsx
│   │   ├── SupplierOrdersPage.jsx
│   │   ├── CustomerOrdersPage.jsx
│   │   ├── AlertsPage.jsx
│   │   └── ReportsPage.jsx
│   │
│   ├── services/
│   │   ├── api.js                      # Axios + interceptors JWT
│   │   ├── authService.js              # ← ajout
│   │   ├── productService.js
│   │   ├── stockService.js
│   │   ├── orderService.js
│   │   ├── alertService.js
│   │   └── reportService.js
│   │
│   ├── context/
│   │   └── AuthContext.jsx             # obligatoire (4 rôles)
│   │
│   ├── hooks/
│   │   ├── useAuth.js                  # ← ajout
│   │   ├── useProducts.js
│   │   ├── useStockMovements.js
│   │   └── useAlerts.js
│   │
│   ├── utils/
│   │   ├── formatDate.js
│   │   ├── formatCurrency.js
│   │   └── stockUtils.js
│   │
│   ├── App.jsx
│   ├── main.jsx
│   ├── index.css
│   └── routes.jsx                      # ProtectedRoute par rôle
│
├── .env.development
├── .env.production
├── package.json
├── vite.config.js
└── Dockerfile
