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
  Map<String, IntroEligibility>? _eligibilityMap;
  String? _preparedOfferingId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkTrialEligibility(List<Package> packages) async {
    try {
      // Get product identifiers
      final productIds = packages
          .map((p) => p.storeProduct.identifier)
          .toList();

      print('🔍 [DEBUG] Checking trial eligibility for products: $productIds');

      // Check eligibility for all products
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);

      print('🔍 [DEBUG] Trial eligibility result: $eligibility');

      // Log each product's eligibility status
      eligibility.forEach((productId, status) {
        print('🔍 [DEBUG] Product: $productId');
        print('   - Status: ${status.status}');
        print('   - Description: ${status.description}');
      });

      if (mounted) {
        setState(() {
          _eligibilityMap = eligibility;
        });
      }
    } catch (e) {
      print('❌ [DEBUG] Error checking trial eligibility: $e');
    }
  }

  Future<void> _preparePackagesIfNeeded(Offerings? offerings) async {
    final current = offerings?.current;
    if (current == null) {
      return;
    }

    // 同一个 offering 只准备一次，避免反复 setState
    if (_preparedOfferingId == current.identifier) {
      return;
    }

    final packages = current.availablePackages;
    if (packages.isEmpty) {
      return;
    }

    _preparedOfferingId = current.identifier;

    // 检查试用资格并默认选中年度包
    await _checkTrialEligibility(packages);

    final annualPackage = packages.firstWhere(
      (p) =>
          p.storeProduct.identifier.contains('yearly') ||
          p.storeProduct.identifier.contains('annual'),
      orElse: () => packages.first,
    );

    if (mounted) {
      setState(() {
        _selectedPackage = annualPackage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final offerings = subscriptionProvider.currentOffering;

    // 当新套餐加载完成时，补齐试用资格检查与默认套餐选择
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preparePackagesIfNeeded(offerings);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: offerings == null
          ? _buildLoadingOrError(context, subscriptionProvider)
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
                            _buildSubscriptionCards(offerings.current!, l10n),

                          const SizedBox(height: 24),

                          // Legal text
                          _buildLegalText(l10n),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom button section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      children: [
                        // Subscribe Button
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: _isProcessing || _selectedPackage == null
                                ? null
                                : _handlePurchase,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF6FEDD6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isProcessing
                                    ? const SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        _getButtonText(l10n),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Restore Purchases Button
                        TextButton(
                          onPressed: _isProcessing ? null : _restorePurchases,
                          child: Text(
                            l10n.restorePurchases,
                            style: const TextStyle(
                              fontSize: 16,
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
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    if (_selectedPackage == null) {
      return isChinese ? '订阅' : 'Subscribe';
    }

    final product = _selectedPackage!.storeProduct;
    final productId = product.identifier;

    print('🔍 [DEBUG] Getting button text for product: $productId');
    print('   - Has introductoryPrice: ${product.introductoryPrice != null}');
    if (product.introductoryPrice != null) {
      final intro = product.introductoryPrice!;
      print('   - Intro price: ${intro.price}');
      print('   - Intro period: ${intro.periodNumberOfUnits} ${intro.periodUnit}');
    }

    // Check trial eligibility first
    final isEligible = _isEligibleForTrial(productId);
    print('   - Is eligible for trial: $isEligible');
    print('   - Eligibility map: $_eligibilityMap');

    // Only show trial text if user is eligible AND product has trial
    if (isEligible && product.introductoryPrice != null) {
      final intro = product.introductoryPrice!;
      if (intro.periodNumberOfUnits > 0) {
        print('   ✅ Showing trial button');
        return _formatTrialCta(intro, isChinese);
      }
    }

    // For ineligible users or products without trials, show subscribe button
    print('   ⚠️ Showing regular subscribe button (no trial)');
    return isChinese ? '订阅' : 'Subscribe';
  }

  String _formatTrialCta(
    IntroductoryPrice intro,
    bool isChinese,
  ) {
    int days;
    switch (intro.periodUnit) {
      case PeriodUnit.day:
        days = intro.periodNumberOfUnits;
        break;
      case PeriodUnit.week:
        days = intro.periodNumberOfUnits * 7;
        break;
      case PeriodUnit.month:
        // 用 30 天近似，主要用于 CTA 文案
        days = intro.periodNumberOfUnits * 30;
        break;
      case PeriodUnit.year:
        days = intro.periodNumberOfUnits * 365;
        break;
      case PeriodUnit.unknown:
      default:
        days = intro.periodNumberOfUnits;
        break;
    }

    return isChinese
        ? '开始${days}天免费试用'
        : 'Start ${days}-Day Trial';
  }

  String _getBillingText(
    Package package,
    bool isAnnual,
    AppLocalizations l10n,
  ) {
    final productId = package.storeProduct.identifier;
    final isEligible = _isEligibleForTrial(productId);
    final hasTrial =
        package.storeProduct.introductoryPrice != null &&
        package.storeProduct.introductoryPrice!.periodNumberOfUnits > 0;

    // Show trial billing text only if eligible for trial
    if (isEligible && hasTrial) {
      return isAnnual
          ? l10n.billedYearlyAfterTrial
          : l10n.billedMonthlyAfterTrial;
    }

    // For ineligible users, show immediate billing text
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    return isAnnual
        ? (isChinese ? '立即按年计费' : 'Billed yearly')
        : (isChinese ? '立即按月计费' : 'Billed monthly');
  }

  bool _isEligibleForTrial(String productId) {
    final eligibility = _eligibilityMap?[productId];
    return eligibility?.status ==
        IntroEligibilityStatus.introEligibilityStatusEligible;
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    final features = [
      (
        l10n.featureMemoriesPage,
        l10n.featureMemoriesPageDesc,
        Icons.star_rounded,
      ),
      (
        l10n.dashboardMemoryLaneTitle,
        l10n.featureMemoryLaneDesc,
        Icons.star_rounded,
      ),
      (
        l10n.dashboardResellReportTitle,
        l10n.featureResellTrendsDesc,
        Icons.star_rounded,
      ),
      (
        l10n.dashboardYearlyReportsTitle,
        l10n.featureYearlyChronicleDesc,
        Icons.star_rounded,
      ),
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

  Widget _buildSubscriptionCards(Offering offering, AppLocalizations l10n) {
    final packages = offering.availablePackages;

    if (packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 48,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(height: 16),
            const Text(
              'Products Pending Approval',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF92400E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Subscription products are waiting for App Store review. They will be available once approved by Apple.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF92400E),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort packages: annual first, then monthly
    final sortedPackages = List<Package>.from(packages);
    sortedPackages.sort((a, b) {
      final aIsAnnual =
          a.storeProduct.identifier.contains('yearly') ||
          a.storeProduct.identifier.contains('annual');
      final bIsAnnual =
          b.storeProduct.identifier.contains('yearly') ||
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
        savingsPercent =
            ((annualMonthlyEquivalent - annualPrice) /
            annualMonthlyEquivalent *
            100);
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sortedPackages.take(2).map((package) {
          final product = package.storeProduct;
          final isAnnual =
              product.identifier.contains('yearly') ||
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
                margin: EdgeInsets.only(
                  left: isFirst ? 0 : 6,
                  right: isFirst ? 6 : 0,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Checkmark for selected
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Savings badge - always takes space
                        Container(
                          height: 24,
                          alignment: Alignment.centerLeft,
                          child: (isAnnual && savingsPercent != null)
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    l10n.savePercent(
                                      savingsPercent.round().toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 12),

                        // Plan name
                        Text(
                          isAnnual
                              ? l10n.annualPlan.toUpperCase()
                              : l10n.monthlyPlan.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Price
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: product.priceString.split('.')[0],
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  height: 1,
                                ),
                              ),
                              if (product.priceString.contains('.'))
                                TextSpan(
                                  text: '.${product.priceString.split('.')[1]}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              TextSpan(
                                text: isAnnual
                                    ? l10n.perYear.toUpperCase()
                                    : l10n.perMonth.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Original price - always takes space
                        Container(
                          height: 20,
                          margin: const EdgeInsets.only(top: 4),
                          alignment: Alignment.centerLeft,
                          child:
                              (isAnnual &&
                                  savingsPercent != null &&
                                  sortedPackages.length >= 2)
                              ? Text(
                                  '\$${(sortedPackages[1].storeProduct.price * 12).toStringAsFixed(2)}${l10n.perYear.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9CA3AF),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        const Spacer(),

                        // Billing info
                        Text(
                          _getBillingText(package, isAnnual, l10n),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegalText(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.changePlansAnytime,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.subscriptionTerms,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await SubscriptionService.purchasePackage(_selectedPackage!);
      if (!mounted) return;

      if (mounted) {
        // Refresh subscription status
        await Provider.of<SubscriptionProvider>(
          context,
          listen: false,
        ).refreshSubscriptionStatus();
        if (!mounted) return;

        // Get trial period info
        final product = _selectedPackage!.storeProduct;
        final hasTrialPeriod =
            product.introductoryPrice != null &&
            product.introductoryPrice!.periodNumberOfUnits > 0;

        if (hasTrialPeriod) {
          if (!mounted) return;
          final trialDays = product.introductoryPrice!.periodNumberOfUnits;
          final isChinese = Localizations.localeOf(
            context,
          ).languageCode.toLowerCase().startsWith('zh');

          // Show trial notification dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5ECFB8), Color(0xFFB794F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isChinese ? '试用已开始！' : 'Trial Started!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isChinese
                        ? '您的 $trialDays 天免费试用已激活！'
                        : 'Your $trialDays-day free trial is now active!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFF59E0B),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isChinese
                                ? '试用期结束后，将自动从您的账户扣款。您可以随时取消订阅。'
                                : 'After the trial period, you will be charged. You can cancel anytime.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    isChinese ? '知道了' : 'Got it',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5ECFB8),
                    ),
                  ),
                ),
              ],
            ),
          );
          if (!mounted) return;
        } else {
          // Show regular success message for non-trial purchases
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.subscriptionSuccess),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }

        // Wait a moment for state to propagate
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        // Close paywall
        Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (!mounted) return;
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Purchase failed'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
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
      if (!mounted) return;

      if (mounted) {
        final hasActiveEntitlement =
            customerInfo.entitlements.active.isNotEmpty;

        // Refresh subscription status
        await Provider.of<SubscriptionProvider>(
          context,
          listen: false,
        ).refreshSubscriptionStatus();
        if (!mounted) return;

        // Check premium status after refresh
        final provider = Provider.of<SubscriptionProvider>(
          context,
          listen: false,
        );

        if (hasActiveEntitlement || provider.isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.paywallRestoreSuccess),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.paywallRestoreFailure),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
          return;
        }

        // Close paywall if premium now
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

  Widget _buildLoadingOrError(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    return SafeArea(
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.errorMessage != null) ...[
                      // Error state
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6FEDD6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Unable to load subscription options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            provider.refreshOfferings();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6FEDD6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.refresh_rounded, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Try Again',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Loading state
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      const Text(
                        'Loading subscription options...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
