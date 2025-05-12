import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/database/wallet.dart';
import '../../components/wallet_provider.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallets = walletProvider.wallets;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Wallets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWalletDialog(context),
          ),
        ],
      ),
      body: wallets.isEmpty
          ? const Center(child: Text("No wallets yet."))
          : ListView.builder(
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: wallet.color,
            ),
            title: Text(wallet.name),
            subtitle: Text('${wallet.amount.toStringAsFixed(2)} EGP'),
            trailing: Text(
              '${walletProvider.getWalletShare(wallet).toStringAsFixed(1)}%',
            ),
          );
        },
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Wallet Name'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Initial Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;

              if (name.isEmpty) return;

              final newWallet = Wallet(
                name: name,
                amount: amount,
                isGoal: false,
                colorValue: Colors.blue.value,
                history: [],
              );

              Provider.of<WalletProvider>(context, listen: false)
                  .addWallet(newWallet);

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
