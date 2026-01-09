import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/services/shiprocket_service.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingEvent> events;

  const TrackingTimeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = context.isTablet ? 48.0 : 40.0;
    final iconSize = context.isTablet ? 24.0 : 20.0;
    final statusFontSize = context.fontSize(14, minSize: 12, maxSize: 16);
    final detailFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    final lineHeight = context.isTablet ? 60.0 : 50.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Text(
            "Tracking History",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: defaultPadding),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final isLast = index == events.length - 1;
            final isFirst = index == 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline dot and line
                  Column(
                    children: [
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFirst
                              ? const Color(0xFF219A00)
                              : Colors.grey.shade300,
                          border: Border.all(
                            color: isFirst
                                ? const Color(0xFF219A00)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getStatusIcon(event.status),
                          color:
                              isFirst ? Colors.white : Colors.grey.shade600,
                          size: iconSize,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: lineHeight,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: defaultPadding),
                  // Event details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: statusFontSize,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (event.location != null)
                            Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: detailFontSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (event.remarks != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                event.remarks!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatTime(event.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'order confirmed':
        return Icons.check_circle;
      case 'picked up':
        return Icons.local_shipping;
      case 'in transit':
        return Icons.directions_run;
      case 'out for delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.local_shipping;
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }
}
