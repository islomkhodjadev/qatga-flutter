import 'package:flutter/material.dart';
import 'package:boyshub/models/places/place_model.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).lang;

    String? imageUrl;
    if (place.images.isNotEmpty) {
      try {
        imageUrl = place.images.first.url;
        if (imageUrl.startsWith('/')) {
          // Uncomment and adjust for local dev if needed:
          // imageUrl = 'http://10.0.2.2:8000$imageUrl';
        }
      } catch (e) {}
    }

    // Localized static labels
    final labels = {
      'name': {
        'uz': "Joy nomi",
        'ru': "Название",
        'en': "Place name",
      },
      'address': {
        'uz': "Manzil",
        'ru': "Адрес",
        'en': "Address",
      },
      'amenities': {
        'uz': "Qulayliklar",
        'ru': "Удобства",
        'en': "Amenities",
      }
    };

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              height: 150,
              width: double.infinity,
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            // Place Info Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place Name Label
                  Text(
                    labels['name']![lang] ?? labels['name']!['uz']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    place.getName(lang),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  // Address Label
                  Text(
                    labels['address']![lang] ?? labels['address']!['uz']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.getAddress(lang),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Amenities Label
                  Text(
                    labels['amenities']![lang] ?? labels['amenities']!['uz']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: place.amenities
                        .take(3)
                        .map((amenity) => Chip(
                      label: Text(amenity.getName(lang)),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
