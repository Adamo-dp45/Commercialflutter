import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_exception.dart';
import 'app_state_views.dart';

/// Rend un [AsyncValue] de façon uniforme : indicateur de chargement, vue
/// d'erreur avec bouton « Réessayer », ou le contenu via [data].
///
/// Évite de répéter le triplet loading/error/data dans chaque écran.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: false,
      data: data,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppErrorView(
        message: error is ApiException
            ? error.message
            : 'Une erreur est survenue.',
        onRetry: onRetry,
      ),
    );
  }
}
