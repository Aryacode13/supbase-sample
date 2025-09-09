import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  // 🔔 helper untuk menampilkan notif
  void _showMessage(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fetchContacts() async {
    final response = await supabase.from('contacts').select();
    setState(() {
      _contacts = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addContact() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      _showMessage("Nama dan Alamat tidak boleh kosong ❌", success: false);
      return;
    }

    try {
      await supabase.from('contacts').insert({
        'name': name,
        'address': address,
      });

      _nameController.clear();
      _addressController.clear();

      _showMessage("Kontak berhasil ditambahkan ✅");
      _fetchContacts();
    } catch (e) {
      _showMessage("Gagal menambahkan kontak ❌", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Kontak")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nama"),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: "Alamat"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text("Tambah Kontak"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact['name']),
                  subtitle: Text(contact['address']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
