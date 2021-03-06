import 'dart:async';

import 'package:bytebankapi/http/webclients/transaction_webclient.dart';
import 'package:bytebankapi/models/contact.dart';
import 'package:bytebankapi/models/transaction.dart';
import 'package:bytebankapi/widgets/progress.dart';
import 'package:bytebankapi/widgets/response_dialog.dart';
import 'package:bytebankapi/widgets/transaction_auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionId = Uuid().v4();

  bool _sending = false;

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
              Visibility(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Progress(
                    message: 'Sending...',
                  ),
                ),
                //esconde ou não o conteúdo
                visible: _sending,
              ),
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
                  onChanged: (_) => setState(() {}),
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(
                      labelText: 'Value',
                      errorText: _valueController.text == ''
                          ? 'Insira um valor'
                          : null),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: _valueController.text != ''
                        ? () {
                            //pega o valor do textField por meio do _valueController e o contato pelo stateful widget
                            final double value =
                                double.parse(_valueController.text);
                            final transactionCreated = Transaction(
                              transactionId,
                              value,
                              widget.contact,
                            );
                            showDialog(
                                context: context,
                                //nome diferente para o context do builder para ter certeza que vai executar o contexto correto
                                builder: (contextDialog) {
                                  return TransactionAuthDialog(
                                    onConfirm: (String password) {
                                      _save(
                                        transactionCreated,
                                        password,
                                        context,
                                      );
                                    },
                                  );
                                });
                          }
                        : null,
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
    Transaction? transaction = await _send(
      transactionCreated,
      password,
      context,
    );
    _showSuccessfullMessage(transaction!, context);
  }

  Future<void> _showSuccessfullMessage(
      Transaction transaction, BuildContext context) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('succesful transaction');
          });
      Navigator.pop(context);
    }
  }

  Future<Transaction?> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    setState(() {
      //quando começar a enviar a transferência é para apresentar o progress
      _sending = true;
    });
    final Transaction? transaction = await _webClient
        .save(transactionCreated, password)
        .catchError((e) {
      _showFailureMessage(context, message: e.message);
      //só executa esse código do catchError quando verificar que é uma exception
    }, test: (e) => e is HttpException).catchError((e) {
      _showFailureMessage(context,
          message: 'timeout submiting the transaction');
    }, test: (e) => e is TimeoutException).catchError((e) {
      _showFailureMessage(context);
    })
        //o whenComplete garante que vai fazer a execução de outra coisa apenas quando esse _send for finalizado
        .whenComplete(() {
      setState(() {
        _sending = false;
      });
    });
    return transaction;
  }

  void _showFailureMessage(BuildContext context,
      {String message = 'Unknown error'}) {
    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }
}
