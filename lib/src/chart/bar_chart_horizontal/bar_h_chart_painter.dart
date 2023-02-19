import 'dart:core';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/extensions/bar_chart_data_extension.dart';
import 'package:fl_chart/src/extensions/bar_h_chart_data_extension.dart';
import 'package:fl_chart/src/extensions/paint_extension.dart';
import 'package:fl_chart/src/extensions/rrect_extension.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:fl_chart/src/utils/utils.dart';
import 'package:flutter/material.dart';

/// Paints [BarHChartData] in the canvas, it can be used in a [CustomPainter]
class BarHChartPainter extends AxisChartPainter<BarHChartData> {
  /// Paints [dataList] into canvas, it is the animating [BarHChartData],
  /// [targetData] is the animation's target and remains the same
  /// during animation, then we should use it  when we need to show
  /// tooltips or something like that, because [dataList] is changing constantly.
  ///
  /// [textScale] used for scaling texts inside the chart,
  /// parent can use [MediaQuery.textScaleFactor] to respect
  /// the system's font size.
  BarHChartPainter() : super() {
    _barPaint = Paint()..style = PaintingStyle.fill;
    _barStrokePaint = Paint()..style = PaintingStyle.stroke;

    _bgTouchTooltipPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    _borderTouchTooltipPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.transparent
      ..strokeWidth = 1.0;
  }
  late Paint _barPaint;
  late Paint _barStrokePaint;
  late Paint _bgTouchTooltipPaint;
  late Paint _borderTouchTooltipPaint;

  List<GroupBarHsPosition>? _groupBarHsPosition;

  /// Paints [BarHChartData] into the provided canvas.
  @override
  void paint(
    BuildContext context,
    CanvasWrapper canvasWrapper,
    PaintHolder<BarHChartData> holder,
  ) {
    super.paint(context, canvasWrapper, holder);
    final data = holder.data;
    final targetData = holder.targetData;

    if (data.barGroups.isEmpty) {
      return;
    }

    final groupsX = data.calculateGroupsX(canvasWrapper.size.width);
    _groupBarHsPosition = calculateGroupAndBarHsPosition(
      canvasWrapper.size,
      groupsX,
      data.barGroups,
    );

    if (!data.extraLinesData.extraLinesOnTop) {
      super.drawHorizontalLines(
        context,
        canvasWrapper,
        holder,
        canvasWrapper.size,
      );
    }

    drawBarHs(canvasWrapper, _groupBarHsPosition!, holder);

    if (data.extraLinesData.extraLinesOnTop) {
      super.drawHorizontalLines(
        context,
        canvasWrapper,
        holder,
        canvasWrapper.size,
      );
    }

    for (var i = 0; i < targetData.barGroups.length; i++) {
      final barGroup = targetData.barGroups[i];
      for (var j = 0; j < barGroup.barRods.length; j++) {
        if (!barGroup.showingTooltipIndicators.contains(j)) {
          continue;
        }
        final barRod = barGroup.barRods[j];

        drawTouchTooltip(
          context,
          canvasWrapper,
          _groupBarHsPosition!,
          targetData.barTouchData.touchTooltipData,
          barGroup,
          i,
          barRod,
          j,
          holder,
        );
      }
    }
  }

  /// Calculates bars position alongside group positions.
  @visibleForTesting
  List<GroupBarHsPosition> calculateGroupAndBarHsPosition(
    Size viewSize,
    List<double> groupsX,
    List<BarHChartGroupData> barGroups,
  ) {
    if (groupsX.length != barGroups.length) {
      throw Exception('inconsistent state groupsX.length != barGroups.length');
    }

    final groupBarHsPosition = <GroupBarHsPosition>[];
    for (var i = 0; i < barGroups.length; i++) {
      final barGroup = barGroups[i];
      final groupX = groupsX[i];
      if (barGroup.groupVertically) {
        groupBarHsPosition.add(
          GroupBarHsPosition(
            groupX,
            List.generate(barGroup.barRods.length, (index) => groupX),
          ),
        );
        continue;
      }

      var tempX = 0.0;
      final barsX = <double>[];
      barGroup.barRods.asMap().forEach((barIndex, barRod) {
        final widthHalf = barRod.width / 2;
        barsX.add(groupX - (barGroup.width / 2) + tempX + widthHalf);
        tempX += barRod.width + barGroup.barsSpace;
      });
      groupBarHsPosition.add(GroupBarHsPosition(groupX, barsX));
    }
    return groupBarHsPosition;
  }

