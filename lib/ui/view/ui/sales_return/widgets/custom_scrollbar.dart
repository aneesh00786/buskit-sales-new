import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
///  Custom horizontal scroll bar with left/right arrows
/// ---------------------------------------------------------------


import 'package:flutter/material.dart';

class CustomHorizontalScrollbar extends StatefulWidget {
  /// The controller that drives the horizontal scroll view.
  final ScrollController controller;

  /// Optional colour for the track (default = grey[300]).
  final Color trackColor;

  /// Colour of the thumb (default = blue).
  final Color thumbColor;

  /// How many pixels the arrows scroll when tapped.
  final double scrollStep;

  const CustomHorizontalScrollbar({
    super.key,
    required this.controller,
    this.trackColor = const Color(0xFFEEEEEE), // Colors.grey[300]
    this.thumbColor = Colors.blue,
    this.scrollStep = 100,
  });

  @override
  State<CustomHorizontalScrollbar> createState() =>
      _CustomHorizontalScrollbarState();
}

class _CustomHorizontalScrollbarState extends State<CustomHorizontalScrollbar> {
  @override
  void initState() {
    super.initState();
    // Re-build when the controller reports a change
    widget.controller.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(covariant CustomHorizontalScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScrollChanged);
      widget.controller.addListener(_onScrollChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScrollChanged);
    super.dispose();
  }

  void _onScrollChanged() {
    // Only rebuild if mounted
    if (mounted) setState(() {});
  }

  void _scrollBy(double delta) {
    if (!widget.controller.hasClients) return;

    final target = (widget.controller.offset + delta).clamp(
      0.0,
      widget.controller.position.maxScrollExtent,
    );

    widget.controller.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.trackColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 1. Check if controller is attached
          if (!widget.controller.hasClients) return const SizedBox();

          final pos = widget.controller.position;

          // 2. CRITICAL FIX: Check if dimensions are ready before accessing maxScrollExtent
          if (!pos.hasContentDimensions) return const SizedBox();

          final maxScroll = pos.maxScrollExtent;
          final currentScroll = pos.outOfRange ? 0.0 : pos.pixels;

          if (maxScroll <= 0) return const SizedBox();

          final viewport = constraints.maxWidth;
          
          // Avoid division by zero if maxScroll + viewport is somehow 0
          final denominator = (maxScroll + viewport);
          if (denominator == 0) return const SizedBox();

          final thumbWidth = (viewport / denominator) * viewport; // proportional
          
          // Prevent NaN/Infinity if maxScroll is 0 (though covered above)
          final thumbOffset = maxScroll == 0 
              ? 0.0 
              : (currentScroll / maxScroll) * (viewport - thumbWidth);

          return Stack(
            children: [
              // ---------- LEFT ARROW ----------
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => _scrollBy(-widget.scrollStep),
                    child: const Icon(
                      Icons.arrow_left,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              // ---------- RIGHT ARROW ----------
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: () => _scrollBy(widget.scrollStep),
                    child: const Icon(
                      Icons.arrow_right,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              // ---------- THUMB ----------
              Positioned(
                left: thumbOffset.clamp(
                  20.0, // clamp to double
                  (viewport - thumbWidth - 20).clamp(20.0, double.infinity),
                ), 
                top: 2,
                child: Container(
                  width: thumbWidth.clamp(30.0, double.infinity),
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.thumbColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
// class CustomHorizontalScrollbar extends StatefulWidget {
//   /// The controller that drives the horizontal scroll view.
//   final ScrollController controller;

//   /// Optional colour for the track (default = grey[300]).
//   final Color trackColor;

//   /// Colour of the thumb (default = blue).
//   final Color thumbColor;

//   /// How many pixels the arrows scroll when tapped.
//   final double scrollStep;

//   const CustomHorizontalScrollbar({
//     super.key,
//     required this.controller,
//     this.trackColor = const Color(0xFFEEEEEE), // Colors.grey[300]
//     this.thumbColor = Colors.blue,
//     this.scrollStep = 100,
//   });

//   @override
//   State<CustomHorizontalScrollbar> createState() =>
//       _CustomHorizontalScrollbarState();
// }

// class _CustomHorizontalScrollbarState extends State<CustomHorizontalScrollbar> {
//   @override
//   void initState() {
//     super.initState();
//     // Re-build when the controller reports a change
//     widget.controller.addListener(_onScrollChanged);
//   }

//   @override
//   void didUpdateWidget(covariant CustomHorizontalScrollbar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.controller != widget.controller) {
//       oldWidget.controller.removeListener(_onScrollChanged);
//       widget.controller.addListener(_onScrollChanged);
//     }
//   }

//   @override
//   void dispose() {
//     widget.controller.removeListener(_onScrollChanged);
//     super.dispose();
//   }

//   void _onScrollChanged() => setState(() {});

//   void _scrollBy(double delta) {
//     if (!widget.controller.hasClients) return;

//     final target = (widget.controller.offset + delta).clamp(
//       0.0,
//       widget.controller.position.maxScrollExtent,
//     );

//     widget.controller.animateTo(
//       target,
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 16,
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: widget.trackColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           if (!widget.controller.hasClients) return const SizedBox();

//           final pos = widget.controller.position;
//           final maxScroll = pos.maxScrollExtent;
//           final currentScroll = pos.outOfRange ? 0.0 : pos.pixels;

//           if (maxScroll <= 0) return const SizedBox();

//           final viewport = constraints.maxWidth;
//           final thumbWidth =
//               (viewport / (maxScroll + viewport)) * viewport; // proportional
//           final thumbOffset =
//               (currentScroll / maxScroll) * (viewport - thumbWidth);

//           return Stack(
//             children: [
//               // ---------- LEFT ARROW ----------
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 4),
//                   child: GestureDetector(
//                     onTap: () => _scrollBy(-widget.scrollStep),
//                     child: Icon(
//                       Icons.arrow_left,
//                       size: 14,
//                       color: Colors.blue,
                     
//                     ),
//                   ),
//                 ),
//               ),

//               // ---------- RIGHT ARROW ----------
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 4),
//                   child: GestureDetector(
//                     onTap: () => _scrollBy(widget.scrollStep),
//                     child: Icon(
//                       Icons.arrow_right,
//                       size: 14,
//                        color: Colors.blue,
                      
//                     ),
//                   ),
//                 ),
//               ),

//               // ---------- THUMB ----------
//               Positioned(
//                 left: thumbOffset.clamp(
//                   20,
//                   viewport - thumbWidth - 20,
//                 ), // keep space for arrows
//                 top: 2,
//                 child: Container(
//                   width: thumbWidth.clamp(30, double.infinity),
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: widget.thumbColor,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }