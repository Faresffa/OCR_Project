# Existing imports
import os
import uuid
from flask import Blueprint, request, jsonify, current_app
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.utils import secure_filename
from datetime import datetime
from .models import Ticket, User, Car, CarMaintenance, db
from .ocr import process_image
from .utils import allowed_file, convert_pdf_to_images, capture_image
from .database import save_receipt, get_user_receipts, get_receipt, delete_receipt, update_receipt
import json

# Créer un Blueprint pour les routes API
api_bp = Blueprint('api', __name__)
auth_bp = Blueprint('auth', __name__)
bp = Blueprint('receipts', __name__)

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
        
        print("=== Résultat OCR brut ===")
        print(ocr_result)
        print("========================")
        
        # Vérifier si le résultat est déjà formaté avec la structure 'data'
        if isinstance(ocr_result, dict) and 'data' in ocr_result:
            formatted_data = ocr_result
        else:
            # Si le résultat n'est pas formaté, le formater
            if ocr_result.get('not_receipt', True):
                return jsonify({'error': 'Le document ne semble pas être un ticket valide'}), 400

            formatted_data = {
                'data': {
                    'date': ocr_result.get('date', ''),
                    'ticket_number': ocr_result.get('transaction_id', ''),
                    'total': float(ocr_result.get('amount', 0.0)),
                    'payment_mode': ocr_result.get('payment_method', 'CB'),
                    'articles': [
                        {
                            'name': article.get('name', ''),
                            'price': float(article.get('price', 0.0)),
                            'quantity': int(article.get('quantity', 1))
                        }
                        for article in ocr_result.get('articles', [])
                    ]
                }
            }
        
        print("\n=== Données formatées pour Flutter ===")
        print(json.dumps(formatted_data, indent=2, ensure_ascii=False))
        print("====================================")
        
        return jsonify(formatted_data)
            
    except Exception as e:
        current_app.logger.error(f"Erreur lors du traitement OCR: {str(e)}")
        return jsonify({"error": f"Erreur lors du traitement OCR: {str(e)}"}), 500

# More existing routes...

@bp.route('/upload', methods=['POST'])
@login_required
def upload_receipt():
    """
    Route pour l'upload d'un ticket de caisse.
    """
    if 'file' not in request.files:
        return jsonify({'error': 'Aucun fichier fourni'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Aucun fichier sélectionné'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': 'Type de fichier non autorisé'}), 400
    
    try:
        # Sauvegarder le fichier temporairement
        filename = secure_filename(file.filename)
        temp_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        file.save(temp_path)
        
        # Convertir PDF en image si nécessaire
        if filename.lower().endswith('.pdf'):
            image_paths = convert_pdf_to_images(temp_path)
            if not image_paths:
                return jsonify({'error': 'Erreur lors de la conversion du PDF'}), 500
            image_path = image_paths[0]  # Utiliser la première page
        else:
            image_path = temp_path
        
        # Traiter l'image avec OCR
        receipt_data = process_image(image_path)
        
        if not receipt_data:
            return jsonify({'error': 'Erreur lors du traitement OCR'}), 500
        
        # Sauvegarder dans la base de données
        receipt = save_receipt(current_user.id, receipt_data, image_path)
        
        # Nettoyer les fichiers temporaires
        os.remove(temp_path)
        if filename.lower().endswith('.pdf'):
            for path in image_paths:
                os.remove(path)
        
        return jsonify({
            'message': 'Ticket traité avec succès',
            'receipt': receipt.to_dict() if hasattr(receipt, 'to_dict') else receipt.__dict__
        }), 201
        
    except Exception as e:
        current_app.logger.error(f"Erreur lors du traitement du ticket : {e}")
        return jsonify({'error': str(e)}), 500

@bp.route('/capture', methods=['POST'])
@login_required
def capture_receipt():
    """
    Route pour la capture d'un ticket via la webcam.
    """
    try:
        # Capturer l'image
        image_path = capture_image()
        if not image_path:
            return jsonify({'error': 'Erreur lors de la capture d\'image'}), 500
        
        # Traiter l'image avec OCR
        receipt_data = process_image(image_path)
        
        if not receipt_data:
            return jsonify({'error': 'Erreur lors du traitement OCR'}), 500
        
        # Sauvegarder dans la base de données
        receipt = save_receipt(current_user.id, receipt_data, image_path)
        
        # Nettoyer le fichier temporaire
        os.remove(image_path)
        
        return jsonify({
            'message': 'Ticket capturé et traité avec succès',
            'receipt': receipt.to_dict() if hasattr(receipt, 'to_dict') else receipt.__dict__
        }), 201
        
    except Exception as e:
        current_app.logger.error(f"Erreur lors de la capture du ticket : {e}")
        return jsonify({'error': str(e)}), 500

