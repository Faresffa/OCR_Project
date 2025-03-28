# # Initialisation de l'application Flask
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from .models import db
from .routes import api_bp

def create_app():
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = 'votre-cle-secrete-ici'  # Changez ceci en production
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['UPLOAD_FOLDER'] = 'uploads'
    
    # Activer CORS pour toutes les routes
    CORS(app)
    
    # Initialiser la base de données
    db.init_app(app)
    
    # Créer les tables si elles n'existent pas
    with app.app_context():
        db.create_all()
    
    # Enregistrer le blueprint principal
    app.register_blueprint(api_bp)
    
    return app