import 'package:flutter/material.dart';
import '../../../../utils/responsive_utils.dart';
import 'report_ui_constants.dart';

class ReportPageScaffold extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Color> headerGradient;
  final List<Widget> children;
  final Widget? floatingActionButton;

  const ReportPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerGradient,
    required this.children,
    this.floatingActionButton,
  });

  @override
  State<ReportPageScaffold> createState() => _ReportPageScaffoldState();
}

class _ReportPageScaffoldState extends State<ReportPageScaffold> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final horizontalPadding = responsive.horizontalPadding;
    final headerHeight = responsive.totalTwoLineHeaderHeight + 24;
    final topPadding = responsive.safeAreaPadding.top;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: ReportUI.backgroundColor,
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                // Parallax/Gradient background
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: widget.headerGradient,
                      stops: const [0.0, 0.4, 0.7],
                    ),
                  ),
                ),
                // Content on top
                Column(
                  children: [
                    // Large Banner Title
                    SizedBox(
                      height: headerHeight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: topPadding + 44,
                          bottom: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: ReportTextStyles.screenTitle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subtitle,
                              style: ReportTextStyles.screenSubtitle,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Sections
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [
                          ...widget.children.map((child) => Padding(
                                padding: const EdgeInsets.only(bottom: ReportUI.sectionGap),
                                child: child,
                              )),
                          const SizedBox(height: 32), // Bottom safe area gap
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sticky Top AppBar that fades in on scroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final threshold = headerHeight - 64;
                final scrollProgress = (scrollOffset / threshold).clamp(0.0, 1.0);
                
                return IgnorePointer(
                  ignoring: scrollProgress < 0.5,
                  child: Opacity(
                    opacity: scrollProgress,
                    child: Container(
                      height: responsive.collapsedHeaderHeight,
                      padding: EdgeInsets.only(top: topPadding),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Back button
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: Colors.black87),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          // Centered Title
                          Center(
                            child: Text(
                              widget.title,
                              style: ReportTextStyles.sectionHeader.copyWith(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Always visible Back button when not scrolled
          Positioned(
            top: topPadding + 6,
            left: 12,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final opacity = (1.0 - (scrollOffset / 30.0)).clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: IgnorePointer(
                    ignoring: opacity < 0.1,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
