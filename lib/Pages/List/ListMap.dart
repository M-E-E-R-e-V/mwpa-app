import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:mwpaapp/Util/UtilTileServer.dart';
import 'package:provider/provider.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// ListMap - map with the home area, the sightings of the list and the
/// current GPS position (flutter_map, works on Android and iOS).
///
/// The map follows the GPS position until the user pans/zooms by hand; the
/// "My Location" button switches following back on.
///
/// The map fills the whole widget; [top] and [bottom] float above it (e.g.
/// the tour card and the quick actions). Empty space between them passes the
/// gestures through to the map.
class ListMap extends StatefulWidget {
  final Widget? top;
  final Widget? bottom;

  const ListMap({super.key, this.top, this.bottom});

  @override
  State<ListMap> createState() => _ListMapState();
}

class _ListMapState extends State<ListMap> {
  late final LocationController _locationController = context.read<LocationController>();
  late final SightingController _sightingController = context.read<SightingController>();

  static const double _defaultZoom = 14;

  final MapController _mapController = MapController();
  bool _mapReady = false;
  bool _followPosition = true;

  /// false until the map was zoomed in on the first GPS fix
  bool _zoomedToPosition = false;

  @override
  void initState() {
    super.initState();
    _locationController.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _locationController.removeListener(_onLocationChanged);
    _mapController.dispose();
    super.dispose();
  }

  LatLng? _currentLatLng() {
    final position = _locationController.currentPosition;

    if (position == null) {
      return null;
    }

    return LatLng(position.latitude, position.longitude);
  }

  void _onLocationChanged() {
    final latLng = _currentLatLng();

    if (!_mapReady || !_followPosition || latLng == null) {
      return;
    }

    // first fix: zoom in from the world view, afterwards keep the user's zoom
    final zoom = _zoomedToPosition ? _mapController.camera.zoom : _defaultZoom;
    _zoomedToPosition = true;
    _mapController.move(latLng, zoom);
  }

  void _gotoDefault() {
    setState(() => _followPosition = true);

    final latLng = _currentLatLng();

    if (_mapReady && latLng != null) {
      _zoomedToPosition = true;
      _mapController.move(latLng, _defaultZoom);
    }
  }

  Marker _buildMarker(LatLng point, Color color, [IconData icon = Icons.location_on]) {
    return Marker(
      point: point,
      width: 24,
      height: 24,
      child: Icon(icon, color: color, size: 24),
    );
  }

  List<Marker> _sightingMarkers() {
    final markers = <Marker>[];

    for (var sighting in _sightingController.sightingList) {
      if (sighting.location_begin == null) {
        continue;
      }

      try {
        Position tPos = Position.fromMap(jsonDecode(sighting.location_begin!));

        markers.add(_buildMarker(
          LatLng(tPos.latitude, tPos.longitude),
          sighting.validateColor(),
        ));
      } catch (locExcept) {
        AppLog.w('Map', 'location not readable', locExcept);
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_locationController, _sightingController]),
      builder: (context, _) {
        final position = _locationController.currentPosition;
        final currentLatLng = _currentLatLng();
        final homeArea = _locationController.homeArea;

        return Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLatLng ?? const LatLng(0, 0),
                  initialZoom: currentLatLng == null ? 2 : _defaultZoom,
                  minZoom: 2,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapReady: () {
                    _mapReady = true;
                    _onLocationChanged();
                  },
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture && _followPosition) {
                      setState(() => _followPosition = false);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: UtilTileServer.openStreetMapUrlTemplate,
                    userAgentPackageName: UtilTileServer.userAgentPackageName,
                  ),

                  // Home Area Polygon -------------------------------------------
                  if (homeArea.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: homeArea.map((l) => LatLng(l.lat, l.lon)).toList(),
                          color: Colors.blue.withValues(alpha: 0.3),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),

                  // sighting + current position markers -------------------------
                  MarkerLayer(
                    markers: [
                      ..._sightingMarkers(),
                      if (currentLatLng != null)
                        _buildMarker(currentLatLng, Colors.red, Icons.my_location),
                    ],
                  ),
                ],
              ),

              // overlays ------------------------------------------------------
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.top != null) widget.top!,
                      const SizedBox(height: 8),
                      const Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _MapPill(child: Text('© OpenStreetMap contributors')),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: _MapPill(
                              child: Text(
                                position == null
                                    ? context.l10n.mapWaitForGps
                                    : context.l10n.mapPositionPoints(
                                        UtilPosition.getStr(position), _locationController.positionCount),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton(
                            heroTag: null,
                            onPressed: _gotoDefault,
                            tooltip: context.l10n.myLocation,
                            backgroundColor: kButtonBackgroundColor,
                            foregroundColor: kButtonFontColor,
                            child: Icon(_followPosition ? Icons.my_location : Icons.location_searching),
                          ),
                        ],
                      ),
                      if (widget.bottom != null) ...[
                        const SizedBox(height: 12),
                        widget.bottom!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
      },
    );
  }
}

/// _MapPill - small translucent label on the map (attribution, GPS info)
class _MapPill extends StatelessWidget {
  final Widget child;

  const _MapPill({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurface),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        child: child,
      ),
    );
  }
}
