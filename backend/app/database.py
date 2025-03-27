# # Gestion de la base de données (connexion, initialisation, etc.)
from .models import db

# Exporter l'instance db de models.py
__all__ = ['db']