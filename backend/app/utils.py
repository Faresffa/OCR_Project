import requests
import json
from PIL import Image, ImageEnhance, ImageFilter
from flask import current_app
from datetime import datetime
from dotenv import load_dotenv
import os
import base64
from io import BytesIO

# Charger les variables d'environnement à partir du fichier .env
load_dotenv()

def allowed_file(filename):
    """
    Vérifie si le fichier a une extension autorisée.
    
    Args:
        filename (str): Nom du fichier à vérifier
    
    Returns:
        bool: True si l'extension est autorisée, False sinon
    """
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in current_app.config['ALLOWED_EXTENSIONS']

'''def preprocess_image(image_path):
    """
    Prétraite une image pour améliorer la qualité de l'OCR.
    
    Args:
        image_path (str): Chemin vers l'image à prétraiter
    
    Returns:
        PIL.Image: Image prétraitée
    """
    # Charger l'image avec OpenCV
    img = cv2.imread(image_path)
    
    # Convertir en niveaux de gris
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Appliquer un filtre gaussien pour réduire le bruit
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # Appliquer un seuillage adaptatif
    thresh = cv2.adaptiveThreshold(
        blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
    )
    
    # Convertir l'image prétraitée en image PIL pour Tesseract
    pil_img = Image.fromarray(thresh)
    
    # Appliquer un filtre de netteté pour améliorer les contours
    img_sharp = pil_img.filter(ImageFilter.SHARPEN)
    
    # Améliorer le contraste pour mieux distinguer le texte
    enhancer = ImageEnhance.Contrast(img_sharp)
    img_contrast = enhancer.enhance(2.0)  # Ajuste cette valeur pour plus ou moins de contraste
    
    # Retourner l'image prétraitée
    return img_contrast '''

def preprocess_image(image_path):
    """
    Prétraite une image pour améliorer la qualité de l'OCR.

    Args:
        image_path (str): Chemin vers l'image à prétraiter

    Returns:
        PIL.Image: Image prétraitée
    """
    # Charger l'image avec PIL
    img = Image.open(image_path).convert("RGB")

    # Convertir en niveaux de gris
    gray = img.convert("L")

    # Appliquer un filtre de flou gaussien pour réduire le bruit
    blurred = gray.filter(ImageFilter.GaussianBlur(radius=1))

    # Augmenter le contraste
    enhancer = ImageEnhance.Contrast(blurred)
    img_contrast = enhancer.enhance(2.0)

    # Appliquer un filtre de netteté pour améliorer les contours
    img_sharp = img_contrast.filter(ImageFilter.SHARPEN)

    return img_sharp

def extract_text_with_mistral(image, api_key=None):
    """
    Utilise l'API Mistral PixTral pour extraire le texte d'une image.
    
    Args:
        image (PIL.Image): Image à traiter
        api_key (str, optional): Clé API Mistral (utilise la clé globale si non fournie)
    
    Returns:
        str: Texte extrait de l'image
    """
    # Convertir l'image en base64
    buffered = BytesIO()
    image.save(buffered, format="PNG")
    img_str = base64.b64encode(buffered.getvalue()).decode()
    
    # Préparer la requête
    url = current_app.config['MISTRAL_API_URL']
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key or current_app.config['MISTRAL_API_KEY']}"
    }
    
    payload = {
        "model": "mistral-large-latest",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Extrais le texte de cette image de ticket de caisse et structure les informations suivantes au format JSON : merchant (nom du magasin), amount (montant total), date (date de la transaction), transaction_id (numéro de ticket)."
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/png;base64,{img_str}"
                        }
                    }
                ]
            }
        ],
        "temperature": 0.0,
        "max_tokens": 1000
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        
        result = response.json()
        return result['choices'][0]['message']['content']
        
    except requests.exceptions.RequestException as e:
        current_app.logger.error(f"Erreur lors de l'appel à l'API Mistral: {str(e)}")
        if hasattr(e.response, 'text'):
            current_app.logger.error(f"Réponse de l'API: {e.response.text}")
        return None
