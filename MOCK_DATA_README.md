# Mock Data for Insights Testing

## Overview
Mock data service has been created to generate test data for insights reports without affecting real user data.

## Files Created
1. `lib/services/mock_data_service.dart` - Service for generating and clearing mock data
2. `lib/features/insights/developer_tools_dialog.dart` - UI dialog for developer tools

## How to Add Developer Tools Button

Add the following code in `insights_screen.dart` before the "Monthly Achievement Card" section (around line 286):

```dart
// Developer Tools Button
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: GestureDetector(
    onTap: () async {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const DeveloperToolsDialog(),
      );
      // Reload page if data was changed
      if (result == true && mounted) {
        setState(() {});
      }
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B4E71), Color(0xFF95E3C6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.developer_mode,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChinese ? '开发者工具' : 'Developer Tools',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isChinese ? '生成测试数据' : 'Generate mock data',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.white,
          ),
        ],
      ),
    ),
  ),
),
const SizedBox(height: 20),
```

## What the Mock Data Service Generates

### Declutter Items (50 items)
- Random categories (Clothes, Books, Papers, etc.)
- Random joy levels (70% have joy, 1-10 scale)
- Random statuses (resell, donate, recycle, discard)
- Distributed over last 6 months

### Deep Cleaning Sessions (20 sessions)
- Random areas (Living Room, Bedroom, Kitchen, etc.)
- Random durations (30min - 2hours)
- Random messiness index improvements
- Random focus index (5-10)
- Distributed over last 3 months

### Resell Items (auto-generated from declutter items)
- Created for items with status "resell"
- 60% sold with realistic prices
- 20% currently listing
- 20% to sell
- Random days to sell (1-45 days)

## How to Use

1. Open the Insights page
2. Tap on "Developer Tools" card
3. Click "Generate" to create mock data
4. View the generated insights reports
5. Click "Clear Mock Data" when done testing

## Features

### Safe Data Identification
- All mock data is marked with `[MOCK_DATA]` prefix
- IDs start with `mock_` prefix
- Can be easily filtered out

### One-Click Cleanup
- Clear button removes ALL mock data
- Uses database queries to find and delete
- Won't affect real user data

## Notes
- Mock data is tied to the current user account
- Generating multiple times will create duplicate data
- Remember to clear before generating new batch
- The reports will show mixed real + mock data

## Example Use Cases
1. **Testing Reports**: Generate data to see how reports look with content
2. **Demo Screenshots**: Create sample data for app store screenshots
3. **Development**: Test new features with realistic data
4. **QA Testing**: Verify calculations and visualizations
