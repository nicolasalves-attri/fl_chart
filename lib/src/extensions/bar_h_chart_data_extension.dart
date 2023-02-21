import 'package:fl_chart/fl_chart.dart';

extension BarChartDataExtension on BarHChartData {
  List<double> calculateGroupsX(double viewWidth) {
    assert(barGroups.isNotEmpty);
    final groupsX = List<double>.filled(barGroups.length, 0);
    switch (alignment) {
      case BarChartAlignment.start:
        var tempX = 0.0;
        barGroups.asMap().forEach((i, group) {
          groupsX[i] = tempX + group.height / 2;
          tempX += group.height;
        });
        break;

      case BarChartAlignment.end:
        var tempX = 0.0;
        for (var i = barGroups.length - 1; i >= 0; i--) {
          final group = barGroups[i];
          groupsX[i] = viewWidth - tempX - group.height / 2;
          tempX += group.height;
        }
        break;

      case BarChartAlignment.center:
        var sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        sumWidth += groupsSpace * (barGroups.length - 1);
        final horizontalMargin = (viewWidth - sumWidth) / 2;

        var tempX = 0.0;
        for (var i = 0; i < barGroups.length; i++) {
          final group = barGroups[i];
          groupsX[i] = horizontalMargin + tempX + group.height / 2;

          final groupSpace = i == barGroups.length - 1 ? 0 : groupsSpace;
          tempX += group.height + groupSpace;
        }
        break;

      case BarChartAlignment.spaceBetween:
        final sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        final spaceAvailable = viewWidth - sumWidth;
        final eachSpace = spaceAvailable / (barGroups.length - 1);

        var tempX = 0.0;
        barGroups.asMap().forEach((index, group) {
          tempX += group.height / 2;
          if (index != 0) {
            tempX += eachSpace;
          }
          groupsX[index] = tempX;
          tempX += group.height / 2;
        });
        break;

      case BarChartAlignment.spaceAround:
        final sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        final spaceAvailable = viewWidth - sumWidth;
        final eachSpace = spaceAvailable / (barGroups.length * 2);

        var tempX = 0.0;
        barGroups.asMap().forEach((i, group) {
          tempX += eachSpace;
          tempX += group.height / 2;
          groupsX[i] = tempX;
          tempX += group.height / 2;
          tempX += eachSpace;
        });
        break;

      case BarChartAlignment.spaceEvenly:
        final sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        final spaceAvailable = viewWidth - sumWidth;
        final eachSpace = spaceAvailable / (barGroups.length + 1);

        var tempX = 0.0;
        barGroups.asMap().forEach((i, group) {
          tempX += eachSpace;
          tempX += group.height / 2;
          groupsX[i] = tempX;
          tempX += group.height / 2;
        });
        break;
    }

    return groupsX;
  }

  List<double> calculateGroupsY(double viewHeight) {
    assert(barGroups.isNotEmpty);
    final groupsX = List<double>.filled(barGroups.length, 0);

    switch (alignment) {
      case BarChartAlignment.start:
        var tempX = 0.0;
        barGroups.asMap().forEach((i, group) {
          groupsX[i] = tempX + group.height / 2;
          tempX += group.height;
        });
        break;

      case BarChartAlignment.end:
        var tempX = 0.0;
        for (var i = barGroups.length - 1; i >= 0; i--) {
          final group = barGroups[i];
          groupsX[i] = viewHeight - tempX - group.height / 2;
          tempX += group.height;
        }
        break;

      case BarChartAlignment.center:
        var sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        sumWidth += groupsSpace * (barGroups.length - 1);
        final horizontalMargin = (viewHeight - sumWidth) / 2;

        var tempX = 0.0;
        for (var i = 0; i < barGroups.length; i++) {
          final group = barGroups[i];
          groupsX[i] = horizontalMargin + tempX + group.height / 2;

          final groupSpace = i == barGroups.length - 1 ? 0 : groupsSpace;
          tempX += group.height + groupSpace;
        }
        break;

      case BarChartAlignment.spaceBetween:
        final sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        final spaceAvailable = viewHeight - sumWidth;
        final eachSpace = spaceAvailable / (barGroups.length - 1);

        var tempX = 0.0;
        barGroups.asMap().forEach((index, group) {
          tempX += group.height / 2;
          if (index != 0) {
            tempX += eachSpace;
          }
          groupsX[index] = tempX;
          tempX += group.height / 2;
        });
        break;

      case BarChartAlignment.spaceAround:
        final sumWidth =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        final spaceAvailable = viewHeight - sumWidth;
        final eachSpace = spaceAvailable / (barGroups.length * 2);

        var tempX = 0.0;
        barGroups.asMap().forEach((i, group) {
          tempX += eachSpace;
          tempX += group.height / 2;
          groupsX[i] = tempX;
          tempX += group.height / 2;
          tempX += eachSpace;
        });
        break;

      // padrão
      case BarChartAlignment.spaceEvenly:
        final sumHeight =
            barGroups.map((group) => group.height).reduce((a, b) => a + b);
        final spaceAvailable = viewHeight - sumHeight;
        final eachSpace = spaceAvailable / (barGroups.length + 1);

        var tempX = 0.0;
        barGroups.asMap().forEach((i, group) {
          tempX += eachSpace;
          tempX += group.height / 2;
          groupsX[i] = tempX;
          tempX += group.height / 2;
        });

        break;
    }

    return groupsX;
  }
}
