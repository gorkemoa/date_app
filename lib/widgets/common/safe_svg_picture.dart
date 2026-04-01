import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SafeSvgPicture extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Color? color;

  const SafeSvgPicture.network(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.color,
  });

  @override
  State<SafeSvgPicture> createState() => _SafeSvgPictureState();
}

class _SafeSvgPictureState extends State<SafeSvgPicture> {
  late Future<String> _svgFuture;

  @override
  void initState() {
    super.initState();
    _svgFuture = _fetchAndCleanSvg(widget.url);
  }

  @override
  void didUpdateWidget(SafeSvgPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _svgFuture = _fetchAndCleanSvg(widget.url);
    }
  }

  Future<String> _fetchAndCleanSvg(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String rawSvg = utf8.decode(response.bodyBytes);
        // Fix for "transform: none" which causes crashes in flutter_svg 2.0+
        return rawSvg.replaceAll('transform="none"', '').replaceAll('transform:none', '');
      }
      throw Exception('Failed to load SVG');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ?? SizedBox(width: widget.width, height: widget.height);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return widget.placeholder ?? const Icon(Icons.broken_image_outlined, size: 20);
        }

        return SvgPicture.string(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          colorFilter: widget.color != null 
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        );
      },
    );
  }
}
