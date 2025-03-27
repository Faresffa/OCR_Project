# Existing imports
import os
import uuid
from flask import Blueprint, request, jsonify, current_app
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.utils import secure_filename
from datetime import datetime
from .models import Ticket, User, Car, CarMaintenance, db
from .ocr import process_image
from .utils import allowed_file

# Créer un Blueprint pour les routes API
api_bp = Blueprint('api', __name__)
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/cars/<int:user_id>', methods=['GET'])
@login_required
def get_user_cars(user_id):
    """Récupération des voitures d'un utilisateur spécifique"""
    # Récupérer les voitures associées à l'utilisateur
    cars = Car.query.filter_by(user_id=user_id).all()
    
    # Transformer les données des voitures en liste de dictionnaires
    car_list = [{
        "id": car.id,
        "make": car.make,
        "model": car.model,
        "year": car.year
    } for car in cars]
    
    # Retourner les informations des voitures au format JSON
    return jsonify(car_list), 200

# Existing routes...
@api_bp.route('/health', methods=['GET'])
def health_check():
    """Vérification de l'état de l'API"""
    return jsonify({"status": "healthy", "message": "L'API fonctionne correctement"})

@api_bp.route('/ocr', methods=['POST'])
def ocr_image():
    """Traitement OCR d'une image de ticket"""
    if 'image' not in request.files and 'image' not in request.json:
        return jsonify({"error": "Aucune image trouvée dans la requête"}), 400
    
    if 'image' in request.files:
        file = request.files['image']
        if file.filename == '':
            return jsonify({"error": "Aucun fichier sélectionné"}), 400
        if not allowed_file(file.filename):
            return jsonify({"error": "Format de fichier non supporté"}), 400
        
        filename = secure_filename(f"{uuid.uuid4()}_{file.filename}")
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
    else:
        import base64
        from io import BytesIO
        base64_image = request.json.get('image', '')
        try:
            image_data = base64.b64decode(base64_image.split(',')[1] if ',' in base64_image else base64_image)
            filename = f"{uuid.uuid4()}.jpg"
            file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
            with open(file_path, 'wb') as f:
                f.write(image_data)
        except Exception as e:
            return jsonify({"error": f"Erreur lors du décodage de l'image base64: {str(e)}"}), 400
    
    try:
        # Traiter l'image avec OCR
        ocr_result = process_image(file_path)
        
        # Créer et sauvegarder le ticket dans le contexte de l'application
        with current_app.app_context():
            ticket = Ticket(
                user_id=1,
                merchant=ocr_result.get('merchant', 'Inconnu'),
                amount=ocr_result.get('amount', 0.0),
                date=ocr_result.get('date'),
                transaction_id=ocr_result.get('transaction_id', ''),
                image_path=file_path,
                raw_text=ocr_result.get('raw_text', '')
            )
            
            db.session.add(ticket)
            db.session.commit()
            
            return jsonify({
                "merchant": ticket.merchant,
                "amount": str(ticket.amount),
                "date": ticket.date.strftime('%Y-%m-%d %H:%M:%S') if ticket.date else None,
                "transaction_id": ticket.transaction_id,
                "ticket_id": ticket.id
            })
    except Exception as e:
        current_app.logger.error(f"Erreur lors du traitement OCR: {str(e)}")
        return jsonify({"error": f"Erreur lors du traitement OCR: {str(e)}"}), 500

# More existing routes...
