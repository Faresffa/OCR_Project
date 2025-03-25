# # Initialisation de l'application Flask
from flask import Flask
from flask_cors import CORS
from .config import Config
from .database import db

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialiser les extensions
    db.init_app(app)
    
    # Permettre les requêtes CORS pour l'API
    CORS(app)
    
    # Importer et enregistrer les routes
    from .routes import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Créer les tables dans la base de données
    with app.app_context():
        db.create_all()
    
    return app