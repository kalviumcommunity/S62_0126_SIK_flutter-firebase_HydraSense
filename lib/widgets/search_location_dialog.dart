import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';

Future<Map<String, dynamic>?> showSearchLocationDialog(
    BuildContext context) {
  final controller = TextEditingController();
  final locationService = LocationService();

  List<Map<String, dynamic>> suggestions = [];
  Timer? debounce;

  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Search Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// 🔎 Search field
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Search apartment, landmark, city',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      if (debounce?.isActive ?? false) debounce!.cancel();

                      debounce =
                          Timer(const Duration(milliseconds: 350), () async {
                        final result =
                            await locationService.getPlaceSuggestions(value);

                        setState(() {
                          suggestions = result;
                        });
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// 📋 Suggestions
                  if (suggestions.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final item = suggestions[index];
                          return ListTile(
                            dense: true,
                            leading:
                                const Icon(Icons.location_on_outlined),
                            title: Text(
                              item['display'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context, {
                                'lat': item['lat'],
                                'lon': item['lon'],
                              });
                            },
                          );
                        },
                      ),
                    ),

                  if (suggestions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Start typing to see suggestions',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}