import json
import re
from datetime import datetime

def clean_text(text):
    """
    Nettoie le texte en le normalisant.
    
    Args:
        text: Texte à nettoyer (peut être une chaîne ou une liste)
    
    Returns:
        str: Texte nettoyé
    """
    if isinstance(text, list):
        text = " ".join(str(item) for item in text)
    if not isinstance(text, str):
        return ""
    text = text.lower()
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def contains_keywords(text, keywords):
    """
    Vérifie si le texte contient des mots-clés spécifiques.
    
    Args:
        text (str): Texte à analyser
        keywords (list): Liste des mots-clés à rechercher
    
    Returns:
        bool: True si le texte contient au moins un mot-clé
    """
    text = clean_text(text)
    return any(keyword in text for keyword in keywords)

def is_likely_receipt(ocr_text):
    """
    Vérifie si le texte OCR semble être un ticket de caisse.
    
    Args:
        ocr_text: Texte OCR à analyser
    
    Returns:
        bool: True si le texte semble être un ticket
    """
    if isinstance(ocr_text, dict):
        ocr_text = json.dumps(ocr_text)

    ocr_text = clean_text(ocr_text)

    # Liste de mots-clés pour identifier les tickets
    receipt_keywords = [
        "article", "tva", "total", "ttc", "cb", "paiement",
        "prix", "pu", "qté", "montant", "facture", "client"
    ]

    if len(ocr_text) < 50:
        return False

    return contains_keywords(ocr_text, receipt_keywords)

def detect_merchant_from_text(raw_text):
    """
    Détecte le marchand à partir du texte.
    
    Args:
        raw_text (str): Texte brut du ticket
    
    Returns:
        str: Nom du marchand détecté
    """
    merchants_list = ["norauto", "carrefour", "leclerc", "auto5", "feu vert", "midas", "speedy", "lidl", "Uexpress"]
    raw_text_lower = raw_text.lower()
    for merchant in merchants_list:
        if merchant in raw_text_lower:
            return merchant.capitalize()
    return "Inconnu"

def parse_date(date_str):
    """
    Parse une date depuis une chaîne de caractères.
    
    Args:
        date_str (str): Date sous forme de chaîne
    
    Returns:
        datetime.date: Objet date
    """
    try:
        # Essayer différents formats de date
        formats = [
            "%Y-%m-%d",
            "%d/%m/%y",
            "%d/%m/%Y",
            "%d-%m-%Y",
            "%d-%m-%y"
        ]
        
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt).date()
            except ValueError:
                continue
                
        raise ValueError(f"Format de date non reconnu : {date_str}")
    except Exception:
        return datetime.today().date()

