import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the platform's default handler (browser, maps app, etc).
Future<void> openUrl(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
