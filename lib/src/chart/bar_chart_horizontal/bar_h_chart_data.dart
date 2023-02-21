// coverage:ignore-file
import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/bar_chart_horizontal/bar_h_chart_helper.dart';
import 'package:fl_chart/src/extensions/color_extension.dart';
import 'package:fl_chart/src/utils/lerp.dart';
import 'package:fl_chart/src/utils/utils.dart';
import 'package:flutter/material.dart';

/// [BarHChart] needs this class to render itself.
///
/// It holds data needed to draw a bar chart,
/// including bar lines, colors, spaces, touches, ...
class BarHChartData extends AxisChartData with EquatableMixin {
  /// [BarHChart] draws some [barGroups] and aligns them using [alignment],
  /// if [alignment] is [BarHChartAlignment.center], you can define [groupsSpace]
  /// to apply space between them.
  ///
  /// It draws some titles on left, top, right, bottom sides per each axis number,
  /// you can modify [titlesData] to have your custom titles,
  /// also you can define the axis title (one text per axis) for each side
  /// using [axisTitleData], you can restrict the y axis using [minX], and [maxY] values.
  ///
  /// It draws a color as a background behind everything you can set it using [backgroundColor],
  /// then a grid over it, you can customize it using [gridData],
  /// and it draws 4 borders around your chart, you can customize it using [borderData].
  ///
  /// You can annotate some regions with a highlight color using [rangeAnnotations].
  ///
  /// You can modify [barTouchData] to customize touch behaviors and responses.
  ///
  /// Horizontal lines are drawn with [extraLinesData]. Vertical lines will not be painted if received.
  /// Please see issue #1149 (https://github.com/imaNNeo/fl_chart/issues/1149) for vertical lines.
  BarHChartData({
    List<BarHChartGroupData>? barGroups,
    double? groupsSpace,
    BarChartAlignment? alignment,
    FlTitlesData? titlesData,
    BarHTouchData? barTouchData,
    double? maxX,
    double? minX,
    super.baselineY,
    FlGridData? gridData,
    super.borderData,
    RangeAnnotations? rangeAnnotations,
    super.backgroundColor,
    ExtraLinesData? extraLinesData,
  })  : barGroups = barGroups ?? const [],
        groupsSpace = groupsSpace ?? 16,
        alignment = alignment ?? BarChartAlignment.spaceEvenly,
        barTouchData = barTouchData ?? BarHTouchData(),
        super(
          titlesData: titlesData ??
              FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
          gridData: gridData ?? FlGridData(),
          rangeAnnotations: rangeAnnotations ?? RangeAnnotations(),
          touchData: barTouchData ?? BarHTouchData(),
          extraLinesData: extraLinesData ?? ExtraLinesData(),
          minY: 0,
          maxY: 1,
          maxX: maxX ??
              BarHChartHelper.calculateMaxAxisValues(barGroups ?? []).maxX,
          minX: minX ??
              BarHChartHelper.calculateMaxAxisValues(barGroups ?? []).minX,
        );

  /// [BarHChart] draws [barGroups] that each of them contains a list of [BarHChartRodData].
  final List<BarHChartGroupData> barGroups;

  /// Apply space between the [barGroups].
  final double groupsSpace;

  /// Arrange the [barGroups], see [BarHChartAlignment].
  final BarChartAlignment alignment;

  /// Handles touch behaviors and responses.
  final BarHTouchData barTouchData;

  /// Copies current [BarHChartData] to a new [BarHChartData],
  /// and replaces provided values.
  BarHChartData copyWith({
    List<BarHChartGroupData>? barGroups,
    double? groupsSpace,
    BarChartAlignment? alignment,
    FlTitlesData? titlesData,
    RangeAnnotations? rangeAnnotations,
    BarHTouchData? barTouchData,
    FlGridData? gridData,
    FlBorderData? borderData,
    double? maxX,
    double? minX,
    double? baselineY,
    Color? backgroundColor,
    ExtraLinesData? extraLinesData,
  }) {
    return BarHChartData(
      barGroups: barGroups ?? this.barGroups,
      groupsSpace: groupsSpace ?? this.groupsSpace,
      alignment: alignment ?? this.alignment,
      titlesData: titlesData ?? this.titlesData,
      rangeAnnotations: rangeAnnotations ?? this.rangeAnnotations,
      barTouchData: barTouchData ?? this.barTouchData,
      gridData: gridData ?? this.gridData,
      borderData: borderData ?? this.borderData,
      maxX: maxX ?? this.maxX,
      minX: minX ?? this.minX,
      baselineY: baselineY ?? this.baselineY,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      extraLinesData: extraLinesData ?? this.extraLinesData,
    );
  }

