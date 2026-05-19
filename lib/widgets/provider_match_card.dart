import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProviderMatchCard extends StatelessWidget {
  const ProviderMatchCard({
    super.key,
    required this.provider,
    required this.onBook,
    required this.onReject,
    this.booked = false,
  });

  final Map<String, dynamic> provider;
  final VoidCallback? onBook;
  final VoidCallback? onReject;
  final bool booked;

  @override
  Widget build(BuildContext context) {
    final name = provider['name'] as String? ?? 'Provider';
    final rating = provider['rating'] ?? '4.8';
    final distance = provider['distanceKm'] ?? '?';
    final price = provider['priceEstimatePkr'] ?? provider['basePrice'] ?? '—';
    final slots = provider['availableSlots'] as List?;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBlueLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: booked ? kGoldenBeige : kBorder, width: booked ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booked ? 'Request sent' : 'Labour available',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: booked ? kGoldenBeige : kText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kText)),
          const SizedBox(height: 4),
          Text('⭐ $rating • ${distance}km', style: const TextStyle(color: kTextMuted, fontSize: 12)),
          if (slots != null && slots.isNotEmpty)
            Text(
              'Slots: ${slots.join(', ')}',
              style: const TextStyle(color: kTextMuted, fontSize: 11),
            ),
          const SizedBox(height: 4),
          Text(
            'Est. ~$price PKR',
            style: const TextStyle(color: kGoldenBeige, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          if (!booked) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGoldenBeige,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Book now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Another', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Waiting for provider to accept…',
                style: TextStyle(fontSize: 12, color: kGoldenBeige, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
