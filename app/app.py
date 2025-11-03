from flask import Flask, jsonify, request
from datetime import datetime
import os
import socket
import json

app = Flask(__name__)

tasks = [
    {'id': 1, 'title': 'Deploy to Kubernetes', 'completed': True},
    {'id': 2, 'title': 'Set up CI/CD', 'completed': True},
    {'id': 3, 'title': 'Add monitoring', 'completed': False},
]

@app.route('/')
def home():
    return jsonify({
        'app': 'Flask Task Manager API',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'hostname': socket.gethostname(),
        'timestamp': datetime.utcnow().isoformat(),
        'endpoints': {
            'health': '/health',
            'tasks': '/api/tasks',
            'info': '/api/info'
        }
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/info')
def info():
    return jsonify({
        'application': 'Task Manager API',
        'description': 'A simple REST API demonstrating Docker + Kubernetes + CI/CD',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'pod_name': socket.gethostname(),
        'features': [
            'RESTful API',
            'Dockerized',
            'Kubernetes deployment',
            'CI/CD with GitHub Actions',
            'Health checks',
            'Production-ready'
        ]
    })

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    return jsonify({
        'tasks': tasks,
        'count': len(tasks),
        'served_by': socket.gethostname()
    }), 200

@app.route('/api/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = next((t for t in tasks if t['id'] == task_id), None)
    if task:
        return jsonify(task), 200
    return jsonify({'error': 'Task not found'}), 404

@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()

    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400

    new_task = {
        'id': max([t['id'] for t in tasks]) + 1 if tasks else 1,
        'title': data['title'],
        'completed': data.get('completed', False)
    }

    tasks.append(new_task)
    return jsonify(new_task), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    task = next((t for t in tasks if t['id'] == task_id), None)

    if not task:
        return jsonify({'error': 'Task not found'}), 404

    data = request.get_json()
    task['title'] = data.get('title', task['title'])
    task['completed'] = data.get('completed', task['completed'])

    return jsonify(task), 200

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    global tasks
    task = next((t for t in tasks if t['id'] == task_id), None)

    if not task:
        return jsonify({'error': 'Task not found'}), 404

    tasks = [t for t in tasks if t['id'] != task_id]
    return jsonify({'message': 'Task deleted'}), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
