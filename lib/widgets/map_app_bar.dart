import 'package:flutter/material.dart';

class MapAppBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onMyLocationTap;
  final VoidCallback onRiskPanelToggle;
  final bool showPanel;

  const MapAppBar({
    super.key,
    required this.onSearchTap,
    required this.onMyLocationTap,
    required this.onRiskPanelToggle,
    required this.showPanel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildLogo(),
            const Spacer(),
            _actionButton(
              icon: showPanel ? Icons.visibility_off : Icons.visibility,
              onTap: onRiskPanelToggle,
              tooltip: 'Toggle Risk Panel',
            ),
            const SizedBox(width: 8),
            _actionButton(
              icon: Icons.search,
              onTap: onSearchTap,
              tooltip: 'Search Location',
            ),
            const SizedBox(width: 8),
            _actionButton(
              icon: Icons.my_location,
              onTap: onMyLocationTap,
              tooltip: 'My Location',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF007AFF).withValues(alpha: 0.9),
            const Color(0xFF5856D6).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(
            Icons.water_damage,
            color: Colors.white,
            size: 22,
          ),
          SizedBox(width: 8),
          Text(
            'HydraSense',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF007AFF),
            size: 22,
          ),
        ),
      ),
    );
  }
}
