import 'dart:core';
import 'dart:math';

import 'package:feather/src/models/internal/line_axis.dart';
import 'package:feather/src/models/internal/point.dart';
import 'package:feather/src/models/internal/weather_forecast_holder.dart';
import 'package:feather/src/models/remote/weather_forecast_response.dart';
import 'package:feather/src/resources/app_const.dart';
import 'package:feather/src/resources/weather_manager.dart';
import 'package:feather/src/ui/widget/chart_painter_widget.dart';
import 'package:feather/src/ui/widget/widget_helper.dart';
import 'package:feather/src/utils/types_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WeatherForecastWidget extends StatelessWidget {
  final WeatherForecastHolder holder;
  final double width;
  final double height;

  const WeatherForecastWidget({Key key, this.holder, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Point> points = _getPoints();
    List<String> pointLabels = _getPointLabels();
    List<LineAxis> axes = getAxes(points);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(holder.getLocationName(),
              style: Theme.of(context).textTheme.title),
          Text(holder.dateFullFormatted,
              style: Theme.of(context).textTheme.subtitle),
          WidgetHelper.buildPadding(top: 20),
          Hero(
              tag: AppConst.imageWeatherHeroTag + holder.dateShortFormatted,
              child: Image.asset(holder.weatherCodeAsset,
                  width: 100, height: 100)),
          WidgetHelper.buildPadding(top: 30),
          ChartPainterWidget(
            height: height,
            width: width,
            points: points,
            pointLabels: pointLabels,
            axes: axes,
          ),
          WidgetHelper.buildPadding(top: 10),
          Row(
            children: getWeatherImages(points),
          )
        ],
      ),
    );
  }

  List<Point> _getPoints() {
    List<Point> points = List();
    double halfHeight = (height - AppConst.chartPadding) / 2;
    double widthStep = width / (holder.forecastList.length - 1);
    double currentX = 0;

    List<double> temperatures = getTemperaturesList();
    double maxTemperature = getMax(temperatures);

    for (double temp in temperatures) {
      var y = halfHeight - (halfHeight * temp / maxTemperature);
      points.add(Point(currentX, y));
      currentX += widthStep;
    }
    return points;
  }

  List<double> getTemperaturesList() {
    List<double> temperatures = new List();
    double averageTemperature = holder.temperature;
    for (WeatherForecastResponse forecastResponse in holder.forecastList) {
      double temperatureDiff =
          averageTemperature - forecastResponse.mainWeatherData.temp;
      temperatures.add(temperatureDiff);
    }
    return temperatures;
  }

  double getMax(List<double> values) {
    double maxValue = 0;
    for (double value in values) {
      maxValue = max(maxValue, value.abs());
    }
    return maxValue;
  }

  List<LineAxis> getAxes(List<Point> points) {
    List<LineAxis> list = new List();
    list.add(LineAxis(
        TypesHelper.formatTemperature(holder.temperature),
        Offset(-25, height / 2 - 15),
        Offset(-5, (height - AppConst.chartPadding) / 2),
        Offset(width + 5, (height - AppConst.chartPadding) / 2)));

    for (int index = 0; index < points.length; index++) {
      Point point = points[index];
      DateTime dateTime = holder.forecastList[index].dateTime;
      list.add(LineAxis(
          _getPointAxisLabel(dateTime),
          Offset(point.x - 10, height - 10),
          Offset(point.x, 0),
          Offset(point.x, height - 10)));
    }
    return list;
  }

  String _getPointAxisLabel(DateTime dateTime) {
    int hour = dateTime.hour;
    String hourText = "";
    if (hour < 10) {
      hourText = "0${hour.toString()}";
    } else {
      hourText = hour.toString();
    }
    return "${hourText.toString()}:00";
  }

  List<String> _getPointLabels() {
    List<String> points = List();
    double averageTemperature = holder.temperature;

    for (WeatherForecastResponse forecastResponse in holder.forecastList) {
      double diff = averageTemperature - forecastResponse.mainWeatherData.temp;
      points.add(diff.toStringAsFixed(1));
    }
    return points;
  }

  List<Widget> getWeatherImages(List<Point> points) {
    List<Widget> widgets = new List();
    if (points.length > 1) {
      double padding = points[1].x - points[0].x - 30;
      widgets.add(WidgetHelper.buildPadding(left:15,top:5));
      for (int index = 0; index < points.length; index++) {
        widgets.add(Image.asset(
            WeatherManager.getWeatherIcon(
                holder.forecastList[index].overallWeatherData[0].id),
            width: 30,
            height: 30));
        widgets.add(WidgetHelper.buildPadding(left:padding));
      }
      widgets.removeLast();
    }

    return widgets;
  }
}
