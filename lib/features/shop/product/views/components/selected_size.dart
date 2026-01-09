import 'package:flutter/material.dart';

import '../../../../constants.dart';

class SelectedSize extends StatelessWidget {
  const SelectedSize({
    super.key,
    required this.sizes,
    required this.selectedIndex,
    required this.press,
    this.availableIndices,
  });

  final List<String> sizes;
  final int selectedIndex;
  final ValueChanged<int> press;
  final List<int>? availableIndices;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Select Size",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Row(
          children: List.generate(
            sizes.length,
            (index) {
              final isAvailable = availableIndices == null || availableIndices!.contains(index);
              return Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? defaultPadding : defaultPadding / 2),
                child: SizeButton(
                  text: sizes[index],
                  isActive: selectedIndex == index,
                  isAvailable: isAvailable,
                  press: () => press(index),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class SizeButton extends StatelessWidget {
  const SizeButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.press,
    this.isAvailable = true,
  });

  final String text;
  final bool isActive;
  final VoidCallback press;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    // Check if text is too long (like "FREE_SIZE", "FREE SIZE", etc.)
    final isLongText = text.length > 3;
    
    return SizedBox(
      height: 40,
      width: isLongText ? null : 40, // Dynamic width for long text
      child: OutlinedButton(
        onPressed: isAvailable ? press : null,
        style: OutlinedButton.styleFrom(
          padding: isLongText 
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              : EdgeInsets.zero,
          shape: isLongText
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )
              : const CircleBorder(),
          side: isActive 
              ? const BorderSide(color: primaryColor) 
              : (!isAvailable 
                  ? BorderSide(color: Colors.grey.shade300) 
                  : null),
          backgroundColor: !isAvailable ? Colors.grey.shade100 : null,
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: isLongText ? 11 : 14, // Smaller font for long text
            color: !isAvailable
                ? Colors.grey.shade400
                : (isActive
                    ? primaryColor
                    : Theme.of(context).textTheme.bodyLarge!.color),
            decoration: !isAvailable ? TextDecoration.lineThrough : null,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
