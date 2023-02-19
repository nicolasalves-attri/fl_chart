import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/bar_chart_horizontal/bar_h_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/render_base_chart.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';

// coverage:ignore-start

/// Low level BarHChart Widget.
class BarHChartLeaf extends LeafRenderObjectWidget {
  const BarHChartLeaf(
      {super.key, required this.data, required this.targetData});

  final BarHChartData data;
  final BarHChartData targetData;

  @override
  RenderBarHChart createRenderObject(BuildContext context) => RenderBarHChart(
        context,
        data,
        targetData,
        MediaQuery.of(context).textScaleFactor,
      );

  @override
  void updateRenderObject(BuildContext context, RenderBarHChart renderObject) {
    renderObject
      ..data = data
      ..targetData = targetData
      ..textScale = MediaQuery.of(context).textScaleFactor
      ..buildContext = context;
  }
}
// coverage:ignore-end

/// Renders our BarHChart, also handles hitTest.
class RenderBarHChart extends RenderBaseChart<BarHTouchResponse> {
  RenderBarHChart(
    BuildContext context,
    BarHChartData data,
    BarHChartData targetData,
    double textScale,
  )   : _data = data,
        _targetData = targetData,
        _textScale = textScale,
        super(targetData.barTouchData, context);

  BarHChartData get data => _data;
  BarHChartData _data;

  set data(BarHChartData value) {
    if (_data == value) return;
    _data = value;
    markNeedsPaint();
  }

  BarHChartData get targetData => _targetData;
  BarHChartData _targetData;

  set targetData(BarHChartData value) {
    if (_targetData == value) return;
    _targetData = value;
    super.updateBaseTouchData(_targetData.barTouchData);
    markNeedsPaint();
  }

  double get textScale => _textScale;
  double _textScale;

  set textScale(double value) {
    if (_textScale == value) return;
    _textScale = value;
    markNeedsPaint();
  }

  // We couldn't mock [size] property of this class, that's why we have this
  @visibleForTesting
  Size? mockTestSize;

  @visibleForTesting
  BarHChartPainter painter = BarHChartPainter();

  PaintHolder<BarHChartData> get paintHolder {
    return PaintHolder(data, targetData, textScale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas
      ..save()
      ..translate(offset.dx, offset.dy);
    painter.paint(
      buildContext,
      CanvasWrapper(canvas, mockTestSize ?? size),
      paintHolder,
    );
    canvas.restore();
  }

  @override
  BarHTouchResponse getResponseAtLocation(Offset localPosition) {
    final touchedSpot = painter.handleTouch(
      localPosition,
      mockTestSize ?? size,
      paintHolder,
    );
    return BarHTouchResponse(touchedSpot);
  }
}