  /// Lerps a [BaseChartData] based on [t] value, check [Tween.lerp].
  @override
  BarHChartData lerp(BaseChartData a, BaseChartData b, double t) {
    if (a is BarHChartData && b is BarHChartData) {
      return BarHChartData(
        barGroups: lerpBarHChartGroupDataList(a.barGroups, b.barGroups, t),
        groupsSpace: lerpDouble(a.groupsSpace, b.groupsSpace, t),
        alignment: b.alignment,
        titlesData: FlTitlesData.lerp(a.titlesData, b.titlesData, t),
        rangeAnnotations:
            RangeAnnotations.lerp(a.rangeAnnotations, b.rangeAnnotations, t),
        barTouchData: b.barTouchData,
        gridData: FlGridData.lerp(a.gridData, b.gridData, t),
        borderData: FlBorderData.lerp(a.borderData, b.borderData, t),
        maxX: lerpDouble(a.maxX, b.maxX, t),
        minX: lerpDouble(a.minX, b.minX, t),
        baselineY: lerpDouble(a.baselineY, b.baselineY, t),
        backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
        extraLinesData:
            ExtraLinesData.lerp(a.extraLinesData, b.extraLinesData, t),
      );
    } else {
      throw Exception('Illegal State');
    }
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        barGroups,
        groupsSpace,
        alignment,
        titlesData,
        barTouchData,
        maxX,
        minX,
        baselineY,
        gridData,
        borderData,
        rangeAnnotations,
        backgroundColor,
        extraLinesData,
      ];
}

/// Represents a group of rods (or bars) inside the [BarHChart].
///
/// in the [BarHChart] we have some rods, they can be grouped or not,
/// if you want to have grouped bars, simply put them in each group,
/// otherwise just pass one of them in each group.
class BarHChartGroupData with EquatableMixin {
  /// [BarHChart] renders groups, and arrange them using [alignment],
  /// [y] value defines the group's value in the x axis (set them incrementally).
  /// it renders a list of [BarHChartRodData] that represents a rod (or a bar) in the bar chart,
  /// and applies [barsSpace] between them.
  ///
  /// you can show some tooltipIndicators (a popup with an information)
  /// on top of each [BarHChartRodData] using [showingTooltipIndicators],
  /// just put indices you want to show it on top of them.
  BarHChartGroupData({
    required this.y,
    bool? groupHorizontally,
    List<BarHChartRodData>? barRods,
    double? barsSpace,
    List<int>? showingTooltipIndicators,
  })  : groupHorizontally = groupHorizontally ?? false,
        barRods = barRods ?? const [],
        barsSpace = barsSpace ?? 2,
        showingTooltipIndicators = showingTooltipIndicators ?? const [];

  /// Order along the x axis in which titles, and titles only, will be shown.
  ///
  /// Note [y] does not reorder bars from [barRods]; instead, it gets the title
  /// in [y] position through [SideTitles.getTitlesWidget] function.
  @required
  final int y;

  /// If set true, it will show bars below/above each other.
  /// Otherwise, it will show bars beside each other.
  final bool groupHorizontally;

  /// [BarHChart] renders [barRods] that represents a rod (or a bar) in the bar chart.
  final List<BarHChartRodData> barRods;

  /// [BarHChart] applies [barsSpace] between [barRods] if [groupHorizontally] is false.
  final double barsSpace;

  /// you can show some tooltipIndicators (a popup with an information)
  /// on top of each [BarHChartRodData] using [showingTooltipIndicators],
  /// just put indices you want to show it on top of them.
  final List<int> showingTooltipIndicators;

