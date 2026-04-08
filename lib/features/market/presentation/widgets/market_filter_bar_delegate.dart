import 'package:flutter/material.dart';

class MarketFilterBarDelegate extends SliverPersistentHeaderDelegate {
  MarketFilterBarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2 : 0,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant MarketFilterBarDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}