  @visibleForTesting
  void drawBarHs(
    CanvasWrapper canvasWrapper,
    List<GroupBarHsPosition> groupBarHsPosition,
    PaintHolder<BarHChartData> holder,
  ) {
    final data = holder.data;
    final viewSize = canvasWrapper.size;

    for (var i = 0; i < data.barGroups.length; i++) {
      final barGroup = data.barGroups[i];
      for (var j = 0; j < barGroup.barRods.length; j++) {
        final barRod = barGroup.barRods[j];
        final widthHalf = barRod.width / 2;
        final borderRadius =
            barRod.borderRadius ?? BorderRadius.circular(barRod.width / 2);
        final borderSide = barRod.borderSide;

        final x = groupBarHsPosition[i].barsX[j];

        final left = x - widthHalf;
        final right = x + widthHalf;
        final cornerHeight =
            max(borderRadius.topLeft.y, borderRadius.topRight.y) +
                max(borderRadius.bottomLeft.y, borderRadius.bottomRight.y);

        RRect barRRect;

        /// Draw [BackgroundBarHChartRodData]
        if (barRod.backDrawRodData.show &&
            barRod.backDrawRodData.toY != barRod.backDrawRodData.fromY) {
          if (barRod.backDrawRodData.toY > barRod.backDrawRodData.fromY) {
            // positive
            final bottom = getPixelY(
              max(data.minY, barRod.backDrawRodData.fromY),
              viewSize,
              holder,
            );
            final top = min(
              getPixelY(barRod.backDrawRodData.toY, viewSize, holder),
              bottom - cornerHeight,
            );

            barRRect = RRect.fromLTRBAndCorners(
              left,
              top,
              right,
              bottom,
              topLeft: borderRadius.topLeft,
              topRight: borderRadius.topRight,
              bottomLeft: borderRadius.bottomLeft,
              bottomRight: borderRadius.bottomRight,
            );
          } else {
            // negative
            final top = getPixelY(
              min(data.maxY, barRod.backDrawRodData.fromY),
              viewSize,
              holder,
            );
            final bottom = max(
              getPixelY(barRod.backDrawRodData.toY, viewSize, holder),
              top + cornerHeight,
            );

            barRRect = RRect.fromLTRBAndCorners(
              left,
              top,
              right,
              bottom,
              topLeft: borderRadius.topLeft,
              topRight: borderRadius.topRight,
              bottomLeft: borderRadius.bottomLeft,
              bottomRight: borderRadius.bottomRight,
            );
          }

          final backDraw = barRod.backDrawRodData;
          _barPaint.setColorOrGradient(
            backDraw.color,
            backDraw.gradient,
            barRRect.getRect(),
          );
          canvasWrapper.drawRRect(barRRect, _barPaint);
        }

        // draw Main Rod
        if (barRod.toY != barRod.fromY) {
          if (barRod.toY > barRod.fromY) {
            // positive
            final bottom =
                getPixelY(max(data.minY, barRod.fromY), viewSize, holder);
            final top = min(
              getPixelY(barRod.toY, viewSize, holder),
              bottom - cornerHeight,
            );

            barRRect = RRect.fromLTRBAndCorners(
              left,
              top,
              right,
              bottom,
              topLeft: borderRadius.topLeft,
              topRight: borderRadius.topRight,
              bottomLeft: borderRadius.bottomLeft,
              bottomRight: borderRadius.bottomRight,
            );
          } else {
            // negative
            final top =
                getPixelY(min(data.maxY, barRod.fromY), viewSize, holder);
            final bottom = max(
              getPixelY(barRod.toY, viewSize, holder),
              top + cornerHeight,
            );

            barRRect = RRect.fromLTRBAndCorners(
              left,
              top,
              right,
              bottom,
              topLeft: borderRadius.topLeft,
              topRight: borderRadius.topRight,
              bottomLeft: borderRadius.bottomLeft,
              bottomRight: borderRadius.bottomRight,
            );
          }
          _barPaint.setColorOrGradient(
            barRod.color,
            barRod.gradient,
            barRRect.getRect(),
          );
          canvasWrapper.drawRRect(barRRect, _barPaint);

          // draw border stroke
          if (borderSide.width > 0 && borderSide.color.opacity > 0) {
            _barStrokePaint
              ..color = borderSide.color
              ..strokeWidth = borderSide.width;
            canvasWrapper.drawRRect(barRRect, _barStrokePaint);
          }

          // draw rod stack
          if (barRod.rodStackItems.isNotEmpty) {
            for (var i = 0; i < barRod.rodStackItems.length; i++) {
              final stackItem = barRod.rodStackItems[i];
              final stackFromY = getPixelY(stackItem.fromY, viewSize, holder);
              final stackToY = getPixelY(stackItem.toY, viewSize, holder);

              _barPaint.color = stackItem.color;
              canvasWrapper
                ..save()
                ..clipRect(Rect.fromLTRB(left, stackToY, right, stackFromY))
                ..drawRRect(barRRect, _barPaint)
                ..restore();

              // draw border stroke for each stack item
              drawStackItemBorderStroke(
                canvasWrapper,
                stackItem,
                i,
                barRod.rodStackItems.length,
                barRod.width,
                barRRect,
                viewSize,
                holder,
              );
            }
          }
        }
      }
    }
  }

