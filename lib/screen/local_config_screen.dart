import 'dart:async';
import 'dart:math';

import 'package:local_config/extension/config_value_extension.dart';
import 'package:local_config/local_config.dart';
import 'package:local_config/widget/config_form.dart';
import 'package:flutter/material.dart';
import 'package:local_config/model/config_value.dart';

class LocalConfigScreen extends StatefulWidget {
  const LocalConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LocalConfigScreenState();
}

class _LocalConfigScreenState extends State<LocalConfigScreen> {
  final _scrollController = ScrollController();

  String _searchQuery = '';

  List<MapEntry<String, ConfigValue>> _allConfigs = [];
  List<MapEntry<String, ConfigValue>> _visibleConfigs = [];

  StreamSubscription? _configsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _configsStreamSubscription = _subscribeToConfigsStream();
  }

  @override
  void dispose() {
    _configsStreamSubscription?.cancel();
    _configsStreamSubscription = null;
    _scrollController.dispose();
    super.dispose();
  }

  StreamSubscription _subscribeToConfigsStream() {
    return LocalConfig.instance.configsStream.listen((configs) {
      _updateConfigsState(configs.entries.toList());
    });
  }

  void _updateConfigsState(List<MapEntry<String, ConfigValue>> configs) {
    setState(() {
      _allConfigs = configs;
      _visibleConfigs = _filterConfigsBy(_searchQuery);
    });
  }

  List<MapEntry<String, ConfigValue>> _filterConfigsBy(String text) {
    return text.trim().isNotEmpty
        ? _filterConfigsContaining(text)
        : _allConfigs;
  }

  List<MapEntry<String, ConfigValue>> _filterConfigsContaining(String text) {
    return _allConfigs
        .where((config) => _caseInsensitiveContains(config.key, text))
        .toList();
  }

  bool _caseInsensitiveContains(String string, String substring) {
    return string.toLowerCase().contains(substring.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const _AppBar(),
            _SearchBar(onChanged: _onSearchQueryChanged),
            _ConfigList(configs: _visibleConfigs)
          ],
        ),
      ),
    );
  }

  void _onSearchQueryChanged(String searchQuery) {
    _updateSearchQueryState(searchQuery);
  }

  void _updateSearchQueryState(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
      _visibleConfigs = _filterConfigsBy(searchQuery);
    });
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
  const _SearchBar({this.onChanged});

  final void Function(String)? onChanged;

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();

  bool isCloseVisible = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onChanged);
  }

  void _onChanged() {
    final searchText = _textController.text;
    widget.onChanged?.call(searchText);
    setState(() => isCloseVisible = searchText.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverHeaderDelegate(
        minHeight: 80,
        maxHeight: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Wrap(
            runAlignment: WrapAlignment.center,
            children: [
              SearchBar(
                padding:
                    const WidgetStatePropertyAll(EdgeInsets.only(left: 16)),
                hintText: 'Search',
                leading: const Icon(Icons.search),
                controller: _textController,
                trailing: [
                  if (isCloseVisible)
                    IconButton(
                      onPressed: () => _textController.clear(),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onChanged);
    _textController.dispose();
    super.dispose();
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _ConfigList extends StatelessWidget {
  const _ConfigList({this.configs = const []});

  final List<MapEntry<String, ConfigValue>> configs;

  @override
  Widget build(BuildContext context) {
    if (configs.isEmpty) {
      return const _Empty();
    }

    return SliverList.separated(
      itemCount: configs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final configEntry = configs[index];

        return _ConfigListTile(
          name: configEntry.key,
          value: configEntry.value,
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
    required this.value,
  });

  final String name;
  final ConfigValue value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(name),
      subtitle: Text(
        value.displayText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Icon(value.type.icon),
      trailing: IconButton(
        onPressed: () {
          showConfigFormModal(
            context: context,
            name: name,
            value: value,
          );
        },
        icon: const Icon(Icons.edit),
      ),
    );
  }
}
