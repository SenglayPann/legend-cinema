import 'package:flutter/material.dart';
import '../../data/models/cinema_model.dart';

class CinemaSelectorDialog extends StatelessWidget {
  final List<CinemaModel> cinemas;
  final String currentSelection;
  final Function(String) onSelected;

  const CinemaSelectorDialog({
    super.key,
    required this.cinemas,
    required this.currentSelection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select a Cinema",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: cinemas.length + 1,
              itemBuilder: (_, i) {
                final isAllCinemas = i == 0;
                final cinemaName = isAllCinemas
                    ? "All Cinemas"
                    : cinemas[i - 1].name;
                final isSelected = cinemaName == currentSelection;

                return GestureDetector(
                  onTap: () {
                    onSelected(cinemaName);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.red.withOpacity(0.2)
                          : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.red, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cinemaName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: Colors.red),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
