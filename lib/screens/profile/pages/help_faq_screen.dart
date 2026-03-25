import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final List<Map<String, String>> _allFaqs = [
    {
      'question': 'How realistic are the CNG availability status?',
      'answer':
          'We rely on community-driven updates. When multiple users or a verified station owner updates the status, it reflects on the app within seconds.',
    },
    {
      'question': 'Why do I have a 30-minute cooldown on reports?',
      'answer':
          'To prevent spam and ensure data reliability, we limit consecutive reports for the same station from a single user to once every 30 minutes.',
    },
    {
      'question': 'What is a Verified Station Owner or Worker?',
      'answer':
          'Users who manage a physical CNG station can apply for verification. Once approved, their reports hold higher weight in our algorithm.',
    },
    {
      'question': 'How can I become a Station Owner?',
      'answer':
          'Go to your Profile page and select "Get Verified". Fill out the request form with your station name and documents.',
    },
    {
      'question': 'My app is stuck or showing incorrect info.',
      'answer':
          'Try forcing a Hot Restart or clearing your app cache. If an issue persists, use the "Send Feedback" menu.',
    },
  ];

  // Logic for filtering
  late List<Map<String, String>> _filteredFaqs;

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs;
  }

  void _filterFaqs(String query) {
    setState(() {
      _filteredFaqs = _allFaqs
          .where(
            (faq) =>
                faq['question']!.toLowerCase().contains(query.toLowerCase()) ||
                faq['answer']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Adaptive SliverAppBar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: isDark ? Colors.black : Colors.green[700],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Help & FAQs',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [Colors.black, const Color(0xFF121212)]
                        : [Colors.green[800]!, Colors.green[600]!],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -10,
                      child: Icon(
                        Icons.help_outline,
                        size: 140,
                        color: Colors.white.withAlpha(isDark ? 15 : 30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: TextField(
                onChanged: _filterFaqs,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search FAQs...',
                  prefixIcon: const Icon(Icons.search),
                  // Uses the theme-aware colors we defined in main.dart
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                ),
              ),
            ),
          ),

          // FAQ List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final faq = _filteredFaqs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? Border.all(color: Colors.white.withAlpha(20))
                        : null,
                  ),
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: Colors.green,
                      collapsedIconColor: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      title: Text(
                        faq['question']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withAlpha(180),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _filteredFaqs.length),
            ),
          ),

          // Support Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue[900]!.withAlpha(30)
                      : Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withAlpha(isDark ? 80 : 45),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: Colors.blue[400],
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
                      'Feel free to reach out to our support team.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pushNamed('feedback'),
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
