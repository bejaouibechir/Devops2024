from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Configuration MySQL depuis les variables d'environnement
MYSQL_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'mysql-service.mysql-app.svc.cluster.local'),
    'port': int(os.getenv('MYSQL_PORT', 3306)),
    'user': os.getenv('MYSQL_USER', 'appuser'),
    'password': os.getenv('MYSQL_PASSWORD', 'AppU5er@2024'),
    'database': os.getenv('MYSQL_DATABASE', 'businessdb')
}

def get_db_connection():
    """Créer une connexion à la base de données"""
    try:
        connection = mysql.connector.connect(**MYSQL_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

@app.route('/')
def home():
    """Page d'accueil de l'API"""
    return jsonify({
        'message': 'MySQL Backend API',
        'version': '1.0',
        'endpoints': {
            '/health': 'Health check',
            '/employees': 'GET all employees, POST new employee',
            '/employees/<id>': 'GET, PUT, DELETE specific employee',
            '/stats': 'GET database statistics'
        }
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    try:
        connection = get_db_connection()
        if connection and connection.is_connected():
            connection.close()
            return jsonify({
                'status': 'healthy',
                'database': 'connected',
                'timestamp': datetime.now().isoformat()
            }), 200
        else:
            return jsonify({
                'status': 'unhealthy',
                'database': 'disconnected',
                'timestamp': datetime.now().isoformat()
            }), 503
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 503

@app.route('/employees', methods=['GET'])
def get_employees():
    """Récupérer tous les employés"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor(dictionary=True)
        
        # Paramètres de pagination
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        offset = (page - 1) * per_page
        
        # Filtre par département
        department = request.args.get('department')
        
        if department:
            query = "SELECT * FROM employees WHERE department = %s LIMIT %s OFFSET %s"
            cursor.execute(query, (department, per_page, offset))
        else:
            query = "SELECT * FROM employees LIMIT %s OFFSET %s"
            cursor.execute(query, (per_page, offset))
        
        employees = cursor.fetchall()
        
        # Compter le total
        cursor.execute("SELECT COUNT(*) as total FROM employees" + 
                      (" WHERE department = %s" if department else ""),
                      (department,) if department else ())
        total = cursor.fetchone()['total']
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'employees': employees,
            'total': total,
            'page': page,
            'per_page': per_page,
            'total_pages': (total + per_page - 1) // per_page
        }), 200
    
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/employees/<int:emp_id>', methods=['GET'])
def get_employee(emp_id):
    """Récupérer un employé spécifique"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM employees WHERE id = %s", (emp_id,))
        employee = cursor.fetchone()
        
        cursor.close()
        connection.close()
        
        if employee:
            return jsonify(employee), 200
        else:
            return jsonify({'error': 'Employee not found'}), 404
    
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/employees', methods=['POST'])
def create_employee():
    """Créer un nouvel employé"""
    try:
        data = request.get_json()
        
        # Validation
        required_fields = ['name', 'address', 'salary']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400
        
        connection = get_db_connection()
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor()
        query = """
            INSERT INTO employees (name, address, salary, department, hire_date) 
            VALUES (%s, %s, %s, %s, %s)
        """
        values = (
            data['name'],
            data['address'],
            data['salary'],
            data.get('department'),
            data.get('hire_date', datetime.now().date())
        )
        
        cursor.execute(query, values)
        connection.commit()
        
        new_id = cursor.lastrowid
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'message': 'Employee created successfully',
            'id': new_id
        }), 201
    
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/employees/<int:emp_id>', methods=['PUT'])
def update_employee(emp_id):
    """Mettre à jour un employé"""
    try:
        data = request.get_json()
        
        connection = get_db_connection()
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor()
        
        # Construire la requête dynamiquement
        update_fields = []
        values = []
        
        for field in ['name', 'address', 'salary', 'department']:
            if field in data:
                update_fields.append(f"{field} = %s")
                values.append(data[field])
        
        if not update_fields:
            return jsonify({'error': 'No fields to update'}), 400
        
        values.append(emp_id)
        query = f"UPDATE employees SET {', '.join(update_fields)} WHERE id = %s"
        
        cursor.execute(query, values)
        connection.commit()
        
        if cursor.rowcount == 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Employee not found'}), 404
        
        cursor.close()
        connection.close()
        
        return jsonify({'message': 'Employee updated successfully'}), 200
    
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/employees/<int:emp_id>', methods=['DELETE'])
def delete_employee(emp_id):
    """Supprimer un employé"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor()
        cursor.execute("DELETE FROM employees WHERE id = %s", (emp_id,))
        connection.commit()
        
        if cursor.rowcount == 0:
            cursor.close()
            connection.close()
            return jsonify({'error': 'Employee not found'}), 404
        
        cursor.close()
        connection.close()
        
        return jsonify({'message': 'Employee deleted successfully'}), 200
    
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/stats')
def get_stats():
    """Statistiques de la base de données"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = connection.cursor(dictionary=True)
        
        # Statistiques diverses
        stats = {}
        
        # Total d'employés
        cursor.execute("SELECT COUNT(*) as total FROM employees")
        stats['total_employees'] = cursor.fetchone()['total']
        
        # Moyenne des salaires
        cursor.execute("SELECT AVG(salary) as avg_salary FROM employees")
        stats['average_salary'] = float(cursor.fetchone()['avg_salary'] or 0)
        
        # Employés par département
        cursor.execute("""
            SELECT department, COUNT(*) as count, AVG(salary) as avg_salary
            FROM employees 
            GROUP BY department
        """)
        stats['by_department'] = cursor.fetchall()
        
        # Salaire min et max
        cursor.execute("SELECT MIN(salary) as min_sal, MAX(salary) as max_sal FROM employees")
        sal_range = cursor.fetchone()
        stats['salary_range'] = {
            'min': float(sal_range['min_sal'] or 0),
            'max': float(sal_range['max_sal'] or 0)
        }
        
        cursor.close()
        connection.close()
        
        return jsonify(stats), 200
    
    except Error as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
