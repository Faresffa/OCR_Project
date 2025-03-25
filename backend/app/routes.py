# # Routes API pour g�rer les requ�tes HTTP de l'application
import os
import uuid
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
from .models import Ticket, db
from .ocr import process_image
from .utils import allowed_file

# Créer un Blueprint pour les routes API
api_bp = Blueprint('api', __name__)

@api_bp.route('/health', methods=['GET'])
def health_check():
    """Vérification de l'état de l'API"""
    return jsonify({"status": "healthy", "message": "L'API fonctionne correctement"})

@api_bp.route('/ocr', methods=['POST'])
def ocr_image():
    """Traitement OCR d'une image de ticket"""
    # Vérifier si la requête a une partie fichier
    if 'image' not in request.files and 'image' not in request.json:
        return jsonify({"error": "Aucune image trouvée dans la requête"}), 400
    
    # Obtenir l'image depuis la requête
    if 'image' in request.files:
        file = request.files['image']
        
        # Vérifier si un fichier a été sélectionné
        if file.filename == '':
            return jsonify({"error": "Aucun fichier sélectionné"}), 400
        
        # Vérifier si le fichier est autorisé
        if not allowed_file(file.filename):
            return jsonify({"error": "Format de fichier non supporté"}), 400
        
        # Enregistrer le fichier avec un nom sécurisé
        filename = secure_filename(f"{uuid.uuid4()}_{file.filename}")
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
    else:
        # Traiter l'image en base64
        import base64
        from io import BytesIO
        
        base64_image = request.json.get('image', '')
        try:
            # Décoder l'image base64
            image_data = base64.b64decode(base64_image.split(',')[1] if ',' in base64_image else base64_image)
            
            # Générer un nom de fichier et enregistrer
            filename = f"{uuid.uuid4()}.jpg"
            file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
            
            with open(file_path, 'wb') as f:
                f.write(image_data)
        except Exception as e:
            return jsonify({"error": f"Erreur lors du décodage de l'image base64: {str(e)}"}), 400
    
    try:
        # Traiter l'image avec OCR
        ocr_result = process_image(file_path)
        
        # Créer un ticket dans la base de données (sans user_id pour l'instant)
        ticket = Ticket(
            user_id=1,  # Utilisateur par défaut pour le moment
            merchant=ocr_result.get('merchant', 'Inconnu'),
            amount=ocr_result.get('amount', 0.0),
            date=ocr_result.get('date'),
            transaction_id=ocr_result.get('transaction_id', ''),
            image_path=file_path,
            raw_text=ocr_result.get('raw_text', '')
        )
        
        db.session.add(ticket)
        db.session.commit()
        
        # Retourner les résultats
        return jsonify({
            "merchant": ticket.merchant,
            "amount": str(ticket.amount),
            "date": ticket.date.strftime('%Y-%m-%d %H:%M:%S') if ticket.date else None,
            "transaction_id": ticket.transaction_id,
            "ticket_id": ticket.id
        })
    
    except Exception as e:
        return jsonify({"error": f"Erreur lors du traitement OCR: {str(e)}"}), 500

@api_bp.route('/tickets', methods=['GET'])
def get_tickets():
    """Récupération de tous les tickets"""
    tickets = Ticket.query.order_by(Ticket.created_at.desc()).all()
    return jsonify([ticket.to_dict() for ticket in tickets])

@api_bp.route('/tickets/<int:ticket_id>', methods=['GET'])
def get_ticket(ticket_id):
    """Récupération d'un ticket spécifique"""
    ticket = Ticket.query.get_or_404(ticket_id)
    return jsonify(ticket.to_dict())