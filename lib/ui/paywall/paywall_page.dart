import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../../services/subscription_service.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  Package? _selectedPackage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Auto-select annual package if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      final offerings = subscriptionProvider.currentOffering;
      if (offerings?.current != null) {
        final packages = offerings!.current!.availablePackages;
        if (packages.isNotEmpty) {
          // Select annual package by default
          final annualPackage = packages.firstWhere(
            (p) =>
                p.storeProduct.identifier.contains('yearly') ||
                p.storeProduct.identifier.contains('annual'),
            orElse: () => packages.first,
          );
          setState(() {
            _selectedPackage = annualPackage;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final offerings = subscriptionProvider.currentOffering;

    return Scaffold(
      backgroundColor: Colors.white,
      body: offerings == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            l10n.upgradeToPremium,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            l10n.premiumMembershipDescription,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Premium Features List
                          _buildFeaturesList(l10n),

                          const SizedBox(height: 32),

                          // Select plan text
                          Center(
                            child: Text(
                              l10n.selectPlan,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Subscription Options (side by side)
                          if (offerings.current != null)
                            _buildSubscriptionCards(
                              offerings.current!,
                              l10n,
                            ),

                          const SizedBox(height: 24),

                          // Legal text
                          _buildLegalText(l10n),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom button section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Subscribe Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing || _selectedPackage == null
                                ? null
                                : _handlePurchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0EA5E9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _getButtonText(l10n),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Restore Purchases Button
                        TextButton(
                          onPressed: _isProcessing ? null : _restorePurchases,
                          child: Text(
                            l10n.restorePurchases,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getButtonText(AppLocalizations l10n) {
    if (_selectedPackage == null) return l10n.subscribeNow;

    final product = _selectedPackage!.storeProduct;
    if (product.introductoryPrice != null) {
      final intro = product.introductoryPrice!;
      if (intro.periodNumberOfUnits > 0) {
        return l10n.startFreeTrial(intro.periodNumberOfUnits.toString());
      }
    }
    return l10n.subscribeNow;
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    final features = [
      (l10n.featureMemoriesPage, l10n.featureMemoriesPageDesc, Icons.star_rounded),
      (l10n.dashboardMemoryLaneTitle, l10n.featureMemoryLaneDesc, Icons.star_rounded),
      (l10n.dashboardResellReportTitle, l10n.featureResellTrendsDesc, Icons.star_rounded),
      (l10n.dashboardYearlyReportsTitle, l10n.featureYearlyChronicleDesc, Icons.star_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature.$3,
                  color: const Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.$1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.$2,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionCards(
    Offering offering,
    AppLocalizations l10n,
  ) {
    final packages = offering.availablePackages;

    if (packages.isEmpty) {
      return Center(
        child: Text(
          l10n.noOfferingsAvailable,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    // Sort packages: annual first, then monthly
    final sortedPackages = List<Package>.from(packages);
    sortedPackages.sort((a, b) {
      final aIsAnnual = a.storeProduct.identifier.contains('yearly') ||
          a.storeProduct.identifier.contains('annual');
      final bIsAnnual = b.storeProduct.identifier.contains('yearly') ||
          b.storeProduct.identifier.contains('annual');

      if (aIsAnnual && !bIsAnnual) return -1;
      if (!aIsAnnual && bIsAnnual) return 1;
      return 0;
    });

    // Calculate savings if both annual and monthly exist
    double? savingsPercent;
    if (sortedPackages.length >= 2) {
      final annualPackage = sortedPackages[0];
      final monthlyPackage = sortedPackages[1];

      // Extract prices (this is simplified, actual implementation may vary)
      final annualPrice = annualPackage.storeProduct.price;
      final monthlyPrice = monthlyPackage.storeProduct.price;

      if (monthlyPrice > 0) {
        final annualMonthlyEquivalent = monthlyPrice * 12;
        savingsPercent = ((annualMonthlyEquivalent - annualPrice) / annualMonthlyEquivalent * 100);
      }
    }

    return Row(
      children: sortedPackages.take(2).map((package) {
        final product = package.storeProduct;
        final isAnnual = product.identifier.contains('yearly') ||
            product.identifier.contains('annual');
        final isSelected = _selectedPackage?.identifier == package.identifier;
        final isFirst = sortedPackages.indexOf(package) == 0;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPackage = package;
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: isFirst ? 0 : 8, right: isFirst ? 8 : 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Savings badge
                  if (isAnnual && savingsPercent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.savePercent(savingsPercent.round().toString()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 28),

                  const SizedBox(height: 16),

                  // Plan name
                  Text(
                    isAnnual ? l10n.annualPlan.toUpperCase() : l10n.monthlyPlan.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: product.priceString.split('.')[0],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        if (product.priceString.contains('.'))
                          TextSpan(
                            text: '.${product.priceString.split('.')[1]}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        TextSpan(
                          text: isAnnual ? l10n.perYear.toUpperCase() : l10n.perMonth.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Original price (if annual and we have savings)
                  if (isAnnual && savingsPercent != null && sortedPackages.length >= 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '\$${(sortedPackages[1].storeProduct.price * 12).toStringAsFixed(2)}${l10n.perYear.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 20),

                  const SizedBox(height: 12),

                  // Billing info with trial
                  Column(
                    children: [
                      // Show trial badge if available
                      if (product.introductoryPrice != null &&
                          product.introductoryPrice!.periodNumberOfUnits > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.trialDays(product.introductoryPrice!.periodNumberOfUnits.toString()),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 20),
                      const SizedBox(height: 8),
                      Text(
                        isAnnual
                            ? l10n.billedYearlyAfterTrial
                            : l10n.billedMonthlyAfterTrial,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Checkmark
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegalText(AppLocalizations l10n) {
    return Text(
      l10n.changePlansAnytime,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9CA3AF),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final customerInfo = await SubscriptionService.purchasePackage(_selectedPackage!);

      print('🎉 Purchase completed!');
      print('📱 Customer Info after purchase:');
      print('   - All Entitlements: ${customerInfo.entitlements.all.keys.toList()}');
      print('   - Active Entitlements: ${customerInfo.entitlements.active.keys.toList()}');

      if (mounted) {
        // Refresh subscription status
        await Provider.of<SubscriptionProvider>(context, listen: false)
            .refreshSubscriptionStatus();

        // Double-check premium status
        final isPremium = await SubscriptionService.isPremium();
        print('✅ Premium status after purchase: $isPremium');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.subscriptionSuccess),
            backgroundColor: const Color(0xFF10B981),
          ),
        );

        // Wait a moment for state to propagate
        await Future.delayed(const Duration(milliseconds: 500));

        // Close paywall
        Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (mounted && errorCode != PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Purchase failed'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final customerInfo = await SubscriptionService.restorePurchases();
      print('🔄 Restore result - Active entitlements: ${customerInfo.entitlements.active}');

      if (mounted) {
        // Refresh subscription status
        await Provider.of<SubscriptionProvider>(context, listen: false)
            .refreshSubscriptionStatus();

        // Check premium status after refresh
        final provider =
            Provider.of<SubscriptionProvider>(context, listen: false);
        print('✅ Premium status after restore: ${provider.isPremium}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchasesRestored),
            backgroundColor: const Color(0xFF10B981),
          ),
        );

        // Close paywall if premium now
        if (provider.isPremium) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('❌ Restore error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring purchases: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
