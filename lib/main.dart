import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unicef/loginsignup.dart';

void main() async {
  runApp(const GovSchemesApp());
}

class GovSchemesApp extends StatelessWidget {
  const GovSchemesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gov Schemes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF015AA5),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late AnimationController _marqueeController;
  late Animation<double> _marqueeAnimation;
  // Store recent searches
  List<String> recentSearches = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  int _langIndex = 0;

  final List<String> marqueeTexts = [
    "Latest Govt Update | New schemes launched | Apply now for education, health, farming & women empowerment | ",
    "नवीन सरकारी योजनाएं जारी | शिक्षा, स्वास्थ्य, किसान और महिला सहायता के लिए आवेदन करें | अंतिम तिथियाँ निकट हैं — अभी जाँचें! | ",
  ];

  late final PageController _pageController;
  int _currentBanner = 0;
  Timer? _bannerTimer;

  int _selectedIndex = 0;
  late final List<Widget Function()> _screens;
  int _selectedSchemeCategory = 0;

  bool _isReady = false;

  final List<String> _bannerTitles = [
    "Mann Ki Baat - Join Live",
    "मन की बात - सीधा प्रसारण",

    "New Scholarship Schemes",
    "नई छात्रवृत्ति योजनाएँ",

    "Women Empowerment Yojana",
    "महिला सशक्तिकरण योजना",
  ];

  final schemeData = {
    "Students": [
      {"name": "National Scholarship Portal (NSP)", "status": "Eligible"},
      {"name": "PM Scholar Merit Scholarship", "status": "Applied"},
      {"name": "AICTE Pragati Scholarship", "status": "Eligible"},
      {"name": "Digital India Internship", "status": "Applied"},
      {"name": "PM YASASVI Scholarship", "status": "New"},
      {"name": "UGC NET Fellowship Scheme", "status": "Eligible"},
      {"name": "INSPIRE Science Scholarship", "status": "Pending"},
      {"name": "EWS Education Subsidy", "status": "Not Eligible"},
    ],

    "Farmers": [
      {"name": "PM Kisan Samman Nidhi", "status": "Eligible"},
      {"name": "Soil Health Card Scheme", "status": "Eligible"},
      {"name": "Pradhan Mantri Fasal Bima Yojana", "status": "Applied"},

      {"name": "Paramparagat Krishi Vikas Yojana", "status": "Eligible"},
      {"name": "Agriculture Infrastructure Fund", "status": "Not Eligible"},
    ],

    "Women": [
      {"name": "Pradhan Mantri Ujjwala Yojana", "status": "Eligible"},
      {"name": "Ladli Laxmi Yojana", "status": "Not Eligible"},
      {"name": "PM Matru Vandana Yojana", "status": "Applied"},
      {"name": "Self Help Group Loan Scheme", "status": "Eligible"},
      {"name": "Mission Shakti Scheme", "status": "Pending"},
      {"name": "Working Women Hostel Scheme", "status": "Eligible"},
      {"name": "Sukanya Samriddhi Yojana", "status": "New"},
      {"name": "Nari Samman Yojana", "status": "Eligible"},
    ],

    "Health": [
      {"name": "Ayushman Bharat - PMJAY", "status": "Eligible"},
      {"name": "Janani Suraksha Yojana", "status": "Applied"},
      {"name": "E-Sanjeevani Online Consultation", "status": "Eligible"},
    ],

    "Jobs": [
      {"name": "PM Skill India Training", "status": "Eligible"},
      {"name": "Mudra Loan for Startups", "status": "Applied"},
      {"name": "NAPS Apprenticeship Program", "status": "Eligible"},
      {"name": "Agnipath Military Recruitment", "status": "Not Eligible"},
      {"name": "PM Vishwakarma Scheme", "status": "New"},
    ],

    "Seniors": [
      {"name": "Atal Pension Yojana", "status": "Eligible"},
      {"name": "Old Age Pension Yojana", "status": "Applied"},
      {"name": "Senior Citizen Travel Subsidy", "status": "Eligible"},
      {"name": "Varishtha Mediclaim Policy", "status": "Pending"},
      {"name": "National Social Assistance Scheme", "status": "Eligible"},
      {"name": "Indira Gandhi Pension Scheme", "status": "Not Eligible"},
      {"name": "Senior Digital Literacy Program", "status": "New"},
      {"name": "Home Visit Medical Support", "status": "Eligible"},
    ],
  };

  final suggestionTags = [
    "Scholarship",
    "Women Empowerment",
    "Farmer Benefits",
    "Free Health Support",
    "Housing Scheme",
  ];

  @override
  void initState() {
    super.initState();

    // Store widget builders instead of building now
    _screens = [
      _buildHomeContent,
      _buildSchemesPage,
      _buildUpdatesPage,
      _buildProfilePage,
    ];

    // Marquee Animation Setup
    _marqueeController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    );

    _marqueeAnimation = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _marqueeController, curve: Curves.linear),
    );

    _marqueeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _langIndex = (_langIndex + 1) % marqueeTexts.length;
        });
        _marqueeController.forward(from: 0);
      }
    });

    // Start marquee
    _marqueeController.forward();

    // Entry Animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    // Carousel auto scroll
    _pageController = PageController();
    _startBannerAutoScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
      setState(() => _isReady = true);
    });
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        int nextPage = (_currentBanner + 1) % _bannerTitles.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    // Save max 5 recent searches
    if (!recentSearches.contains(query)) {
      if (recentSearches.length >= 5) recentSearches.removeLast();
      recentSearches.insert(0, query);
    }

    _searchController.clear();
    FocusScope.of(context).unfocus();

    // Redirect to schemes tab
    setState(() => _selectedIndex = 1);

    // Try matching scheme name
    Future.delayed(const Duration(milliseconds: 500), () {
      var match = schemeData.entries
          .expand((e) => e.value)
          .firstWhere(
            (scheme) => (scheme['name'] as String).toLowerCase().contains(
              query.toLowerCase(),
            ),
            orElse: () => <String, String>{},
          );

      _showSchemeDetails(match["name"] as String, match["status"] as String);
    });

    setState(() {});
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pageController.dispose();
    _bannerTimer?.cancel();
    _marqueeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isReady ? _screens[_selectedIndex]() : SizedBox(),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildHeader(),
        const SizedBox(height: 8),
        _buildSearchBar(),
        const SizedBox(height: 8),
        _buildMarquee(),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildCarousel(),
                const SizedBox(height: 14),
                _buildQuickActions(),
                const SizedBox(height: 8),
                _buildStatsRow(),
                const SizedBox(height: 18),
                _buildGetInvolvedCard(),
                const SizedBox(height: 18),
                _buildOurSchemesSection(),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchemesPage() {
    final categories = [
      {"name": "Students", "icon": Icons.school},
      {"name": "Farmers", "icon": Icons.agriculture},
      {"name": "Women", "icon": Icons.woman},
      {"name": "Health", "icon": Icons.health_and_safety},
      {"name": "Jobs", "icon": Icons.work},
      {"name": "Seniors", "icon": Icons.elderly},
    ];

    final selectedCategory = categories[_selectedSchemeCategory]["name"];
    final schemes = schemeData[selectedCategory] ?? [];

    // Status → Color mapping
    Color statusColor(String status) {
      switch (status) {
        case "Eligible":
          return Color(0xFF2E7D32); // Green
        case "Applied":
          return Color(0xFF1976D2); // Blue
        case "Not Eligible":
          return Color(0xFFD32F2F); // Red
        case "Pending":
          return Color(0xFFFFA000); // Amber
        case "New":
          return Color(0xFF673AB7); // Purple
        default:
          return Colors.grey;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildHeader(),
        const SizedBox(height: 10),

        // MAIN CONTENT DIVIDED IN TWO PARTS
        Expanded(
          child: Row(
            children: [
              // LEFT CATEGORY PANEL
              Container(
                width: MediaQuery.of(context).size.width * 0.22,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  itemBuilder: (context, index) {
                    final selected = _selectedSchemeCategory == index;

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedSchemeCategory = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF015AA5)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              categories[index]["icon"] as IconData,
                              color: selected ? Colors.white : Colors.black54,
                              size: 21,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              categories[index]["name"] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // RIGHT SIDE — SCHEMES SECTION
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: schemes.length,
                    itemBuilder: (context, index) {
                      final scheme = schemes[index];
                      final status = scheme["status"];
                      final col = statusColor(status!);

                      return GestureDetector(
                        onTap: () => _showSchemeDetails(
                          scheme["name"] as String,
                          status,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: col.withOpacity(0.15),
                                child: Icon(Icons.description, color: col),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  scheme["name"] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: col.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: col,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesPage() {
    final updates = [
      {
        "scheme": "PM Kisan Samman Nidhi",
        "status": "Approved",
        "date": "10 Feb 2025",
        "message": "Your application has been successfully approved.",
        "icon": Icons.check_circle_outline,
        "color": Colors.green,
      },
      {
        "scheme": "National Scholarship Portal",
        "status": "Under Review",
        "date": "06 Feb 2025",
        "message": "Documents verified. Awaiting departmental approval.",
        "icon": Icons.timelapse_outlined,
        "color": Colors.orange,
      },
      {
        "scheme": "Ujjwala Yojana",
        "status": "Rejected",
        "date": "02 Feb 2025",
        "message": "Application rejected due to missing income certificate.",
        "icon": Icons.cancel_outlined,
        "color": Colors.redAccent,
      },
      {
        "scheme": "Pradhan Mantri Awas Yojana",
        "status": "Pending",
        "date": "29 Jan 2025",
        "message": "Application submitted and waiting for review.",
        "icon": Icons.hourglass_bottom,
        "color": Colors.blueGrey,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 8),
        // _buildHeader(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: const Text(
              "Application Status",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Text(
            "Track the status of your  scheme applications /आपकी योजनाओं की स्थिति देखें",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final item = updates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 8),
                    // _buildHeader(),
                    // Header row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: (item["color"] as Color).withOpacity(
                            0.14,
                          ),
                          child: Icon(
                            item["icon"] as IconData,
                            size: 20,
                            color: item["color"] as Color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item["scheme"] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Status tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (item["color"] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item["status"] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item["color"] as Color,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Message
                    Text(
                      item["message"] as String,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Date
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item["date"] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    final options = [
      {"title": "My Activities", "icon": Icons.task_alt_rounded},
      {"title": "Saved Schemes", "icon": Icons.bookmark_added_outlined},
      {"title": "Application History", "icon": Icons.history_toggle_off},
      {"title": "Support & Helpdesk", "icon": Icons.support_agent_rounded},
      {"title": "Language Preference", "icon": Icons.language_rounded},
      {"title": "Settings", "icon": Icons.settings_outlined},
      {"title": "About App", "icon": Icons.info_outline},
    ];

    return Column(
      children: [
        const SizedBox(height: 8),
        _buildHeader(),

        // -------- HEADER GRADIENT SECTION --------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D92FF), Color(0xFF05A64C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 10),

              // Welcome Text
              const Text(
                "Welcome",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Login/Register Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Login / Register",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // -------- OPTIONS LIST --------
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final item = options[index];
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE9F4FF),
                        child: Icon(
                          item["icon"] as IconData,
                          size: 20,
                          color: const Color(0xFF015AA5),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item["title"] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSchemeDetails(String title, String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                // Status Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                const Text(
                  "📌 Scheme Overview",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "This scheme aims to provide benefits to eligible citizens by supporting education, financial aid, and welfare depending on the scheme category.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 18),

                // Eligibility Section
                const Text(
                  "✔ Eligibility Criteria",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _bullet("- Indian Citizen"),
                _bullet("- Aadhaar required"),
                _bullet("- Income criteria may apply"),
                _bullet("- Age and education requirements vary"),

                const SizedBox(height: 18),

                // Required Documents
                const Text(
                  "📄 Required Documents",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _bullet("- Aadhaar Card"),
                _bullet("- Income Certificate"),
                _bullet("- Bank Passbook"),
                _bullet("- Passport size photo"),
                _bullet("- Address proof"),

                const SizedBox(height: 22),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF015AA5),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Apply Now",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Optional Link Button
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text("View Official Website"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "eligible":
        return Colors.green;
      case "applied":
        return Colors.orange;
      case "not eligible":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ------------------ WIDGETS -------------------------

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF015AA5),
      unselectedItemColor: Colors.grey,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          label: 'Schemes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Updates',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        "label_en": "My Schemes",
        "label_hi": "आपकी योजनाएँ",
        "icon": Icons.account_balance_wallet_outlined,
        "color": Color(0xFF005BBB),
      },
      {
        "label_en": "Eligibility",
        "label_hi": "पात्रता",
        "icon": Icons.verified_user_outlined,
        "color": Color(0xFF008F4A),
      },
      {
        "label_en": "Documents",
        "label_hi": "दस्तावेज़",
        "icon": Icons.file_present_outlined,
        "color": Color(0xFFDD6B20),
      },
      {
        "label_en": "Apply",
        "label_hi": "आवेदन",
        "icon": Icons.how_to_reg_outlined,
        "color": Color(0xFF9C27B0),
      },
      {
        "label_en": "Support",
        "label_hi": "सहायता",
        "icon": Icons.support_agent_outlined,
        "color": Color(0xFF37474F),
      },
      {
        "label_en": "Nearby",
        "label_hi": "पास में",
        "icon": Icons.location_on_outlined,
        "color": Color(0xFFE53935),
      },
      {
        "label_en": "Updates",
        "label_hi": "अपडेट",
        "icon": Icons.new_releases_outlined,
        "color": Color(0xFF3F51B5),
      },
      {
        "label_en": "Helpdesk",
        "label_hi": "सहायता केंद्र",
        "icon": Icons.support_outlined,
        "color": Color(0xFF0097A7),
      },
    ];

    // group into pages of 4
    final pages = List.generate(
      (actions.length / 4).ceil(),
      (i) => actions.skip(i * 4).take(4).toList(),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Row(
              children: const [
                Icon(
                  Icons.flash_on_rounded,
                  size: 18,
                  color: Color(0xFF015AA5),
                ),
                SizedBox(width: 6),
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF015AA5),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 90,
            child: PageView.builder(
              itemCount: pages.length,
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: 1),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final pageItems = pages[index];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: pageItems.map((item) {
                    return GestureDetector(
                      onTap: () => print("Tapped: ${item["label_en"]}"),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (item["color"] as Color).withOpacity(
                                  0.4,
                                ),
                                width: 1.5,
                              ),
                              color: (item["color"] as Color).withOpacity(0.12),
                            ),
                            child: Icon(
                              item["icon"] as IconData,
                              size: 26,
                              color: item["color"] as Color,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item["label_en"] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            item["label_hi"] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF595959),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // <-- THIS FIXES IT
            children: [
              Row(
                children: const [
                  SizedBox(width: 10),
                  Icon(
                    Icons.account_balance,
                    size: 22,
                    color: Color(0xFF777777),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "UNICEF",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2),

              Row(
                children: const [
                  Text(
                    "your",
                    style: TextStyle(
                      color: Color(0xFF05A64C),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Schemes ",
                    style: TextStyle(
                      color: Color(0xFF015AA5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "आपकी योजनाएँ",
                    style: TextStyle(color: Color(0xFF777777), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_outlined, size: 26),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  height: 14,
                  width: 14,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "1",
                    style: TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        // SEARCH FIELD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() => _isSearchFocused = hasFocus);
            },
            child: TextField(
              controller: _searchController,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                hintText: "Search schemes, benefits, tasks...",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF015AA5),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),

        // RECENT SEARCH BOX (only visible when focused)
        if (_isSearchFocused && recentSearches.isNotEmpty)
          Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: recentSearches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 18),
                  title: Text(
                    recentSearches[index],
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 15),
                    onPressed: () {
                      setState(() => recentSearches.removeAt(index));
                    },
                  ),
                  onTap: () => _handleSearch(recentSearches[index]),
                );
              },
            ),
          ),
        if (_isSearchFocused)
          Column(
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                child: Column(
                  children: suggestionTags.take(5).map((tag) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => _handleSearch(tag),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMarquee() {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDF4FF), Color(0xFFE0F7FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF015AA5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "NEWS/सूचना",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 1),

          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _marqueeController,
                builder: (context, child) {
                  final width = MediaQuery.of(context).size.width;

                  return Transform.translate(
                    offset: Offset(_marqueeAnimation.value * width, 0),
                    child: child!,
                  );
                },
                child: Text(
                  (marqueeTexts[_langIndex] * 2), // ensures seamless flow
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF204B78),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _bannerTitles.length,
                    onPageChanged: (i) {
                      setState(() => _currentBanner = i);
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0C5AA6), Color(0xFF022B5B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 12,
                              bottom: 14,
                              right: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _bannerTitles[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "30th Nov 2025 • 11:00 AM\nWatch live and participate.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "WATCH LIVE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage(
                                    "assets/modi.jpg",
                                  ),
                                  // replace with any public image you like
                                  onBackgroundImageError: (_, __) {},
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _bannerTitles.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: _currentBanner == i ? 18 : 7,
                          decoration: BoxDecoration(
                            color: _currentBanner == i
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCards() {
    final cards = [
      {
        "title": "Join MyGov on WhatsApp",
        "tag": "LATEST",
        "color": const Color(0xFF0A7E3D),
        "icon": Icons.chat_bubble_outline,
      },
      {
        "title": "MyGov Pulse Newsletter",
        "tag": "LATEST",
        "color": const Color(0xFF015AA5),
        "icon": Icons.mail_outline,
      },
      {
        "title": "MyGov Saathi - build India",
        "tag": "FEATURED",
        "color": const Color(0xFFEE6B2D),
        "icon": Icons.people_outline,
      },
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 14),
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        (card["color"] as Color).withOpacity(0.9),
                        (card["color"] as Color).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      card["icon"] as IconData,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    card["title"] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      card["tag"] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF015AA5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              value: "604.14 + Lakh",
              label: "Registered Members",
              icon: Icons.groups,
              color: const Color(0xFF1A73E8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              value: "18.37 + Lakh",
              label: "Submissions in 1,865 Tasks",
              icon: Icons.assignment_turned_in_outlined,
              color: const Color(0xFFE37400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetInvolvedCard() {
    final items = [
      {"icon": Icons.check_box_outlined, "label": "Do/Task"},
      {"icon": Icons.chat_bubble_outline, "label": "Discuss"},
      {"icon": Icons.bar_chart_outlined, "label": "Poll/Survey"},
      {"icon": Icons.edit_outlined, "label": "Blog"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get Involved",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            const Text(
              "Participate in nation building activities",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((item) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item["icon"] as IconData,
                        size: 22,
                        color: const Color(0xFF015AA5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 70,
                      child: Text(
                        item["label"] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOurSchemesSection() {
    final schemes = [
      {
        "label": "For Students",
        "icon": Icons.school_outlined,
        "color": const Color(0xFF1565C0),
      },
      {
        "label": "For Farmers",
        "icon": Icons.agriculture_outlined,
        "color": const Color(0xFF2E7D32),
      },
      {
        "label": "For Women",
        "icon": Icons.woman_2_outlined,
        "color": const Color(0xFFD81B60),
      },
      {
        "label": "Health & Care",
        "icon": Icons.health_and_safety_outlined,
        "color": const Color(0xFF00897B),
      },
      {
        "label": "Jobs & Skills",
        "icon": Icons.work_outline,
        "color": const Color(0xFF5E35B1),
      },
      {
        "label": "Housing",
        "icon": Icons.house_outlined,
        "color": const Color(0xFFEF6C00),
      },
      {
        "label": "Senior Citizens",
        "icon": Icons.elderly_outlined,
        "color": const Color(0xFF455A64),
      },
      {
        "label": "All Schemes",
        "icon": Icons.grid_view_outlined,
        "color": const Color(0xFF015AA5),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Our Schemes for You",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Browse schemes based on your category and needs",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: schemes.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = schemes[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: (item["color"] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item["icon"] as IconData,
                      color: item["color"] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["label"] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