@bp.route('/receipts', methods=['GET'])
@login_required
def get_receipts():
    """
    Route pour récupérer tous les tickets d'un utilisateur.
    """
    try:
        receipts = get_user_receipts(current_user.id)
        return jsonify({
            'receipts': [receipt.to_dict() if hasattr(receipt, 'to_dict') else receipt.__dict__ for receipt in receipts]
        }), 200
    except Exception as e:
        current_app.logger.error(f"Erreur lors de la récupération des tickets : {e}")
        return jsonify({'error': str(e)}), 500

@bp.route('/receipts/<int:receipt_id>', methods=['GET'])
@login_required
def get_receipt_by_id(receipt_id):
    """
    Route pour récupérer un ticket spécifique.
    """
    try:
        receipt = get_receipt(receipt_id, current_user.id)
        if not receipt:
            return jsonify({'error': 'Ticket non trouvé'}), 404
        return jsonify({
            'receipt': receipt.to_dict() if hasattr(receipt, 'to_dict') else receipt.__dict__
        }), 200
    except Exception as e:
        current_app.logger.error(f"Erreur lors de la récupération du ticket : {e}")
        return jsonify({'error': str(e)}), 500

@bp.route('/receipts/<int:receipt_id>', methods=['DELETE'])
@login_required
def delete_receipt_by_id(receipt_id):
    """
    Route pour supprimer un ticket.
    """
    try:
        if delete_receipt(receipt_id, current_user.id):
            return jsonify({'message': 'Ticket supprimé avec succès'}), 200
        return jsonify({'error': 'Ticket non trouvé'}), 404
    except Exception as e:
        current_app.logger.error(f"Erreur lors de la suppression du ticket : {e}")
        return jsonify({'error': str(e)}), 500

@bp.route('/receipts/<int:receipt_id>', methods=['PUT'])
@login_required
def update_receipt_by_id(receipt_id):
    """
    Route pour mettre à jour un ticket.
    """
    try:
        receipt_data = request.get_json()
        receipt = update_receipt(receipt_id, current_user.id, receipt_data)
        if receipt:
            return jsonify({
                'message': 'Ticket mis à jour avec succès',
                'receipt': receipt.to_dict() if hasattr(receipt, 'to_dict') else receipt.__dict__
            }), 200
        return jsonify({'error': 'Ticket non trouvé'}), 404
    except Exception as e:
        current_app.logger.error(f"Erreur lors de la mise à jour du ticket : {e}")
        return jsonify({'error': str(e)}), 500

@api_bp.route('/process_image', methods=['POST'])
def process_image_route():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'Aucune image fournie'}), 400
        
        file = request.files['image']
        if file.filename == '':
            return jsonify({'error': 'Aucun fichier sélectionné'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': 'Type de fichier non autorisé'}), 400
        
        # Sauvegarder l'image
        filename = secure_filename(file.filename)
        filepath = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Traiter l'image avec OCR
        result = process_image(filepath)
        
        print("=== Résultat OCR brut ===")
        print(result)
        print("========================")
        
        if result.get('not_receipt', True):
            return jsonify({'error': 'Le document ne semble pas être un ticket valide'}), 400

        # Formater les données pour le modèle Flutter
        formatted_data = {
            'data': {
                'date': result.get('date', ''),
                'ticket_number': result.get('transaction_id', ''),
                'total': float(result.get('amount', 0.0)),
                'payment_mode': result.get('payment_method', 'CB'),
                'articles': [
                    {
                        'name': article.get('name', ''),
                        'price': float(article.get('price', 0.0)),
                        'quantity': int(article.get('quantity', 1))
                    }
                    for article in result.get('articles', [])
                ]
            }
        }
        
        print("\n=== Données formatées pour Flutter ===")
        print(json.dumps(formatted_data, indent=2, ensure_ascii=False))
        print("====================================")
        
        # Sauvegarder les données formatées dans la base de données
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            # Insérer les données formatées
            cur.execute("""
                INSERT INTO processed_tickets (data, created_at)
                VALUES (?, datetime('now'))
            """, (json.dumps(formatted_data),))
            
            conn.commit()
            print("✅ Données formatées sauvegardées en DB avec succès")
            
        except Exception as e:
            print(f"❌ Erreur lors de la sauvegarde des données formatées: {e}")
        finally:
            if 'cur' in locals():
                cur.close()
            if 'conn' in locals():
                conn.close()
            
        return jsonify(formatted_data)
        
    except Exception as e:
        print(f"Erreur : {str(e)}")
        return jsonify({'error': str(e)}), 500

def allowed_file(filename):
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf'}
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
