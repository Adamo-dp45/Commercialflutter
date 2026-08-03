import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Charge les symboles de dates fr (DateFormat) avant le premier rendu.
  await initializeDateFormatting('fr_FR');

  runApp(
    const ProviderScope(
      child: CommercialApp(),
    ),
  );
}