  @visibleForTesting
  void drawTouchTooltip(
    BuildContext context,
    CanvasWrapper canvasWrapper,
    List<GroupBarHsPosition> groupPositions,
    BarHTouchTooltipData tooltipData,
    BarHChartGroupData showOnBarHGroup,
    int barGroupIndex,
    BarHChartRodData showOnRodData,
    int barRodIndex,
    PaintHolder<BarHChartData> holder,
  ) {
    final viewSize = canvasWrapper.size;

    const textsBelowMargin = 4;

    final tooltipItem = tooltipData.getTooltipItem(
      showOnBarHGroup,
      barGroupIndex,
      showOnRodData,
      barRodIndex,
    );

    if (tooltipItem == null) {
      return;
    }

    final span = TextSpan(
      style: Utils().getThemeAwareTextStyle(context, tooltipItem.textStyle),
      text: tooltipItem.text,
      children: tooltipItem.children,
    );

    final tp = TextPainter(
      text: span,
      textAlign: tooltipItem.textAlign,
      textDirection: tooltipItem.textDirection,
      textScaleFactor: holder.textScale,
    )..layout(maxWidth: tooltipData.maxContentWidth);

    /// creating TextPainters to calculate the width and height of the tooltip
    final drawingTextPainter = tp;

    /// biggerWidth
    /// some texts maybe larger, then we should
    /// draw the tooltip' width as wide as biggerWidth
    ///
    /// sumTextsHeight
    /// sum up all Texts height, then we should
    /// draw the tooltip's height as tall as sumTextsHeight
    final textWidth = drawingTextPainter.width;
    final textHeight = drawingTextPainter.height + textsBelowMargin;

    /// if we have multiple bar lines,
    /// there are more than one FlCandidate on touch area,
    /// we should get the most top FlSpot Offset to draw the tooltip on top of it
    final barOffset = Offset(
      groupPositions[barGroupIndex].barsX[barRodIndex],
      getPixelY(showOnRodData.toY, viewSize, holder),
    );

    final tooltipWidth = textWidth + tooltipData.tooltipPadding.horizontal;
    final tooltipHeight = textHeight + tooltipData.tooltipPadding.vertical;

    final zeroY = getPixelY(0, viewSize, holder);
    final barTopY = min(zeroY, barOffset.dy);
    final barBottomY = max(zeroY, barOffset.dy);
    final drawTooltipOnTop = tooltipData.direction == TooltipDirection.top ||
        (tooltipData.direction == TooltipDirection.auto &&
            showOnRodData.isUpward());
    final tooltipTop = drawTooltipOnTop
        ? barTopY - tooltipHeight - tooltipData.tooltipMargin
        : barBottomY + tooltipData.tooltipMargin;

    final tooltipLeft = getTooltipLeft(
      barOffset.dx,
      tooltipWidth,
      tooltipData.tooltipHorizontalAlignment,
      tooltipData.tooltipHorizontalOffset,
    );

    /// draw the background rect with rounded radius
    // ignore: omit_local_variable_types
    Rect rect = Rect.fromLTWH(
      tooltipLeft,
      tooltipTop,
      tooltipWidth,
      tooltipHeight,
    );

    if (tooltipData.fitInsideHorizontally) {
      if (rect.left < 0) {
        final shiftAmount = 0 - rect.left;
        rect = Rect.fromLTRB(
          rect.left + shiftAmount,
          rect.top,
          rect.right + shiftAmount,
          rect.bottom,
        );
      }

      if (rect.right > viewSize.width) {
        final shiftAmount = rect.right - viewSize.width;
        rect = Rect.fromLTRB(
          rect.left - shiftAmount,
          rect.top,
          rect.right - shiftAmount,
          rect.bottom,
        );
      }
    }

    if (tooltipData.fitInsideVertically) {
      if (rect.top < 0) {
        final shiftAmount = 0 - rect.top;
        rect = Rect.fromLTRB(
          rect.left,
          rect.top + shiftAmount,
          rect.right,
          rect.bottom + shiftAmount,
        );
      }

      if (rect.bottom > viewSize.height) {
        final shiftAmount = rect.bottom - viewSize.height;
        rect = Rect.fromLTRB(
          rect.left,
          rect.top - shiftAmount,
          rect.right,
          rect.bottom - shiftAmount,
        );
      }
    }

    final radius = Radius.circular(tooltipData.tooltipRoundedRadius);
    final roundedRect = RRect.fromRectAndCorners(
      rect,
      topLeft: radius,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
    );
    _bgTouchTooltipPaint.color = tooltipData.tooltipBgColor;

    final rotateAngle = tooltipData.rotateAngle;
    final rectRotationOffset =
        Offset(0, Utils().calculateRotationOffset(rect.size, rotateAngle).dy);
    final rectDrawOffset = Offset(roundedRect.left, roundedRect.top);

    final textRotationOffset =
        Utils().calculateRotationOffset(tp.size, rotateAngle);

    /// draw the texts one by one in below of each other
    final top = tooltipData.tooltipPadding.top;
    final drawOffset = Offset(
      rect.center.dx - (tp.width / 2),
      rect.topCenter.dy + top - textRotationOffset.dy + rectRotationOffset.dy,
    );

    if (tooltipData.tooltipBorder != BorderSide.none) {
      _borderTouchTooltipPaint
        ..color = tooltipData.tooltipBorder.color
        ..strokeWidth = tooltipData.tooltipBorder.width;
    }

    canvasWrapper.drawRotated(
      size: rect.size,
      rotationOffset: rectRotationOffset,
      drawOffset: rectDrawOffset,
      angle: rotateAngle,
      drawCallback: () {
        canvasWrapper
          ..drawRRect(roundedRect, _bgTouchTooltipPaint)
          ..drawRRect(roundedRect, _borderTouchTooltipPaint)
          ..drawText(tp, drawOffset);
      },
    );
  }

