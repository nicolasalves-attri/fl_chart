import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/chart/bar_chart_horizontal/bar_h_chart_data.dart';
import 'package:fl_chart/src/utils/list_wrapper.dart';

/// Contains anything that helps BarHChart works
class BarHChartHelper {
  /// Contains List of cached results, base on [List<BarHChartGroupData>]
  ///
  /// We use it to prevent redundant calculations
  static final Map<ListWrapper<BarHChartGroupData>, BarHChartMinMaxAxisValues>
      _cachedResults = {};

  /// Calculates minY, and maxY based on [barGroups],
  /// returns cached values, to prevent redundant calculations.
  static BarHChartMinMaxAxisValues calculateMaxAxisValues(
    List<BarHChartGroupData> barGroups,
  ) {
    if (barGroups.isEmpty) {
      return BarHChartMinMaxAxisValues(0, 0);
    }

    final listWrapper = barGroups.toWrapperClass();

    if (_cachedResults.containsKey(listWrapper)) {
      return _cachedResults[listWrapper]!.copyWith(readFromCache: true);
    }

    final BarHChartGroupData barGroup;
    try {
      barGroup = barGroups.firstWhere((element) => element.barRods.isNotEmpty);
    } catch (e) {
      // There is no barChartGroupData with at least one barRod
      return BarHChartMinMaxAxisValues(0, 0);
    }

    var maxY = barGroup.barRods[0].toY;
    var minY = 0.0;

    for (var i = 0; i < barGroups.length; i++) {
      final barGroup = barGroups[i];
      for (var j = 0; j < barGroup.barRods.length; j++) {
        final rod = barGroup.barRods[j];

        if (rod.toY > maxY) {
          maxY = rod.toY;
        }

        if (rod.backDrawRodData.show && rod.backDrawRodData.toY > maxY) {
          maxY = rod.backDrawRodData.toY;
        }

        if (rod.toY < minY) {
          minY = rod.toY;
        }

        if (rod.backDrawRodData.show && rod.backDrawRodData.toY < minY) {
          minY = rod.backDrawRodData.toY;
        }
      }
    }

    final result = BarHChartMinMaxAxisValues(minY, maxY);
    _cachedResults[listWrapper] = result;
    return result;
  }
}

/// Holds minY, and maxY for use in [BarHChartData]
class BarHChartMinMaxAxisValues with EquatableMixin {
  BarHChartMinMaxAxisValues(this.minY, this.maxY, {this.readFromCache = false});
  final double minY;
  final double maxY;
  final bool readFromCache;

  @override
  List<Object?> get props => [minY, maxY, readFromCache];

  BarHChartMinMaxAxisValues copyWith({
    double? minY,
    double? maxY,
    bool? readFromCache,
  }) {
    return BarHChartMinMaxAxisValues(
      minY ?? this.minY,
      maxY ?? this.maxY,
      readFromCache: readFromCache ?? this.readFromCache,
    );
  }
}
