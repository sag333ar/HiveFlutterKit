import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/image_thumbs.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/inkwell_wrapper.dart';

class UserProfileimage extends StatefulWidget {
  const UserProfileimage(
      {super.key,
      this.isOverride = false,
      required this.url,
      this.radius,
      this.verticalPadding = 12,
      this.fillColor,
      this.resize = false,
      this.fit,
      this.onTap});

  final String? url;
  final double? radius;
  final double verticalPadding;
  final BoxFit? fit;
  final bool resize;
  final VoidCallback? onTap;
  final Color? fillColor;
  final bool isOverride;

  @override
  State<UserProfileimage> createState() => _UserProfileimageState();
}

class _UserProfileimageState extends State<UserProfileimage> {
  bool isErrorImage = false;

  @override
  void didUpdateWidget(covariant UserProfileimage oldWidget) {
    isErrorImage = false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
        onTap: widget.onTap,
        borderRadius: widget.onTap != null
            ? const BorderRadius.all(Radius.circular(100))
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
          child: CircleAvatar(
            radius: widget.radius ?? 20,
            backgroundImage: widget.url != null && !isErrorImage
                ? NetworkImage(
                    widget.isOverride
                        ? context.proxyImage(widget.url!)
                        : context.resizedImage(
                            widget.resize
                                ? context.resizedImage(
                                    context.userOwnerThumb(widget.url!),
                                    height: height,
                                    width: width)
                                : context.userOwnerThumb(widget.url!),
                            height: height,
                            width: width,
                          ),
                  )
                : null,
            onBackgroundImageError: !isErrorImage
                ? (exception, stackTrace) =>
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      if (mounted && !isErrorImage) {
                        setState(() {
                          isErrorImage = true;
                        });
                      }
                    })
                : null,
            backgroundColor: widget.fillColor ?? Colors.grey.shade600,
            child: Visibility(
              visible: isErrorImage,
              child: const Icon(
                Icons.account_circle,
                size: 30,
              ),
            ),
          ),
        ));
  }

  int? get width {
    if (widget.radius == null) {
      return null;
    } else {
      return widget.radius!.toInt() * 10;
    }
  }

  int? get height {
    if (widget.radius == null) {
      return null;
    } else {
      return widget.radius!.toInt() * 6;
    }
  }
}
