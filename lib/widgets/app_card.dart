import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A modern card widget with gradient support, shadows, and hover effects
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? borderRadius;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.elevated = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppTheme.radiusLarge;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: widget.margin ?? EdgeInsets.zero,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered && widget.onTap != null ? -2.0 : 0.0),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          color: widget.gradient == null
              ? (widget.backgroundColor ?? AppTheme.surface)
              : null,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: widget.elevated
              ? (_isHovered && widget.onTap != null
                  ? AppTheme.cardShadowHover
                  : AppTheme.cardShadow)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingMD),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A stat card with icon, value, title, and optional trend indicator
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? iconColor;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
    this.iconColor,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasGradient = gradient != null;

    return AppCard(
      gradient: gradient,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasGradient
                      ? Colors.white.withOpacity(0.2)
                      : (iconColor ?? AppTheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: hasGradient
                      ? Colors.white
                      : (iconColor ?? AppTheme.primary),
                  size: 24,
                ),
              ),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasGradient
                        ? Colors.white.withOpacity(0.2)
                        : (isPositiveTrend
                            ? AppTheme.success.withOpacity(0.1)
                            : AppTheme.error.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: hasGradient
                            ? Colors.white
                            : (isPositiveTrend
                                ? AppTheme.success
                                : AppTheme.error),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasGradient
                              ? Colors.white
                              : (isPositiveTrend
                                  ? AppTheme.success
                                  : AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: hasGradient ? Colors.white : AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: hasGradient
                  ? Colors.white.withOpacity(0.8)
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// An action card with icon, title, subtitle, and arrow indicator
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final LinearGradient? iconGradient;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconGradient,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: iconGradient,
              color: iconGradient == null
                  ? (iconColor ?? AppTheme.primary).withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: iconGradient != null
                  ? Colors.white
                  : (iconColor ?? AppTheme.primary),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ??
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textLight,
                ),
              ),
        ],
      ),
    );
  }
}

/// A feature card for displaying services or features
class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? accentColor;
  final VoidCallback? onTap;
  final String? badge;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.gradient,
    this.accentColor,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: gradient ?? AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A pill-shaped button matching the design system
class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSmall;
  final LinearGradient? gradient;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = true,
    this.isSmall = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    if (gradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 24,
                vertical: isSmall ? 10 : 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: isSmall ? 18 : 20),
                    SizedBox(width: isSmall ? 6 : 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 13 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return isPrimary
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon != null
                ? Icon(icon, size: isSmall ? 18 : 20)
                : const SizedBox.shrink(),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 24,
                vertical: isSmall ? 10 : 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon != null
                ? Icon(icon, size: isSmall ? 18 : 20)
                : const SizedBox.shrink(),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 24,
                vertical: isSmall ? 10 : 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              ),
            ),
          );
  }
}

/// A section header with optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
