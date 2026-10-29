import 'package:flutter/material.dart';
import 'database.dart';
import 'models.dart';
import 'report.dart';
import 'widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IncomeExpensesApp());
}

class IncomeExpensesApp extends StatelessWidget {
  const IncomeExpensesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income & Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Account> accounts = [];
  List<TransactionItem> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final loadedAccounts = await DBHelper.instance.getAccounts();
      final loadedTransactions = await DBHelper.instance.getTransactions();
      if (!mounted) return;
      setState(() {
        accounts = loadedAccounts;
        transactions = loadedTransactions;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load saved data.')),
      );
    }
  }

  double getTotalNetWorth() {
    double total = 0;
    for (var acc in accounts) {
      if (acc.type == 'Bank' || acc.type == 'Cash' || acc.type == 'Receivable') {
        total += acc.balance;
      } else if (acc.type == 'Payable') {
        total -= acc.balance;
      }
    }
    return total;
  }

  double getCardBalance(String type) {
    return accounts
        .where((acc) => acc.type == type)
        .fold(0.0, (sum, acc) => sum + acc.balance);
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedType = 'Bank';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Account / Ledger'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name (e.g. HBL / Ali)')),
              TextField(controller: balanceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Balance')),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp Phone (optional)')),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: ['Bank', 'Cash', 'Payable', 'Receivable']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => selectedType = val!,
                decoration: const InputDecoration(labelText: 'Account Type'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await DBHelper.instance.insertAccount(
                  Account(
                    name: nameController.text,
                    type: selectedType,
                    balance: double.tryParse(balanceController.text) ?? 0.0,
                    phoneNumber: phoneController.text,
                  ),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                loadData();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double netWorth = getTotalNetWorth();
    double bankBalance = getCardBalance('Bank');
    double cashBalance = getCardBalance('Cash');
    double payableBalance = getCardBalance('Payable');
    double receivableBalance = getCardBalance('Receivable');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.tealAccent),
            onPressed: _showAddAccountDialog,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Net Worth Card with Neon Gradient & Outline
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF00F2FE), blurRadius: 10, spreadRadius: 1)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Net Worth / Balance', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          '\$${netWorth.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: netWorth < 0 ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bank & Cash Cards
                  Row(
                    children: [
                      Expanded(
                        child: NeonCard(
                          title: 'Bank',
                          amount: bankBalance,
                          icon: Icons.account_balance,
                          gradientColors: const [Color(0xFFf12711), Color(0xFFf5af19)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonCard(
                          title: 'Cash',
                          amount: cashBalance,
                          icon: Icons.money,
                          gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Payable & Receivable Cards
                  Row(
                    children: [
                      Expanded(
                        child: NeonCard(
                          title: 'Payable',
                          amount: payableBalance,
                          icon: Icons.payment,
                          gradientColors: const [Color(0xFFcb2d3e), Color(0xFFef473a)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonCard(
                          title: 'Receivable',
                          amount: receivableBalance,
                          icon: Icons.request_quote,
                          gradientColors: const [Color(0xFF833ab4), Color(0xFFfd1d1d)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Chart / Analytics placeholder section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.tealAccent, width: 1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Analytics Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                        SizedBox(height: 100, child: Center(child: Text('Transaction Overview Chart'))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.home, color: Colors.white)),
              onPressed: () => loadData(),
            ),
            IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.money_off, color: Colors.white)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen(type: 'Payable')))
                    .then((_) => loadData());
              },
            ),
            IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.attach_money, color: Colors.white)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen(type: 'Receivable')))
                    .then((_) => loadData());
              },
            ),
          ],
        ),
      ),
    );
  }
}
