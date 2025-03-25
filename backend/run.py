import os
from app import create_app

app = create_app()

if __name__ == '__main__':
    # Créer le dossier d'uploads s'il n'existe pas
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    
    # Démarrer l'application
    app.run(host='0.0.0.0', port=5000, debug=True)