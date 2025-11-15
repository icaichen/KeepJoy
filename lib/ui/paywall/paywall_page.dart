import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../services/subscription_service.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  Offerings? _offerings;
  bool _isLoading = true;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
    });

    final offerings = await SubscriptionService.getOfferings();
    if (!mounted) return;

    setState(() {
      _offerings = offerings;
      _isLoading = false;
    });
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() {
      _actionInProgress = true;
    });

    await SubscriptionService.purchasePackage(package);
    final isPremium = await SubscriptionService.isPremium();

    if (!mounted) return;

    setState(() {
      _actionInProgress = false;
    });

    final l10n = AppLocalizations.of(context)!;
    if (isPremium) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallPurchaseSuccess)));
      }
      Navigator.of(context).pop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallPurchaseFailure)));
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _actionInProgress = true;
    });

    await SubscriptionService.restorePurchases();
    final isPremium = await SubscriptionService.isPremium();

    if (!mounted) return;

    setState(() {
      _actionInProgress = false;
    });

    final l10n = AppLocalizations.of(context)!;
    if (isPremium) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallRestoreSuccess)));
      }
      Navigator.of(context).pop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paywallRestoreFailure)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final packages = _offerings?.current?.availablePackages ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywallTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? _buildLoading(l10n)
            : packages.isEmpty
            ? _buildUnavailable(l10n)
            : _buildPackageList(l10n, packages),
      ),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.paywallLoading, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildUnavailable(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.paywallUnavailable,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadOfferings, child: Text(l10n.tryAgain)),
        ],
      ),
    );
  }

  Widget _buildPackageList(AppLocalizations l10n, List<Package> packages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.paywallDescription, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final product = package.storeProduct;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.priceString,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _actionInProgress
                            ? null
                            : () => _purchasePackage(package),
                        child: Text(l10n.paywallPurchaseButton),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _actionInProgress ? null : _restorePurchases,
          child: Text(l10n.paywallRestorePurchases),
        ),
      ],
    );
  }
}
