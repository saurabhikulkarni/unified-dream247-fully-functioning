import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';

/// Expandable description widget with View More/View Less functionality
class ExpandableDescriptionWidget extends StatefulWidget {
  final String description;
  final int maxLines;
  final TextStyle? textStyle;

  const ExpandableDescriptionWidget({
    super.key,
    required this.description,
    this.maxLines = 3,
    this.textStyle,
  });

  @override
  State<ExpandableDescriptionWidget> createState() => _ExpandableDescriptionWidgetState();
}

class _ExpandableDescriptionWidgetState extends State<ExpandableDescriptionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product info",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: defaultPadding / 2),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.description,
                maxLines: _isExpanded ? null : widget.maxLines,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: widget.textStyle ?? const TextStyle(height: 1.4),
              ),
              if (!_isExpanded && _shouldShowViewMore())
                const SizedBox(height: defaultPadding / 4),
            ],
          ),
        ),
        if (_shouldShowViewMore())
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding / 4),
              child: Text(
                _isExpanded ? 'View Less' : 'View More',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        const SizedBox(height: defaultPadding / 2),
      ],
    );
  }

  /// Check if description is long enough to need View More button
  bool _shouldShowViewMore() {
    // Count newlines to estimate if text exceeds max lines
    final lineCount = '\n'.allMatches(widget.description).length + 1;
    return lineCount > widget.maxLines || widget.description.length > 150;
  }
}
