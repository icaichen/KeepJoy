import 'package:flutter/foundation.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final offerings = context.read<SubscriptionProvider>().currentOffering;
    if (offerings != null) {
      Future.microtask(() => _preparePackagesIfNeeded(offerings));
    }
  }

  Future<void> _checkTrialEligibility(List<Package> packages) async {
    try {
      // Get product identifiers
      final productIds = packages
          .map((p) => p.storeProduct.identifier)
          .toList();

      debugPrint(
        '🔍 [DEBUG] Checking trial eligibility for products: $productIds',
      );

      // Check eligibility for all products
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);

      debugPrint('🔍 [DEBUG] Trial eligibility result: $eligibility');

      // Log each product's eligibility status
      eligibility.forEach((productId, status) {
        debugPrint('🔍 [DEBUG] Product: $productId');
        debugPrint('   - Status: ${status.status}');
        debugPrint('   - Description: ${status.description}');
      });

      if (mounted) {
        setState(() {
          _eligibilityMap = eligibility;
        });
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Error checking trial eligibility: $e');
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

    // 检查试用资格并默认选中年付（其次月付、终身）
    await _checkTrialEligibility(packages);

    Package? annualPackage;
    Package? monthlyPackage;
    Package? annualTrialPackage;
    Package? monthlyTrialPackage;
    Package? lifetimePackage;
    for (final package in packages) {
      if (_isAnnualPackage(package)) {
        annualPackage ??= package;
        if (_hasTrialPhase(package)) {
          annualTrialPackage ??= package;
        }
      } else if (_isMonthlyPackage(package)) {
        monthlyPackage ??= package;
        if (_hasTrialPhase(package)) {
          monthlyTrialPackage ??= package;
        }
      } else if (_isLifetimePackage(package)) {
        lifetimePackage ??= package;
      }
    }
    final defaultPackage = defaultTargetPlatform == TargetPlatform.android
        ? (annualTrialPackage ??
              monthlyTrialPackage ??
              annualPackage ??
              monthlyPackage ??
              lifetimePackage ??
              packages.first)
        : (annualPackage ??
              monthlyPackage ??
              lifetimePackage ??
              packages.first);

    if (mounted) {
      setState(() {
        _selectedPackage = defaultPackage;
      });
    }
  }

  bool _isAnnualPackage(Package package) {
    final productId = package.storeProduct.identifier.toLowerCase();
    return package.packageType == PackageType.annual ||
        productId.contains('yearly') ||
        productId.contains('annual');
  }

  bool _isMonthlyPackage(Package package) {
    final productId = package.storeProduct.identifier.toLowerCase();
    return package.packageType == PackageType.monthly ||
        productId.contains('monthly') ||
        productId.contains('month');
  }

  bool _isLifetimePackage(Package package) {
    final productId = package.storeProduct.identifier.toLowerCase();
    final packageId = package.identifier.toLowerCase();
    return package.packageType == PackageType.lifetime ||
        productId.contains('lifetime') ||
        productId.contains('forever') ||
        productId.contains('one_time') ||
        productId.contains('onetime') ||
        packageId.contains('lifetime') ||
        packageId.contains('forever');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final offerings = subscriptionProvider.currentOffering;

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
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isProcessing || _selectedPackage == null
                                ? null
                                : _handlePurchase,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
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
                                borderRadius: BorderRadius.circular(27),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isProcessing
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
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
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
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
    if (_isLifetimePackage(_selectedPackage!)) {
      return isChinese ? '解锁终身版' : 'Unlock Lifetime';
    }

    debugPrint('🔍 [DEBUG] Getting button text for product: $productId');
    debugPrint(
      '   - Has introductoryPrice: ${product.introductoryPrice != null}',
    );
    if (product.introductoryPrice != null) {
      final intro = product.introductoryPrice!;
      debugPrint('   - Intro price: ${intro.price}');
      debugPrint(
        '   - Intro period: ${intro.periodNumberOfUnits} ${intro.periodUnit}',
      );
    }

    // Check trial eligibility first
    final isEligible = _isEligibleForTrial(productId);
    debugPrint('   - Is eligible for trial: $isEligible');
    debugPrint('   - Eligibility map: $_eligibilityMap');

    final shouldShowTrial = _shouldShowTrialCta(_selectedPackage!);
    final trialDays = _getTrialDays(_selectedPackage!);
    if (shouldShowTrial) {
      debugPrint('   ✅ Showing trial button');
      if (trialDays != null && trialDays > 0) {
        return isChinese ? '开始$trialDays天免费试用' : 'Start $trialDays-Day Trial';
      }
      return isChinese ? '开始免费试用' : 'Start Free Trial';
    }

    // For ineligible users or products without trials, show subscribe button
    debugPrint('   ⚠️ Showing regular subscribe button (no trial)');
    return isChinese ? '订阅' : 'Subscribe';
  }

  String _getBillingText(Package package, AppLocalizations l10n) {
    final isAnnual = _isAnnualPackage(package);
    final isLifetime = _isLifetimePackage(package);
    final productId = package.storeProduct.identifier;
    final isEligible = _isEligibleForTrial(productId);
    final hasTrial = _hasTrialPhase(package);

    // Show trial billing text only if eligible for trial (iOS)
    if (isEligible && hasTrial) {
      return isAnnual
          ? l10n.billedYearlyAfterTrial
          : l10n.billedMonthlyAfterTrial;
    }

    // For ineligible users, show immediate billing text
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    if (isLifetime) {
      return isChinese
          ? '一次性付款，永久解锁全部高级功能'
          : 'One-time payment, lifetime premium access';
    }
    if (defaultTargetPlatform == TargetPlatform.android && hasTrial) {
      return isChinese
          ? (isAnnual ? '试用资格将在结算页确认，之后按年计费' : '试用资格将在结算页确认，之后按月计费')
          : (isAnnual
                ? 'Trial eligibility confirmed at checkout, then billed yearly'
                : 'Trial eligibility confirmed at checkout, then billed monthly');
    }
    return isAnnual
        ? (isChinese ? '立即按年计费' : 'Billed yearly')
        : (isChinese ? '立即按月计费' : 'Billed monthly');
  }

  bool _hasTrialPhase(Package package) {
    if (_isLifetimePackage(package)) return false;
    final intro = package.storeProduct.introductoryPrice;
    final hasIntro = intro != null && intro.periodNumberOfUnits > 0;
    final hasAndroidTrialPeriod = _getAndroidTrialPeriod(package) != null;
    return hasIntro || hasAndroidTrialPeriod;
  }

  bool _shouldShowTrialCta(Package package) {
    if (!_hasTrialPhase(package)) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      // RevenueCat Android intro eligibility is always "unknown",
      // so we rely on configured free trial phase instead.
      return true;
    }
    return _isEligibleForTrial(package.storeProduct.identifier);
  }

  int? _getTrialDays(Package package) {
    final intro = package.storeProduct.introductoryPrice;
    if (intro != null && intro.periodNumberOfUnits > 0) {
      return _periodToDays(intro.periodUnit, intro.periodNumberOfUnits);
    }

    final period = _getAndroidTrialPeriod(package);
    if (period == null || period.value <= 0) {
      return null;
    }
    return _periodToDays(period.unit, period.value);
  }

  Period? _getAndroidTrialPeriod(Package package) {
    final product = package.storeProduct;
    final options = <SubscriptionOption>[
      if (product.defaultOption != null) product.defaultOption!,
      ...?product.subscriptionOptions,
    ];

    for (final option in options) {
      final freePeriod = option.freePhase?.billingPeriod;
      if (freePeriod != null && freePeriod.value > 0) {
        return freePeriod;
      }

      final intro = option.introPhase;
      if (intro != null &&
          intro.price.amountMicros == 0 &&
          intro.billingPeriod != null &&
          intro.billingPeriod!.value > 0) {
        return intro.billingPeriod;
      }

      for (final phase in option.pricingPhases) {
        final phasePeriod = phase.billingPeriod;
        if (phasePeriod == null || phasePeriod.value <= 0) {
          continue;
        }
        final isFreeTrialMode =
            phase.offerPaymentMode == OfferPaymentMode.freeTrial;
        final isFreeByPrice = phase.price.amountMicros == 0;
        if (isFreeTrialMode || isFreeByPrice) {
          return phasePeriod;
        }
      }
    }
    return null;
  }

  int _periodToDays(PeriodUnit unit, int value) {
    switch (unit) {
      case PeriodUnit.day:
        return value;
      case PeriodUnit.week:
        return value * 7;
      case PeriodUnit.month:
        return value * 30;
      case PeriodUnit.year:
        return value * 365;
      case PeriodUnit.unknown:
        return value;
    }
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

    // Sort packages: annual -> lifetime -> monthly -> others
    final sortedPackages = List<Package>.from(packages);
    sortedPackages.sort((a, b) {
      int rank(Package package) {
        if (_isAnnualPackage(package)) return 0;
        if (_isLifetimePackage(package)) return 1;
        if (_isMonthlyPackage(package)) return 2;
        return 3;
      }

      final rankDiff = rank(a).compareTo(rank(b));
      if (rankDiff != 0) return rankDiff;
      return 0;
    });

    // Calculate savings if both annual and monthly exist
    double? savingsPercent;
    Package? annualPackage;
    Package? monthlyPackage;
    for (final package in sortedPackages) {
      if (annualPackage == null && _isAnnualPackage(package)) {
        annualPackage = package;
      }
      if (monthlyPackage == null && _isMonthlyPackage(package)) {
        monthlyPackage = package;
      }
    }
    if (annualPackage != null && monthlyPackage != null) {
      final annualPrice = annualPackage.storeProduct.price;
      final monthlyPrice = monthlyPackage.storeProduct.price;
      if (monthlyPrice > 0) {
        final annualMonthlyEquivalent = monthlyPrice * 12;
        savingsPercent =
            ((annualMonthlyEquivalent - annualPrice) /
                    annualMonthlyEquivalent *
                    100)
                .clamp(0, 100);
      }
    }

    Widget buildCard(Package package, {required bool showSavingsBadge}) {
      final product = package.storeProduct;
      final isAnnual = _isAnnualPackage(package);
      final isLifetime = _isLifetimePackage(package);
      final isSelected = _selectedPackage?.identifier == package.identifier;
      final isChinese = Localizations.localeOf(
        context,
      ).languageCode.toLowerCase().startsWith('zh');
      final periodLabel = isLifetime
          ? (isChinese ? '一次性' : 'one-time')
          : (isAnnual
                ? (isChinese ? '/年' : '/yr')
                : (isChinese ? '/月' : '/mo'));
      final planName = isLifetime
          ? (isChinese ? '终身方案' : 'LIFETIME')
          : (isAnnual
                ? l10n.annualPlan.toUpperCase()
                : l10n.monthlyPlan.toUpperCase());

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedPackage = package;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          planName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (showSavingsBadge && savingsPercent != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F8F0),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.savePercent(
                                savingsPercent.round().toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            product.priceString,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          periodLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBillingText(package, l10n),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    final displayedPackages = sortedPackages.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < displayedPackages.length; i++) ...[
          buildCard(
            displayedPackages[i],
            showSavingsBadge: _isAnnualPackage(displayedPackages[i]),
          ),
          if (i != displayedPackages.length - 1) const SizedBox(height: 10),
        ],
      ],
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
          final isChinese = Localizations.localeOf(
            context,
          ).languageCode.toLowerCase().startsWith('zh');
          final isLifetimePurchase = _isLifetimePackage(_selectedPackage!);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isLifetimePurchase
                    ? (isChinese ? '终身版已解锁！' : 'Lifetime unlocked!')
                    : AppLocalizations.of(context)!.subscriptionSuccess,
              ),
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
              content: Text(
                AppLocalizations.of(context)!.paywallRestoreSuccess,
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.paywallRestoreFailure,
              ),
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
