import functions_framework
import firebase_admin
from firebase_admin import credentials, firestore
import openai
import json
from datetime import datetime
from flask import jsonify
import sqlite3

# Initialize Firebase Admin
cred = credentials.Certificate('service-account.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

@functions_framework.http
def generate_report(request):
    """HTTP Cloud Function to generate an exercise report.
    Args:
        request (flask.Request): The request object.
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`.
    """
    if request.method != 'POST':
        return jsonify({'error': 'Method not allowed'}), 405

    request_json = request.get_json()
    
    if not request_json or 'user_id' not in request_json or 'exercise_id' not in request_json:
        return jsonify({'error': 'Missing required fields'}), 400

    user_id = request_json['user_id']
    exercise_id = request_json['exercise_id']
    
    # Get exercise session details from database
    conn = sqlite3.connect('patients_database.sqlite')
    cursor = conn.cursor()
    
    cursor.execute('''
    SELECT e.name, e.description, es.duration, es.completed, es.notes, es.created_at
    FROM exercise_sessions es
    JOIN exercises e ON e.id = es.exercise_id
    WHERE es.patient_id = ? AND es.exercise_id = ?
    ORDER BY es.created_at DESC
    LIMIT 1
    ''', (user_id, exercise_id))
    
    result = cursor.fetchone()
    if not result:
        return jsonify({'error': 'Exercise session not found'}), 404
        
    exercise_name, description, duration, completed, notes, created_at = result
    
    # Generate report summary
    report = {
        'exercise_name': exercise_name,
        'description': description,
        'duration_minutes': duration,
        'completed': completed,
        'notes': notes,
        'date': created_at,
        'summary': f"Completed {exercise_name} exercise for {duration} minutes. {'Successfully completed all reps.' if completed else 'Exercise was interrupted.'}"
    }
    
    conn.close()
    
    return jsonify({
        'report': report,
        'status': 'success'
    })

def extract_exercise_metrics(conversation_history):
    """Extract exercise metrics from conversation history."""
    metrics = {
        'sets_completed': 0,
        'reps_completed': 0,
        'duration_minutes': 0
    }
    
    # Initialize variables to track the latest metrics mentioned
    for message in conversation_history:
        content = message.get('content', '').lower()
        
        # Look for sets completed
        if 'set' in content or 'sets' in content:
            # Try to find numbers followed by "set" or "sets"
            import re
            set_matches = re.findall(r'(\d+)\s*sets?', content)
            if set_matches:
                metrics['sets_completed'] = max(metrics['sets_completed'], int(set_matches[-1]))
        
        # Look for reps completed
        if 'rep' in content or 'reps' in content:
            rep_matches = re.findall(r'(\d+)\s*reps?', content)
            if rep_matches:
                metrics['reps_completed'] = max(metrics['reps_completed'], int(rep_matches[-1]))
        
        # Look for duration
        if 'minute' in content or 'minutes' in content:
            duration_matches = re.findall(r'(\d+)\s*minutes?', content)
            if duration_matches:
                metrics['duration_minutes'] = max(metrics['duration_minutes'], int(duration_matches[-1]))
    
    return metrics

def format_conversation_history(conversation_history):
    """Format conversation history for better GPT analysis."""
    formatted_messages = []
    for msg in conversation_history:
        role = msg.get('role', '')
        content = msg.get('content', '')
        speaker = 'Patient' if role == 'user' else 'AI Coach'
        formatted_messages.append(f"{speaker}: {content}")
    
    return "\n".join(formatted_messages) 