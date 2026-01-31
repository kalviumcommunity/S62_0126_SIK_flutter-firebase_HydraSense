import 'package:flutter/material.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 6, 70, 100),
              Color.fromARGB(255, 20, 120, 180),
              Color.fromARGB(255, 2, 25, 40),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔝 Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Safety Checklist',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📝 Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Flood Preparedness Guide',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha:0.95),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Essential steps to stay safe',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha:0.7),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 📋 Checklist Items (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // BEFORE FLOOD SECTION
                      _buildSection(
                        title: '🛡️ BEFORE Flood (Preparation)',
                        items: [
                          'Prepare an emergency kit with food, water, and first aid',
                          'Charge all mobile devices and power banks',
                          'Move important documents to higher ground',
                          'Know your evacuation routes and shelter locations',
                          'Install the HydraSense app for early warnings',
                        ],
                        color: Colors.blue.withValues(alpha:0.2),
                      ),

                      const SizedBox(height: 25),

                      // DURING FLOOD SECTION
                      _buildSection(
                        title: '⚠️ DURING Flood (Immediate Action)',
                        items: [
                          'Move to higher ground immediately',
                          'Avoid walking or driving through flood water',
                          'Stay away from electrical equipment and poles',
                          'Do not enter flooded buildings',
                          'Follow official instructions from authorities',
                        ],
                        color: Colors.orange.withOpacity(0.2),
                      ),

                      const SizedBox(height: 25),

                      // EMERGENCY CONTACTS SECTION
                      _buildSection(
                        title: '📞 Emergency Contacts',
                        items: [
                          'National Disaster Response: 108',
                          'Fire & Rescue: 101',
                          'Police: 100',
                          'Medical Emergency: 102',
                          'Local Flood Helpline: Check local authorities',
                        ],
                        color: Colors.red.withOpacity(0.2),
                      ),

                      const SizedBox(height: 25),

                      // AFTER FLOOD SECTION
                      _buildSection(
                        title: '🩹 AFTER Flood (Recovery)',
                        items: [
                          'Return home only when authorities say it\'s safe',
                          'Check for structural damage before entering',
                          'Avoid flood water (may be contaminated)',
                          'Document damage for insurance claims',
                          'Help neighbors if it\'s safe to do so',
                        ],
                        color: Colors.green.withOpacity(0.2),
                      ),

                      const SizedBox(height: 40),

                      // ⚠️ Important Note
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info, color: Colors.yellow),
                                const SizedBox(width: 10),
                                const Text(
                                  'Important Note',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'This checklist works offline. Save a screenshot or write down important numbers. Your safety comes first!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for each section
  Widget _buildSection({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3, right: 12),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}