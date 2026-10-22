import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/core/constants/app_colors.dart';

typedef AsyncBuilder<T> = Future<T> Function();

class AsyncStateView<T> extends StatefulWidget {
  final AsyncBuilder<T> futureBuilder;
  final Widget Function(BuildContext, T) onSuccess;
  final Widget Function(BuildContext, String, VoidCallback?)? onError;
  final Widget Function(BuildContext)? onEmpty;
  final Widget Function(BuildContext)? loadingBuilder;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? emptyAction;

  const AsyncStateView({
    required this.futureBuilder,
    required this.onSuccess,
    this.onError,
    this.onEmpty,
    this.loadingBuilder,
    this.emptyMessage = 'No data available',
    this.emptyActionLabel,
    this.emptyAction,
    super.key,
  });

  @override
  State<AsyncStateView<T>> createState() => _AsyncStateViewState<T>();
}

class _AsyncStateViewState<T> extends State<AsyncStateView<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.futureBuilder();
  }

  void _retry() {
    setState(() {
      _future = widget.futureBuilder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentPrimary,
                ),
              );
        }

        if (snapshot.hasError) {
          return widget.onError?.call(
                context,
                snapshot.error.toString(),
                _retry,
              ) ??
              ErrorState(message: snapshot.error.toString(), onRetry: _retry);
        }

        final data = snapshot.data;
        if (data == null) {
          return widget.onEmpty?.call(context) ??
              EmptyState(
                message: widget.emptyMessage,
                actionLabel: widget.emptyActionLabel,
                onAction: widget.emptyAction,
              );
        }

        return widget.onSuccess(context, data);
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorState({required this.message, this.onRetry, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 64,
              color: AppColors.accentError,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    ).animate().shimmer(duration: 1500.ms, color: AppColors.borderDefault);
  }
}

class LoadingSkeletonCard extends StatelessWidget {
  const LoadingSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeleton(width: 120, height: 20),
          const SizedBox(height: 12),
          const LoadingSkeleton(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const LoadingSkeleton(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const LoadingSkeleton(width: 80, height: 16),
        ],
      ),
    );
  }
}