  /// height of the group (sum of all [BarHChartRodData]'s height and spaces)
  double get height {
    if (barRods.isEmpty) {
      return 0;
    }

    if (groupHorizontally) {
      return barRods.map((rodData) => rodData.height).reduce(max);
    } else {
      final sumHeight = barRods
          .map((rodData) => rodData.height)
          .reduce((first, second) => first + second);
      final spaces = (barRods.length - 1) * barsSpace;

      return sumHeight + spaces;
    }
  }

  /// Copies current [BarHChartGroupData] to a new [BarHChartGroupData],
  /// and replaces provided values.
  BarHChartGroupData copyWith({
    int? y,
    bool? groupHorizontally,
    List<BarHChartRodData>? barRods,
    double? barsSpace,
    List<int>? showingTooltipIndicators,
  }) {
    return BarHChartGroupData(
      y: y ?? this.y,
      groupHorizontally: groupHorizontally ?? this.groupHorizontally,
      barRods: barRods ?? this.barRods,
      barsSpace: barsSpace ?? this.barsSpace,
      showingTooltipIndicators:
          showingTooltipIndicators ?? this.showingTooltipIndicators,
    );
  }

  /// Lerps a [BarHChartGroupData] based on [t] value, check [Tween.lerp].
  static BarHChartGroupData lerp(
    BarHChartGroupData a,
    BarHChartGroupData b,
    double t,
  ) {
    return BarHChartGroupData(
      y: (a.y + (b.y - a.y) * t).round(),
      groupHorizontally: b.groupHorizontally,
      barRods: lerpBarHChartRodDataList(a.barRods, b.barRods, t),
      barsSpace: lerpDouble(a.barsSpace, b.barsSpace, t),
      showingTooltipIndicators: lerpIntList(
        a.showingTooltipIndicators,
        b.showingTooltipIndicators,
        t,
      ),
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        y,
        groupHorizontally,
        barRods,
        barsSpace,
        showingTooltipIndicators,
      ];
}

/// Holds data about rendering each rod (or bar) in the [BarHChart].
class BarHChartRodData with EquatableMixin {
  /// [BarHChart] renders rods vertically from zero to [toY],
  /// and the x is equivalent to the [BarHChartGroupData.x] value.
  ///
  /// It renders each rod using [color], [width], and [borderRadius] for rounding corners and also [borderSide] for stroke border.
  ///
  /// This bar draws with provided [color] or [gradient].
  /// You must provide one of them.
  ///
  /// If you want to have a bar drawn in rear of this rod, use [backDrawRodData],
  /// it uses to have a bar with a passive color in rear of the rod,
  /// for example you can use it as the maximum value place holder.
  ///
  /// If you are a fan of stacked charts (If you don't know what is it, google it),
  /// you can fill up the [rodStackItems] to have a Stacked Chart.
  /// for example if you want to have a Stacked Chart with three colors:
  /// ```
  /// BarHChartRodData(
  ///   y: 9,
  ///   color: Colors.grey,
  ///   rodStackItems: [
  ///     BarHChartRodStackItem(0, 3, Colors.red),
  ///     BarHChartRodStackItem(3, 6, Colors.green),
  ///     BarHChartRodStackItem(6, 9, Colors.blue),
  ///   ]
  /// )
  /// ```
  BarHChartRodData({
    double? fromX,
    required this.toX,
    Color? color,
    this.gradient,
    double? height,
    BorderRadius? borderRadius,
    BorderSide? borderSide,
    BackgroundBarHChartRodData? backDrawRodData,
    List<BarHChartRodStackItem>? rodStackItems,
  })  : fromX = fromX ?? 0,
        color =
            color ?? ((color == null && gradient == null) ? Colors.cyan : null),
        height = height ?? 8,
        borderRadius = Utils().normalizeBorderRadius(borderRadius, height ?? 8),
        borderSide = Utils().normalizeBorderSide(borderSide, height ?? 8),
        backDrawRodData = backDrawRodData ?? BackgroundBarHChartRodData(),
        rodStackItems = rodStackItems ?? const [];

