import 'dart:convert';

import 'package:bytebankapi/http/webclient.dart';
import 'package:bytebankapi/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  //busca
  Future<List<Transaction>> findAll() async {
    //cria o client e utiliza ele para fazer o get
    //colocamos na lista de interceptadores as instâncias dos interceptadores que a gente quer adicionar

    //o get é uma requisição e precisamos da resposta dela, podemos usar o then ou o async await
    //o response recebe um json
    final Response response =
        //ao invés de fazer o get sozinho, ele é utilizado a partir do client
        await client.get(
      Uri.parse(baseUrl),
    );

    //map pega cada elemento do decodedJson e transforma numa lista nova
    //nessa tranformação ele vem com estrutura de iterable e o toList converte para lista

    //equivalente ao código de baixo
    // final List<Transaction> transactions = [];
    // for (Map<String, dynamic> transactionJson in decodedJson) {
    //   transactions.add(Transaction.fromJson(transactionJson));
    // }
    final List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction?> save(Transaction transaction, String password) async {
    //encode vai deovlver uma String que vai representar o json
    final String transactionJson = jsonEncode(transaction.toJson());

    await Future.delayed(Duration(seconds: 2));

    final Response response = await client.post(
      Uri.parse(baseUrl),
      headers: {
        //esse password faz parte da integração entre formulário e dialog
        'Content-type': 'application/json',
        'password': password,
      },
      //convertemos o objeto em json
      body: transactionJson,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }

    //quando não preenchemos valor de transferência
    throw HttpException(_getMessage(response.statusCode));
  }

  String _getMessage(int statusCode) {
    if (_statusCodeResponses.containsKey(statusCode)) {
      return _statusCodeResponses[statusCode]!;
    }
    return 'Unknown error';
  }

  static final Map<int, String> _statusCodeResponses = {
    400: 'there was an error submiting transaction',
    401: 'authentication failed',
    409: 'transaction always exists'
  };
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);
}
