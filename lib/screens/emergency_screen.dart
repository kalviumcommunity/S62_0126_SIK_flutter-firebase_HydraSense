import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'checklist_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // Function to make phone calls - SIMPLIFIED VERSION
  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final url = Uri.parse('tel:$phoneNumber');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Show error if can't launch
        _showError(context, 'Cannot make call to $phoneNumber');
      }
    } catch (e) {
      _showError(context, 'Error: ${e.toString()}');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 Emergency Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade900,
                      const Color.fromARGB(255, 100, 0, 0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMERGENCY MODE',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Flood emergency detected in your area',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🚨 IMMEDIATE ACTIONS (OFFLINE-FIRST)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'IMMEDIATE SAFETY ACTIONS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildEmergencyCard(
                      icon: Icons.arrow_upward_rounded,
                      title: 'Move to Higher Ground',
                      description: 'Get to the highest floor or elevation immediately.',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildEmergencyCard(
                      icon: Icons.directions_walk,
                      title: 'Avoid Flood Water',
                      description: 'Do NOT walk or drive through flood water. It may be contaminated or have hidden dangers.',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildEmergencyCard(
                      icon: Icons.power_off_rounded,
                      title: 'Stay Away from Electricity',
                      description: 'Avoid electrical equipment and downed power lines. Water conducts electricity.',
                      color: Colors.yellow.shade700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 📞 EMERGENCY CALLS (ONE-TAP) - UPDATED
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'EMERGENCY CONTACTS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildCallButton(
                      number: '108',
                      label: 'National Disaster Response',
                      description: 'Primary emergency number for floods',
                      color: Colors.red,
                      context: context,
                    ),
                    const SizedBox(height: 12),
                    _buildCallButton(
                      number: '101',
                      label: 'Fire & Rescue Services',
                      description: 'For trapped persons or fire emergencies',
                      color: Colors.orange,
                      context: context,
                    ),
                    const SizedBox(height: 12),
                    _buildCallButton(
                      number: '100',
                      label: 'Police Emergency',
                      description: 'For law enforcement assistance',
                      color: Colors.blue,
                      context: context,
                    ),
                    const SizedBox(height: 12),
                    _buildCallButton(
                      number: '102',
                      label: 'Medical Ambulance',
                      description: 'For medical emergencies',
                      color: Colors.green,
                      context: context,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🏠 NEARBY SAFE LOCATIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'NEARBY SHELTERS & SAFE ZONES',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Online Services Unavailable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'During network outages, proceed to known high ground:\n• Local schools\n• Government buildings\n• Multi-story buildings\n• Designated flood shelters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Divider(color: Colors.white30),
                          const SizedBox(height: 10),
                          const Text(
                            '⚠️ IMPORTANT:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'If you cannot reach emergency services, help neighbors if safe, and wait for rescue teams.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 🔄 Regular Safety Checklist Link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChecklistScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue.withOpacity(0.2),
                      border: Border.all(color: Colors.blue.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rounded, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'View Full Safety Checklist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for emergency action cards
  Widget _buildEmergencyCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for call buttons - SIMPLIFIED
  Widget _buildCallButton({
    required String number,
    required String label,
    required String description,
    required Color color,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => _makePhoneCall(number, context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color.withOpacity(0.2),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.3),
              ),
              child: const Icon(Icons.phone, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}