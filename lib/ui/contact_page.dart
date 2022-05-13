import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listacontatos/helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;

  late Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact.name as String;
      if (_editedContact.email != null) {
        _emailController.text = _editedContact.email as String;
      }
      if (_editedContact.phone != null) {
        _phoneController.text = _editedContact.phone as String;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.amber,
              title: Text(_editedContact.name ?? 'Novo Contato'),
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (_editedContact.name != null &&
                    _editedContact.name!.isNotEmpty) {
                  Navigator.pop(context, _editedContact);
                } else {
                  FocusScope.of(context).requestFocus(_nameFocus);
                }
              },
              child: const Icon(Icons.save_alt_rounded),
              backgroundColor: Colors.amber,
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: _editedContact.img != null
                                    ? FileImage(
                                        File(_editedContact.img as String))
                                    : const AssetImage('images/person.png')
                                        as ImageProvider)),
                      ),
                      onTap: () {
                        ImagePicker()
                            .pickImage(source: ImageSource.gallery)
                            .then((file) {
                          if (file == null) return;
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        });
                      },
                    ),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedContact.name = text;
                        });
                      },
                    ),
                    TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (text) {
                          _userEdited = true;
                          _editedContact.email = text;
                        },
                        keyboardType: TextInputType.emailAddress),
                    TextField(
                        controller: _phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Telefone'),
                        onChanged: (text) {
                          _userEdited = true;
                          _editedContact.phone = text;
                        },
                        keyboardType: TextInputType.phone)
                  ],
                ))));
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Descartar alterações?'),
              content: const Text('Todas as alterações serão perdidas.'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Voltar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                OutlinedButton(
                    child: const Text('Sim'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
