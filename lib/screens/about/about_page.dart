import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// AboutPage displays app version, description, and links to GitHub, author, and license.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "1.0.0.";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => version = info.version);
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Couldn't open link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D49),
      appBar: AppBar(
        title: const Text("About This App"),
        backgroundColor: const Color(0xFF2D2D49),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "PennyWise",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text("v$version", style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
            const Text(
              "PennyWise is a privacy-focused offline budgeting app. "
              "Track your expenses, goals, and income securely—no internet required.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            _buildTile("GitHub Repository", "View the source code", () {
              _launchUrl("https://github.com/sadmaxie/PennyWise");
            }),
            _buildTile("Author", "@sadmaxie", () {
              _launchUrl("https://github.com/sadmaxie");
            }),
            _buildTile("License", "GNU GPL-3.0", null),
            _buildTile("Privacy", "Your data stays on your device.", null),
            _buildTile("Built With", "Flutter • Hive", null),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, String subtitle, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing:
          onTap != null
              ? const Icon(Icons.open_in_new, color: Colors.white30)
              : null,
      onTap: onTap,
    );
  }
}
