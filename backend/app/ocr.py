import os
import re
import json
import base64
import mimetypes
import hashlib
from PIL import Image
from datetime import datetime
from flask import current_app
from mistralai import Mistral
from .utils import enhance_image_for_ocr
from .ticket_processing import extract_elements
import requests

API_KEY = "iQUfZle3E832CGpT5Bh2x4c3xoFZjvxP"
client = Mistral(api_key=API_KEY)

def process_image(image_path):
    """
    Traite une image avec OCR pour extraire les informations du ticket en utilisant Mistral PixTral.

    Args:
        image_path (str): Chemin vers l'image à traiter
    
    Returns:
        dict: Dictionnaire contenant les informations extraites du ticket
    """
    try:
        # Prétraiter l'image pour améliorer la qualité de l'OCR
        enhanced_path = enhance_image_for_ocr(image_path)
        mime_type = mimetypes.guess_type(enhanced_path)[0] or "image/jpeg"
        
        # Lire et encoder l'image
        with open(enhanced_path, "rb") as f:
            encoded_image = base64.b64encode(f.read()).decode()

        data_url = f"data:{mime_type};base64,{encoded_image}"

        messages = [{
            "role": "user",
            "content": [
                {"type": "text", "text": "Donne uniquement un JSON structuré contenant les informations du ticket (date, ticket_number, total, mode_paiement, articles, etc.). Chaque article doit avoir un nom, un prix et une quantité. Le total doit être un nombre. La date doit être au format JJ/MM/AA. Pas de texte hors JSON."},
                {"type": "image_url", "image_url": {"url": data_url}}
            ]
        }]

        # Faire la requête API
        response = client.chat.complete(model="pixtral-12b", messages=messages)
        raw_content = response.choices[0].message.content
        
        # Afficher la réponse brute dans le terminal
        print("[{}] INFO in ocr: Réponse brute de l'API Mistral : ```json".format(
            datetime.now().strftime("%Y-%m-%d %H:%M:%S,%f")[:-3]
        ))
        print(raw_content)
        print("```")

        # Nettoyer le fichier temporaire
        if enhanced_path != image_path:
            try:
                os.remove(enhanced_path)
            except:
                pass

        # Traiter le résultat
        try:
            extracted_data = extract_elements(raw_content)
            return extracted_data
        except Exception as e:
            current_app.logger.error(f"Erreur lors du traitement des données : {e}")
            return {
                'merchant': '',
                'amount': 0.0,
                'date': None,
                'transaction_id': '',
                'raw_text': raw_content
            }
    except Exception as e:
        current_app.logger.error(f"Erreur OCR : {e}")
        return {
            'merchant': '',
            'amount': 0.0,
            'date': None,
            'transaction_id': '',
            'raw_text': ''
        }

def generate_hash(content):
    """
    Génère un hash SHA-256 du contenu.
    
    Args:
        content (str): Contenu à hasher
    
    Returns:
        str: Hash SHA-256 du contenu
    """
    return hashlib.sha256(content.encode('utf-8')).hexdigest()