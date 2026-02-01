import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_assets.dart';

class CurvedBackground extends StatelessWidget {
  const CurvedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      right: 0,
      child: ClipPath(
        clipper: _CornerClipper(),
        child: Container(
          width: screenSize.width * 0.8,
          height: screenSize.height * 0.55,
          color: AppTheme.secondaryColor,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                right: 5,
                child: Image.asset(
                  AppAssets.doctorIllustration,
                  height: screenSize.height * 0.3,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: screenSize.height * 0.4,
                      width: screenSize.width * 0.6,
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: Text('Ilustración no encontrada')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(0, 0, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
