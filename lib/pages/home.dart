import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_tp/services/firebase.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  String? _editedText;

  void _openDialogCode() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un code'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Entrez votre code',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  FirebaseService().createCode(_controller.text);
                  Navigator.of(context).pop();
                  _controller.clear();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié dans le presse-papiers =)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Codes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDialogCode,
        label: const Text('Ajouter'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
      body: StreamBuilder(
        stream: FirebaseService().getCodes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final code = snapshot.data!.docs[index]['code'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    code,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.content_copy, color: Colors.blue),
                        onPressed: () => _copyToClipboard(code),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseService()
                              .deleteCode(snapshot.data!.docs[index].id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          _showEditDialog(
                              context, snapshot.data!.docs[index].id, code);
                        },
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, String currentText) {
    _editedText = currentText;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editer :'),
          content: TextField(
            controller: TextEditingController(text: currentText),
            onChanged: (value) {
              _editedText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                FirebaseService().updateCode(docId, _editedText!);
                Navigator.of(context).pop();
              },
              child: const Text('SoVeGaRdEr'),
            ),
          ],
        );
      },
    );
  }
}
