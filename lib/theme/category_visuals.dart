import 'package:flutter/material.dart';

import 'vf_colors.dart';

/// Visual metadata for a product category — an icon plus a tint colour. The
/// tint is used as a tiny leading stripe / pill in shopping + dashboard rows
/// so the user can scan by category at a glance.
class CategoryVisual {
  const CategoryVisual({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}

/// Look up the visual treatment for a category slug. Falls back to the
/// `other` bucket (muted brand tone) when the slug is unknown so we never
/// crash on data drift from the server.
CategoryVisual categoryVisual(BuildContext context, String slug) {
  final vf = context.vfColors;
  final scheme = Theme.of(context).colorScheme;
  switch (slug) {
    case 'dairy':
      return CategoryVisual(icon: Icons.icecream_outlined, color: vf.mistral);
    case 'meat-fish':
      return CategoryVisual(icon: Icons.set_meal_outlined, color: scheme.error);
    case 'vegetables':
      return CategoryVisual(icon: Icons.eco_outlined, color: vf.success);
    case 'fruits':
      return CategoryVisual(icon: Icons.spa_outlined, color: vf.pulpe);
    case 'bakery':
      return CategoryVisual(icon: Icons.bakery_dining_outlined, color: vf.solara);
    case 'pantry':
      return CategoryVisual(icon: Icons.kitchen_outlined, color: vf.solara);
    case 'snacks':
      return CategoryVisual(icon: Icons.cookie_outlined, color: vf.pulpe);
    case 'drinks':
      return CategoryVisual(icon: Icons.local_cafe_outlined, color: vf.mistral);
    case 'alcohol':
      return CategoryVisual(icon: Icons.wine_bar_outlined, color: scheme.error);
    case 'sauces':
      return CategoryVisual(icon: Icons.water_drop_outlined, color: vf.pulpe);
    case 'frozen':
      return CategoryVisual(icon: Icons.ac_unit_outlined, color: vf.mistral);
    case 'canned-prepared':
      return CategoryVisual(icon: Icons.inventory_2_outlined, color: vf.solara);
    default:
      return CategoryVisual(icon: Icons.label_outline, color: vf.mutedForeground);
  }
}
