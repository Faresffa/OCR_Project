import os
import re
from PIL import Image
from datetime import datetime
from flask import current_app
from .utils import preprocess_image, extract_text_with_mistral

def process_image(image_path):
    """
    Traite une image avec OCR pour extraire les informations du ticket en utilisant Mistral PixTral.

    Args:
        image_path (str): Chemin vers l'image à traiter
    
    Returns:
        dict: Dictionnaire contenant les informations extraites du ticket
    """
    # Prétraiter l'image pour améliorer la qualité de l'OCR
    preprocessed_image = preprocess_image(image_path)

    # Vérifier si la clé API de Mistral est disponible
    mistral_api_key = current_app.config.get('MISTRAL_API_KEY')
    if not mistral_api_key:
        raise ValueError("Clé API Mistral manquante. Vérifiez votre configuration.")

    # Extraire le texte avec Mistral PixTral
    raw_text = extract_text_with_mistral(preprocessed_image, mistral_api_key)

    # Extraire les informations avec Mistral
    extraction_result = extract_info_with_mistral(raw_text)

    return extraction_result

def extract_info_with_mistral(text):
    """
    Extrait les informations d'un ticket avec Mistral PixTral.

    Args:
        text (str): Texte brut extrait de l'image
    
    Returns:
        dict: Dictionnaire contenant les informations extraites
    """
    lines = text.split('\n')
    result = {
        'merchant': '',
        'amount': 0.0,
        'date': None,
        'transaction_id': '',
        'raw_text': text
    }

    # Extraction avec Mistral (si un modèle NLP est utilisé)
    extracted_data = extract_text_with_mistral(text)
    if extracted_data:
        result.update(extracted_data)
        return result

    # Extraction manuelle en cas d'échec de Mistral
    return extract_info_with_regex(text)

def extract_info_with_regex(text):
    """
    Extraction alternative avec regex si Mistral ne fonctionne pas.

    Args:
        text (str): Texte brut extrait
    
    Returns:
        dict: Données extraites
    """
    lines = text.split('\n')
    result = {
        'merchant': '',
        'amount': 0.0,
        'date': None,
        'transaction_id': '',
        'raw_text': text
    }

    # Recherche du montant
    amount_pattern = r'(\d+[,.]\d{2})[\s€]*'
    for line in lines:
        amount_match = re.search(amount_pattern, line)
        if amount_match:
            amount_str = amount_match.group(1).replace(',', '.')
            try:
                result['amount'] = float(amount_str)
                break
            except ValueError:
                continue

    # Recherche de la date
    date_patterns = [
        r'(\d{2}[/-]\d{2}[/-]\d{4})',  # DD/MM/YYYY ou DD-MM-YYYY
        r'(\d{2}[/-]\d{2}[/-]\d{2})',  # DD/MM/YY ou DD-MM-YY
    ]

    for pattern in date_patterns:
        for line in lines:
            date_match = re.search(pattern, line)
            if date_match:
                date_str = date_match.group(1)
                try:
                    if '/' in date_str:
                        separator = '/'
                    else:
                        separator = '-'

                    day, month, year = date_str.split(separator)

                    if len(year) == 2:
                        year = f'20{year}'

                    result['date'] = datetime(int(year), int(month), int(day))
                    break
                except ValueError:
                    continue
        
        if result['date']:
            break

    # Recherche du commerçant (première ligne non vide)
    for line in lines:
        if line.strip() and not re.search(r'^\d+', line):
            result['merchant'] = line.strip()
            break

    # Recherche du numéro de transaction
    transaction_patterns = [
        r'N[°o][\s:]*(\w+)',
        r'Transaction[\s:]*(\w+)',
        r'Ticket[\s:]*(\w+)',
    ]

    for pattern in transaction_patterns:
        for line in lines:
            transaction_match = re.search(pattern, line, re.IGNORECASE)
            if transaction_match:
                result['transaction_id'] = transaction_match.group(1)
                break

        if result['transaction_id']:
            break

    return result
