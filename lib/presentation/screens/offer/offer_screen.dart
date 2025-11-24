import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legend_cinema/presentation/widgets/custom_alert.dart';
import 'package:legend_cinema/presentation/widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/loading_overlay.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      showBackButton: false,
      title: 'Offers',
      body: SafeArea(child: Container()),
    );
  }
}
