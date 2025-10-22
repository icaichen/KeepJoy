import 'dart:async';
import 'package:flutter/material.dart';

import 'features/quick_declutter/quick_declutter_flow.dart';
import 'utils/localization.dart';

void main() {
  runApp(const KeepJoyApp());
}

class KeepJoyApp extends StatefulWidget {
  const KeepJoyApp({super.key});

  @override
  State<KeepJoyApp> createState() => _KeepJoyAppState();
}

class _KeepJoyAppState extends State<KeepJoyApp> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  int _index = 0;
  _QuickSweepSession? _activeQuickSweep;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _DashboardScreen(
        onQuickSweepTap: _openQuickSweepSelection,
        onQuickDeclutterTap: _openQuickDeclutterFlow,
        activeQuickSweep: _activeQuickSweep,
        onResumeQuickSweep: _openQuickSweepTimer,
      ),
      const _ItemsScreen(),
      const _MemoriesScreen(),
      const _InsightsScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KeepJoy',
      theme: _theme,
      navigatorKey: _navKey,
      home: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              label: 'Items',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              label: 'Memories',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              label: 'Insights',
            ),
          ],
          onDestinationSelected: (i) => setState(() => _index = i),
        ),
      ),
    );
  }

  void _openQuickSweepSelection() async {
    final navigator = _navKey.currentState;
    if (navigator == null) return;
    final area = await navigator.push<String>(
      MaterialPageRoute(builder: (_) => const _QuickSweepAreaPage()),
    );
    if (!mounted) return;
    if (area != null && area.isNotEmpty) {
      _startQuickSweep(area);
      _openQuickSweepTimer();
    }
  }

  void _startQuickSweep(String area) {
    setState(() {
      _activeQuickSweep = _QuickSweepSession(
        area: area,
        startedAt: DateTime.now(),
      );
    });
  }

  void _openQuickSweepTimer() {
    final navigator = _navKey.currentState;
    final session = _activeQuickSweep;
    if (navigator == null || session == null) return;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => _QuickSweepTimerPage(
          session: session,
          onStop: _completeQuickSweep,
          onMinimize: () => navigator.popUntil((route) => route.isFirst),
        ),
      ),
    );
  }

  void _completeQuickSweep() {
    final navigator = _navKey.currentState;
    setState(() {
      _activeQuickSweep = null;
    });
    navigator?.popUntil((route) => route.isFirst);
  }

  void _openQuickDeclutterFlow() async {
    final navigator = _navKey.currentState;
    if (navigator == null) return;
    final ctx = navigator.context;
    final useChinese = isChineseLocale(ctx);
    final messenger = ScaffoldMessenger.of(ctx);
    final items = await navigator.push<List<QuickDeclutterItem>>(
      MaterialPageRoute(builder: (_) => const QuickDeclutterFlowPage()),
    );
    if (!navigator.mounted) return;
    if (items != null && items.isNotEmpty) {
      final message = useChinese
          ? '已通过快速整理添加${items.length}件物品。'
          : 'Added ${items.length} item(s) via Quick Declutter.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

// Theme matching the soft “KeepJoy” palette from the screenshot
const _headerPurple = Color(0xFF5C4B63);
const _softSurface = Color(0xFFF2EFEB);
const _cardSurface = Colors.white;
const _textInk = Color(0xFF42424A);

class _Quote {
  const _Quote({required this.en, required this.zh});
  final String en;
  final String zh;
}

const _dailyQuotes = <_Quote>[
  _Quote(en: 'Let go with gratitude.', zh: '带着感恩放手。'),
  _Quote(en: 'Joy thrives in tidy spaces.', zh: '喜悦在整洁空间绽放。'),
  _Quote(en: 'Love what you keep, thank what you release.', zh: '珍爱留下的，感谢放下的。'),
  _Quote(en: 'Clear clutter, awaken calm.', zh: '清理杂物，唤醒平静。'),
  _Quote(en: 'Choose items that spark a brighter today.', zh: '选择点亮今天的物品。'),
  _Quote(en: 'Honor memories, cherish the present.', zh: '尊重回忆，珍惜当下。'),
  _Quote(
    en: 'A joyful home begins with one mindful choice.',
    zh: '喜悦之家源于每个用心选择。',
  ),
  _Quote(en: 'Release to invite new blessings.', zh: '放手让祝福有空间。'),
];

String _quoteForToday(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context);
  final language = locale?.languageCode.toLowerCase();
  final epoch = DateTime(2020, 1, 1);
  final days = DateTime.now().difference(epoch).inDays;
  final quote = _dailyQuotes[days % _dailyQuotes.length];
  if (language == 'zh' || language == 'zh-hans' || language == 'zh-hant') {
    return quote.zh;
  }
  return quote.en;
}

final _theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _headerPurple,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: _softSurface,
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.w700, color: _textInk),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, color: _textInk),
    bodyMedium: TextStyle(color: _textInk),
  ),
  cardTheme: CardThemeData(
    color: _cardSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    elevation: 0.5,
    margin: EdgeInsets.zero,
  ),
);

class _QuickSweepSession {
  _QuickSweepSession({required this.area, required this.startedAt});

  final String area;
  final DateTime startedAt;
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen({
    required this.onQuickSweepTap,
    required this.onQuickDeclutterTap,
    this.activeQuickSweep,
    this.onResumeQuickSweep,
  });

