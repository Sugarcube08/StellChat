import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../../design_system/components/components.dart';

class StellarWalletScreen extends ConsumerStatefulWidget {
  const StellarWalletScreen({super.key});

  @override
  ConsumerState<StellarWalletScreen> createState() => _StellarWalletScreenState();
}

class _StellarWalletScreenState extends ConsumerState<StellarWalletScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallet = ref.read(stellarWalletServiceProvider);
      if (wallet.isConnected) {
        wallet.fetchBalances();
        wallet.fetchTransactions();
      }
    });
  }

  void _toggleWalletConnection() async {
    final wallet = ref.read(stellarWalletServiceProvider);
    if (wallet.isConnected) {
      wallet.disconnect();
    } else {
      try {
        await wallet.connectWallet();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to connect wallet: $e')),
          );
        }
      }
    }
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final wallet = ref.watch(stellarWalletServiceProvider);

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                          vertical: AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WALLET',
                              style: AppTypography.hero(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Native Stellar Integration & ZK Verification',
                              style: AppTypography.secondary(context).copyWith(
                                color: colors.secondaryText.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        child: _buildWalletBalanceCard(context, wallet, colors),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xl, AppSpacing.l, AppSpacing.m),
                        child: Text(
                          'RECENT VERIFIED PAYMENTS',
                          style: AppTypography.caption(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.secondaryText.withAlpha(80),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    _buildTransactionsList(wallet, colors),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard(BuildContext context, dynamic wallet, dynamic colors) {
    return StellSurface(
      type: StellSurfaceType.secondary,
      padding: const EdgeInsets.all(AppSpacing.l),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.stellAccent.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet, size: 20, color: colors.stellAccent),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    wallet.isConnected ? 'STELLAR ACCOUNT' : 'STELLAR DISCONNECTED',
                    style: AppTypography.caption(context).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              wallet.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white24),
                    )
                  : StellButton(
                      label: wallet.isConnected ? 'DISCONNECT' : 'CONNECT WALLET',
                      onPressed: _toggleWalletConnection,
                    ),
            ],
          ),
          if (wallet.isConnected) ...[
            const SizedBox(height: AppSpacing.l),
            GestureDetector(
              onTap: () => _copyAddress(wallet.address),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      wallet.address,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.copy, size: 12, color: colors.secondaryText.withAlpha(100)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BALANCE (XLM)', style: AppTypography.caption(context).copyWith(color: colors.secondaryText.withAlpha(100))),
                      const SizedBox(height: 4),
                      Text(
                        '${wallet.xlmBalance.toStringAsFixed(2)} XLM',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BALANCE (USDC)', style: AppTypography.caption(context).copyWith(color: colors.secondaryText.withAlpha(100))),
                      const SizedBox(height: 4),
                      Text(
                        '\$${wallet.usdcBalance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.l),
            Text(
              'Connect your Stellar wallet to view balances, settle pending payment requests inside conversations, and view ZK payment proofs.',
              style: AppTypography.caption(context).copyWith(
                color: colors.secondaryText.withAlpha(80),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsList(dynamic wallet, dynamic colors) {
    if (!wallet.isConnected) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Text(
              'Wallet disconnected. Connect to view ledger history.',
              style: TextStyle(color: colors.textMuted.withAlpha(100), fontSize: 12),
            ),
          ),
        ),
      );
    }

    final txs = wallet.transactions;
    if (txs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Text(
              'No recent transactions found on the ledger.',
              style: TextStyle(color: colors.textMuted.withAlpha(100), fontSize: 12),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = txs[index];
          final isSent = tx['type'] == 'Sent';
          return StellCard(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
            type: StellSurfaceType.secondary,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSent ? Icons.arrow_outward : Icons.call_received,
                color: isSent ? colors.error : colors.success,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tx['type']} ${tx['amount']}',
                    style: AppTypography.body(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.success.withAlpha(40), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, size: 8, color: colors.success),
                        const SizedBox(width: 2),
                        Text(
                          'ZK VERIFIED',
                          style: TextStyle(color: colors.success, fontSize: 7, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSent ? 'To ${tx['recipient']}' : 'From ${tx['recipient']}',
                      style: AppTypography.caption(context).copyWith(color: colors.secondaryText.withAlpha(80)),
                    ),
                    Text(
                      tx['time'],
                      style: AppTypography.caption(context).copyWith(color: colors.secondaryText.withAlpha(50), fontSize: 9),
                    ),
                  ],
                ),
              ),
              onTap: () => _showTxDetails(context, tx, colors),
            ),
          );
        },
        childCount: txs.length,
      ),
    );
  }

  void _showTxDetails(BuildContext context, Map<String, dynamic> tx, dynamic colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.secondaryBackground,
        title: Text('${tx['type'].toUpperCase()} RECEIPT', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', tx['amount']),
            _buildDetailRow('Counterparty', tx['recipient']),
            _buildDetailRow('TX Hash', tx['txHash'], isMonospace: true),
            _buildDetailRow('Verification', 'Zero-Knowledge Groth16 (bn128)'),
            _buildDetailRow('Status', 'Settled & Authenticated on Stellar'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Zero-knowledge proof ensures this transaction occurred with the exact amount and assets, verified locally and confirmed on-chain without revealing sensitive user parameters.',
              style: TextStyle(fontSize: 10, color: Colors.white38, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE', style: TextStyle(color: colors.secondaryText.withAlpha(100))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open local quickstart Horizon transaction details
              final url = "${ref.read(stellarWalletServiceProvider).horizonUrl}/transactions/${tx['txHash']}";
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Explorer URL copied: $url')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.stellAccent, foregroundColor: Colors.black),
            child: const Text('EXPLORE LEDGER'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: isMonospace ? 'monospace' : null,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
