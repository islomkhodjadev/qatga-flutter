import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:boyshub/models/places/place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:boyshub/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:boyshub/providers/language_provider.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Try fallback: open in browser (for web links)
        final browserLaunched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        if (!browserLaunched) {
          debugPrint('Could NOT launch $url');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open: $url')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening: $url')),
      );
    }
  }

  void _openMap(BuildContext context, double latitude, double longitude, {String? placeUrl}) {
    print(placeUrl);
    final url = (placeUrl != null && placeUrl.isNotEmpty)
        ? placeUrl
        : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    _launchUrl(context, url);
  }


  String _extractHandle(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
      return url;
    } catch (e) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).lang;

    final labels = {
      'photos': {
        'uz': "RASMLAR",
        'ru': "ФОТО",
        'en': "PHOTOS",
      },
      'map': {
        'uz': "XARITA",
        'ru': "КАРТА",
        'en': "MAP",
      },
      'details': {
        'uz': "TO'LIQ MA'LUMOT",
        'ru': "ПОДРОБНОСТИ",
        'en': "DETAILS",
      },
      'openMap': {
        'uz': "Xaritadan ochish",
        'ru': "Открыть на карте",
        'en': "Open in map",
      },
      'contacts': {
        'uz': "KONTAKTLAR",
        'ru': "КОНТАКТЫ",
        'en': "CONTACTS",
      },
      'telegram': {
        'uz': "Telegram",
        'ru': "Телеграм",
        'en': "Telegram",
      },
      'instagram': {
        'uz': "Instagram",
        'ru': "Инстаграм",
        'en': "Instagram",
      },
      'services': {
        'uz': "XIZMATLAR",
        'ru': "УСЛУГИ",
        'en': "SERVICES",
      },
      'amenities': {
        'uz': "QULAYLIKLAR",
        'ru': "УДОБСТВА",
        'en': "AMENITIES",
      },
      'sum': {
        'uz': "so'm",
        'ru': "сум",
        'en': "sum",
      },
      'openingHours': {
        'uz': "ISH VAQTI",
        'ru': "ВРЕМЯ РАБОТЫ",
        'en': "OPENING HOURS",
      },
      'alwaysOpen': {
        'uz': "24/7 OCHIQ",
        'ru': "ОТКРЫТО 24/7",
        'en': "OPEN 24/7",
      },
      'fromTo': {
        'uz': "{from} dan {to} gacha",
        'ru': "с {from} до {to}",
        'en': "From {from} to {to}",
      }

    };

    TextStyle sectionStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.blueAccent,
      letterSpacing: 1.2,
    );

    return Scaffold(
      appBar: MyAppBar(title: place.getName(lang)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- PHOTOS SECTION ---
          if (place.images.isNotEmpty) ...[
            Text(labels['photos']![lang] ?? labels['photos']!['uz']!, style: sectionStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: place.images.length,
                itemBuilder: (context, index) {
                  // Sort images to show primary first
                  final sortedImages = List.from(place.images)
                    ..sort((a, b) => (b.is_primary ? 1 : 0).compareTo(a.is_primary ? 1 : 0));
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      sortedImages[index].url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
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
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // --- MAP SECTION ---
          Text(labels['map']![lang] ?? labels['map']!['uz']!, style: sectionStyle),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(place.latitude, place.longitude),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(place.latitude, place.longitude),
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- DETAILS SECTION ---
          Text(labels['details']![lang] ?? labels['details']!['uz']!, style: sectionStyle),
          const SizedBox(height: 8),
          Text(place.getName(lang), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(place.getDescription(lang), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          const SizedBox(height: 8),
          Text(labels['openingHours']![lang] ?? 'OPENING HOURS', style: sectionStyle),
          const SizedBox(height: 4),
          Text(
            place.openingTime == place.closingTime
                ? labels['alwaysOpen']![lang] ?? '24/7 OPEN'
                : (labels['fromTo']![lang] ?? 'From {from} to {to}')
                .replaceFirst('{from}', place.openingTime)
                .replaceFirst('{to}', place.closingTime),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // --- AMENITIES SECTION ---
          if (place.amenities.isNotEmpty) ...[
            Text(labels['amenities']![lang] ?? labels['amenities']!['uz']!, style: sectionStyle),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: place.amenities.map((amenity) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(amenity.getName(lang)),
                  subtitle: amenity.getDescription(lang).isNotEmpty
                      ? Text(amenity.getDescription(lang))
                      : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // --- MAP BUTTON SECTION ---
          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: Text(labels['openMap']![lang] ?? labels['openMap']!['uz']!),
            onPressed: () => _openMap(context, place.latitude, place.longitude,placeUrl: place.address_url),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // --- CONTACTS SECTION ---
          Text(labels['contacts']![lang] ?? labels['contacts']!['uz']!, style: sectionStyle),
          const SizedBox(height: 8),
          if (place.phoneNumber.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text(place.phoneNumber),
                onTap: () => _launchUrl(context, 'tel:${place.phoneNumber}'),
              ),
            ),
          if (place.telegram?.isNotEmpty ?? false)
            Card(
              child: ListTile(
                leading: const Icon(Icons.send, color: Colors.blueAccent),
                title: Text(
                  '${labels['telegram']![lang] ?? 'Telegram'}',
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onTap: () => _launchUrl(context, place.telegram!),
              ),
            ),

          if (place.instagram?.isNotEmpty ?? false)
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.purple),
                title: Text(
                  '${labels['instagram']![lang] ?? 'Instagram'}',
                  style: const TextStyle(
                    color: Colors.purple,
                  ),
                ),
                onTap: () => _launchUrl(context, place.instagram!),
              ),
            ),

          // --- SERVICES SECTION ---
          if (place.services.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(labels['services']![lang] ?? labels['services']!['uz']!, style: sectionStyle),
            const SizedBox(height: 8),
            ...place.services.map((service) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(service.name),
                trailing: Text('${service.price} ${labels['sum']![lang] ?? "so\'m"}'),
              ),
            )),
          ],
        ],
      ),
    );
  }
}