  @visibleForTesting
  void drawStackItemBorderStroke(
    CanvasWrapper canvasWrapper,
    BarHChartRodStackItem stackItem,
    int index,
    int rodStacksSize,
    double barThickSize,
    RRect barRRect,
    Size drawSize,
    PaintHolder<BarHChartData> holder,
  ) {
    if (stackItem.borderSide.width == 0 ||
        stackItem.borderSide.color.opacity == 0) return;
    RRect strokeBarHRect;
    if (index == 0) {
      strokeBarHRect = RRect.fromLTRBAndCorners(
        barRRect.left,
        getPixelY(stackItem.toY, drawSize, holder),
        barRRect.right,
        getPixelY(stackItem.fromY, drawSize, holder),
        bottomLeft:
            stackItem.fromY < stackItem.toY ? barRRect.blRadius : Radius.zero,
        bottomRight:
            stackItem.fromY < stackItem.toY ? barRRect.brRadius : Radius.zero,
        topLeft:
            stackItem.fromY < stackItem.toY ? Radius.zero : barRRect.tlRadius,
        topRight:
            stackItem.fromY < stackItem.toY ? Radius.zero : barRRect.trRadius,
      );
    } else if (index == rodStacksSize - 1) {
      strokeBarHRect = RRect.fromLTRBAndCorners(
        barRRect.left,
        max(getPixelY(stackItem.toY, drawSize, holder), barRRect.top),
        barRRect.right,
        getPixelY(stackItem.fromY, drawSize, holder),
        bottomLeft:
            stackItem.fromY < stackItem.toY ? Radius.zero : barRRect.blRadius,
        bottomRight:
            stackItem.fromY < stackItem.toY ? Radius.zero : barRRect.brRadius,
        topLeft:
            stackItem.fromY < stackItem.toY ? barRRect.tlRadius : Radius.zero,
        topRight:
            stackItem.fromY < stackItem.toY ? barRRect.trRadius : Radius.zero,
      );
    } else {
      strokeBarHRect = RRect.fromLTRBR(
        barRRect.left,
        getPixelY(stackItem.toY, drawSize, holder),
        barRRect.right,
        getPixelY(stackItem.fromY, drawSize, holder),
        Radius.zero,
      );
    }
    _barStrokePaint
      ..color = stackItem.borderSide.color
      ..strokeWidth = min(stackItem.borderSide.width, barThickSize / 2);
    canvasWrapper.drawRRect(strokeBarHRect, _barStrokePaint);
  }

