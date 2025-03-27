class TicketModel {
  final String date;
  final String ticketNumber;
  final double total;
  final String paymentMode;
  final List<ArticleModel> articles;

  TicketModel({
    required this.date,
    required this.ticketNumber,
    required this.total,
    required this.paymentMode,
    required this.articles,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    try {
      print("\n=== DÉBUT CONVERSION TICKETMODEL ===");
      print("JSON reçu: $json");

      // Vérifier si les données sont dans un objet 'data'
      final data = json['data'] as Map<String, dynamic>? ?? json;
      print("\nDonnées extraites:");
      print("- Type des données: ${data.runtimeType}");
      print("- Clés disponibles: ${data.keys.toList()}");

      // Extraire et vérifier chaque champ
      final dateValue = data['date'];
      print("\nDate:");
      print("- Valeur brute: $dateValue");
      print("- Type: ${dateValue?.runtimeType}");
      final date = dateValue?.toString() ?? 'Date inconnue';

      final ticketNumberValue = data['ticket_number'];
      print("\nNuméro de ticket:");
      print("- Valeur brute: $ticketNumberValue");
      print("- Type: ${ticketNumberValue?.runtimeType}");
      final ticketNumber = ticketNumberValue?.toString() ?? 'Sans numéro';

      final totalValue = data['total'];
      print("\nTotal:");
      print("- Valeur brute: $totalValue");
      print("- Type: ${totalValue?.runtimeType}");
      final total = (totalValue as num?)?.toDouble() ?? 0.0;

      final paymentModeValue = data['payment_mode'];
      print("\nMode de paiement:");
      print("- Valeur brute: $paymentModeValue");
      print("- Type: ${paymentModeValue?.runtimeType}");
      final paymentMode = paymentModeValue?.toString() ?? 'Non spécifié';

      final articlesValue = data['articles'];
      print("\nArticles:");
      print("- Valeur brute: $articlesValue");
      print("- Type: ${articlesValue?.runtimeType}");
      
      List<ArticleModel> articlesList = [];
      if (articlesValue != null && articlesValue is List) {
        print("Conversion des articles:");
        articlesList = articlesValue.map((article) {
          print("\nTraitement article: $article");
          try {
            return ArticleModel.fromJson(article as Map<String, dynamic>);
          } catch (e) {
            print("❌ Erreur conversion article: $e");
            return null;
          }
        }).whereType<ArticleModel>().toList();
        print("Nombre d'articles convertis: ${articlesList.length}");
      }

      final ticket = TicketModel(
        date: date,
        ticketNumber: ticketNumber,
        total: total,
        paymentMode: paymentMode,
        articles: articlesList,
      );

      print("\n=== RÉSULTAT DE LA CONVERSION ===");
      print("Date: ${ticket.date}");
      print("Numéro: ${ticket.ticketNumber}");
      print("Total: ${ticket.total}");
      print("Mode de paiement: ${ticket.paymentMode}");
      print("Nombre d'articles: ${ticket.articles.length}");
      if (ticket.articles.isNotEmpty) {
        print("\nPremier article:");
        print("- Nom: ${ticket.articles.first.name}");
        print("- Prix: ${ticket.articles.first.price}");
        print("- Quantité: ${ticket.articles.first.quantity}");
      }
      print("=== FIN CONVERSION TICKETMODEL ===\n");

      return ticket;
    } catch (e, stackTrace) {
      print("\n❌ ERREUR LORS DE LA CONVERSION DU TICKET");
      print("Erreur: $e");
      print("Stack trace: $stackTrace");
      print("JSON problématique: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'ticket_number': ticketNumber,
      'total': total,
      'payment_mode': paymentMode,
      'articles': articles.map((article) => article.toJson()).toList(),
    };
  }
}

class ArticleModel {
  final String name;
  final double price;
  final int quantity;

  ArticleModel({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    try {
      print("\n--- Conversion ArticleModel ---");
      print("Données reçues: $json");
      
      // Accepter les noms en français et en anglais
      final nameValue = json['name'] ?? json['nom'];
      print("Nom:");
      print("- Valeur brute: $nameValue");
      print("- Type: ${nameValue?.runtimeType}");
      final name = nameValue?.toString() ?? 'Article sans nom';

      // Accepter les prix en français et en anglais
      final priceValue = json['price'] ?? json['prix'];
      print("Prix:");
      print("- Valeur brute: $priceValue");
      print("- Type: ${priceValue?.runtimeType}");
      final price = (priceValue as num?)?.toDouble() ?? 0.0;

      // Accepter les quantités en français et en anglais
      final quantityValue = json['quantity'] ?? json['quantite'];
      print("Quantité:");
      print("- Valeur brute: $quantityValue");
      print("- Type: ${quantityValue?.runtimeType}");
      final quantity = (quantityValue as num?)?.toInt() ?? 1;

      final article = ArticleModel(
        name: name,
        price: price,
        quantity: quantity,
      );

      print("Article créé avec succès:");
      print("- Nom: ${article.name}");
      print("- Prix: ${article.price}€");
      print("- Quantité: ${article.quantity}");
      print("--- Fin conversion ArticleModel ---\n");

      return article;
    } catch (e, stackTrace) {
      print("\n❌ ERREUR LORS DE LA CONVERSION DE L'ARTICLE");
      print("Erreur: $e");
      print("Stack trace: $stackTrace");
      print("JSON problématique: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nom': name,
      'price': price,
      'prix': price,
      'quantity': quantity,
      'quantite': quantity,
    };
  }
}