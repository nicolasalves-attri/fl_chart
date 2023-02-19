import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/bar_chart_horizontal/bar_h_chart_renderer.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_scaffold_widget.dart';
import 'package:flutter/cupertino.dart';

/// Renders a bar chart as a widget, using provided [BarHChartData].
class BarHChart extends ImplicitlyAnimatedWidget {
  /// [data] determines how the [BarHChart] should be look like,
  /// when you make any change in the [BarHChartData], it updates
  /// new values with animation, and duration is [swapAnimationDuration].
  /// also you can change the [swapAnimationCurve]
  /// which default is [Curves.linear].
  const BarHChart(
    this.data, {
    this.chartRendererKey,
    super.key,
    Duration swapAnimationDuration = const Duration(milliseconds: 150),
    Curve swapAnimationCurve = Curves.linear,
  }) : super(
          duration: swapAnimationDuration,
          curve: swapAnimationCurve,
        );

  /// Determines how the [BarHChart] should be look like.
  final BarHChartData data;

  /// We pass this key to our renderers which are supposed to
  /// render the chart itself (without anything around the chart).
  final Key? chartRendererKey;

  /// Creates a [_BarHChartState]
  @override
  _BarHChartState createState() => _BarHChartState();
}

class _BarHChartState extends AnimatedWidgetBaseState<BarHChart> {
  /// we handle under the hood animations (implicit animations) via this tween,
  /// it lerps between the old [BarHChartData] to the new one.
  BarHChartDataTween? _barChartDataTween;

  /// If [BarHTouchData.handleBuiltInTouches] is true, we override the callback to handle touches internally,
  /// but we need to keep the provided callback to notify it too.
  BaseTouchCallback<BarHTouchResponse>? _providedTouchCallback;

  final Map<int, List<int>> _showingTouchedTooltips = {};

  @override
  Widget build(BuildContext context) {
    final showingData = _getData();

    return AxisChartScaffoldWidget(
      data: showingData,
      chart: BarHChartLeaf(
        data: _withTouchedIndicators(_barChartDataTween!.evaluate(animation)),
        targetData: _withTouchedIndicators(showingData),
        key: widget.chartRendererKey,
      ),
    );
  }

  BarHChartData _withTouchedIndicators(BarHChartData barChartData) {
    if (!barChartData.barTouchData.enabled ||
        !barChartData.barTouchData.handleBuiltInTouches) {
      return barChartData;
    }

    final newGroups = <BarHChartGroupData>[];
    for (var i = 0; i < barChartData.barGroups.length; i++) {
      final group = barChartData.barGroups[i];

      newGroups.add(
        group.copyWith(
          showingTooltipIndicators: _showingTouchedTooltips[i],
        ),
      );
    }

    return barChartData.copyWith(
      barGroups: newGroups,
    );
  }

  BarHChartData _getData() {
    final barTouchData = widget.data.barTouchData;
    if (barTouchData.enabled && barTouchData.handleBuiltInTouches) {
      _providedTouchCallback = barTouchData.touchCallback;
      return widget.data.copyWith(
        barTouchData: widget.data.barTouchData
            .copyWith(touchCallback: _handleBuiltInTouch),
      );
    }
    return widget.data;
  }

  void _handleBuiltInTouch(
    FlTouchEvent event,
    BarHTouchResponse? touchResponse,
  ) {
    _providedTouchCallback?.call(event, touchResponse);

    if (!event.isInterestedForInteractions ||
        touchResponse == null ||
        touchResponse.spot == null) {
      setState(_showingTouchedTooltips.clear);
      return;
    }
    setState(() {
      final spot = touchResponse.spot!;
      final groupIndex = spot.touchedBarGroupIndex;
      final rodIndex = spot.touchedRodDataIndex;

      _showingTouchedTooltips.clear();
      _showingTouchedTooltips[groupIndex] = [rodIndex];
    });
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _barChartDataTween = visitor(
      _barChartDataTween,
      widget.data,
      (dynamic value) =>
          BarHChartDataTween(begin: value as BarHChartData, end: widget.data),
    ) as BarHChartDataTween?;
  }
}