  /// Makes a [BarHTouchedSpot] based on the provided [localPosition]
  ///
  /// Processes [localPosition] and checks
  /// the elements of the chart that are near the offset,
  /// then makes a [BarHTouchedSpot] from the elements that has been touched.
  ///
  /// Returns null if finds nothing!
  BarHTouchedSpot? handleTouch(
    Offset localPosition,
    Size viewSize,
    PaintHolder<BarHChartData> holder,
  ) {
    final data = holder.data;
    final targetData = holder.targetData;
    final touchedPoint = localPosition;
    if (targetData.barGroups.isEmpty) {
      return null;
    }

    if (_groupBarHsPosition == null) {
      final groupsX = data.calculateGroupsX(viewSize.width);
      _groupBarHsPosition =
          calculateGroupAndBarHsPosition(viewSize, groupsX, data.barGroups);
    }

    /// Find the nearest barRod
    for (var i = 0; i < _groupBarHsPosition!.length; i++) {
      final groupBarHPos = _groupBarHsPosition![i];
      for (var j = 0; j < groupBarHPos.barsX.length; j++) {
        final barX = groupBarHPos.barsX[j];
        final barWidth = targetData.barGroups[i].barRods[j].width;
        final halfBarHWidth = barWidth / 2;

        double barTopY;
        double barBotY;

        final isUpward = targetData.barGroups[i].barRods[j].isUpward();
        if (isUpward) {
          barTopY = getPixelY(
            targetData.barGroups[i].barRods[j].toY,
            viewSize,
            holder,
          );
          barBotY = getPixelY(
            targetData.barGroups[i].barRods[j].fromY,
            viewSize,
            holder,
          );
        } else {
          barTopY = getPixelY(
            targetData.barGroups[i].barRods[j].fromY,
            viewSize,
            holder,
          );
          barBotY = getPixelY(
            targetData.barGroups[i].barRods[j].toY,
            viewSize,
            holder,
          );
        }

        final backDrawBarHY = getPixelY(
          targetData.barGroups[i].barRods[j].backDrawRodData.toY,
          viewSize,
          holder,
        );
        final touchExtraThreshold = targetData.barTouchData.touchExtraThreshold;

        final isXInTouchBounds = (touchedPoint.dx <=
                barX + halfBarHWidth + touchExtraThreshold.right) &&
            (touchedPoint.dx >=
                barX - halfBarHWidth - touchExtraThreshold.left);

        bool isYInBarHBounds;
        if (isUpward) {
          isYInBarHBounds =
              (touchedPoint.dy <= barBotY + touchExtraThreshold.bottom) &&
                  (touchedPoint.dy >= barTopY - touchExtraThreshold.top);
        } else {
          isYInBarHBounds =
              (touchedPoint.dy >= barTopY - touchExtraThreshold.top) &&
                  (touchedPoint.dy <= barBotY + touchExtraThreshold.bottom);
        }

        bool isYInBarHBackDrawBounds;
        if (isUpward) {
          isYInBarHBackDrawBounds =
              (touchedPoint.dy <= barBotY + touchExtraThreshold.bottom) &&
                  (touchedPoint.dy >= backDrawBarHY - touchExtraThreshold.top);
        } else {
          isYInBarHBackDrawBounds = (touchedPoint.dy >=
                  barTopY - touchExtraThreshold.top) &&
              (touchedPoint.dy <= backDrawBarHY + touchExtraThreshold.bottom);
        }

        final isYInTouchBounds =
            (targetData.barTouchData.allowTouchBarHBackDraw &&
                    isYInBarHBackDrawBounds) ||
                isYInBarHBounds;

        if (isXInTouchBounds && isYInTouchBounds) {
          final nearestGroup = targetData.barGroups[i];
          final nearestBarHRod = nearestGroup.barRods[j];
          final nearestSpot =
              FlSpot(nearestGroup.x.toDouble(), nearestBarHRod.toY);
          final nearestSpotPos =
              Offset(barX, getPixelY(nearestSpot.y, viewSize, holder));

          var touchedStackIndex = -1;
          BarHChartRodStackItem? touchedStack;
          for (var stackIndex = 0;
              stackIndex < nearestBarHRod.rodStackItems.length;
              stackIndex++) {
            final stackItem = nearestBarHRod.rodStackItems[stackIndex];
            final fromPixel = getPixelY(stackItem.fromY, viewSize, holder);
            final toPixel = getPixelY(stackItem.toY, viewSize, holder);
            if (touchedPoint.dy <= fromPixel && touchedPoint.dy >= toPixel) {
              touchedStackIndex = stackIndex;
              touchedStack = stackItem;
              break;
            }
          }

          return BarHTouchedSpot(
            nearestGroup,
            i,
            nearestBarHRod,
            j,
            touchedStack,
            touchedStackIndex,
            nearestSpot,
            nearestSpotPos,
          );
        }
      }
    }

    return null;
  }
}

@visibleForTesting
class GroupBarHsPosition {
  GroupBarHsPosition(this.groupX, this.barsX);
  final double groupX;
  final List<double> barsX;
}
