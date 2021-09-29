import 'dart:async';

import 'package:bytebankapi/http/webclients/transaction_webclient.dart';
import 'package:bytebankapi/models/contact.dart';
import 'package:bytebankapi/models/transaction.dart';
import 'package:bytebankapi/widgets/response_dialog.dart';
import 'package:bytebankapi/widgets/transaction_auth_dialog.dart';
import 'package:flutter/material.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      //pega o valor do textField por meio do _valueController e o contato pelo stateful widget
                      final double? value =
                          double.tryParse(_valueController.text);
                      final transactionCreated =
                          Transaction(value!, widget.contact);
                      showDialog(
                          context: context,
                          //nome diferente para o context do builder para ter certeza que vai executar o contexto correto
                          builder: (contextDialog) {
                            return TransactionAuthDialog(
                              onConfirm: (String password) {
                                _save(transactionCreated, password, context);
                              },
                            );
                          });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save(
    Transaction transactionCreated,
    String password,
    BuildContext context,
  ) async {
    final Transaction? transaction =
        await _webClient.save(transactionCreated, password).catchError((e) {
      showDialog(
          context: context,
          builder: (contextDialog) {
            return FailureDialog(e.message);
          });
      //só executa esse código do catchError quando verificar que é uma exception
    }, test: (e) => e is HttpException).catchError((e) {
      showDialog(
          context: context,
          builder: (contextDialog) {
            return FailureDialog('timeout submiting the transaction');
          });
    }, test: (e) => e is TimeoutException);

    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('succesful transaction');
          });
      Navigator.pop(context);
    }
  }
}
