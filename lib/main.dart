import 'package:flutter/material.dart';
import 'package:route_tracking/Featuers/views/google_map_veiw.dart';

void main() {
  runApp(const GoogleTrackerApp());
}

class GoogleTrackerApp extends StatelessWidget {
  const GoogleTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Scaffold(
        resizeToAvoidBottomInset: false,
          body: SafeArea(child: GoogleMapVeiw())) ,
    );
 }
}
