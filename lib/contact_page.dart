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

  // 🔔 helper untuk notif
  void _showMessage(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // READ
  Future<void> _fetchContacts() async {
    try {
      final response = await supabase.from('contacts').select().order('id');
      setState(() {
        _contacts = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showMessage("Gagal memuat data: $e", success: false);
    }
  }

  // CREATE
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
      _showMessage("Gagal menambahkan: $e", success: false);
    }
  }

  // UPDATE
  Future<void> _editContact(
      int id, String currentName, String currentAddress) async {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Kontak"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama")),
            TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Alamat")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              try {
                await supabase.from('contacts').update({
                  'name': nameController.text,
                  'address': addressController.text,
                }).eq('id', id);

                _showMessage("Kontak berhasil diupdate ✅");
                Navigator.pop(context);
                _fetchContacts();
              } catch (e) {
                _showMessage("Gagal update: $e", success: false);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // DELETE
  Future<void> _deleteContact(int id) async {
    try {
      await supabase.from('contacts').delete().eq('id', id);
      _showMessage("Kontak berhasil dihapus 🗑️");
      _fetchContacts();
    } catch (e) {
      _showMessage("Gagal hapus: $e", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Kontak")),
      body: Column(
        children: [
          // Form Tambah
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Nama")),
                TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: "Alamat")),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: _addContact, child: const Text("Tambah Kontak")),
              ],
            ),
          ),
          const Divider(),
          // List Kontak
          Expanded(
            child: _contacts.isEmpty
                ? const Center(child: Text("Belum ada kontak"))
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        title: Text(contact['name']),
                        subtitle: Text(contact['address']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editContact(contact['id'],
                                  contact['name'], contact['address']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteContact(contact['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
