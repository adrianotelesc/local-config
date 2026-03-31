import 'package:flutter/material.dart';

class DashedLConnector extends StatelessWidget {
  final List<DashedLEntry> entries;

  final bool hasLeadingLine;

  final double leadingLineHeight;

  const DashedLConnector({
    super.key,
    required this.entries,
    this.hasLeadingLine = true,
    this.leadingLineHeight = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLeadingLine) _LeadingLine(height: leadingLineHeight),
        ...entries.indexed.map(
          (e) => _LEntry(
            entry: e.$2,
            isLast: e.$1 == entries.length - 1,
          ),
        ),
      ],
    );
  }
}

class DashedLEntry {
  final Widget label;
  final Widget value;
  final TextStyle? valueStyle;

  const DashedLEntry({
    required this.label,
    required this.value,
    this.valueStyle,
  });
}

class _LeadingLine extends StatelessWidget {
  final double height;

  const _LeadingLine({required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: CustomPaint(
        size: Size(1, height),
        painter: _VerticalLinePainter(),
      ),
    );
  }
}

class _LEntry extends StatelessWidget {
  final DashedLEntry entry;

  final bool isLast;

  const _LEntry({required this.entry, required this.isLast});

  double _valueCenterOffset(BuildContext context) {
    final style = entry.valueStyle ?? DefaultTextStyle.of(context).style;
    final painter = TextPainter(
      text: TextSpan(text: 'A', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.height / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          entry.label,
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 8),
              CustomPaint(
                size: const Size(32, 24),
                painter: _LShapePainter(
                  valueCenterOffset: _valueCenterOffset(context),
                  isLast: isLast,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: entry.value),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawDashedLine(
      canvas,
      _linePaint(),
      from: Offset.zero,
      to: Offset(0, size.height),
    );
  }

  @override
  bool shouldRepaint(_VerticalLinePainter old) => false;
}

class _LShapePainter extends CustomPainter {
  final double valueCenterOffset;

  final bool isLast;

  const _LShapePainter({
    required this.valueCenterOffset,
    required this.isLast,
  });

  static const double _railX = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _linePaint();
    final horizontalY = size.height / 2;

    _drawDashedLine(
      canvas,
      paint,
      from: Offset(_railX, 0),
      to: Offset(_railX, isLast ? horizontalY : size.height),
    );

    _drawDashedLine(
      canvas,
      paint,
      from: Offset(_railX, horizontalY),
      to: Offset(size.width, horizontalY),
    );
  }

  @override
  bool shouldRepaint(_LShapePainter old) =>
      old.valueCenterOffset != valueCenterOffset || old.isLast != isLast;
}

Paint _linePaint() =>
    Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

void _drawDashedLine(
  Canvas canvas,
  Paint paint, {
  required Offset from,
  required Offset to,
  double dashLength = 4.0,
  double gapLength = 4.0,
}) {
  final delta = to - from;
  final totalLength = delta.distance;
  final step = Offset(delta.dx / totalLength, delta.dy / totalLength);

  double elapsed = 0;
  while (elapsed < totalLength) {
    final dashEnd = (elapsed + dashLength).clamp(0, totalLength).toDouble();
    canvas.drawLine(
      from + step * elapsed,
      from + step * dashEnd,
      paint,
    );
    elapsed += dashLength + gapLength;
  }
}
