#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Script pour initialiser la base de données SQLite.
Exécutez ce script pour créer le fichier ocr.db avec les tables nécessaires.
"""

import os
import sys

# Ajouter le répertoire parent au chemin Python pour accéder aux modules du backend
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.app import create_app
from backend.app.models import db, User, Ticket

def init_database():
    """Initialise la base de données en créant toutes les tables définies dans les modèles."""
    # Crée une instance de l'application Flask
    app = create_app()
    
    # Assure que le dossier database existe
    os.makedirs('database', exist_ok=True)
    
    with app.app_context():
        # Crée toutes les tables définies dans les modèles
        db.create_all()
        print("Base de données initialisée avec succès !")
        print(f"Base de données créée à l'emplacement: {os.path.abspath('database/ocr.db')}")

if __name__ == "__main__":
    init_database()