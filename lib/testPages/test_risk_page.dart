import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/risk_state.dart';

class TestRiskPage extends StatelessWidget {
  TestRiskPage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Risk Test'),
      ),
      body: StreamBuilder<RiskState>(
        stream: _firestoreService.getRiskState('chennai'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No risk data available'),
            );
          }

          final risk = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('District: ${risk.districtId}'),
                Text('Current Risk: ${risk.currentRisk}'),
                Text('Predicted Risk: ${risk.predictedRisk}'),
                Text('Current Radius: ${risk.currentRadius} m'),
                Text('Predicted Radius: ${risk.predictedRadius} m'),
                Text('Prediction Window: ${risk.predictionWindow} hrs'),
                const SizedBox(height: 12),
                Text('Updated At: ${risk.updatedAt}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
