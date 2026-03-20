import 'package:flutter/material.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_ios,
            iconSize: 20,
          ),
          Text(
            'FLASH DROP',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 4.0,
              fontSize: 16,
            ),
          ),
          _HeaderButton(
            icon: Icons.more_horiz,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;

  const _HeaderButton({
    required this.icon,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: iconSize),
      onPressed: () {},
    );
  }
}