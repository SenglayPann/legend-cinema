import 'package:flutter/widgets.dart';
import '../../core/constants/routes_list.dart';

// 1. Define the map type for clarity
typedef AppRoutesMap = Map<String, Widget Function(BuildContext)>;

// 2. Map the list of objects into the required map format
AppRoutesMap getRoutes() {
  return {
    for (var route in appRoutes) 
      route.name: (context) => route.component,
  };
}