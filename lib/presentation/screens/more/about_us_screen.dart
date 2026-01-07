import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "About Us",
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/d/1VwfMEVzXsVN0a3evhGP6LoeyKskN0tkR',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "About Legend Cinema Cambodia",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Legend Cinema is the no. 1 and the first International Standard Cinema in Cambodia, created and operated by Khmer since 2011. Our rapid growth and expansion from 1 to 13 cinema locations in the past 12 years across the country, has shown our strength in delivery and influence in the film and entertainment industry.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Today, we have successfully implemented and deployed advanced cinema technologies and levelled up our offerings, beyond cinema norms. Our team is dedicated to providing top tier immersive cinema experience and excellent services with the essence of Khmer hospitality. With our new direction in place, we are determined to inspire, drive change and make an impact in the industry, and exceed expectations.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
