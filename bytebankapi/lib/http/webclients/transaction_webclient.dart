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
        await client
            .get(
              Uri.parse(baseUrl),
            )
            .timeout(
              Duration(seconds: 5),
            );

    //map pega cada elemento do decodedJson e transforma numa lista nova
    //nessa tranformação ele vem com estrutura de iterable e aí o toList converte para lista

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

  Future<Transaction> save(Transaction transaction) async {
    //encode vai deovlver uma String que vai representar o json
    final String transactionJson = jsonEncode(transaction.toJson());

    final Response response = await client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-type': 'application/json',
        'password': '1000',
      },
      //convertemos o objeto em json
      body: transactionJson,
    );

    return Transaction.fromJson(jsonDecode(response.body));
  }
}
