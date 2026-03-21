import 'package:flutter/material.dart';
import 'package:local_config/src/domain/repositories/local_config_repository.dart';
import 'package:local_config/src/local_config_internals.dart';
import 'package:local_config/src/presentation/extensions/config_display_extension.dart';
import 'package:local_config/src/domain/entities/local_config_value.dart';
import 'package:local_config/src/presentation/l10n/generated/local_config_localizations.dart';
import 'package:local_config/src/presentation/widgets/root_aware_sliver_app_bar.dart';
import 'package:local_config/src/presentation/widgets/text_editor/text_editor.dart';
import 'package:local_config/src/presentation/widgets/input_form_field.dart';

class ConfigEditScreen extends StatefulWidget {
  final String name;

  const ConfigEditScreen({super.key, required this.name});

  @override
  State<StatefulWidget> createState() => _ConfigEditScreenState();
}

class _ConfigEditScreenState extends State<ConfigEditScreen> {
  final _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late final LocalConfigRepository _repo;

  late LocalConfigValue configValue;

  @override
  void initState() {
    super.initState();
    _repo = configRepository;
    configValue = _repo.all[widget.name]!;
    _controller.text = configValue.asString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _AppBar(
            formKey: _formKey,
            name: widget.name,
            controller: _controller,
            repo: _repo,
          ),
          _Form(
            formKey: _formKey,
            name: widget.name,
            config: configValue,
            controller: _controller,
            repo: _repo,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AppBar extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String name;
  final TextEditingController controller;
  final LocalConfigRepository repo;

  const _AppBar({
    required this.formKey,
    required this.name,
    required this.controller,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return RootAwareSliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      title: Text(LocalConfigLocalizations.of(context)!.editParameter),
      actionsPadding: const EdgeInsets.all(8),
      actions: [
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() == false) return;
            repo.set(name, controller.text);
            Navigator.of(context).pop();
          },
          child: Text(LocalConfigLocalizations.of(context)!.save),
        ),
      ],
      centerTitle: false,
      pinned: true,
    );
  }
}

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String name;
  final LocalConfigValue config;
  final TextEditingController controller;
  final LocalConfigRepository repo;

  const _Form({
    required this.formKey,
    required this.name,
    required this.config,
    required this.controller,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              InputFormField(
                controller: TextEditingController(text: name),
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'GoogleSansCode',
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(97),
                ),
                label: Tooltip(
                  preferBelow: true,
                  showDuration: const Duration(seconds: 5),
                  triggerMode: TooltipTriggerMode.tap,
                  padding: const EdgeInsets.all(8),
                  richMessage: config.type.help(context, name: name),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(LocalConfigLocalizations.of(context)!.parameterName),
                      const Icon(Icons.help_outline, size: 16),
                    ],
                  ),
                ),
                enabled: false,
              ),
              InputFormField(
                controller: TextEditingController(
                  text: config.type.getDisplayName(context),
                ),
                entries:
                    LocalConfigType.values.map((value) {
                      return DropdownMenuEntry(
                        value: value.getDisplayName(context),
                        label: value.getDisplayName(context),
                        leadingIcon: Icon(value.displayIcon),
                      );
                    }).toList(),
                validator:
                    (value) => config.type.validator(context, value ?? ''),
                enabled: false,
                label: Text(
                  LocalConfigLocalizations.of(context)!.dataType,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              InputFormField(
                controller: controller,
                entries:
                    config.type.presets.map((item) {
                      return DropdownMenuEntry(value: item, label: item);
                    }).toList(),
                autofocus: true,
                onFieldSubmitted: (_) {
                  if (formKey.currentState?.validate() == false) return;
                  repo.set(name, controller.text);
                  Navigator.of(context).pop();
                },
                validator:
                    (value) => config.type.validator(context, value ?? ''),
                textInputAction: TextInputAction.done,
                suffixIcon:
                    config.type.isTextBased
                        ? IconButton(
                          onPressed: () async {
                            final changedText = await Navigator.of(
                              context,
                            ).push(
                              MaterialPageRoute<String>(
                                fullscreenDialog: true,
                                builder: (_) {
                                  return TextEditor(
                                    value: controller.text,
                                    title: LocalConfigLocalizations.of(
                                      context,
                                    )!.editorOf(
                                      config.type.getDisplayName(context),
                                    ),
                                    controller:
                                        config.type.textEditorController,
                                  );
                                },
                              ),
                            );
                            controller.text = changedText ?? '';
                          },
                          icon: const Icon(Icons.open_in_full),
                          tooltip:
                              LocalConfigLocalizations.of(
                                context,
                              )!.fullScreenEditor,
                        )
                        : null,
                label: Text(
                  LocalConfigLocalizations.of(context)!.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
