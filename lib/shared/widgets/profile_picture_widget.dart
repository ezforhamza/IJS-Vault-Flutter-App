import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({
    super.key,
    required this.radius,
    required this.imageUrl,
  });
  final double radius;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: ClipOval(child: CachedNetworkImage(imageUrl: imageUrl)),
    );
  }
}
