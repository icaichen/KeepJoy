import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'memory_detail_page.dart';

enum MemoryViewMode { grid, timeline }

class MemoriesPage extends StatefulWidget {
  const MemoriesPage({
    super.key,
    required this.memories,
    required this.onMemoryDeleted,
    required this.onMemoryUpdated,
    required this.onMemoryCreated,
  });

  final List<Memory> memories;
  final void Function(Memory memory) onMemoryDeleted;
  final void Function(Memory memory) onMemoryUpdated;
  final void Function(Memory memory) onMemoryCreated;

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  MemoryViewMode _viewMode = MemoryViewMode.grid;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    final memories = widget.memories;
    final topPadding = MediaQuery.of(context).padding.top;

    // Calculate scroll-based animations
    const headerHeight = 120.0;
    final scrollProgress = (_scrollOffset / headerHeight).clamp(0.0, 1.0);
    final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
    final collapsedHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;

    final pageName = l10n.memoriesTitle;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPadding + 80)),
              SliverToBoxAdapter(
                child: memories.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - topPadding - 80,
                        child: _EmptyMemoriesState(),
                      )
                    : _viewMode == MemoryViewMode.grid
                        ? _GridViewWrapper(memories: memories)
                        : _TimelineView(memories: memories, isChinese: isChinese),
              ),
            ],
          ),

          // Collapsed header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: collapsedHeaderOpacity < 0.5,
              child: Opacity(
                opacity: collapsedHeaderOpacity,
                child: Container(
                  height: topPadding + kToolbarHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F6F7),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E5EA),
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(top: topPadding),
                  alignment: Alignment.center,
                  child: Text(
                    pageName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Original header with view mode toggle
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 16,
                  top: topPadding + 12,
                ),
                child: Opacity(
                  opacity: headerOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pageName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                      // View mode toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _buildViewModeButton(
                              icon: Icons.grid_view_rounded,
                              mode: MemoryViewMode.grid,
                              isSelected: _viewMode == MemoryViewMode.grid,
                            ),
                            const SizedBox(width: 4),
                            _buildViewModeButton(
                              icon: Icons.timeline_rounded,
                              mode: MemoryViewMode.timeline,
                              isSelected: _viewMode == MemoryViewMode.timeline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required MemoryViewMode mode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF1C1C1E) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

// Grid View (Original Photo Wall Style)
class _GridView extends StatelessWidget {
  final List<Memory> memories;

  const _GridView({required this.memories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return _MemoryGridItem(memory: memory);
      },
    );
  }
}

// Wrapper for GridView to work with CustomScrollView
class _GridViewWrapper extends StatelessWidget {
  final List<Memory> memories;

  const _GridViewWrapper({required this.memories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return _MemoryGridItem(memory: memory);
      },
    );
  }
}

class _MemoryGridItem extends StatelessWidget {
  const _MemoryGridItem({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMemoryDetail(context),
      child: memory.hasPhoto
          ? Image.file(memory.photoFile!, fit: BoxFit.cover)
          : Container(
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  memory.type.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
    );
  }

  void _openMemoryDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MemoryDetailPage(memory: memory)),
    );
  }
}

// Timeline View with Dotted Line
class _TimelineView extends StatelessWidget {
  final List<Memory> memories;
  final bool isChinese;

  const _TimelineView({required this.memories, required this.isChinese});

  @override
  Widget build(BuildContext context) {
    // Sort memories by date (newest first)
    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Group memories by date
    final groupedMemories = <String, List<Memory>>{};
    for (final memory in sortedMemories) {
      final dateKey = DateFormat('yyyy-MM-dd').format(memory.createdAt);
      groupedMemories.putIfAbsent(dateKey, () => []).add(memory);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: groupedMemories.entries.map((entry) {
          final index = groupedMemories.keys.toList().indexOf(entry.key);
          final dateKey = entry.key;
          final dateMemories = entry.value;
          final date = DateTime.parse(dateKey);
          final isLast = index == groupedMemories.length - 1;

          return _TimelineDateSection(
            date: date,
            memories: dateMemories,
            isChinese: isChinese,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineDateSection extends StatelessWidget {
  final DateTime date;
  final List<Memory> memories;
  final bool isChinese;
  final bool isLast;

  const _TimelineDateSection({
    required this.date,
    required this.memories,
    required this.isChinese,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = isChinese
        ? DateFormat('yyyy年M月d日', 'zh_CN').format(date)
        : DateFormat('MMMM d, yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(left: 50, bottom: 16, top: 8),
          child: Text(
            dateLabel,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        // Memories for this date
        ...memories.asMap().entries.map((entry) {
          final isLastMemory = entry.key == memories.length - 1 && isLast;
          return _TimelineMemoryItem(
            memory: entry.value,
            showLine: !isLastMemory,
          );
        }),
      ],
    );
  }
}

class _TimelineMemoryItem extends StatelessWidget {
  final Memory memory;
  final bool showLine;

  const _TimelineMemoryItem({
    required this.memory,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line with dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: _getTypeColor(memory.type),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getTypeColor(memory.type).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Vertical dotted line
                if (showLine)
                  Expanded(
                    child: CustomPaint(
                      painter: _DottedLinePainter(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Memory card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MemoryDetailPage(memory: memory),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EA)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(memory.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Memory type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(memory.type).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                memory.type.icon,
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                memory.type.label(context),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(memory.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Photo if present
                    if (memory.hasPhoto) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          memory.photoFile!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Item name if present
                    if (memory.itemName != null && memory.itemName!.isNotEmpty) ...[
                      Text(
                        memory.itemName!,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Memory story
                    if (memory.story.isNotEmpty)
                      Text(
                        memory.story,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(MemoryType type) {
    switch (type) {
      case MemoryType.decluttering:
        return const Color(0xFF5ECFB8);
      case MemoryType.cleaning:
        return const Color(0xFF89CFF0);
      case MemoryType.custom:
        return const Color(0xFFB794F6);
      case MemoryType.grateful:
        return const Color(0xFFFF9AA2);
      case MemoryType.lesson:
        return const Color(0xFF89CFF0);
      case MemoryType.celebrate:
        return const Color(0xFFFFD93D);
    }
  }
}

// Custom painter for dotted line
class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) => false;
}

class _EmptyMemoriesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.memoriesEmptyTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isChinese
                  ? '开始整理你的物品，\n创建美好的回忆吧'
                  : 'Start decluttering to create\nbeautiful memories',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
