import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllcontacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de a-z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de z-a"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(context, index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                height: 150.0,
                width: 150.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/default.png"))),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: botaoFlat("Ligar", index),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: botaoFlat("Editar", index),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: botaoFlat("Excluir", index),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  Widget botaoFlat(String text, index) {
    print(contacts[index]);
    return FlatButton(
        child: Text(
          text,
          style: TextStyle(color: Colors.red, fontSize: 20.0),
        ),
        onPressed: () {
          if (text == "Editar") {
            print(contacts[index]);
            _showContactPage(contact: contacts[index]);
          }
          if (text == "Excluir") {
            print(contacts[index].id);
            helper.deleteContact(contacts[index].id);
            setState(() {
              contacts.removeAt(index);
              Navigator.pop(context);
            });
          }
          if (text == "Ligar") {
            launch("tel:${contacts[index].phone}");
          }
        });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
        setState(() {});
    }
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
        _getAllcontacts();
      } else {
        await helper.saveContact(recContact); // add novo contato
      }
      _getAllcontacts(); // atualiza contato existente

    }
  }

  void _getAllcontacts() async {
    await helper.getAllcontacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}
