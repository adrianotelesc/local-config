import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_config/di/service_locator.dart';
import 'package:local_config/repository/config_repository.dart';
import 'package:local_config/ui/theme/extended_color_scheme.dart';
import 'package:local_config/extension/config_display_extension.dart';
import 'package:local_config/ui/widget/callout.dart';
import 'package:local_config/ui/widget/config_form.dart';
import 'package:local_config/model/config.dart';
import 'package:local_config/ui/widget/sliver_header_delegate.dart';

class LocalConfigScreen extends StatefulWidget {
  const LocalConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LocalConfigScreenState();
}

class _LocalConfigScreenState extends State<LocalConfigScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  List<MapEntry<String, Config>> _configs = [];
  List<MapEntry<String, Config>> _visibleConfigs = [];

  StreamSubscription? _configsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _configs = ServiceLocator.get<ConfigRepository>().configs.entries.toList();
    _configsStreamSubscription = _subscribeToConfigsStream();
    _textController.addListener(_handleSearchTextChange);
  }

  StreamSubscription _subscribeToConfigsStream() {
    return ServiceLocator.get<ConfigRepository>()
        .stream
        .listen(_updateConfigsState);
  }

  void _updateConfigsState(Map<String, Config> localConfigs) {
    setState(() {
      _configs = localConfigs.entries.toList();
      _visibleConfigs = _filterConfigsBy(_textController.text);
    });
  }

  List<MapEntry<String, Config>> _filterConfigsBy(String text) {
    return text.trim().isNotEmpty ? _filterConfigsContaining(text) : _configs;
  }

  List<MapEntry<String, Config>> _filterConfigsContaining(String text) {
    return _configs
        .where((config) => _caseInsensitiveContains(config.key, text))
        .toList();
  }

  bool _caseInsensitiveContains(String string, String substring) {
    return string.toLowerCase().contains(substring.toLowerCase());
  }

  void _handleSearchTextChange() {
    final searchText = _textController.text;
    _updateVisibleConfigsState(searchText);
  }

  void _updateVisibleConfigsState(String searchText) {
    setState(() => _visibleConfigs = _filterConfigsBy(searchText));
  }

  @override
  void dispose() {
    _configsStreamSubscription?.cancel();
    _configsStreamSubscription = null;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF1A73E8),
          primary: const Color(0XFF86ABF2),
          onPrimary: const Color(0XFF0B1D46),
          surface: const Color(0xFF121212),
        ),
        useMaterial3: true,
        searchBarTheme: SearchBarTheme.of(context).copyWith(
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        extensions: [
          ExtendedColorScheme(
            warning: const Color(0XFFFFB300),
            warningContainer: const Color(0X14FFB300),
            onWarning: const Color(0XFF000000),
            onWarningContainer: const Color(0X4DFFB300),
            success: const Color(0XFF6DD58C),
            onSuccess: const Color(0XFF000000),
            successContainer: const Color(0X146DD58C),
            onSuccessContainer: const Color(0X4D6DD58C),
          ),
        ],
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const _AppBar(),
                if (_configs
                    .where((config) => config.value.isOverridden)
                    .isNotEmpty)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverHeaderDelegate(
                      minHeight: 59,
                      maxHeight: 59,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.black,
                          ),
                          Callout.warning(
                            icon: Icons.error,
                            text: 'Configs changed locally',
                            action: FilledButton(
                              onPressed: () {
                                ServiceLocator.get<ConfigRepository>()
                                    .resetAll();
                              },
                              child: const Text('Reset all'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _SearchBar(controller: _textController),
                  ),
                ),
                _ConfigList(
                  configs: _visibleConfigs,
                  localConfigs: Map.fromEntries(_configs),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      title: Text('Local Config'),
      centerTitle: false,
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _isClearVisible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final text = widget.controller.text;
    setState(() => _isClearVisible = text.isNotEmpty);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.only(left: 16),
      ),
      hintText: 'Search',
      leading: const Icon(Icons.search),
      controller: widget.controller,
      trailing: [
        if (_isClearVisible)
          IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }

  void _clearSearch() {
    widget.controller.clear();
  }
}

class _ConfigList extends StatelessWidget {
  const _ConfigList({
    this.configs = const [],
    this.localConfigs = const {},
  });

  final List<MapEntry<String, Config>> configs;
  final Map<String, Config> localConfigs;

  @override
  Widget build(BuildContext context) {
    if (configs.isEmpty) {
      return const _EmptyState();
    }

    return SliverList.separated(
      itemCount: configs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final configEntry = configs[index];
        return _ConfigListTile(
          name: configEntry.key,
          config: configEntry.value,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 128, horizontal: 8),
        child: Column(
          children: [
            Text(
              '( ╹ -╹)',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox.square(dimension: 16),
            Text(
              'There is nothing here.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigListTile extends StatelessWidget {
  const _ConfigListTile({
    required this.name,
    required this.config,
  });

  final String name;
  final Config config;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<ExtendedColorScheme>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.isOverridden)
          Container(
            color: customColors?.warningContainer,
            child: Padding(
              padding: const EdgeInsetsGeometry.only(
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Callout.warning(
                style: CalloutStyle(cornerRadius: 8),
                icon: Icons.error,
                text: 'Locally changed',
                action: TextButton(
                  onPressed: () {
                    ServiceLocator.get<ConfigRepository>().reset(name);
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(
                      customColors?.warningContainer,
                    ),
                    foregroundColor: WidgetStatePropertyAll(
                      customColors?.warning,
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ),
          ),
        ListTile(
          tileColor: config.isOverridden
              ? customColors?.warningContainer
              : ListTileTheme.of(context).tileColor,
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 8,
          ),
          title: Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: config.isOverridden ? FontWeight.bold : null,
                ),
          ),
          subtitle: Text(
            config.displayText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: config.isOverridden ? FontWeight.bold : null,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          leading: Icon(config.type.icon),
          trailing: IconButton(
            onPressed: () {
              showConfigFormModal(
                context: context,
                name: name,
                value: config,
              );
            },
            icon: const Icon(Icons.edit),
          ),
        )
      ],
    );
  }
}