  /// [BarHChart] renders rods vertically from [fromX].
  final double fromX;

  /// [BarHChart] renders rods vertically from [fromX] to [toX].
  final double toX;

  /// If provided, this [BarHChartRodData] draws with this [color]
  /// Otherwise we use  [gradient] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Color? color;

  /// If provided, this [BarHChartRodData] draws with this [gradient].
  /// Otherwise we use [color] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Gradient? gradient;

  /// [BarHChart] renders each rods with this value.
  final double height;

  /// If you want to have a rounded rod, set this value.
  final BorderRadius? borderRadius;

  /// If you want to have a border for rod, set this value.
  final BorderSide borderSide;

  /// If you want to have a bar drawn in rear of this rod, use [backDrawRodData],
  /// it uses to have a bar with a passive color in rear of the rod,
  /// for example you can use it as the maximum value place holder.
  final BackgroundBarHChartRodData backDrawRodData;

  /// If you are a fan of stacked charts (If you don't know what is it, google it),
  /// you can fill up the [rodStackItems] to have a Stacked Chart.
  final List<BarHChartRodStackItem> rodStackItems;

  /// Determines the upward or downward direction
  bool isUpward() => toX >= fromX;

  /// Copies current [BarHChartRodData] to a new [BarHChartRodData],
  /// and replaces provided values.
  BarHChartRodData copyWith({
    double? fromX,
    double? toX,
    Color? color,
    Gradient? gradient,
    double? height,
    BorderRadius? borderRadius,
    BorderSide? borderSide,
    BackgroundBarHChartRodData? backDrawRodData,
    List<BarHChartRodStackItem>? rodStackItems,
  }) {
    return BarHChartRodData(
      fromX: fromX ?? this.fromX,
      toX: toX ?? this.toX,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      borderSide: borderSide ?? this.borderSide,
      backDrawRodData: backDrawRodData ?? this.backDrawRodData,
      rodStackItems: rodStackItems ?? this.rodStackItems,
    );
  }

