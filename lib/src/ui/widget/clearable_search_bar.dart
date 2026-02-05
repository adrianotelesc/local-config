import 'package:flutter/material.dart';

class ClearableSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final FocusNode? focusNode;

  const ClearableSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.focusNode,
  });

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<ClearableSearchBar> {
  late final TextEditingController _controller;

  var _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final text = widget.controller?.text ?? '';
    setState(() => _showClearButton = text.isNotEmpty);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      hintText: widget.hintText,
      focusNode: widget.focusNode,
      trailing: [
        if (_showClearButton)
          Tooltip(
            message: 'Clear',
            child: IconButton(
              onPressed: _controller.clear,
              icon: const Icon(Icons.cancel_outlined),
            ),
          ),
      ],
      backgroundColor: WidgetStateColor.fromMap({
        WidgetState.focused: Theme.of(context).colorScheme.surfaceContainer,
        WidgetState.any:
            _showClearButton
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainer,
      }),
      onTapOutside: (event) => widget.focusNode?.unfocus(),
      leading: const Icon(Icons.search),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.only(left: 16, right: 4),
      ),
    );
  }
}
