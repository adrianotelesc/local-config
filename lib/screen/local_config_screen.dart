import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_config/extension/config_value_extension.dart';
import 'package:local_config/local_config.dart';
import 'package:local_config/widget/config_form.dart';
import 'package:local_config/model/config.dart';
import 'package:local_config/widget/sliver_header_delegate.dart';

class LocalConfigScreen extends StatefulWidget {
  const LocalConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LocalConfigScreenState();
}

class _LocalConfigScreenState extends State<LocalConfigScreen> {
  final _scrollController = ScrollController();

  final _searchTextController = TextEditingController();

  List<MapEntry<String, Config>> _allConfigs = [];
  List<MapEntry<String, Config>> _visibleConfigs = [];

  StreamSubscription? _configsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _configsStreamSubscription = _subscribeToConfigsStream();
    _searchTextController.addListener(_handleSearchTextChange);
  }

  StreamSubscription _subscribeToConfigsStream() {
    return LocalConfig.instance.configsStream.listen(_updateConfigsState);
  }

  void _updateConfigsState(Map<String, Config> allConfigs) {
    setState(() {
      _allConfigs = allConfigs.entries.toList();
      _visibleConfigs = _filterConfigsBy(_searchTextController.text);
    });
  }

  List<MapEntry<String, Config>> _filterConfigsBy(String text) {
    return text.trim().isNotEmpty
        ? _filterConfigsContaining(text)
        : _allConfigs;
  }

  List<MapEntry<String, Config>> _filterConfigsContaining(String text) {
    return _allConfigs
        .where((config) => _caseInsensitiveContains(config.key, text))
        .toList();
  }

  bool _caseInsensitiveContains(String string, String substring) {
    return string.toLowerCase().contains(substring.toLowerCase());
  }

  void _handleSearchTextChange() {
    final searchText = _searchTextController.text;
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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const _AppBar(),
            _SearchBar(controller: _searchTextController),
            _ConfigList(configs: _visibleConfigs)
          ],
        ),
      ),
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
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverHeaderDelegate(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearSearch() {
    widget.controller.clear();
  }
}

class _ConfigList extends StatelessWidget {
  const _ConfigList({this.configs = const []});

  final List<MapEntry<String, Config>> configs;

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
          value: configEntry.value,
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
    required this.value,
  });

  final String name;
  final Config value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 16,
        right: 8,
      ),
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
