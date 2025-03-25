#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Script pour insérer des données de démonstration dans la base de données.
Utile pour les tests et le développement.
"""

import os
import sys
import random
from datetime import datetime, timedelta

# Ajouter le répertoire parent au chemin Python pour accéder aux modules du backend
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.app import create_app
from backend.app.models import db, User, Ticket
from werkzeug.security import generate_password_hash

# Liste de marchands fictifs pour les données de démonstration
SAMPLE_MERCHANTS = [
    "Carrefour", "Auchan", "Leclerc", "Intermarché", 
    "Casino", "Monoprix", "SNCF", "Fnac", 
    "Darty", "Décathlon", "Leroy Merlin", "Ikea",
    "McDonald's", "KFC", "Subway", "Pizza Hut"
]

def create_demo_user():
    """Crée un utilisateur de démonstration s'il n'existe pas déjà."""
    app = create_app()
    
    with app.app_context():
        # Vérifier si l'utilisateur demo existe déjà
        existing_user = User.query.filter_by(username="demo").first()
        if existing_user:
            print("L'utilisateur demo existe déjà.")
            return existing_user
        
        # Créer un nouvel utilisateur demo
        demo_user = User(
            username="demo",
            email="demo@example.com",
            password_hash=generate_password_hash("demo123")
        )
        db.session.add(demo_user)
        db.session.commit()
        
        print(f"Utilisateur demo créé avec succès (ID: {demo_user.id}).")
        return demo_user

def generate_random_tickets(user_id, count=10):
    """Génère des tickets aléatoires pour un utilisateur donné."""
    app = create_app()
    
    with app.app_context():
        # Vérifier si l'utilisateur existe
        user = User.query.get(user_id)
        if not user:
            print(f"L'utilisateur avec l'ID {user_id} n'existe pas.")
            return
        
        # Générer les tickets aléatoires
        for i in range(count):
            # Date aléatoire dans les 30 derniers jours
            random_days = random.randint(0, 30)
            ticket_date = datetime.now() - timedelta(days=random_days)
            
            # Montant aléatoire entre 1 et 150 euros
            amount = round(random.uniform(1.0, 150.0), 2)
            
            # Marchand aléatoire
            merchant = random.choice(SAMPLE_MERCHANTS)
            
            # ID de transaction fictif
            transaction_id = f"TX{random.randint(10000, 99999)}"
            
            # Texte brut fictif
            raw_text = f"""
            {merchant}
            Date: {ticket_date.strftime('%d/%m/%Y')}
            Montant: {amount} EUR
            Transaction: {transaction_id}
            """
            
            # Créer le ticket
            ticket = Ticket(
                user_id=user_id,
                merchant=merchant,
                amount=amount,
                date=ticket_date,
                transaction_id=transaction_id,
                raw_text=raw_text
            )
            
            db.session.add(ticket)
        
        db.session.commit()
        print(f"{count} tickets aléatoires générés avec succès pour l'utilisateur {user.username}.")

if __name__ == "__main__":
    print("Génération de données de démonstration")
    
    # Créer un utilisateur démo
    demo_user = create_demo_user()
    
    # Demander combien de tickets à générer
    try:
        num_tickets = int(input("Combien de tickets voulez-vous générer? (défaut: 10): ") or "10")
    except ValueError:
        num_tickets = 10
        print("Valeur non valide, utilisation de la valeur par défaut: 10")
    
    # Générer les tickets
    generate_random_tickets(demo_user.id, num_tickets)