import 'dart:io';
import 'package:flutter/material.dart';
import 'package:listacontatos/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/contact_helper.dart';

enum OrderOptions { orderAZ, orderZA }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Contatos"),
          centerTitle: true,
          backgroundColor: Colors.amber,
          actions: <Widget>[
            PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text('Ordenar A-Z'),
                  value: OrderOptions.orderAZ,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text('Ordenar Z-A'),
                  value: OrderOptions.orderZA,
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
          child: const Icon(Icons.add),
          backgroundColor: Colors.amber,
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _contactCard(context, index);
            }));
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img as String))
                          : const AssetImage('images/person.png')
                              as ImageProvider)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    contacts[index].name ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    contacts[index].email ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    contacts[index].phone ?? '',
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                    color: Colors.amber,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.all(10)),
                        TextButton.icon(
                          label: const Text(
                            'Chamar',
                            style: TextStyle(color: Colors.green, fontSize: 20),
                          ),
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            Navigator.pop(context);
                            if (contacts[index].phone != null) {
                              launchUrl(
                                Uri.parse('tel:${contacts[index].phone}'),
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      title: const Text(
                                          'Contato não possuí telefone.'),
                                      actions: <Widget>[
                                        OutlinedButton(
                                          child: const Text('Ok'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            }
                          },
                        ),
                        TextButton.icon(
                          label: const Text(
                            'Modificar',
                            style: TextStyle(color: Colors.blue, fontSize: 20),
                          ),
                          icon: const Icon(Icons.mode_edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                        ),
                        TextButton.icon(
                          label: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              helper.deleteContact(contacts[index].id as int);
                              contacts.removeAt(index);
                            });
                          },
                        )
                      ],
                    ));
              });
        });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderAZ:
        contacts.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        contacts.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
        _getAllContacts();
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list as List<Contact>;
      });
    });
  }
}
