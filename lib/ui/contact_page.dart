import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum OrderOptions { orderaz, orderza }

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  // File _image;

  Contact _editedContact;
  bool _userEdited = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name.isNotEmpty && _editedContact.name != null) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : AssetImage("images/default.png"))),
                ),
                onTap: () {
                  // getImage();
                  ImagePicker.pickImage(source: ImageSource.gallery)
                      .then((file) {
                    if (file != null) {
                      setState(() {
                        return _editedContact.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
                focusNode: _nameFocus,
                controller: _nameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: "E-mail"),
                onChanged: (text) {
                  _userEdited = true;

                  _editedContact.email = text;
                },
                controller: _emailcontroller,
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future getImage() async {
  //   var image = await ImagePicker.pickImage(source: ImageSource.camera);

  //   setState(() {
  //     _image = image;
  //     _editedContact.img = _image.path;
  //   });
  // }

  Future<bool> _requestPop() async {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: botaoflat("Cancelar"),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: botaoflat("Sim"),
                )
              ],
            );
          });
    } else {
      Navigator.pop(context);
    }
  }

  Widget botaoflat(String text) {
    return FlatButton(
        child: Text(text),
        onPressed: () {
          if (text == "Sim") {
            Navigator.pop(context);
            Navigator.pop(context);
          } else if (text == "Cancelar") {
            Navigator.pop(context);
          }
        });
  }

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailcontroller.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }
}
