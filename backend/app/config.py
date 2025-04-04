# # Configuration de l'application (dépendances, paramètres...)
import os
from datetime import timedelta

basedir = os.path.abspath(os.path.dirname(__file__))

class Config:
    # Configuration générale de l'application
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-key-change-in-production'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # Limite de 16MB pour les téléchargements
    
    # Configuration de la base de données
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, '..', '..', 'database', 'ocr.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Configuration pour les téléchargements
    UPLOAD_FOLDER = os.path.join(basedir, '..', 'static', 'uploads')
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
    
    # Configuration pour Tesseract OCR
    TESSERACT_CMD = os.environ.get('TESSERACT_CMD') or 'tesseract'
    TESSERACT_LANG = os.environ.get('TESSERACT_LANG') or 'fra'  # Langue française par défaut
    
    # Configuration pour l'API Mistral
    MISTRAL_API_KEY = "AAvpnVtVaztKsvvhaCpfNsVel5Ycs4dZ"
    MISTRAL_API_URL = "https://api.mistral.ai/v1/chat/completions" 