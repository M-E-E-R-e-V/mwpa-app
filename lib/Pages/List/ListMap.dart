import 'dart:async';
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
/// gestures through to the map. [side] sits at the left edge of the free
/// area between them (next to the map buttons) and gets its height as
/// constraint (e.g. the running sightings).
class ListMap extends StatefulWidget {
  final Widget? top;
  final Widget? bottom;
  final Widget? side;

  const ListMap({super.key, this.top, this.bottom, this.side});

  @override
  State<ListMap> createState() => _ListMapState();
}

class _ListMapState extends State<ListMap> {
  late final LocationController _locationController = context.read<LocationController>();
  late final SightingController _sightingController = context.read<SightingController>();

  static const double _defaultZoom = 14;
  static const double _minZoom = 2;
  static const double _maxZoom = 18;

  final MapController _mapController = MapController();
  final GlobalKey<_MapAttributionState> _attributionKey = GlobalKey();
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

  /// _zoomBy - +/- buttons; keeps the center (and following the position)
  void _zoomBy(double delta) {
    if (!_mapReady) {
      return;
    }

    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta).clamp(_minZoom, _maxZoom).roundToDouble();
    _mapController.move(camera.center, zoom);
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
                minZoom: _minZoom,
                maxZoom: _maxZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: () {
                  _mapReady = true;
                  _onLocationChanged();
                },
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    _attributionKey.currentState?.collapse();
                  }

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

                // route of the running tour -----------------------------------
                if (_locationController.route.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [for (final p in _locationController.route) LatLng(p.lat, p.lon)],
                        strokeWidth: 4,
                        color: kButtonBackgroundColor,
                        borderStrokeWidth: 1.5,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),

                // sighting + current position markers -------------------------
                MarkerLayer(
                  markers: [
                    ..._sightingMarkers(),
                    if (currentLatLng != null) _buildMarker(currentLatLng, Colors.red, Icons.my_location),
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
                    // GPS info hangs centered below the top card
                    Center(
                      child: _GpsTab(
                        text: position == null
                            ? context.l10n.mapWaitForGps
                            : context.l10n
                                .mapPositionPoints(UtilPosition.getStr(position), _locationController.positionCount),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _MapAttribution(key: _attributionKey),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // e.g. running sightings, top left of the free area
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.topStart,
                              child: widget.side ?? const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // map buttons at the right edge, at the bottom
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _ZoomButtons(
                                onZoomIn: () => _zoomBy(1),
                                onZoomOut: () => _zoomBy(-1),
                              ),
                              const SizedBox(height: 12),
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
                        ],
                      ),
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

/// _MapAttribution - OSM credit as required by the OSMF attribution
/// guidelines: visible on start, collapses into an (i) button after five
/// seconds or on the first map gesture; the button shows it again.
class _MapAttribution extends StatefulWidget {
  const _MapAttribution({super.key});

  @override
  State<_MapAttribution> createState() => _MapAttributionState();
}

class _MapAttributionState extends State<_MapAttribution> {
  static const Duration _visibleFor = Duration(seconds: 5);

  bool _expanded = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_visibleFor, _onTimer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// _onTimer - collapses after [_visibleFor] in front; while a dialog or
  /// another page covers the map the credit stays open a while longer
  void _onTimer() {
    if (!mounted) return;

    if (ModalRoute.of(context)?.isCurrent == false) {
      _timer = Timer(_visibleFor, _onTimer);
      return;
    }

    collapse();
  }

  void collapse() {
    _timer?.cancel();

    if (mounted && _expanded) {
      setState(() => _expanded = false);
    }
  }

  void _toggle() {
    _timer?.cancel();
    setState(() => _expanded = !_expanded);

    if (_expanded) {
      _timer = Timer(_visibleFor, _onTimer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: context.l10n.mapAttribution,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _expanded
              ? const _MapPill(key: ValueKey('text'), child: Text('© OpenStreetMap contributors'))
              : Container(
                  key: const ValueKey('icon'),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Icon(Icons.info_outline, size: 18, color: scheme.onSurface),
                ),
        ),
      ),
    );
  }
}

/// _GpsTab - current position and point count, attached like a tab to the
/// bottom edge of the card above (same color, only the bottom corners round)
class _GpsTab extends StatelessWidget {
  final String text;

  const _GpsTab({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 5, 14, 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.93),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_fixed, size: 14, color: scheme.onPrimaryContainer.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// _ZoomButtons - "+" above "-" in one rounded box, as wide as the FAB
class _ZoomButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomButtons({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      elevation: 4,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onZoomIn,
              tooltip: context.l10n.zoomIn,
              icon: const Icon(Icons.add),
              color: scheme.onSurface,
              constraints: const BoxConstraints.tightFor(width: 56, height: 52),
            ),
            Divider(height: 1, thickness: 1, indent: 10, endIndent: 10, color: scheme.outlineVariant),
            IconButton(
              onPressed: onZoomOut,
              tooltip: context.l10n.zoomOut,
              icon: const Icon(Icons.remove),
              color: scheme.onSurface,
              constraints: const BoxConstraints.tightFor(width: 56, height: 52),
            ),
          ],
        ),
      ),
    );
  }
}

/// _MapPill - small translucent label on the map (attribution, GPS info)
class _MapPill extends StatelessWidget {
  final Widget child;

  const _MapPill({super.key, required this.child});

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
