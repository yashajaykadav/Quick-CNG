import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How realistic are the CNG availability status?',
      'answer':
          'We rely on community-driven updates. When multiple users or a verified station owner updates the status, it reflects on the app within seconds. Keep an eye on the timestamps to see how recent the update is.',
    },
    {
      'question': 'Why do I have a 30-minute cooldown on reports?',
      'answer':
          'To prevent spam and ensure data reliability, we limit consecutive reports for the same station from a single user to once every 30 minutes.',
    },
    {
      'question': 'What is a Verified Station Owner or Worker?',
      'answer':
          'Users who manage a physical CNG station can apply for verification. Once approved by our team, their reports bypass cooldowns and hold a higher weight in our algorithm, turning them into official updates.',
    },
    {
      'question': 'How can I become a Station Owner?',
      'answer':
          'Go to your Profile page and select "Get Verified". Fill out the request form with your station name and documents. Our Super Admin will verify your request shortly.',
    },
    {
      'question': 'My app is stuck or showing incorrect info.',
      'answer':
          'Try forcing a Hot Restart or clearing your app cache. If an issue persists, you can use the "Send Feedback" menu to notify our development team directly.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.green[700],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 20,
                bottom: 16,
                right: 20,
              ),
              title: const Text(
                'Help & FAQs',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.green[700]),
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Icon(
                      Icons.help_outline,
                      size: 150,
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add this SliverToBoxAdapter right below your SliverAppBar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search FAQs...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Implement filtering logic on your _faqs list here
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final faq = _faqs[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: Colors.green[700],
                      textColor: Colors.green[800],
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _faqs.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withAlpha(45)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: Colors.blue[700],
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Still need help?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you cannot find the answer here, feel free to reach out to our support team.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pushNamed('feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Contact Support'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}
