import 'package:bytebankapi/models/contact.dart';

class Transaction {
  final double value;
  final Contact contact;

  Transaction(
    this.value,
    this.contact,
  );

  //pega o json e converte para transaction(objeto)
  Transaction.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        contact = Contact.fromJson(json['contact']);

  //pega o transaction e converte para json
  Map<String, dynamic> toJson() =>
      {'value': value, 'contact': contact.toJson()};

  @override
  String toString() {
    return 'Transaction{value: $value, contact: $contact}';
  }
}
