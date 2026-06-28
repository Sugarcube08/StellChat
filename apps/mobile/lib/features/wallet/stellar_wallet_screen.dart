import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _isConnected = false;
  String _walletAddress = "GD7O...K3PL";
  double _xlmBalance = 245.50;
  double _usdcBalance = 80.00;
  bool _isConnecting = false;

  final List<Map<String, dynamic>> _mockTransactions = [
    {
      "type": "Sent",
      "amount": "15.00 USDC",
      "recipient": "Alice (A3K...)",
      "txHash": "8cf5be...1c2a",
      "status": "ZK Verified",
      "time": "10 mins ago"
    },
    {
      "type": "Received",
      "amount": "50.00 XLM",
      "recipient": "Bob (B9W...)",
      "txHash": "a1f9d2...7b3e",
      "status": "ZK Verified",
      "time": "2 hours ago"
    },
    {
      "type": "Sent",
      "amount": "100.00 XLM",
      "recipient": "Merchant (M1X...)",
      "txHash": "7e3b9f...2d8c",
      "status": "ZK Verified",
      "time": "Yesterday"
    }
  ];

  void _toggleWalletConnection() async {
    if (_isConnected) {
      setState(() {
        _isConnected = false;
        _xlmBalance = 0.0;
        _usdcBalance = 0.0;
      });
    } else {
      setState(() => _isConnecting = true);
      await Future.delayed(const Duration(seconds: 1)); // Simulate ledger fetch
      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _walletAddress = "GD7OQ4KRLDWR3B5MX43NBLF2J7J37A2C7L6E2QPL47G53WJ735STELL";
        _xlmBalance = 245.50;
        _usdcBalance = 80.00;
      });
    }
  }

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: _walletAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                        child: _buildWalletBalanceCard(context, colors),
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
                    _buildTransactionsList(colors),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard(BuildContext context, dynamic colors) {
    return GhostSurface(
      type: GhostSurfaceType.secondary,
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
                      color: colors.ghostAccent.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet, size: 20, color: colors.ghostAccent),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    _isConnected ? 'STELLAR ACCOUNT' : 'STELLAR DISCONNECTED',
                    style: AppTypography.caption(context).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              _isConnecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white24),
                    )
                  : GhostButton(
                      label: _isConnected ? 'DISCONNECT' : 'CONNECT WALLET',
                      onPressed: _toggleWalletConnection,
                    ),
            ],
          ),
          if (_isConnected) ...[
            const SizedBox(height: AppSpacing.l),
            GestureDetector(
              onTap: _copyAddress,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _walletAddress,
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
                        '${_xlmBalance.toStringAsFixed(2)} XLM',
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
                        '\$${_usdcBalance.toStringAsFixed(2)}',
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

  Widget _buildTransactionsList(dynamic colors) {
    if (!_isConnected) {
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

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = _mockTransactions[index];
          final isSent = tx['type'] == 'Sent';
          return GhostCard(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
            type: GhostSurfaceType.secondary,
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
        childCount: _mockTransactions.length,
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
              // Open mock Stellar Explorer link
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Stellar Explorer (Testnet)...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.ghostAccent, foregroundColor: Colors.black),
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
