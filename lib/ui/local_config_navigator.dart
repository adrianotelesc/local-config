import 'package:flutter/material.dart';
import 'package:local_config/ui/local_config_routes.dart';
import 'package:local_config/ui/page/config_edit_page.dart';
import 'package:local_config/ui/page/config_list_page.dart';

class LocalConfigNavigator extends StatelessWidget {
  const LocalConfigNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: LocalConfigRoutes.configList,
      onGenerateRoute: (settings) {
        return switch (settings.name) {
          LocalConfigRoutes.configList => MaterialPageRoute(
            builder: (_) => const ConfigListScreen(),
          ),
          LocalConfigRoutes.configEdit => MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) {
              return ConfigEditScreen(
                name: settings.arguments.toString(),
              );
            },
          ),
          _ => null,
        };
      },
    );
  }
}
