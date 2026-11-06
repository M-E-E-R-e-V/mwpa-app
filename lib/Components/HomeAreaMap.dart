import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilTileServer.dart';
import 'package:provider/provider.dart';

/// HomeAreaMap - small, fixed map of the home area (polygon) with the
/// current position; shows where the tour starts and ends automatically.
class HomeAreaMap extends StatelessWidget {
  final List<UtilLocationDouble> homeArea;
  final double height;

  const HomeAreaMap({super.key, required this.homeArea, this.height = 180});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = [for (final p in homeArea) LatLng(p.lat, p.lon)];
    final position = context.watch<LocationController>().currentPosition;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints(points),
                  padding: const EdgeInsets.all(24),
                ),
                // only a picture: the page scrolls over it
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: UtilTileServer.openStreetMapUrlTemplate,
                  userAgentPackageName: UtilTileServer.userAgentPackageName,
                ),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: points,
                      color: Colors.blue.withValues(alpha: 0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                if (position != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(position.latitude, position.longitude),
                        width: 22,
                        height: 22,
                        child: const Icon(Icons.my_location, color: Colors.red, size: 22),
                      ),
                    ],
                  ),
              ],
            ),
            // OSM credit (attribution guidelines)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
