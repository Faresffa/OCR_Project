# # Configuration de l'application (d�pendances, param�tres...)
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
    
    # Configuration pour l'API Mistral (si utilisée)
    MISTRAL_API_KEY = os.environ.get('oue93klhrJfR41W4vHGCtMP7g2v3WYQj')
    MISTRAL_API_URL = os.environ.get('https://api.mistral.ai/v1/chat/completions') 