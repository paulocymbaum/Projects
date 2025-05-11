// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:el_tooltip/el_tooltip.dart';

class CustomTooltip extends StatefulWidget {
  const CustomTooltip({
    super.key,
    this.width,
    this.height,
    this.child,
    this.content,
    this.backgroundColor,
    this.distance,
    this.padding,
    this.position,
    this.radius,
    this.showModal,
    this.timeout,
    this.showArrow,
    this.showChildAboveOverlay,
    this.showDelay,
  });

  final double? width;
  final double? height;
  final Widget Function()? child;
  final Widget Function()? content;
  final Color? backgroundColor;
  final double? distance;
  final double? padding;
  final String? position;
  final double? radius;
  final bool? showModal;
  final int? timeout;
  final bool? showArrow;
  final bool? showChildAboveOverlay;
  final int? showDelay;

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  static ElTooltipController? _activeController;
  ElTooltipController? _controller;
  bool _isVisible = false;
  Timer? _hideTimer;
  Timer? _showTimer;
  bool _isHoveringContent = false;
  bool _isHoveringTrigger = false;

  @override
  void initState() {
    super.initState();
    _controller = ElTooltipController();
  }

  void _showTooltip() {
    if (!_isVisible && mounted && _controller != null) {
      _showTimer?.cancel();

      _showTimer = Timer(Duration(milliseconds: widget.showDelay ?? 300), () {
        if (mounted && (_isHoveringTrigger || _isHoveringContent)) {
          if (_activeController != null && _activeController != _controller) {
            _activeController!.hide();
          }
          setState(() {
            _isVisible = true;
            _activeController = _controller;
          });
          _controller!.show();
        }
      });
    }
  }

  void _hideTooltip() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
          if (_activeController == _controller) {
            _activeController = null;
          }
        });
        _controller!.hide();
      }
    });
  }

  void _handleTriggerEnter(PointerEvent event) {
    _isHoveringTrigger = true;
    _hideTimer?.cancel();
    _showTooltip();
  }

  void _handleTriggerExit(PointerEvent event) {
    _isHoveringTrigger = false;
    _showTimer?.cancel();
    _hideTooltip();
  }

  void _handleContentEnter(PointerEvent event) {
    _isHoveringContent = true;
    _hideTimer?.cancel();
  }

  void _handleContentExit(PointerEvent event) {
    _isHoveringContent = false;
    _hideTooltip();
  }

  ElTooltipPosition _getTooltipPosition(String position) {
    final mappedPosition = <String, ElTooltipPosition>{
      'topStart': ElTooltipPosition.topStart,
      'topCenter': ElTooltipPosition.topCenter,
      'topEnd': ElTooltipPosition.topEnd,
      'bottomStart': ElTooltipPosition.bottomStart,
      'bottomCenter': ElTooltipPosition.bottomCenter,
      'bottomEnd': ElTooltipPosition.bottomEnd,
      'leftStart': ElTooltipPosition.leftStart,
      'leftCenter': ElTooltipPosition.leftCenter,
      'leftEnd': ElTooltipPosition.leftEnd,
      'rightStart': ElTooltipPosition.rightStart,
      'rightCenter': ElTooltipPosition.rightCenter,
      'rightEnd': ElTooltipPosition.rightEnd,
    }[position];

    if (mappedPosition == null) {
      debugPrint(
          'Invalid position "$position" provided. Defaulting to topCenter.');
      return ElTooltipPosition.topCenter;
    }
    return mappedPosition;
  }

  @override
  Widget build(BuildContext context) {
    final childWidget = widget.child?.call();
    final contentWidget = widget.content?.call();

    if (childWidget == null || contentWidget == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        // Hide tooltip when clicking outside both child and content
        if (_isVisible) {
          _hideTooltip();
        }
      },
      child: MouseRegion(
        onEnter: _handleTriggerEnter,
        onExit: _handleTriggerExit,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ElTooltip(
            controller: _controller,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Allow the child widget's click to propagate
                if (childWidget is GestureDetector) {
                  (childWidget as GestureDetector).onTap?.call();
                }
                _hideTooltip();
              },
              child: childWidget,
            ),
            content: MouseRegion(
              onEnter: _handleContentEnter,
              onExit: _handleContentExit,
              child: GestureDetector(
                onTap: () {
                  // Allow the content widget's click to propagate
                  if (contentWidget is GestureDetector) {
                    (contentWidget as GestureDetector).onTap?.call();
                  }
                  _hideTooltip();
                },
                behavior: HitTestBehavior.opaque,
                child: contentWidget,
              ),
            ),
            color: widget.backgroundColor ?? Colors.white,
            distance: widget.distance ?? 10.0,
            padding: EdgeInsets.all(widget.padding ?? 14.0),
            position: _getTooltipPosition(widget.position ?? 'topCenter'),
            radius: Radius.circular(widget.radius ?? 8.0),
            showModal: false,
            showArrow: widget.showArrow ?? true,
            showChildAboveOverlay: false,
            appearAnimationDuration: const Duration(milliseconds: 200),
            disappearAnimationDuration: const Duration(milliseconds: 200),
            timeout: Duration.zero,
            modalConfiguration: const ModalConfiguration(
              opacity: 0.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _showTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
