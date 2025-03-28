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
from werkzeug.security import generate_password_hash, check_password_hash

# Un seul blueprint pour toutes les routes
api_bp = Blueprint('api', __name__)

@api_bp.route('/health', methods=['GET'])
def health_check():
    """Vérification de l'état de l'API"""
    return jsonify({"status": "healthy", "message": "L'API fonctionne correctement"})

@api_bp.route('/ocr', methods=['POST'])
def ocr_image():
    """Traitement OCR d'une image de ticket"""
    try:
        print("=== Début du traitement de l'image ===")
        
        # Vérifier si l'image est présente dans la requête
        if 'image' not in request.files and 'image' not in request.json:
            print("❌ Aucune image trouvée dans la requête")
            return jsonify({'error': 'Aucune image fournie'}), 400
        
        # Créer le dossier uploads s'il n'existe pas
        os.makedirs(current_app.config['UPLOAD_FOLDER'], exist_ok=True)
        
        # Traiter l'image selon son format (multipart ou base64)
        if 'image' in request.files:
            file = request.files['image']
            if file.filename == '':
                print("❌ Nom de fichier vide")
                return jsonify({'error': 'Aucun fichier sélectionné'}), 400
            
            if not allowed_file(file.filename):
                print("❌ Type de fichier non autorisé")
                return jsonify({'error': 'Type de fichier non autorisé'}), 400
            
            filename = secure_filename(f"{uuid.uuid4()}_{file.filename}")
            filepath = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)
            print(f"✅ Image sauvegardée: {filepath}")
        else:
            # Traitement de l'image en base64
            base64_image = request.json.get('image', '')
            try:
                image_data = base64.b64decode(base64_image.split(',')[1] if ',' in base64_image else base64_image)
                filename = f"{uuid.uuid4()}.jpg"
                filepath = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
                with open(filepath, 'wb') as f:
                    f.write(image_data)
                print(f"✅ Image base64 sauvegardée: {filepath}")
            except Exception as e:
                print(f"❌ Erreur lors du décodage base64: {str(e)}")
                return jsonify({'error': f"Erreur lors du décodage de l'image: {str(e)}"}), 400
        
        # Traiter l'image avec OCR
        result = process_image(filepath)
        print("✅ OCR effectué avec succès")
        
        print("=== Résultat OCR brut ===")
        print(result)
        print("========================")
        
        # Si le résultat est déjà dans le bon format, l'utiliser directement
        if isinstance(result, dict) and 'data' in result:
            formatted_data = result
        else:
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
        
        # Nettoyer le fichier temporaire
        try:
            os.remove(filepath)
            print("✅ Fichier temporaire supprimé")
        except Exception as e:
            print(f"⚠️ Erreur lors de la suppression du fichier temporaire: {e}")
        
        return jsonify(formatted_data)
        
    except Exception as e:
        print(f"❌ Erreur lors du traitement: {str(e)}")
        return jsonify({'error': f"Erreur lors du traitement de l'image: {str(e)}"}), 500

@api_bp.route('/signup', methods=['POST'])
def signup():
    """Route d'inscription"""
    try:
        data = request.get_json()
        
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({
                'message': 'Email et mot de passe requis'
            }), 400

        email = data['email']
        password = data['password']

        # Vérifier si l'utilisateur existe déjà
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({
                'message': 'Un compte existe déjà avec cet email'
            }), 409

        # Créer le nouvel utilisateur
        new_user = User(
            email=email,
            password=generate_password_hash(password),
            created_at=datetime.utcnow()
        )
        
        db.session.add(new_user)
        db.session.commit()

        return jsonify({
            'message': 'Compte créé avec succès',
            'user': {
                'id': new_user.id,
                'email': new_user.email
            }
        }), 200

    except Exception as e:
        print(f"Erreur lors de l'inscription: {str(e)}")
        db.session.rollback()
        return jsonify({
            'message': "Une erreur est survenue lors de l'inscription"
        }), 500

@api_bp.route('/login', methods=['POST'])
def login():
    """Route de connexion"""
    try:
        data = request.get_json()
        
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({
                'message': 'Email et mot de passe requis'
            }), 400

        email = data['email']
        password = data['password']

        # Rechercher l'utilisateur
        user = User.query.filter_by(email=email).first()
        
        if not user or not check_password_hash(user.password, password):
            return jsonify({
                'message': 'Email ou mot de passe incorrect'
            }), 401

        # Ici vous pourriez générer un token JWT pour l'authentification
        return jsonify({
            'message': 'Connexion réussie',
            'user': {
                'id': user.id,
                'email': user.email
            }
        }), 200

    except Exception as e:
        print(f"Erreur lors de la connexion: {str(e)}")
        return jsonify({
            'message': 'Une erreur est survenue lors de la connexion'
        }), 500

def allowed_file(filename):
    """Vérifie si l'extension du fichier est autorisée"""
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