  final VoidCallback onQuickSweepTap;
  final VoidCallback onQuickDeclutterTap;
  final _QuickSweepSession? activeQuickSweep;
  final VoidCallback? onResumeQuickSweep;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Header background
          Container(height: 140, color: _headerPurple),
          // Content
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const _DashboardHeader(),
              const SizedBox(height: 16),
              const _GreetingCard(),
              if (activeQuickSweep != null) ...[
                const SizedBox(height: 12),
                _ActiveSweepBanner(
                  session: activeQuickSweep!,
                  onResume: onResumeQuickSweep,
                ),
              ],
              const SizedBox(height: 20),
              const _SectionTitle('Core Modules'),
              const SizedBox(height: 12),
              _CoreModulesRow(
                onQuickSweepTap: onQuickSweepTap,
                onQuickDeclutterTap: onQuickDeclutterTap,
              ),
              const SizedBox(height: 20),
              const _MemoriesHeader(),
              const SizedBox(height: 12),
              const _MemoryPreviewCard(),
              const SizedBox(height: 16),
              const _KpiCardsRow(),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'KeepJoy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(28 * 8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.person_outline, color: Colors.white)],
          ),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final quote = _quoteForToday(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: const Color(0xFFFBEADF),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Evening',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quote,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                _RoundIcon(const Icon(Icons.event_note, color: _textInk)),
                const SizedBox(height: 12),
                _RoundIcon(const Icon(Icons.edit_outlined, color: _textInk)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSweepBanner extends StatelessWidget {
  const _ActiveSweepBanner({required this.session, this.onResume});

  final _QuickSweepSession session;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final timeOfDay = TimeOfDay.fromDateTime(session.startedAt);
    final startedLabel = timeOfDay.format(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFFE8F6ED),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Quick Sweep',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Area: ${session.area} • Started $startedLabel'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onResume,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF35A86B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Resume'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _CoreModulesRow extends StatelessWidget {
  const _CoreModulesRow({
    required this.onQuickSweepTap,
    required this.onQuickDeclutterTap,
  });
  final VoidCallback onQuickSweepTap;
  final VoidCallback onQuickDeclutterTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModuleTile(
            color: const Color(0xFFE2F2E5),
            icon: Icons.eco_outlined,
            title: 'Quick\nDeclutter',
            onTap: onQuickDeclutterTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModuleTile(
            color: const Color(0xFFE3EDFF),
            icon: Icons.schedule_outlined,
            title: 'Quick\nSweep',
            onTap: onQuickSweepTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModuleTile(
            color: const Color(0xFFFFF4C8),
            icon: Icons.inventory_2_outlined,
            title: 'Joy\nDeclutter',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _textInk),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoriesHeader extends StatelessWidget {
  const _MemoriesHeader();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _SectionTitle('Joyful Memories'),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chevron_right, size: 18, color: _textInk),
          label: const Text('View All', style: TextStyle(color: _textInk)),
          style: TextButton.styleFrom(foregroundColor: _textInk),
        ),
      ],
    );
  }
}

class _MemoryPreviewCard extends StatelessWidget {
  const _MemoryPreviewCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundImage: null,
              child: Icon(Icons.photo, color: _textInk),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'A wonderful sunny day spent with Momo at the park',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCardsRow extends StatelessWidget {
  const _KpiCardsRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(
          child: _StatCard(
            title: "This Month's Progress",
            lines: ['Items let go: 15', 'Sessions: 4', 'Space freed: 2.5 m²'],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Second-hand Tracker',
            lines: ['Selling: 1 | Sold: 1', 'Income: ¥850'],
            trailingLink: 'View Details',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.lines,
    this.trailingLink,
  });
  final String title;
  final List<String> lines;
  final String? trailingLink;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final line in lines) ...[
              Text(line),
              const SizedBox(height: 6),
            ],
            if (trailingLink != null)
              TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailingLink!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_right_alt),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon(this.icon);
  final Widget icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: icon,
    );
  }
}

class _QuickSweepAreaPage extends StatelessWidget {
  const _QuickSweepAreaPage();

  static const _areas = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Home Office',
    'Garage',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick an area')),
      body: ListView(
        children: [
          for (final area in _areas)
            ListTile(
              title: Text(area),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(area),
            ),
          ListTile(
            title: const Text('Custom area…'),
            leading: const Icon(Icons.add),
            onTap: () async {
              final controller = TextEditingController();
              final custom = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Name your area'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Entryway closet',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(context).pop(text);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (custom != null && custom.isNotEmpty) {
                if (!context.mounted) return;
                Navigator.of(context).pop(custom.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _QuickSweepTimerPage extends StatefulWidget {
  const _QuickSweepTimerPage({
    required this.session,
    required this.onStop,
    required this.onMinimize,
  });

  final _QuickSweepSession session;
  final VoidCallback onStop;
  final VoidCallback onMinimize;

  @override
  State<_QuickSweepTimerPage> createState() => _QuickSweepTimerPageState();
}

class _QuickSweepTimerPageState extends State<_QuickSweepTimerPage> {
  late Duration _elapsed;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration.zero;
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _updateElapsed();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateElapsed(),
    );
  }

  void _updateElapsed() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.session.startedAt);
    });
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes % 60;
    final seconds = value.inSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Sweep'),
        actions: [
          TextButton(
            onPressed: widget.onMinimize,
            child: const Text('Minimize'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              widget.session.area,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _formatDuration(_elapsed),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onStop,
                    icon: const Icon(Icons.flag_outlined),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF6A6A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    label: const Text('Complete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onMinimize,
                    icon: const Icon(Icons.remove),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    label: const Text('Minimize'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsScreen extends StatelessWidget {
  const _ItemsScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderTab(title: 'Items');
}

class _MemoriesScreen extends StatelessWidget {
  const _MemoriesScreen();
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderTab(title: 'Memories');
}

class _InsightsScreen extends StatelessWidget {
  const _InsightsScreen();
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderTab(title: 'Insights');
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          '$title — coming next',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
