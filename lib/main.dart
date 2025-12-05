import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unicef/loginsignup.dart';
 import 'package:url_launcher/url_launcher.dart';


void main() async {
  runApp(const GovSchemesApp());
}

class GovSchemesApp extends StatelessWidget {
  const GovSchemesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GovtS Schemes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF015AA5),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
 // Change this to your actual HomeScreen import



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.3)
        .animate(CurvedAnimation(curve: Curves.easeOutBack, parent: _controller));

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(curve: Curves.easeIn, parent: _controller));

    _controller.forward();

    /// Redirect after 2.2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Updated Bigger Logo
                Image.asset(
                  "assets/splash.jpg",
                  width: 200, // Increased Size
                ),

                const SizedBox(height: 16),

                const Text(
                  "yourSchemes",
                  style: TextStyle(
                    fontSize: 26,  // Bigger Text
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF015AA5),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "आपकी योजनाएँ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

final List<Map<String, String>> notifications = [
  {
    "title": "PM Awas Yojana List Updated",
    "time": "2 hrs ago",
    "msg": "New beneficiary list available. Check eligibility now."
  },
  {
    "title": "Ayushman Bharat Verification",
    "time": "Yesterday",
    "msg": "Your Ayushman health card requires verification."
  },
  {
    "title": "Kisan Samman Nidhi Released",
    "time": "2 days ago",
    "msg": "₹2,000 installment transferred to eligible farmers."
  },
  {
    "title": "New Scholarship Applications Open",
    "time": "3 days ago",
    "msg": "Apply before the deadline to avoid rejection."
  },
];


final schemeData = {
  "Infancy": [
    {
      "name": "Pradhan Mantri Matru Vandana Yojana (PMMVY)",
      "status": "Eligible",
      "link": "https://www.myscheme.gov.in/schemes/pmmvy?utm_source=chatgpt.com",
      "desc":
          "Provides ₹5,000 financial support to pregnant and lactating mothers to compensate wage loss and support nutrition."
    },
    {
      "name": "Janani Suraksha Yojana (JSY)",
      "status": "Applied",
      "link": "https://nhm.gov.in/index1.php?lang=1&level=3&lid=309&sublinkid=841&utm_source=chatgpt.com",
      "desc":
          "Cash assistance for institutional delivery and maternal care, especially for BPL and SC/ST mothers."
    },
  ],

  "Childhood": [
    {
      "name": "Integrated Child Development Services (ICDS / Anganwadi)",
      "status": "Eligible",
      "link": "https://icds.gov.in/en/about-us?utm_source=chatgpt.com",
      "desc":
          "Provides nutrition, immunization, preschool education, and health check-ups to children (0–6 yrs) and mothers."
    },
    {
      "name": "Mukhyamantri Suposhan Abhiyan (Chhattisgarh)",
      "status": "Pending",
      "link": "https://manendragarh-chirmiri-bharatpur.cg.gov.in/scheme/%E0%A4%AE%E0%A5%81%E0%A4%96%E0%A5%8D%E0%A4%AF%E0%A4%AE%E0%A4%82%E0%A4%A4%E0%A5%8D%E0%A4%B0%E0%A5%80-%E0%A4%B8%E0%A5%81%E0%A4%AA%E0%A5%8B%E0%A4%B7%E0%A4%A3-%E0%A4%85%E0%A4%AD%E0%A4%BF%E0%A4%AF%E0%A4%BE/?utm_source=chatgpt.com",
      "desc":
          "Free nutritious meals for malnourished children and anaemic women to eliminate malnutrition."
    },
  ],

  "Adulthood": [
    {
      "name": "Pradhan Mantri Kaushal Vikas Yojana (PMKVY)",
      "status": "Eligible",
      "link": "https://www.msde.gov.in/offerings/schemes-and-services/details/pradhan-mantri-kaushal-vikas-yojana-4-0-pmkvy-4-0-2021-ITO3ATMtQWa?utm_source=chatgpt.com",
      "desc":
          "Free skill training with certification to improve employability and job placement for youth."
    },
  ],

  "Family": [
    {
      "name": "Pradhan Mantri Awas Yojana (Urban & Gramin)",
      "status": "Eligible",
      "link": "https://pmaymis.gov.in/?utm_source=chatgpt.com",
      "desc":
          "Financial assistance to build or upgrade pucca houses under Housing for All mission."
    },
    {
      "name": "Ayushman Bharat - Jan Arogya Yojana (PMJAY)",
      "status": "Applied",
      "link": "https://nha-gov-in.translate.goog/PM-JAY?_x_tr_sl=en&_x_tr_tl=hi&_x_tr_hl=hi&_x_tr_pto=tc",
      "desc":
          "₹5 lakh free health insurance per family per year for eligible citizens in empanelled hospitals."
    },
  ],

  "Farmers": [
    {
      "name": "PM Kisan Samman Nidhi",
      "status": "Eligible",
      "link": "https://www.digitalindia.gov.in/initiative/pm-kisan/?utm_source=chatgpt.com",
      "desc":
          "Direct income support of ₹6,000/year to small and marginal farmers credited in three instalments."
    },
    {
      "name": "Rajiv Gandhi Kisan Nyay Yojana (Chhattisgarh)",
      "status": "Eligible",
      "link": "https://www.myscheme.gov.in/schemes/rgkny",
      "desc":
          "Financial support per acre to farmers for paddy and other notified crops to boost income."
    },
  ],

  "Old Age": [
    {
      "name": "Indira Gandhi National Old Age Pension Scheme (IGNOAPS)",
      "status": "Eligible",
      "link": "https://www.myscheme.gov.in/schemes/nsap-ignoaps?utm_source=chatgpt.com",
      "desc":
          "Monthly pension for BPL citizens aged 60+ to provide financial security in old age."
    },
  ],
};



  final List<String> _bannerTitles = [
    "Mann Ki Baat - Join Live",
    "मन की बात - सीधा प्रसारण",

    "New Scholarship Schemes",
    "नई छात्रवृत्ति योजनाएँ",

    "Women Empowerment Yojana",
    "महिला सशक्तिकरण योजना",
  ];

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

      _showSchemeDetails(schemeData);
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
                const SizedBox(height: 2),
                _buildVerticalAnnouncement(),
                const SizedBox(height: 10),
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
      {"name": "Infancy", "icon": Icons.school},
      {"name": "Childhood", "icon": Icons.agriculture},
      {"name": "Adulthood", "icon": Icons.woman},
      {"name": "Family", "icon": Icons.health_and_safety},
      {"name": "Old Age", "icon": Icons.work},
      {"name": "Farmers", "icon": Icons.elderly},
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
                        onTap: () => _showSchemeDetails(scheme),

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: col.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Title & Badge Row
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: col.withOpacity(0.13),
                                    child: Icon(
                                      Icons.assured_workload,
                                      color: col,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      scheme["name"] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  
                                ],
                              ),

                              const SizedBox(height: 10),

                              // 🔹 Short description (auto assigned)
                              Text(
                                scheme["desc"] ??
                                    "Tap to view eligibility, benefits & how to apply.",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(height: 10),

                         Row(
  children: [
    Icon(
      Icons.info_outline,
      size: 16,
      color: Colors.grey.shade500,
    ),
    const SizedBox(width: 6),

    Expanded(
      child: Text(
        "Tap to view details",
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Spacing before status badge
    const SizedBox(width: 6),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: col,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
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


void _showSchemeDetails(Map<String, dynamic> scheme) async {
  final String title = scheme["name"];
  final String status = scheme["status"];
  final String desc = scheme["desc"];
  final String link = scheme["link"] ?? "";

  Color statusColor(String status) {
    switch (status) {
      case "Eligible":
        return Color(0xFF2E7D32);
      case "Applied":
        return Color(0xFF1976D2);
      case "Pending":
        return Color(0xFFFFA000);
      case "Not Eligible":
        return Color(0xFFD32F2F);
      case "New":
        return Color(0xFF673AB7);
      default:
        return Colors.grey;
    }
  }

  Future<void> launchURL() async {
  final Uri uri = Uri.parse(link);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not launch $uri");
  }
}


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    builder: (_) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Bar
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor(status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor(status),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Description
            const Text(
              "📌 Scheme Overview",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            Text(
              desc,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "✔ Eligibility Criteria",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            _bullet("- Indian Citizen"),
            _bullet("- Aadhaar required"),
            _bullet("- Income criteria may apply"),
            _bullet("- Age requirements vary per scheme"),

            const SizedBox(height: 22),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: link.isNotEmpty ? launchURL : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF015AA5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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

            // Official Website Text Button
            if (link.isNotEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: launchURL,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text("Open Official Website"),
                ),
              ),
          ],
        ),
      );
    },
  );
}

Widget _bullet(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("•  ", style: TextStyle(fontSize: 14)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    ),
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
          InkWell(
            
               
             
            
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(),
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () {
                  _showNotificationPanel();
                },
                child: const Icon(Icons.notifications_none_outlined, size: 29)),
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
                    "4",
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
  return Column(
    children: [
      // 🔹 Original Stat Container
      Container(
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
      ),

      const SizedBox(height: 10),

      // 🔹 Vertical Auto Scrolling Announcement
      
    ],
  );
}



Widget _buildVerticalAnnouncement() {
  final List<String> announcements = [
    "📌 New Scholarship Applications Open — Apply Before Dec 15.",
    "📌 नई छात्रवृत्ति आवेदन प्रक्रिया शुरू — अंतिम तिथि: 15 दिसंबर।",

    "📌 PM Awas Yojana Beneficiary List Released — Check Now.",
    "📌 प्रधानमंत्री आवास योजना लाभार्थी सूची जारी — अभी देखें।",

    "📌 Free Govt. Skill Development Training Starts Next Week.",
    "📌 निःशुल्क सरकारी कौशल विकास प्रशिक्षण अगले सप्ताह से शुरू।",

    "📌 Ayushman Bharat Card Verification Required Immediately.",
    "📌 आयुष्मान भारत कार्ड सत्यापन आवश्यक — तुरंत पूरा करें।",

    "📌 Kisan Samman Nidhi 16th Installment Released.",
    "📌 किसान सम्मान निधि की 16वीं किश्त जारी कर दी गई है।",
  ];

  // group into pairs (ENG + HINDI)
  final List<List<String>> grouped = [];
  for (int i = 0; i < announcements.length; i += 2) {
    grouped.add([
      announcements[i],
      announcements[i + 1],
    ]);
  }

  final PageController controller = PageController();
  final int totalSlides = grouped.length;

  // 🔄 Auto scroll every 3 seconds
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (controller.hasClients) {
        final nextPage = (controller.page!.round() + 1) % totalSlides;
        controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  });

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Container(
      height: 125,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // 🔔 Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF015AA5).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign, color: Color(0xFF015AA5), size: 20),
          ),

          const SizedBox(width: 14),

          // 🚫 Disable manual scroll
          Expanded(
            child: IgnorePointer(
              ignoring: true,
              child: PageView.builder(
                controller: controller,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grouped.length,
                itemBuilder: (_, index) {
                  final pair = grouped[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pair[0], // English
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pair[1], // Hindi
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.30,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
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


void _showNotificationPanel() {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.35), // Background blur
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: MediaQuery.of(context).size.width * 0.95,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // ------- HEADER -------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "🔔 Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        notifications.clear();
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text(
                        "Clear All",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No notifications yet",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final item = notifications[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0057C1)
                                          .withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      color: Color(0xFF0057C1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["title"]!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item["msg"]!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.25,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item["time"]!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    },

    // Slide down animation
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        )),
        child: Opacity(opacity: anim.value, child: child),
      );
    },
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
