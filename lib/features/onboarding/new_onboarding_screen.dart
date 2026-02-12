import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/features/auth/welcome_page.dart';
import 'package:keepjoy_app/widgets/glass_container.dart';
import 'package:keepjoy_app/widgets/gradient_button.dart';

class NewOnboardingScreen extends StatefulWidget {
  const NewOnboardingScreen({super.key});

  @override
  State<NewOnboardingScreen> createState() => _NewOnboardingScreenState();
}

class _NewOnboardingScreenState extends State<NewOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Define the 3 Feature Slides (Indices 1, 2, 3)
    // Grouping: Reset (3 features), Value (2 features), Heart (1 feature)
    final featureSlides = [
      _SlideData(
        title: l10n.onboardingPage1Title, // Decision Support
        description: l10n.onboardingPage1Desc,
        icon: Icons.auto_awesome_rounded, 
        features: [
          _RichFeature(Icons.auto_fix_high_rounded, l10n.onboardingPage1Feat1, l10n.onboardingPage1Feat1Desc), // Quick
          _RichFeature(Icons.psychology_rounded, l10n.onboardingPage1Feat2, l10n.onboardingPage1Feat2Desc), // Joy
          _RichFeature(Icons.cleaning_services_rounded, l10n.onboardingPage1Feat3, l10n.onboardingPage1Feat3Desc), // Clean Sweep
        ],
      ),
      _SlideData(
        title: l10n.onboardingPage2Title, // Total Control
        description: l10n.onboardingPage2Desc,
        icon: Icons.inventory_2_outlined,
        features: [
          _RichFeature(Icons.analytics_rounded, l10n.onboardingPage2Feat1, l10n.onboardingPage2Feat1Desc), // Items/Stats
          _RichFeature(Icons.payments_rounded, l10n.onboardingPage2Feat2, l10n.onboardingPage2Feat2Desc), // Resell
        ],
      ),
      _SlideData(
        title: l10n.onboardingPage3Title, // Your Safety Net
        description: l10n.onboardingPage3Desc,
        icon: Icons.favorite_outline_rounded,
        features: [
          _RichFeature(Icons.auto_stories_rounded, l10n.onboardingPage3Feat1, l10n.onboardingPage3Feat1Desc), // Memories
        ],
      ),
    ];

    final totalPages = 1 + featureSlides.length; // Intro + 3 Feature Slides

    return Scaffold(
      body: Stack(
        children: [
          // Background - Subtle, high-end gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFCFCFD),
                  Color(0xFFF9FAFB),
                  Color(0xFFF3F4F6),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalPages,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _IntroSlide();
                      }
                      return _FeatureSlide(data: featureSlides[index - 1]);
                    },
                  ),
                ),

                // Indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 32 : 8,
                        decoration: BoxDecoration(
                          color: isActive 
                              ? const Color(0xFF111827)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // Primary Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: GradientButton(
                    onPressed: () {
                      if (_currentPage < totalPages - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.fastOutSlowIn,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      _currentPage == totalPages - 1
                          ? l10n.getStarted
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroSlide extends StatefulWidget {
  const _IntroSlide();

  @override
  State<_IntroSlide> createState() => _IntroSlideState();
}

class _IntroSlideState extends State<_IntroSlide> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // Text animations
  late Animation<double> _fadeQ1;
  late Animation<double> _fadeQ2;
  late Animation<double> _fadeQ3;
  late Animation<double> _fadeSolution;
  
  // Floating box animations (10 boxes for richer chaos)
  late List<Animation<double>> _boxFadeIn;
  late List<Animation<double>> _boxFadeOut;
  late List<Animation<Offset>> _boxDrift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    
    // Text timeline (starts as chaos peak ends)
    _fadeQ1 = CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.55, curve: Curves.easeOut));
    _fadeQ2 = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.75, curve: Curves.easeOut));
    _fadeQ3 = CurvedAnimation(parent: _controller, curve: const Interval(0.8, 0.95, curve: Curves.easeOut));
    _fadeSolution = CurvedAnimation(parent: _controller, curve: const Interval(0.9, 1.0, curve: Curves.easeOut));

    // Box timeline (starts early, fades when Q1 appears)
    _boxFadeIn = List.generate(10, (i) {
      double start = 0.0 + (i * 0.04); // Rapid pop up
      double end = start + 0.1;
      return CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic));
    });

    _boxFadeOut = List.generate(10, (i) {
      // Sync fade start with Q1 appearance
      return CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.6, curve: Curves.easeIn));
    });

    _boxDrift = List.generate(10, (i) {
      return Tween<Offset>(
        begin: Offset.zero,
        end: Offset(i % 2 == 0 ? 30.0 : -30.0, -50.0),
      ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.linear)));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Abstract, designer-curated positions to avoid central overlap
    final boxesData = [
      _BoxData(l10n.onboardingPainProcrastination, const Offset(0.08, 0.12), 1.2),
      _BoxData(l10n.onboardingPainSunkCost, const Offset(0.68, 0.08), 1.0),
      _BoxData(l10n.onboardingPainNoTime, const Offset(0.05, 0.45), 1.4),
      _BoxData(l10n.onboardingPainSunkShort, const Offset(0.72, 0.42), 0.9),
      _BoxData(l10n.onboardingPainTooManyMemories, const Offset(0.12, 0.68), 1.1),
      _BoxData(l10n.onboardingPainParalysis, const Offset(0.65, 0.62), 1.3),
      _BoxData(l10n.onboardingPainStartWhere, const Offset(0.35, 0.05), 0.8),
      _BoxData(l10n.onboardingPainSentimental, const Offset(0.42, 0.78), 1.0),
      _BoxData(l10n.onboardingPainMaybeTomorrow, const Offset(0.02, 0.32), 1.1),
      _BoxData(l10n.onboardingPainTooMuchMess, const Offset(0.78, 0.28), 0.9),
    ];

    return Stack(
      children: [
        // Floating Boxes (Designer Modular Layout)
        ...List.generate(boxesData.length, (i) {
          final data = boxesData[i];
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width * data.pos.dx + _boxDrift[i].value.dx,
                top: MediaQuery.of(context).size.height * data.pos.dy + _boxDrift[i].value.dy,
                child: child!,
              );
            },
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_boxFadeOut[i]),
              child: ScaleTransition(
                scale: _boxFadeIn[i],
                child: _FloatingPainBox(
                  text: data.text,
                  widthScale: data.widthScale,
                  opacity: 0.2 + (i % 3 * 0.1), // Varied subtle opacity
                ),
              ),
            ),
          );
        }),

        // Clear Narrative Text
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeQ1,
                  child: Text(
                    l10n.onboardingIntroQ1,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF9CA3AF),
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeQ2,
                  child: Text(
                    l10n.onboardingIntroQ2,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeQ3,
                  child: Text(
                    l10n.onboardingIntroQ3,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _fadeSolution,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    color: Colors.white, 
                    blur: 30,
                    borderRadius: BorderRadius.circular(24),
                    borderWidth: 1.0,
                    child: Text(
                      l10n.onboardingIntroSolution,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingPainBox extends StatelessWidget {
  final String text;
  final double widthScale;
  final double opacity;

  const _FloatingPainBox({
    required this.text, 
    this.widthScale = 1.0,
    this.opacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * widthScale, 
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(8), // Geometric modular look
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280).withOpacity(0.7),
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _BoxData {
  final String text;
  final Offset pos;
  final double widthScale;

  _BoxData(this.text, this.pos, this.widthScale);
}

class _FeatureSlide extends StatelessWidget {
  final _SlideData data;

  const _FeatureSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(data.icon, size: 40, color: const Color(0xFF111827)),
          ),
          const SizedBox(height: 24),
          
          // Headline
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          
          // Narrative "Why"
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Rich Feature Cards - Variable count
          ...data.features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildRichFeatureCard(context, feature),
          )),
        ],
      ),
    );
  }

  Widget _buildRichFeatureCard(BuildContext context, _RichFeature feature) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      color: Colors.white.withOpacity(0.6),
      blur: 20,
      borderWidth: 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              feature.icon,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String description;
  final IconData icon;
  final List<_RichFeature> features;

  _SlideData({
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
  });
}

class _RichFeature {
  final IconData icon;
  final String title;
  final String description;

  _RichFeature(this.icon, this.title, this.description);
}