def extract_elements(ocr_result):
    """
    Extrait et structure les informations du ticket.
    
    Args:
        ocr_result: Résultat de l'OCR (dict ou str)
    
    Returns:
        dict: Informations structurées du ticket
    """
    try:
        print("\n=== Début du traitement OCR ===")
        print("Type des données reçues:", type(ocr_result))
        print("Contenu brut des données:", ocr_result)
        
        # Si le résultat est une chaîne, essayer de la parser en JSON
        if isinstance(ocr_result, str):
            print("\nTentative de parsing JSON...")
            try:
                if "```json" in ocr_result:
                    print("Format Markdown JSON détecté")
                    json_str = ocr_result.split("```json")[1].split("```")[0].strip()
                    print("JSON extrait:", json_str)
                    ocr_result = json.loads(json_str)
                else:
                    print("Parsing JSON direct")
                    ocr_result = json.loads(ocr_result)
                print("JSON parsé avec succès:", ocr_result)
            except json.JSONDecodeError as e:
                print(f"❌ Erreur de parsing JSON: {e}")
                print("Contenu problématique:", ocr_result)
                return {"not_receipt": True, "error": "Invalid JSON format"}

        # Vérifier la structure des données
        print("\n=== Vérification de la structure ===")
        if not isinstance(ocr_result, dict):
            print(f"❌ Format invalide: attendu dict, reçu {type(ocr_result)}")
            return {"not_receipt": True, "error": "Invalid data format"}

        # Extraire le texte brut pour la détection du marchand
        texte_complet = json.dumps(ocr_result, ensure_ascii=False)
        print("\n=== Texte complet du ticket ===")
        print(texte_complet)
        
        # Vérifier si c'est un ticket valide
        if not is_likely_receipt(texte_complet):
            print("⚠️ Ce n'est pas un ticket valide")
            return {"not_receipt": True, "error": "Not a valid receipt"}

        # Extraire les informations principales
        print("\n=== Extraction des champs principaux ===")
        merchant = detect_merchant_from_text(texte_complet)
        date_raw = ocr_result.get("date", "")
        total = ocr_result.get("total", 0)
        transaction_id = ocr_result.get("ticket_number", "")
        payment_method = ocr_result.get("payment_mode", "CB")
        articles = ocr_result.get("articles", [])

        print(f"Champs trouvés dans les données:")
        print(f"- date: {date_raw}")
        print(f"- ticket_number: {transaction_id}")
        print(f"- total: {total}")
        print(f"- payment_mode: {payment_method}")
        print(f"- articles: {len(articles)} trouvés")

        if len(articles) == 0:
            print("⚠️ Aucun article trouvé dans les données!")
            # Chercher des articles potentiels dans d'autres champs
            print("Clés disponibles:", ocr_result.keys())
            if "items" in ocr_result:
                print("'items' trouvé au lieu de 'articles'")
                articles = ocr_result["items"]
            elif "products" in ocr_result:
                print("'products' trouvé au lieu de 'articles'")
                articles = ocr_result["products"]

        # Nettoyer et formater les articles
        real_articles = []
        calculated_total = 0.0

        print("\n=== Traitement des articles ===")
        for article in articles:
            try:
                # Vérifier si l'article est un dictionnaire
                if not isinstance(article, dict):
                    print(f"⚠️ Article ignoré - format invalide: {article}")
                    continue

                # Récupérer les informations de l'article
                name = article.get("name", article.get("nom", "")).strip()
                price = article.get("price", article.get("prix", 0))
                quantity = article.get("quantity", article.get("quantite", 1))

                # Convertir le prix en float si c'est une chaîne
                if isinstance(price, str):
                    price = float(price.replace(',', '.').replace('€', '').strip())
                
                # Convertir la quantité en int si c'est une chaîne
                if isinstance(quantity, str):
                    quantity = int(quantity.strip())

                # Ignorer les articles sans nom ou avec prix négatif
                if not name or price < 0:
                    print(f"⚠️ Article ignoré - données invalides: nom={name}, prix={price}")
                    continue

                print(f"\nArticle trouvé: {name}")
                print(f"Prix: {price}€")
                print(f"Quantité: {quantity}")

                total_price = price * quantity
                calculated_total += total_price

                real_articles.append({
                    "name": name,
                    "price": round(price, 2),
                    "quantity": quantity,
                    "total_price": round(total_price, 2)
                })
                print(f"✅ Article ajouté: {name} - {price}€ x {quantity} = {total_price}€")
            except Exception as e:
                print(f"❌ Erreur lors du traitement de l'article: {e}")
                continue

        print(f"\nNombre d'articles traités: {len(real_articles)}")
        print(f"Total calculé: {calculated_total}€")

        # Traiter la date
        receipt_date = parse_date(date_raw)
        print(f"\nDate parsée: {receipt_date}")

        # Formater la sortie pour un meilleur affichage
        formatted_output = {
            "data": {
                "date": receipt_date.strftime("%d/%m/%Y"),
                "ticket_number": transaction_id,
                "total": round(total, 2),
                "payment_mode": payment_method,
                "articles": [
                    {
                        "name": article["name"],
                        "price": article["price"],
                        "quantity": article["quantity"]
                    }
                    for article in real_articles
                ]
            }
        }

        print("\n=== Données finales ===")
        print(json.dumps(formatted_output, indent=2, ensure_ascii=False))
        print("=== Fin du traitement ===\n")

        return formatted_output

    except Exception as e:
        print(f"\n❌ Erreur lors de l'extraction des éléments : {e}")
        return {"not_receipt": True} 