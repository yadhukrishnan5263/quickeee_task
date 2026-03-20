
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/product_bloc.dart';

class BuildPriceChart extends StatelessWidget {
  const BuildPriceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) => 
          previous.liveData.length != current.liveData.length ||
          (previous.liveData.isNotEmpty && current.liveData.isNotEmpty && 
           previous.liveData.last.price != current.liveData.last.price),
      builder: (context, state) {
        final priceHistory = state.liveData.map((data) => data.price).toList();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: double.infinity,
            child: CustomPaint(
              painter: PriceChart(
                data: priceHistory,
                lineColor: const Color(0xFF64FF00),
              ),
              isComplex: true,
              willChange: false,
            ),
          ),
        );
      },
    );
  }
}

class PriceChart extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  PriceChart({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double minPrice = data.reduce(min);
    final double maxPrice = data.reduce(max);
    final double range = maxPrice - minPrice == 0 ? 1 : maxPrice - minPrice;

    final Path linePath = Path();
    final Path gradientPath = Path();

    final double stepX = data.length > 1 ? size.width / (data.length - 1) : 0;

    for (int i = 0; i < data.length; i++) {
      final double x = data.length > 1 ? i * stepX : size.width / 2;
      final double normalizedY = (data[i] - minPrice) / range;
      final double clampedY = normalizedY.clamp(0.0, 1.0);
      final double y = size.height - (clampedY * size.height);

      if (y.isNaN || y.isInfinite) {
        continue;
      }

      if (i == 0) {
        linePath.moveTo(x, y);
        gradientPath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    final double gradientLastX = data.length > 1 ? (data.length - 1) * stepX : size.width / 2;
    gradientPath.lineTo(gradientLastX, size.height);
    gradientPath.lineTo(0, size.height);
    gradientPath.close();

    final Paint gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.0),
        ],
      );

    canvas.drawPath(gradientPath, gradientPaint);

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = false;

    canvas.drawPath(linePath, linePaint);

    final double lastX = data.length > 1 ? (data.length - 1) * stepX : size.width / 2;
    final double lastNormalizedY = (data.last - minPrice) / range;
    final double lastClampedY = lastNormalizedY.clamp(0.0, 1.0);
    final double lastY = size.height - (lastClampedY * size.height);

    if (!lastY.isNaN && !lastY.isInfinite) {
      final Paint dotPaint = Paint()
        ..color = Colors.white
        ..isAntiAlias = false;
      canvas.drawCircle(Offset(lastX, lastY), 3.0, dotPaint);

      final Paint pulsePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill
        ..isAntiAlias = false;
      canvas.drawCircle(Offset(lastX, lastY), 8.0, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PriceChart oldDelegate) {
    return oldDelegate.data.length != data.length || oldDelegate.data.last != data.last;
  }
}