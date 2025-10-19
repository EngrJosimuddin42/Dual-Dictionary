import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  // ফোন কল করার ফাংশন
  Future<void> _makeCall() async {
    final Uri callUri = Uri(scheme: "tel", path: "+8801518380199");
    try {
      await launchUrl(callUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("❌ Could not launch dialer: $e");
    }
  }

  // ইমেইল পাঠানোর ফাংশন
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: "mailto",
      path: "josimcse@gmail.com",
      query: "subject=Hello&body=How are you?",
    );
    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("❌ Could not launch email app: $e");
    }
  }

  // Feature point builder
  Widget _featurePoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Profile & Dictionary Info"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    // 🔹 Avatar with white border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage("assets/aaa.jpg"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Profile info card
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Josim Uddin",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "App Developer & Designer",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(height: 20, thickness: 1),
                            ListTile(
                              leading: const Icon(Icons.phone, color: Colors.teal),
                              title: const Text("+8801518380199"),
                              onTap: _makeCall,
                            ),
                            ListTile(
                              leading: const Icon(Icons.email, color: Colors.teal),
                              title: const Text("josimcse@gmail.com"),
                              onTap: _sendEmail,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _makeCall,
                                  icon: const Icon(Icons.call),
                                  label: const Text("Call"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _sendEmail,
                                  icon: const Icon(Icons.email),
                                  label: const Text("Email"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Header
                    const Text(
                      "📚 Key Features",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Features list with icons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _featurePoint(Icons.language, "Search English → Bangla words"),
                          _featurePoint(Icons.translate, "Search Bangla → English words"),
                          _featurePoint(Icons.auto_fix_high, "Auto-suggestions while typing"),
                          _featurePoint(Icons.visibility, "Quick meaning display"),
                          _featurePoint(Icons.swap_horiz, "Switch between dictionary modes easily"),
                          _featurePoint(Icons.speed, "User-friendly & fast UI"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Footer
                    const Text(
                      "Powered by Flutter 🚀",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
