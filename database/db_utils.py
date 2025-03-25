#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Utilitaires pour la gestion de la base de données.
Inclut des fonctions pour vérifier l'intégrité, faire des sauvegardes, etc.
"""

import os
import sys
import sqlite3
import shutil
from datetime import datetime

# Chemin vers la base de données
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ocr.db')

def check_database_exists():
    """Vérifie si le fichier de base de données existe."""
    return os.path.exists(DB_PATH)

def create_backup():
    """Crée une sauvegarde de la base de données."""
    if not check_database_exists():
        print("La base de données n'existe pas encore. Aucune sauvegarde créée.")
        return False
    
    # Nom du fichier de sauvegarde avec la date et l'heure
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_filename = f"ocr_backup_{timestamp}.db"
    backup_path = os.path.join(os.path.dirname(DB_PATH), backup_filename)
    
    # Copie la base de données
    shutil.copy2(DB_PATH, backup_path)
    print(f"Sauvegarde créée: {backup_path}")
    return True

def check_database_integrity():
    """Vérifie l'intégrité de la base de données SQLite."""
    if not check_database_exists():
        print("La base de données n'existe pas encore.")
        return False
    
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute("PRAGMA integrity_check")
        result = cursor.fetchone()[0]
        conn.close()
        
        if result == "ok":
            print("La base de données est intègre.")
            return True
        else:
            print(f"Problème d'intégrité dans la base de données: {result}")
            return False
    except Exception as e:
        print(f"Erreur lors de la vérification d'intégrité: {e}")
        return False

def reset_database():
    """Supprime la base de données existante (avec confirmation)."""
    if not check_database_exists():
        print("La base de données n'existe pas encore.")
        return
    
    confirm = input("Êtes-vous sûr de vouloir réinitialiser la base de données? Cette action est irréversible. (y/n): ")
    if confirm.lower() == 'y':
        try:
            # Créer une sauvegarde avant de supprimer
            create_backup()
            
            # Supprimer le fichier
            os.remove(DB_PATH)
            print("Base de données supprimée avec succès.")
        except Exception as e:
            print(f"Erreur lors de la suppression de la base de données: {e}")
    else:
        print("Réinitialisation annulée.")

if __name__ == "__main__":
    # Si exécuté directement, affiche un menu d'options
    print("Utilitaires de base de données")
    print("1. Vérifier si la base de données existe")
    print("2. Créer une sauvegarde")
    print("3. Vérifier l'intégrité")
    print("4. Réinitialiser la base de données")
    print("q. Quitter")
    
    choice = input("Choisissez une option: ")
    
    if choice == "1":
        exists = check_database_exists()
        print(f"Base de données existe: {exists}")
    elif choice == "2":
        create_backup()
    elif choice == "3":
        check_database_integrity()
    elif choice == "4":
        reset_database()
    elif choice.lower() == "q":
        print("Au revoir!")
    else:
        print("Option non valide.")