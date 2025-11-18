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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final offerings = subscriptionProvider.currentOffering;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(l10n.premiumMembership),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
      ),
      body: offerings == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    l10n.upgradeToPremium,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.premiumMembershipDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Premium Features List
                  _buildFeaturesList(l10n),

                  const SizedBox(height: 32),

                  // Subscription Options
                  if (offerings.current != null)
                    ..._buildSubscriptionOptions(
                      offerings.current!,
                      l10n,
                    ),

                  const SizedBox(height: 24),

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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              l10n.subscribeNow,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Restore Purchases Button
                  Center(
                    child: TextButton(
                      onPressed: _isProcessing ? null : _restorePurchases,
                      child: Text(
                        l10n.restorePurchases,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms and Privacy
                  _buildLegalText(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(l10n.featureAnnualReports, Icons.bar_chart_rounded),
        _buildFeatureItem(l10n.featureMonthlyReports, Icons.calendar_month_rounded),
        _buildFeatureItem(l10n.featureDeepReports, Icons.insights_rounded),
        _buildFeatureItem(l10n.featureMemoriesPage, Icons.photo_library_rounded),
        _buildFeatureItem(l10n.featureExportData, Icons.download_rounded),
        _buildFeatureItem(l10n.featureAdvancedInsights, Icons.analytics_rounded),
        _buildFeatureItem(l10n.featureCustomReminders, Icons.notifications_active_rounded),
        _buildFeatureItem(l10n.featureSessionResume, Icons.play_arrow_rounded),
      ],
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0EA5E9), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubscriptionOptions(
    Offering offering,
    AppLocalizations l10n,
  ) {
    final packages = offering.availablePackages;

    if (packages.isEmpty) {
      return [
        Center(
          child: Text(
            l10n.noOfferingsAvailable,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      ];
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

    return sortedPackages.map((package) {
      final product = package.storeProduct;
      final isAnnual = product.identifier.contains('yearly') ||
          product.identifier.contains('annual');
      final isSelected = _selectedPackage?.identifier == package.identifier;

      // Get trial info
      String? trialText;
      if (product.introductoryPrice != null) {
        final intro = product.introductoryPrice!;
        if (intro.periodNumberOfUnits > 0) {
          trialText = '${intro.periodNumberOfUnits} ${_getPeriodUnit(intro.periodUnit)} ${l10n.freeTrial}';
        }
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedPackage = package;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0EA5E9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Package info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.title.split('(').first.trim(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        if (isAnnual) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.recommended,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (trialText != null)
                      Text(
                        trialText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              // Price
              Text(
                product.priceString,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getPeriodUnit(PeriodUnit unit) {
    switch (unit) {
      case PeriodUnit.day:
        return 'day';
      case PeriodUnit.week:
        return 'week';
      case PeriodUnit.month:
        return 'month';
      case PeriodUnit.year:
        return 'year';
      default:
        return '';
    }
  }

  Widget _buildLegalText(AppLocalizations l10n) {
    return Text(
      l10n.subscriptionTerms,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF9CA3AF),
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
      await SubscriptionService.purchasePackage(_selectedPackage!);
      
      if (mounted) {
        // Refresh subscription status
        await Provider.of<SubscriptionProvider>(context, listen: false)
            .refreshSubscriptionStatus();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.subscriptionSuccess),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        
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
      await SubscriptionService.restorePurchases();
      
      if (mounted) {
        // Refresh subscription status
        await Provider.of<SubscriptionProvider>(context, listen: false)
            .refreshSubscriptionStatus();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchasesRestored),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        
        // Close paywall if premium now
        final provider = Provider.of<SubscriptionProvider>(context, listen: false);
        if (provider.isPremium) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
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

