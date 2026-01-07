import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Privacy Policy",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              "Vista Entertainment built the Legend Cinema app as a Free app. This SERVICE is provided by Vista Entertainment at no cost and is intended for use as is.",
            ),
            _buildParagraph(
              "This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.",
            ),
            _buildParagraph(
              "If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.",
            ),
            _buildParagraph(
              "The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Legend Cinema unless otherwise defined in this Privacy Policy.",
            ),

            _buildSectionTitle("Information Collection and Use"),
            _buildParagraph(
              "For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information. The information that we request will be retained by us and used as described in this privacy policy.",
            ),
            _buildParagraph(
              "The app does use third party services that may collect information used to identify you.",
            ),
            _buildParagraph(
              "Link to privacy policy of third party service providers used by the app:\n\n• Google Play Services",
            ),

            _buildSectionTitle("Log Data"),
            _buildParagraph(
              "We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.",
            ),

            _buildSectionTitle("Cookies"),
            _buildParagraph(
              "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.",
            ),
            _buildParagraph(
              "This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.",
            ),

            _buildSectionTitle("Service Providers"),
            _buildParagraph(
              "We may employ third-party companies and individuals due to the following reasons:",
            ),
            _buildList([
              "To facilitate our Service;",
              "To provide the Service on our behalf;",
              "To perform Service-related services; or",
              "To assist us in analyzing how our Service is used.",
            ]),
            _buildParagraph(
              "We want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
            ),

            _buildSectionTitle("Security"),
            _buildParagraph(
              "We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.",
            ),

            _buildSectionTitle("Links to Other Sites"),
            _buildParagraph(
              "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.",
            ),

            _buildSectionTitle("Children’s Privacy"),
            _buildParagraph(
              "These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.",
            ),

            _buildSectionTitle("Changes to This Privacy Policy"),
            _buildParagraph(
              "We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.",
            ),

            _buildSectionTitle("Contact Us"),
            _buildParagraph(
              "If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at info@legend.com.kh.",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "• ",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
