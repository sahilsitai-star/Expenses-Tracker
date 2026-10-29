import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database.dart';
import 'models.dart';

class ReportScreen extends StatefulWidget {
  final String type; // 'Payable' or 'Receivable'
  const ReportScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Account> accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    setState(() => isLoading = true);
    final allAccounts = await DBHelper.instance.getAccounts();
    if (!mounted) return;
    setState(() {
      accounts = allAccounts.where((acc) => acc.type == widget.type).toList();
      isLoading = false;
    });
  }

  void sendWhatsAppMessage(Account account) async {
    if (account.phoneNumber == null || account.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is missing, cannot send WhatsApp message.')),
      );
      return;
    }
    final phone = account.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid international phone number.')),
      );
      return;
    }
    final message = 'Hello ${account.name}, your ${widget.type.toLowerCase()} balance is \$${account.balance}. Please clear your dues.';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!mounted) return;
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void editCategoryDialog(Account account) {
    TextEditingController categoryController = TextEditingController(text: account.category ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Category for ${account.name}'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              account.category = categoryController.text;
              await DBHelper.instance.updateAccount(account);
              if (!context.mounted) return;
              Navigator.pop(context);
              fetchAccounts();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Report Page'),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? Center(child: Text('No ${widget.type} accounts found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF232526), Color(0xFF414345)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.tealAccent, width: 1),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(acc.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Category: ${acc.category ?? "General"}\nBalance: \$${acc.balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.type == 'Payable')
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.amber),
                                onPressed: () => editCategoryDialog(acc),
                              ),
                            IconButton(
                              icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.share, color: Colors.white, size: 16)),
                              onPressed: () => sendWhatsAppMessage(acc),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
