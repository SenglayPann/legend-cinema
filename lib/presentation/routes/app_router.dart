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

// presentation/routes/app_router.dart

import 'package:flutter/material.dart';
// ... other screen imports ...
import 'package:legend_cinema/presentation/screens/cinemascreen/cinema_screen.dart'; 

Map<String, WidgetBuilder> getRoutes() {
  return {
    // ... existing routes ...
    
    // --- ADD THIS LINE ---
    '/cinema': (context) => const CinemaScreen(), 
  };
}