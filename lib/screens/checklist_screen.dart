import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1E3C),
              Color(0xFF0F2B4A),
              Color(0xFF123258),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔝 Sticky Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E3C).withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Flood Safety Checklist',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stay Prepared • Stay Safe',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF0099FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF00D4FF).withOpacity(0.1),
                                border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
                              ),
                              child: const Text(
                                'COMPLETE GUIDE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D4FF),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Flood Preparedness Checklist',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Essential steps organized in clear sections. Tap emergency numbers to call immediately.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // BEFORE FLOOD SECTION
                      _buildChecklistSection(
                        icon: Icons.shield_rounded,
                        iconColor: const Color(0xFF00D4FF),
                        title: 'BEFORE FLOOD',
                        subtitle: 'Preparation Phase',
                        items: [
                          ChecklistItem(
                            text: 'Prepare emergency kit with food, water, and first aid',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Charge all devices and power banks',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Move important documents to higher ground',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Know evacuation routes and shelter locations',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Install HydraSense for early warnings',
                            isCompleted: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // DURING FLOOD SECTION
                      _buildChecklistSection(
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFFFA502),
                        title: 'DURING FLOOD',
                        subtitle: 'Immediate Actions',
                        items: [
                          ChecklistItem(
                            text: 'Move to higher ground immediately',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Avoid walking or driving through flood water',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Stay away from electrical equipment',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Do not enter flooded buildings',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Follow official instructions',
                            isCompleted: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // EMERGENCY CONTACTS SECTION
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF4757).withOpacity(0.15),
                              const Color(0xFFFF4757).withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFF4757).withOpacity(0.1),
                                    border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
                                  ),
                                  child: const Icon(
                                    Icons.emergency_rounded,
                                    color: Color(0xFFFF4757),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EMERGENCY CONTACTS',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap to call immediately',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ..._buildEmergencyContacts(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // AFTER FLOOD SECTION
                      _buildChecklistSection(
                        icon: Icons.medical_services_rounded,
                        iconColor: const Color(0xFF2ED573),
                        title: 'AFTER FLOOD',
                        subtitle: 'Recovery Steps',
                        items: [
                          ChecklistItem(
                            text: 'Return only when authorities say it\'s safe',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Check for structural damage first',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Avoid contaminated flood water',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Document damage for insurance',
                            isCompleted: false,
                          ),
                          ChecklistItem(
                            text: 'Help neighbors if safe',
                            isCompleted: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 📌 Important Note
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFA502).withOpacity(0.1),
                                    border: Border.all(color: const Color(0xFFFFA502).withOpacity(0.3)),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFFFFA502),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Important Note',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This checklist works offline. Save a screenshot or write down important numbers. Tap the checkboxes to mark completed items.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
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

  Widget _buildChecklistSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<ChecklistItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withOpacity(0.1),
            iconColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.1),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map((item) => _buildChecklistItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              item.isCompleted = !item.isCompleted;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: item.isCompleted
                        ? const Color(0xFF2ED573)
                        : Colors.transparent,
                    border: Border.all(
                      color: item.isCompleted
                          ? const Color(0xFF2ED573)
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: item.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: item.isCompleted
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white,
                      height: 1.5,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildEmergencyContacts() {
    final contacts = [
      {'name': 'National Disaster Response', 'number': '108'},
      {'name': 'Fire & Rescue', 'number': '101'},
      {'name': 'Police Emergency', 'number': '100'},
      {'name': 'Medical Emergency', 'number': '102'},
      {'name': 'Local Flood Helpline', 'number': '1098'},
    ];

    return contacts.map((contact) {
      return GestureDetector(
        onTap: () => _launchPhoneDialer(contact['number']!),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF4757).withOpacity(0.2),
                      const Color(0xFFFF4757).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone_rounded,
                    color: Color(0xFFFF4757),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact['number']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFF4757).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFFF4757).withOpacity(0.3)),
                ),
                child: const Text(
                  'CALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4757),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class ChecklistItem {
  String text;
  bool isCompleted;

  ChecklistItem({
    required this.text,
    required this.isCompleted,
  });
}