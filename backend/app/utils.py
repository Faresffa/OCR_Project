import cv2
import requests
import json
from PIL import Image, ImageEnhance, ImageFilter
from flask import current_app
from datetime import datetime
from dotenv import load_dotenv
import os



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
    img_contrast = enhancer.enhance(2.0)  # Ajuste cette valeur selon le besoin

    # Appliquer un filtre de netteté pour améliorer les contours
    img_sharp = img_contrast.filter(ImageFilter.SHARPEN)

    # Retourner l'image prétraitée
    return img_sharp

def extract_text_with_mistral(text):
    """
    Utilise l'API Mistral pour extraire les informations structurées d'un texte de ticket.
    
    Args:
        text (str): Texte brut extrait de l'image
    
    Returns:
        dict: Dictionnaire contenant les informations extraites ou None en cas d'erreur
    """
    api_key = os.getenv('oue93klhrJfR41W4vHGCtMP7g2v3WYQj')
    if not api_key:
        current_app.logger.error("Clé API Mistral manquante.")
        return None
    
    api_url = "https://api.mistral.ai/v1/chat/completions"
    
    prompt = f"""
    Voici le texte extrait d'un ticket de caisse :
    
    {text}
    
    Extrais les informations suivantes au format JSON :
    - merchant: Le nom du magasin ou du commerçant
    - amount: Le montant total de la transaction (en nombre, sans le symbole €)
    - date: La date de la transaction au format YYYY-MM-DD
    - transaction_id: Le numéro de transaction ou de ticket
    
    Réponds uniquement avec le JSON, sans autre texte.
    """
    
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {api_key}'
    }
    
    payload = {
        'model': 'mistral-large-latest',
        'messages': [
            {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.0,
        'max_tokens': 500
    }
    
    try:
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()  # Vérifie les erreurs HTTP
        
        result = response.json()
        content = result['choices'][0]['message']['content']
        
        try:
            extracted_data = json.loads(content)
            
            # Convertir la date en objet datetime si elle existe
            if 'date' in extracted_data and extracted_data['date']:
                try:
                    extracted_data['date'] = datetime.strptime(extracted_data['date'], '%Y-%m-%d')
                except ValueError:
                    extracted_data['date'] = None
            
            return extracted_data
        
        except json.JSONDecodeError:
            current_app.logger.error("Erreur lors du décodage du JSON retourné par Mistral.")
            return None

    except requests.RequestException as e:
        current_app.logger.error(f"Erreur de requête avec l'API Mistral: {str(e)}")
    except KeyError:
        current_app.logger.error("Clé manquante dans la réponse de l'API Mistral.")
    
    return None
