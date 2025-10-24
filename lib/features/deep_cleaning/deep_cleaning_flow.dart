import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class DeepCleaningFlowPage extends StatefulWidget {
  const DeepCleaningFlowPage({super.key});

  @override
  State<DeepCleaningFlowPage> createState() => _DeepCleaningFlowPageState();
}

class _DeepCleaningFlowPageState extends State<DeepCleaningFlowPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deepCleaningTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Spacer(),
            // Section with 6 circles and input
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    // First row - 3 circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircle(screenWidth),
                        _buildCircle(screenWidth),
                        _buildCircle(screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Second row - 3 circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircle(screenWidth),
                        _buildCircle(screenWidth),
                        _buildCircle(screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Input area under all 6 circles
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(l10n.continueButton),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double screenWidth) {
    return Container(
      width: screenWidth * 0.2,
      height: screenWidth * 0.2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
    );
  }
}
