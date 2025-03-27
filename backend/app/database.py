# # Gestion de la base de données (connexion, initialisation, etc.)
from .models import db
from datetime import datetime
from flask import current_app
from .models import Receipt, Article, User

# Exporter l'instance db de models.py
__all__ = ['db']

def save_receipt(user_id, receipt_data, image_path):
    """
    Sauvegarde un ticket de caisse dans la base de données.
    
    Args:
        user_id (int): ID de l'utilisateur
        receipt_data (dict): Données du ticket
        image_path (str): Chemin de l'image du ticket
    
    Returns:
        Receipt: L'objet ticket créé
    """
    try:
        # Créer le ticket
        receipt = Receipt(
            user_id=user_id,
            merchant=receipt_data.get('merchant', 'Inconnu'),
            amount=receipt_data.get('amount', 0.0),
            date=datetime.strptime(receipt_data.get('date', datetime.now().strftime('%Y-%m-%d')), '%Y-%m-%d').date(),
            transaction_id=receipt_data.get('transaction_id', ''),
            payment_method=receipt_data.get('payment_method', 'Inconnu'),
            image_path=image_path
        )
        
        # Ajouter les articles
        for article_data in receipt_data.get('articles', []):
            article = Article(
                name=article_data.get('name', ''),
                price=article_data.get('price', 0.0),
                quantity=article_data.get('quantity', 1)
            )
            receipt.articles.append(article)
        
        db.session.add(receipt)
        db.session.commit()
        return receipt
    except Exception as e:
        current_app.logger.error(f"Erreur lors de la sauvegarde du ticket : {e}")
        db.session.rollback()
        raise

def get_user_receipts(user_id):
    """
    Récupère tous les tickets d'un utilisateur.
    
    Args:
        user_id (int): ID de l'utilisateur
    
    Returns:
        list: Liste des tickets
    """
    return Receipt.query.filter_by(user_id=user_id).order_by(Receipt.date.desc()).all()

def get_receipt(receipt_id, user_id):
    """
    Récupère un ticket spécifique.
    
    Args:
        receipt_id (int): ID du ticket
        user_id (int): ID de l'utilisateur
    
    Returns:
        Receipt: Le ticket demandé
    """
    return Receipt.query.filter_by(id=receipt_id, user_id=user_id).first()

def delete_receipt(receipt_id, user_id):
    """
    Supprime un ticket.
    
    Args:
        receipt_id (int): ID du ticket
        user_id (int): ID de l'utilisateur
    
    Returns:
        bool: True si la suppression a réussi
    """
    receipt = get_receipt(receipt_id, user_id)
    if receipt:
        try:
            db.session.delete(receipt)
            db.session.commit()
            return True
        except Exception as e:
            current_app.logger.error(f"Erreur lors de la suppression du ticket : {e}")
            db.session.rollback()
    return False

def update_receipt(receipt_id, user_id, receipt_data):
    """
    Met à jour un ticket.
    
    Args:
        receipt_id (int): ID du ticket
        user_id (int): ID de l'utilisateur
        receipt_data (dict): Nouvelles données du ticket
    
    Returns:
        Receipt: Le ticket mis à jour
    """
    receipt = get_receipt(receipt_id, user_id)
    if receipt:
        try:
            receipt.merchant = receipt_data.get('merchant', receipt.merchant)
            receipt.amount = receipt_data.get('amount', receipt.amount)
            receipt.date = datetime.strptime(receipt_data.get('date', receipt.date.strftime('%Y-%m-%d')), '%Y-%m-%d').date()
            receipt.transaction_id = receipt_data.get('transaction_id', receipt.transaction_id)
            receipt.payment_method = receipt_data.get('payment_method', receipt.payment_method)
            
            # Mettre à jour les articles
            if 'articles' in receipt_data:
                # Supprimer les anciens articles
                for article in receipt.articles:
                    db.session.delete(article)
                
                # Ajouter les nouveaux articles
                for article_data in receipt_data['articles']:
                    article = Article(
                        name=article_data.get('name', ''),
                        price=article_data.get('price', 0.0),
                        quantity=article_data.get('quantity', 1)
                    )
                    receipt.articles.append(article)
            
            db.session.commit()
            return receipt
        except Exception as e:
            current_app.logger.error(f"Erreur lors de la mise à jour du ticket : {e}")
            db.session.rollback()
    return None