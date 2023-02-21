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

  /// Calculates minX, and maxX based on [barGroups],
  /// returns cached values, to prevent redundant calculations.
  static BarHChartMinMaxAxisValues calculateMaxAxisValues(
    List<BarHChartGroupData> barGroups,
  ) {
    // return BarHChartMinMaxAxisValues(0, 20);
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
    var maxX = barGroup.barRods[0].toX;
    var minX = 0.0;

    for (var i = 0; i < barGroups.length; i++) {
      final barGroup = barGroups[i];
      for (var j = 0; j < barGroup.barRods.length; j++) {
        final rod = barGroup.barRods[j];

        if (rod.toX > maxX) {
          maxX = rod.toX;
        }

        if (rod.backDrawRodData.show && rod.backDrawRodData.toX > maxX) {
          maxX = rod.backDrawRodData.toX;
        }

        if (rod.toX < minX) {
          minX = rod.toX;
        }

        if (rod.backDrawRodData.show && rod.backDrawRodData.toX < minX) {
          minX = rod.backDrawRodData.toX;
        }
      }
    }

    final result = BarHChartMinMaxAxisValues(minX, maxX);
    _cachedResults[listWrapper] = result;
    return result;
  }
}

/// Holds minX, and maxX for use in [BarHChartData]
class BarHChartMinMaxAxisValues with EquatableMixin {
  BarHChartMinMaxAxisValues(this.minX, this.maxX, {this.readFromCache = false});
  final double minX;
  final double maxX;
  final bool readFromCache;

  @override
  List<Object?> get props => [minX, maxX, readFromCache];

  BarHChartMinMaxAxisValues copyWith({
    double? minX,
    double? maxX,
    bool? readFromCache,
  }) {
    return BarHChartMinMaxAxisValues(
      minX ?? this.minX,
      maxX ?? this.maxX,
      readFromCache: readFromCache ?? this.readFromCache,
    );
  }
}
