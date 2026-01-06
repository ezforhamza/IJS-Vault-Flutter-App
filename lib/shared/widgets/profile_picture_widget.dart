import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:shimmer/shimmer.dart';

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
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          placeholder: (BuildContext context, String url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[300],
            ),
          ),
          errorWidget: (BuildContext context, String url, Object error) =>
              Image.asset(
                AppImages.imagePlaceholder, // fallback asset image
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
        ),
      ),
    );
  }
}
