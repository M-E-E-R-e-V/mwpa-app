import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:mwpaapp/Util/UtilTileServer.dart';

class ListMap extends StatefulWidget {

  const ListMap({super.key});

  @override
  State<ListMap> createState() => _ListMapState();
}

class _ListMapState extends State<ListMap> {
  final LocationController _locationController = Get.find<LocationController>();
  final SightingController _sightingController = Get.find<SightingController>();

  final controller = MapController(location: LatLng.degree(0, 0), zoom: 6);

  double _clamp(double x, double min, double max) {
    if (x < min) x = min;
    if (x > max) x = max;

    return x;
  }

  void _onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = _clamp(controller.zoom + delta, 2, 18);

    transformer.setZoomInPlace(zoom, position);
    setState(() {});
  }

  Offset? _dragStart;

  double _scaleStart = 3.0;

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;

      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      if (controller.zoom < 1) {
        controller.zoom = 1;
      }
      setState(() {});
    } else {
      final now = details.focalPoint;
      var diff = now - _dragStart!;
      _dragStart = now;
      final h = transformer.constraints.maxHeight;

      final vp = transformer.getViewport();
      if (diff.dy < 0 && vp.bottom - diff.dy < h) {
        diff = Offset(diff.dx, 0);
      }

      if (diff.dy > 0 && vp.top - diff.dy > 0) {
        diff = Offset(diff.dx, 0);
      }

      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  Widget _buildMarkerWidget(
      MapTransformer transformer,
      LatLng location,
      Color color,
      [IconData icon = Icons.location_on]
      ) {

    Offset pos = transformer.toOffset(location);

    return Positioned(
      left: pos.dx - 12,
      top: pos.dy - 12,
      width: 24,
      height: 24,
      child: GestureDetector(
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
        onTap: () {
          /*showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              content: Text('You have clicked a marker!'),
            ),
          );*/
        },
      ),
    );
  }

  void _gotoDefault() {
    var position = _locationController.currentPosition;

    if (position != null) {
      controller.center = LatLng.degree(position.latitude, position.longitude);
    }

    controller.zoom = 14;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      var position = locationController.currentPosition;

      if (position != null) {
        controller.center = LatLng.degree(position.latitude, position.longitude);
      }

      return Scaffold(
        body: MapLayout(
          controller: controller,
          builder: (context, transformer) {
            List<Widget> markerWidgets = [];

            for (var sighting in _sightingController.sightingList) {
              if (sighting.location_begin != null) {
                try {
                  Position tPos = Position.fromMap(jsonDecode(sighting.location_begin!));
                  Color backgroundColor = sighting.validateColor();

                  markerWidgets.add(
                      _buildMarkerWidget(
                          transformer,
                          LatLng.degree(tPos.latitude, tPos.longitude),
                          backgroundColor
                      )
                  );
                }
                catch(locExcept) {
                  if (kDebugMode) {
                    print(locExcept);
                  }
                }
              }
            }

            if (position != null) {
              markerWidgets.add(
                _buildMarkerWidget(
                  transformer,
                  LatLng.degree(
                    position.latitude,
                    position.longitude
                  ),
                  Colors.red,
                  Icons.my_location
                )
              );
            }

            Widget gpsInfo = Container();

            gpsInfo = PositionedDirectional(
                bottom: 5,
                start: 5,
                child: Container(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    decoration: const BoxDecoration(
                      color: kPrimaryHeaderColor,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      position == null ? "wait for GPS ..." : "${UtilPosition.getStr(position)} / Points: ${locationController.positionCount}",
                      style: subTitleStyle.copyWith(color: kButtonFontColor),
                    )
                )
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTapDown: (details) => _onDoubleTap(
                transformer,
                details.localPosition,
              ),
              onScaleStart: _onScaleStart,
              onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta.dy / -1000.0;
                    final zoom = _clamp(controller.zoom + delta, 2, 18);

                    transformer.setZoomInPlace(zoom, event.localPosition);
                    setState(() {});
                  }
                },
                child: Stack(
                  children: [
                    TileLayer(
                      builder: (context, x, y, z) {
                        final tilesInZoom = pow(2.0, z).floor();

                        while (x < 0) {
                          x += tilesInZoom;
                        }
                        while (y < 0) {
                          y += tilesInZoom;
                        }

                        x %= tilesInZoom;
                        y %= tilesInZoom;

                        return CachedNetworkImage(
                          imageUrl: UtilTileServer.openstreetmap(z, x, y),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    ...markerWidgets,
                    gpsInfo
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _gotoDefault,
          tooltip: 'My Location',
          backgroundColor: kButtonBackgroundColor,
          child: const Icon(Icons.my_location),
        ),
      );
    });
  }
}