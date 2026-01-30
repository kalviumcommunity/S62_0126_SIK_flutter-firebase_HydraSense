import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';

Future<Map<String, dynamic>?> showSearchLocationDialog(
    BuildContext context) {
  final controller = TextEditingController();
  final locationService = LocationService();

  List<Map<String, dynamic>> suggestions = [];
  Timer? debounce;

  return showGeneralDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        ),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF)
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Color(0xFF007AFF),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Search Location',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_outlined,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Search city, landmark, address...',
                                      border: InputBorder.none,
                                      hintStyle:
                                          TextStyle(color: Colors.grey),
                                    ),
                                    style:
                                        const TextStyle(fontSize: 16),
                                    onChanged: (value) {
                                      debounce?.cancel();

                                      debounce = Timer(
                                        const Duration(milliseconds: 350),
                                        () async {
                                          final currentQuery = value;

                                          if (currentQuery.isEmpty) {
                                            setState(() => suggestions = []);
                                            return;
                                          }

                                          final result =
                                              await locationService.getPlaceSuggestions(currentQuery);

                                          // 🛑 Prevent old results overriding new ones
                                          if (controller.text != currentQuery) return;

                                          setState(() => suggestions = result);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (suggestions.isNotEmpty)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius:
                                const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: ListView.builder(
                            physics:
                                const BouncingScrollPhysics(),
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final item = suggestions[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    debounce?.cancel();
                                    FocusScope.of(context)
                                        .unfocus();
                                    Navigator.pop(context, {
                                      'lat': item['lat'],
                                      'lon': item['lon'],
                                    });
                                  },
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(
                                                        alpha: 0.05),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons
                                                .location_on_outlined,
                                            color:
                                                Colors.grey.shade700,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                item['display'],
                                                style:
                                                    const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color:
                                                      Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                              if (item['address'] !=
                                                  null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .only(
                                                    top: 4,
                                                  ),
                                                  child: Text(
                                                    item['address'],
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors
                                                          .grey
                                                          .shade600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color:
                                              Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else if (controller.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.explore_outlined,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for locations',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_outlined,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
