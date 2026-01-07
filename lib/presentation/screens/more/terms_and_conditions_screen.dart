import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Terms & Conditions",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ticket Purchased Rule and Regulation",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNumberedItem(
              "1.",
              "Every movie tickets purchased via the Sale Channels are strictly non-refundable and are not available for exchange under whatever circumstances.",
            ),
            _buildNumberedItem(
              "2.",
              "Purchased tickets are not exchangeable for tickets at a different price, for another movie, or for another screening or day.",
            ),
            _buildNumberedItem(
              "3.",
              "Movie tickets purchased via the Sales Channels will be available for collection at the relevant cinema from the ticket counter or at our KIOSK machine (where available) by producing the booking numbers/reservation sent by email or as available under the purchased history feature in Legend Mobile application or any other means that shall be introduced by Legend Cinema from time to time.",
            ),
            _buildNumberedItem(
              "4.",
              "In case of any malfunctions of the reservation or purchase form placed on the website or mobile application, please contact us immediately at the following e-mail address hotline@legend.com.kh or contact our hotline 081300400 at least 30 minutes before the movie start. We would also like to inform you that it is the basis and condition for an effective complaint about the impossibility or difficulties in purchasing tickets online.",
            ),
            _buildNumberedItem(
              "5.",
              "If the User fails to purchase a ticket for the screening for which he or she has reserved a seat in the Legend Cinema within the time limit specified in clause 4 above, the reservation of such a seat cannot be guaranteed.",
            ),
            _buildNumberedItem(
              "6.",
              "Movie tickets are made available subject to the classification of relevant film given by the Film Censorship Board of Cambodia. Legend Cinema has a legal obligation to refuse admission to a person, who in the opinion of its duty manager, is under the minimum age required for NC15 and R18 classified films (including children in arms). Proof of age may be required in certain instances.",
            ),

            const SizedBox(height: 24),
            const Text(
              "Legend Cinema reserved the rights to have term and condition changed.\nAll rights reserved Legend Cinema Co, Ltd 2024.",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
