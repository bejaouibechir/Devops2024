import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Métriques personnalisées
const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Montée progressive à 10 utilisateurs
    { duration: '1m', target: 20 },    // Montée à 20 utilisateurs
    { duration: '30s', target: 30 },   // Pic à 30 utilisateurs
    { duration: '1m', target: 20 },    // Descente à 20
    { duration: '30s', target: 0 },    // Arrêt progressif
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% des requêtes doivent être < 500ms
    errors: ['rate<0.1'],               // Taux d'erreur < 10%
  },
};

const BASE_URL = 'http://localhost:5000';

export default function () {
  // Test 1: GET /health
  let res = http.get(`${BASE_URL}/health`);
  check(res, {
    'health check status 200': (r) => r.status === 200,
    'health check is healthy': (r) => JSON.parse(r.body).status === 'healthy',
  }) || errorRate.add(1);

  sleep(1);

  // Test 2: GET /employees
  res = http.get(`${BASE_URL}/employees?per_page=5`);
  check(res, {
    'GET employees status 200': (r) => r.status === 200,
    'employees list returned': (r) => JSON.parse(r.body).employees.length > 0,
  }) || errorRate.add(1);

  sleep(1);

  // Test 3: GET /stats
  res = http.get(`${BASE_URL}/stats`);
  check(res, {
    'GET stats status 200': (r) => r.status === 200,
    'stats contains total_employees': (r) => {
      const body = JSON.parse(r.body);
      return 'total_employees' in body;
    },
  }) || errorRate.add(1);

  sleep(1);

  // Test 4: POST /employees (création)
  const payload = JSON.stringify({
    name: `LoadTest User ${__VU}-${__ITER}`,
    address: `${__VU} Test Street, ${__ITER} LoadCity`,
    salary: 40000 + Math.floor(Math.random() * 30000),
    department: ['IT', 'HR', 'Finance', 'Marketing'][Math.floor(Math.random() * 4)],
    hire_date: '2024-01-15'
  });

  res = http.post(`${BASE_URL}/employees`, payload, {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const createSuccess = check(res, {
    'POST employee status 201': (r) => r.status === 201,
    'employee created with ID': (r) => {
      try {
        return 'id' in JSON.parse(r.body);
      } catch {
        return false;
      }
    },
  });

  if (!createSuccess) {
    errorRate.add(1);
  } else {
    // Si la création réussit, récupérer l'ID et mettre à jour
    const createdId = JSON.parse(res.body).id;
    
    sleep(1);

    // Test 5: PUT /employees/:id (mise à jour)
    const updatePayload = JSON.stringify({
      salary: 45000 + Math.floor(Math.random() * 25000),
    });

    res = http.put(`${BASE_URL}/employees/${createdId}`, updatePayload, {
      headers: { 'Content-Type': 'application/json' },
    });

    check(res, {
      'PUT employee status 200': (r) => r.status === 200,
    }) || errorRate.add(1);

    sleep(1);

    // Test 6: GET /employees/:id (lecture)
    res = http.get(`${BASE_URL}/employees/${createdId}`);
    check(res, {
      'GET specific employee status 200': (r) => r.status === 200,
    }) || errorRate.add(1);

    sleep(1);

    // Test 7: DELETE /employees/:id (suppression)
    res = http.del(`${BASE_URL}/employees/${createdId}`);
    check(res, {
      'DELETE employee status 200': (r) => r.status === 200,
    }) || errorRate.add(1);
  }

  sleep(2);
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
  };
}

function textSummary(data, options) {
  const indent = options.indent || '';
  const enableColors = options.enableColors || false;
  
  return `
${indent}========== Test de Charge - Résumé ==========
${indent}
${indent}Durée totale: ${data.state.testRunDurationMs / 1000}s
${indent}
${indent}Requêtes:
${indent}  Total: ${data.metrics.http_reqs.values.count}
${indent}  Par seconde: ${data.metrics.http_reqs.values.rate.toFixed(2)}
${indent}
${indent}Temps de réponse:
${indent}  Moyenne: ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms
${indent}  Min: ${data.metrics.http_req_duration.values.min.toFixed(2)}ms
${indent}  Max: ${data.metrics.http_req_duration.values.max.toFixed(2)}ms
${indent}  p(95): ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms
${indent}
${indent}Taux de succès: ${((1 - data.metrics.errors.values.rate) * 100).toFixed(2)}%
${indent}Taux d'erreur: ${(data.metrics.errors.values.rate * 100).toFixed(2)}%
${indent}
${indent}============================================
`;
}