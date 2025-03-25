 // Mod�le de donn�es pour un ticket (montant, date, transaction)
class TicketModel {
  final String amount;
  final String date;
  final String merchant;
  final String transactionId;
  final String? imageUrl;

  TicketModel({
    required this.amount,
    required this.date,
    required this.merchant,
    required this.transactionId,
    this.imageUrl,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      amount: json['amount'] ?? '0.00',
      date: json['date'] ?? 'Inconnue',
      merchant: json['merchant'] ?? 'Inconnu',
      transactionId: json['transaction_id'] ?? 'N/A',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date,
      'merchant': merchant,
      'transaction_id': transactionId,
      'image_url': imageUrl,
    };
  }
}