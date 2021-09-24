import 'package:bytebankapi/http/webclients/transaction_webclient.dart';
import 'package:bytebankapi/models/transaction.dart';
import 'package:bytebankapi/widgets/centered_message.dart';
import 'package:bytebankapi/widgets/progress.dart';
import 'package:flutter/material.dart';

class TransactionsList extends StatelessWidget {
  final TransactionWebClient _webClient = TransactionWebClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _webClient.findAll(),
        builder: (context, snapshot) {
          //switch vai ficar atento com o estado da conexão entre o snapshot e o future
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return Progress();
              break;
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              if (snapshot.hasData) {
                final List<Transaction> transactions = snapshot.data!;
                if (transactions.isNotEmpty) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final Transaction transaction = transactions[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.monetization_on),
                          title: Text(
                            transaction.value.toString(),
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            transaction.contact.accountNumber.toString(),
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: transactions.length,
                  );
                }
              }
              return CenteredMessage(
                'No transactions found',
                icon: Icons.warning,
              );
              break;
          }
          return CenteredMessage('Unknown error');
        },
      ),
    );
  }
}
