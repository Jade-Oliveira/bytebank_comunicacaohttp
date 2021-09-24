import 'package:bytebankapi/screens/transactions_list.dart';
import 'package:flutter/material.dart';

import 'contacts_list.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('images/bytebank_logo.png'),
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 250,
                    margin: EdgeInsets.only(bottom: 30),
                    child: Row(
                      children: [
                        _FeatureItem(
                          name: 'Transfer',
                          icon: Icons.monetization_on,
                          onClick: () {
                            _showContactsList(context);
                          },
                        ),
                        _FeatureItem(
                            name: 'Transaction Feed',
                            icon: Icons.description,
                            onClick: () => _showTransactionsList(context)),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  //função para navegar para a lista de contatos
  void _showContactsList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactsList(),
      ),
    );
  }
}

void _showTransactionsList(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TransactionsList(),
    ),
  );
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem(
      {Key? key, required this.name, required this.icon, required this.onClick})
      : super(key: key);

  final String name;
  final IconData icon;
  //callback do dart
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          onTap: () => onClick(),
          child: Container(
            padding: EdgeInsets.all(8.0),
            height: 100,
            width: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24.0,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