  /// Lerps a [BarHChartRodData] based on [t] value, check [Tween.lerp].
  static BarHChartRodData lerp(
    BarHChartRodData a,
    BarHChartRodData b,
    double t,
  ) {
    return BarHChartRodData(
      // ignore: invalid_use_of_protected_member
      gradient: a.gradient?.lerpTo(b.gradient, t),
      color: Color.lerp(a.color, b.color, t),
      height: lerpDouble(a.height, b.height, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      borderSide: BorderSide.lerp(a.borderSide, b.borderSide, t),
      fromX: lerpDouble(a.fromX, b.fromX, t),
      toX: lerpDouble(a.toX, b.toX, t)!,
      backDrawRodData: BackgroundBarHChartRodData.lerp(
        a.backDrawRodData,
        b.backDrawRodData,
        t,
      ),
      rodStackItems:
          lerpBarHChartRodStackList(a.rodStackItems, b.rodStackItems, t),
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        fromX,
        toX,
        height,
        borderRadius,
        borderSide,
        backDrawRodData,
        rodStackItems,
        color,
        gradient,
      ];
}

/// A colored section of Stacked Chart rod item
///
/// Each [BarHChartRodData] can have a list of [BarHChartRodStackItem] (with different colors
/// and position) to represent a Stacked Chart rod,
class BarHChartRodStackItem with EquatableMixin {
  /// Renders a section of Stacked Chart from [fromY] to [toY] with [color]
  /// for example if you want to have a Stacked Chart with three colors:
  /// ```
  /// BarHChartRodData(
  ///   y: 9,
  ///   color: Colors.grey,
  ///   rodStackItems: [
  ///     BarHChartRodStackItem(0, 3, Colors.red),
  ///     BarHChartRodStackItem(3, 6, Colors.green),
  ///     BarHChartRodStackItem(6, 9, Colors.blue),
  ///   ]
  /// )
  /// ```
  BarHChartRodStackItem(
    this.fromX,
    this.toX,
    this.color, [
    this.borderSide = Utils.defaultBorderSide,
  ]);

  /// Renders a Stacked Chart section from [fromX]
  final double fromX;

  /// Renders a Stacked Chart section to [toX]
  final double toX;

  /// Renders a Stacked Chart section with [color]
  final Color color;

  /// Renders border stroke for a Stacked Chart section
  final BorderSide borderSide;

  /// Copies current [BarHChartRodStackItem] to a new [BarHChartRodStackItem],
  /// and replaces provided values.
  BarHChartRodStackItem copyWith({
    double? fromX,
    double? toX,
    Color? color,
    BorderSide? borderSide,
  }) {
    return BarHChartRodStackItem(
      fromX ?? this.fromX,
      toX ?? this.toX,
      color ?? this.color,
      borderSide ?? this.borderSide,
    );
  }

  /// Lerps a [BarHChartRodStackItem] based on [t] value, check [Tween.lerp].
  static BarHChartRodStackItem lerp(
    BarHChartRodStackItem a,
    BarHChartRodStackItem b,
    double t,
  ) {
    return BarHChartRodStackItem(
      lerpDouble(a.fromX, b.fromX, t)!,
      lerpDouble(a.toX, b.toX, t)!,
      Color.lerp(a.color, b.color, t)!,
      BorderSide.lerp(a.borderSide, b.borderSide, t),
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [fromX, toX, color, borderSide];
}

/// Holds values to draw a rod in rear of the main rod.
///
/// If you want to have a bar drawn in rear of the main rod, use [BarHChartRodData.backDrawRodData],
/// it uses to have a bar with a passive color in rear of the rod,
/// for example you can use it as the maximum value place holder in rear of your rod.
class BackgroundBarHChartRodData with EquatableMixin {
  /// It will be rendered in rear of the main rod,
  /// background starts to show from [fromX] to [toX],
  /// It draws with [color] or [gradient]. You must provide one of them,
  /// you prevent to show it, using [show] property.
  BackgroundBarHChartRodData({
    double? fromX,
    double? toX,
    bool? show,
    Color? color,
    this.gradient,
  })  : fromX = fromX ?? 0,
        toX = toX ?? 0,
        show = show ?? false,
        color = color ??
            ((color == null && gradient == null) ? Colors.blueGrey : null);

  /// Determines to show or hide this
  final bool show;

  /// [fromX] is where background starts to show
  final double fromX;

  /// background starts to show from [fromX] to [toX]
  final double toX;

  /// If provided, Background draws with this [color]
  /// Otherwise we use  [gradient] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Color? color;

  /// If provided, background draws with this [gradient].
  /// Otherwise we use [color] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Gradient? gradient;

  /// Lerps a [BackgroundBarHChartRodData] based on [t] value, check [Tween.lerp].
  static BackgroundBarHChartRodData lerp(
    BackgroundBarHChartRodData a,
    BackgroundBarHChartRodData b,
    double t,
  ) {
    return BackgroundBarHChartRodData(
      fromX: lerpDouble(a.fromX, b.fromX, t),
      toX: lerpDouble(a.toX, b.toX, t),
      color: Color.lerp(a.color, b.color, t),
      // ignore: invalid_use_of_protected_member
      gradient: a.gradient?.lerpTo(b.gradient, t),
      show: b.show,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
        fromX,
        toX,
        color,
        gradient,
      ];
}

/// Holds data to handle touch events, and touch responses in the [BarHChart].
///
/// There is a touch flow, explained [here](https://github.com/imaNNeo/fl_chart/blob/master/repo_files/documentations/handle_touches.md)
/// in a simple way, each chart's renderer captures the touch events, and passes the pointerEvent
/// to the painter, and gets touched spot, and wraps it into a concrete [BarHTouchResponse].
class BarHTouchData extends FlTouchData<BarHTouchResponse> with EquatableMixin {
  /// You can disable or enable the touch system using [enabled] flag,
  ///
  /// [touchCallback] notifies you about the happened touch/pointer events.
  /// It gives you a [FlTouchEvent] which is the happened event such as [FlPointerHoverEvent], [FlTapUpEvent], ...
  /// It also gives you a [BarHTouchResponse] which contains information
  /// about the elements that has touched.
  ///
  /// Using [mouseCursorResolver] you can change the mouse cursor
  /// based on the provided [FlTouchEvent] and [BarHTouchResponse]
  ///
  /// if [handleBuiltInTouches] is true, [BarHChart] shows a tooltip popup on top of the bars if
  /// touch occurs (or you can show it manually using, [BarHChartGroupData.showingTooltipIndicators]),
  /// You can customize this tooltip using [touchTooltipData].
  /// If you need to have a distance threshold for handling touches, use [touchExtraThreshold].
  /// If [allowTouchBarHBackDraw] sets to true, touches will work
  /// on [BarHChartRodData.backDrawRodData] too (by default it only works on the main rods).
  BarHTouchData({
    bool? enabled,
    BaseTouchCallback<BarHTouchResponse>? touchCallback,
    MouseCursorResolver<BarHTouchResponse>? mouseCursorResolver,
    Duration? longPressDuration,
    BarHTouchTooltipData? touchTooltipData,
    EdgeInsets? touchExtraThreshold,
    bool? allowTouchBarHBackDraw,
    bool? handleBuiltInTouches,
  })  : touchTooltipData = touchTooltipData ?? BarHTouchTooltipData(),
        touchExtraThreshold = touchExtraThreshold ?? const EdgeInsets.all(4),
        allowTouchBarHBackDraw = allowTouchBarHBackDraw ?? false,
        handleBuiltInTouches = handleBuiltInTouches ?? true,
        super(
          enabled ?? true,
          touchCallback,
          mouseCursorResolver,
          longPressDuration,
        );

  /// Configs of how touch tooltip popup.
  final BarHTouchTooltipData touchTooltipData;

  /// Distance threshold to handle the touch event.
  final EdgeInsets touchExtraThreshold;

  /// Determines to handle touches on the back draw bar.
  final bool allowTouchBarHBackDraw;

  /// Determines to handle default built-in touch responses,
  /// [BarHTouchResponse] shows a tooltip popup above the touched spot.
  final bool handleBuiltInTouches;

  /// Copies current [BarHTouchData] to a new [BarHTouchData],
  /// and replaces provided values.
  BarHTouchData copyWith({
    bool? enabled,
    BaseTouchCallback<BarHTouchResponse>? touchCallback,
    MouseCursorResolver<BarHTouchResponse>? mouseCursorResolver,
    Duration? longPressDuration,
    BarHTouchTooltipData? touchTooltipData,
    EdgeInsets? touchExtraThreshold,
    bool? allowTouchBarHBackDraw,
    bool? handleBuiltInTouches,
  }) {
    return BarHTouchData(
      enabled: enabled ?? this.enabled,
      touchCallback: touchCallback ?? this.touchCallback,
      mouseCursorResolver: mouseCursorResolver ?? this.mouseCursorResolver,
      longPressDuration: longPressDuration ?? this.longPressDuration,
      touchTooltipData: touchTooltipData ?? this.touchTooltipData,
      touchExtraThreshold: touchExtraThreshold ?? this.touchExtraThreshold,
      allowTouchBarHBackDraw:
          allowTouchBarHBackDraw ?? this.allowTouchBarHBackDraw,
      handleBuiltInTouches: handleBuiltInTouches ?? this.handleBuiltInTouches,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        enabled,
        touchCallback,
        mouseCursorResolver,
        longPressDuration,
        touchTooltipData,
        touchExtraThreshold,
        allowTouchBarHBackDraw,
        handleBuiltInTouches,
      ];
}

/// Holds representation data for showing tooltip popup on top of rods.
class BarHTouchTooltipData with EquatableMixin {
  /// if [BarHTouchData.handleBuiltInTouches] is true,
  /// [BarHChart] shows a tooltip popup on top of rods automatically when touch happens,
  /// otherwise you can show it manually using [BarHChartGroupData.showingTooltipIndicators].
  /// Tooltip shows on top of rods, with [tooltipBgColor] as a background color,
  /// and you can set corner radius using [tooltipRoundedRadius].
  /// If you want to have a padding inside the tooltip, fill [tooltipPadding],
  /// or If you want to have a bottom margin, set [tooltipMargin].
  /// Content of the tooltip will provide using [getTooltipItem] callback, you can override it
  /// and pass your custom data to show in the tooltip.
  /// You can restrict the tooltip's width using [maxContentWidth].
  /// Sometimes, [BarHChart] shows the tooltip outside of the chart,
  /// you can set [fitInsideHorizontally] true to force it to shift inside the chart horizontally,
  /// also you can set [fitInsideVertically] true to force it to shift inside the chart vertically.
  BarHTouchTooltipData({
    Color? tooltipBgColor,
    double? tooltipRoundedRadius,
    EdgeInsets? tooltipPadding,
    double? tooltipMargin,
    FLHorizontalAlignment? tooltipHorizontalAlignment,
    double? tooltipHorizontalOffset,
    double? maxContentWidth,
    GetBarHTooltipItem? getTooltipItem,
    bool? fitInsideHorizontally,
    bool? fitInsideVertically,
    TooltipDirection? direction,
    double? rotateAngle,
    BorderSide? tooltipBorder,
  })  : tooltipBgColor = tooltipBgColor ?? Colors.blueGrey.darken(15),
        tooltipRoundedRadius = tooltipRoundedRadius ?? 4,
        tooltipPadding = tooltipPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tooltipMargin = tooltipMargin ?? 16,
        tooltipHorizontalAlignment =
            tooltipHorizontalAlignment ?? FLHorizontalAlignment.center,
        tooltipHorizontalOffset = tooltipHorizontalOffset ?? 0,
        maxContentWidth = maxContentWidth ?? 120,
        getTooltipItem = getTooltipItem ?? defaultBarHTooltipItem,
        fitInsideHorizontally = fitInsideHorizontally ?? false,
        fitInsideVertically = fitInsideVertically ?? false,
        direction = direction ?? TooltipDirection.auto,
        rotateAngle = rotateAngle ?? 0.0,
        tooltipBorder = tooltipBorder ?? BorderSide.none,
        super();

  /// The tooltip background color.
  final Color tooltipBgColor;

  /// Sets a rounded radius for the tooltip.
  final double tooltipRoundedRadius;

  /// Applies a padding for showing contents inside the tooltip.
  final EdgeInsets tooltipPadding;

  /// Applies a bottom margin for showing tooltip on top of rods.
  final double tooltipMargin;

  /// Controls showing tooltip on left side, right side or center aligned with rod, default is center
  final FLHorizontalAlignment tooltipHorizontalAlignment;

  /// Applies horizontal offset for showing tooltip, default is zero.
  final double tooltipHorizontalOffset;

  /// Restricts the tooltip's width.
  final double maxContentWidth;

  /// Retrieves data for showing content inside the tooltip.
  final GetBarHTooltipItem getTooltipItem;

  /// Forces the tooltip to shift horizontally inside the chart, if overflow happens.
  final bool fitInsideHorizontally;

  /// Forces the tooltip to shift vertically inside the chart, if overflow happens.
  final bool fitInsideVertically;

  /// Controls showing tooltip on top or bottom, default is auto.
  final TooltipDirection direction;

  /// Controls the rotation of the tooltip.
  final double rotateAngle;

  /// The tooltip border color.
  final BorderSide tooltipBorder;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        tooltipBgColor,
        tooltipRoundedRadius,
        tooltipPadding,
        tooltipMargin,
        tooltipHorizontalAlignment,
        tooltipHorizontalOffset,
        maxContentWidth,
        getTooltipItem,
        fitInsideHorizontally,
        fitInsideVertically,
        rotateAngle,
        tooltipBorder,
      ];
}

/// Provides a [BarHTooltipItem] for showing content inside the [BarHTouchTooltipData].
///
/// You can override [BarHTouchTooltipData.getTooltipItem], it gives you
/// [group], [groupIndex], [rod], and [rodIndex] that touch happened on,
/// then you should and pass your custom [BarHTooltipItem] to show inside the tooltip popup.
typedef GetBarHTooltipItem = BarHTooltipItem? Function(
  BarHChartGroupData group,
  int groupIndex,
  BarHChartRodData rod,
  int rodIndex,
);

/// Default implementation for [BarHTouchTooltipData.getTooltipItem].
BarHTooltipItem? defaultBarHTooltipItem(
  BarHChartGroupData group,
  int groupIndex,
  BarHChartRodData rod,
  int rodIndex,
) {
  final color = rod.gradient?.colors.first ?? rod.color;
  final textStyle = TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  return BarHTooltipItem(rod.toX.toString(), textStyle);
}

/// Holds data needed for showing custom tooltip content.
class BarHTooltipItem with EquatableMixin {
  /// content of the tooltip, is a [text] String with a [textStyle],
  /// [textDirection] and optional [children].
  BarHTooltipItem(
    this.text,
    this.textStyle, {
    this.textAlign = TextAlign.center,
    this.textDirection = TextDirection.ltr,
    this.children,
  });

  /// Text of the content.
  final String text;

  /// TextStyle of the showing content.
  final TextStyle textStyle;

  /// TextAlign of the showing content.
  final TextAlign textAlign;

  /// Direction of showing text.
  final TextDirection textDirection;

  /// List<TextSpan> add further style and format to the text of the tooltip
  final List<TextSpan>? children;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        text,
        textStyle,
        textAlign,
        textDirection,
        children,
      ];
}

/// Holds information about touch response in the [BarHChart].
///
/// You can override [BarHTouchData.touchCallback] to handle touch events,
/// it gives you a [BarHTouchResponse] and you can do whatever you want.
class BarHTouchResponse extends BaseTouchResponse {
  /// If touch happens, [BarHChart] processes it internally and passes out a BarHTouchedSpot
  /// that contains a [spot], it gives you information about the touched spot.
  BarHTouchResponse(this.spot) : super();

  /// Gives information about the touched spot
  final BarHTouchedSpot? spot;

  /// Copies current [BarHTouchResponse] to a new [BarHTouchResponse],
  /// and replaces provided values.
  BarHTouchResponse copyWith({
    BarHTouchedSpot? spot,
  }) {
    return BarHTouchResponse(
      spot ?? this.spot,
    );
  }
}

/// It gives you information about the touched spot.
class BarHTouchedSpot extends TouchedSpot with EquatableMixin {
  /// When touch happens, a [BarHTouchedSpot] returns as a output,
  /// it tells you where the touch happened.
  /// [touchedBarGroup], and [touchedBarGroupIndex] tell you in which group touch happened,
  /// [touchedRodData], and [touchedRodDataIndex] tell you in which rod touch happened,
  /// [touchedStackItem], and [touchedStackItemIndex] tell you in which rod stack touch happened
  /// ([touchedStackItemIndex] means nothing found).
  /// You can also have the touched x and y in the chart as a [FlSpot] using [spot] value,
  /// and you can have the local touch coordinates on the screen as a [Offset] using [offset] value.
  BarHTouchedSpot(
    this.touchedBarGroup,
    this.touchedBarGroupIndex,
    this.touchedRodData,
    this.touchedRodDataIndex,
    this.touchedStackItem,
    this.touchedStackItemIndex,
    FlSpot spot,
    Offset offset,
  ) : super(spot, offset);
  final BarHChartGroupData touchedBarGroup;
  final int touchedBarGroupIndex;

  final BarHChartRodData touchedRodData;
  final int touchedRodDataIndex;

  /// It can be null, if nothing found
  final BarHChartRodStackItem? touchedStackItem;

  /// It can be -1, if nothing found
  final int touchedStackItemIndex;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        touchedBarGroup,
        touchedBarGroupIndex,
        touchedRodData,
        touchedRodDataIndex,
        touchedStackItem,
        touchedStackItemIndex,
        spot,
        offset,
      ];
}

/// It lerps a [BarHChartData] to another [BarHChartData] (handles animation for updating values)
class BarHChartDataTween extends Tween<BarHChartData> {
  BarHChartDataTween({required BarHChartData begin, required BarHChartData end})
      : super(begin: begin, end: end);

  /// Lerps a [BarHChartData] based on [t] value, check [Tween.lerp].
  @override
  BarHChartData lerp(double t) => begin!.lerp(begin!, end!, t);
}
