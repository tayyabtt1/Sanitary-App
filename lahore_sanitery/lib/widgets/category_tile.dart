import 'package:flutter/material.dart';
import '../utils/category_style.dart';

class CategoryTile extends StatelessWidget {
  final String categoryName;
  final VoidCallback? onTap;

  const CategoryTile({super.key, required this.categoryName, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = styleFor(categoryName);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: style.imagePath.isNotEmpty
                  ? Image.asset(
                      style.imagePath,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 64,
                        width: 64,
                        color: style.color.withOpacity(0.15),
                        child: Icon(Icons.category, color: style.color),
                      ),
                    )
                  : Container(
                      height: 64,
                      width: 64,
                      color: style.color.withOpacity(0.15),
                      child: Icon(Icons.category, color: style.color),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              categoryName,
              style: TextStyle(
                color: style.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}