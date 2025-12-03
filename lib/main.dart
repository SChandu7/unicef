import 'package:flutter/material.dart';
import 'package:unicef/customre.dart';

void main() {
  runApp(const GovtSchemesApp());
}

class GovtSchemesApp extends StatelessWidget {
  const GovtSchemesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Govt Schemes Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F5FB),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Roboto')),
      ),
      home: const GovtDashboardScreen(),
    );
  }
}

class Scheme {
  final String id;
  final String name;
  final String shortCode;
  final IconData icon;
  final Color color;

  final int totalFamilies;
  final int coveredFamilies;
  final int poorCount;
  final int middleCount;
  final int richCount;
  final Map<String, int> villageCoverage;
  final List<String> eligibilityPoints;
  final List<String> reasonsNotAvailing;

  Scheme({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.icon,
    required this.color,
    required this.totalFamilies,
    required this.coveredFamilies,
    required this.poorCount,
    required this.middleCount,
    required this.richCount,
    required this.villageCoverage,
    required this.eligibilityPoints,
    required this.reasonsNotAvailing,
  });

  double get coveragePercentage {
    if (totalFamilies == 0) return 0;
    return (coveredFamilies / totalFamilies) * 100;
  }
}

class GovtDashboardScreen extends StatefulWidget {
  const GovtDashboardScreen({super.key});

  @override
  State<GovtDashboardScreen> createState() => _GovtDashboardScreenState();
}

class _GovtDashboardScreenState extends State<GovtDashboardScreen> {
  late List<Scheme> schemes;
  Scheme? selectedScheme;

  @override
  void initState() {
    super.initState();
    schemes = _mockSchemes;
    selectedScheme = schemes.first;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                // LEFT PANE – scheme cards
                SizedBox(
                  width: isNarrow ? 280 : 320,
                  child: _buildLeftPane(context),
                ),

                // Divider line
                Container(width: 1, color: Colors.grey.shade300),

                // RIGHT PANE – dashboard details
                Expanded(
                  child: selectedScheme == null
                      ? const Center(
                          child: Text(
                            'Select a scheme from left side to view dashboard',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : _buildRightPane(context, selectedScheme!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeftPane(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF101322),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Govt Schemes\nDashboard – NIT Raipur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CitizenDashboard()),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.white70),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C2033),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white54, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search schemes...',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Schemes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: schemes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                final bool isSelected = scheme.id == selectedScheme?.id;
                return _SchemeCard(
                  scheme: scheme,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedScheme = scheme;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(BuildContext context, Scheme scheme) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top bar: title + filters
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(scheme.icon, color: scheme.color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  scheme.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // small quick filters – just UI
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All Families'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Poor / BPL'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Village-wise'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // KPI cards row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoStatCard(
                          title: 'Total Families',
                          value: '${scheme.totalFamilies}',
                          subtitle: 'Households surveyed',
                          icon: Icons.groups,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoStatCard(
                          title: 'Covered Families',
                          value: '${scheme.coveredFamilies}',
                          subtitle: 'Already received scheme benefit',
                          icon: Icons.verified_user,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoStatCard(
                          title: 'Coverage',
                          value:
                              '${scheme.coveragePercentage.toStringAsFixed(1)}%',
                          subtitle: 'Families covered / total',
                          icon: Icons.show_chart,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Charts row – Poverty graph + village graph
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Socio-economic bar chart
                      Expanded(
                        flex: 2,
                        child: _CardContainer(
                          title: 'Socio-Economic Distribution',
                          subtitle:
                              'How many families (Poor / Middle / Rich) are covered under this scheme',
                          child: _SocioEconomicChart(scheme: scheme),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Village coverage graph
                      Expanded(
                        flex: 3,
                        child: _CardContainer(
                          title: 'Village-wise Coverage',
                          subtitle:
                              'Number of families per village that received scheme benefits',
                          child: _VillageCoverageChart(scheme: scheme),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Eligibility & reasons not availing
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CardContainer(
                          title: 'Eligibility Criteria',
                          subtitle:
                              'Which families are eligible to receive this scheme',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final point in scheme.eligibilityPoints)
                                _BulletPoint(text: point),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CardContainer(
                          title: 'Why eligible families are not taking it',
                          subtitle:
                              'Reasons why some households are still not availing this scheme',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final reason in scheme.reasonsNotAvailing)
                                _BulletPoint(text: reason),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Bottom info: summary
                  _CardContainer(
                    title: 'Summary for Officials',
                    subtitle:
                        'Quick view for district / block level decision makers',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Approx. ${scheme.coveragePercentage.toStringAsFixed(1)}% families covered. '
                          'Focus is required on remaining ${(100 - scheme.coveragePercentage).toStringAsFixed(1)}% families.\n'
                          '• Priority villages: ${_topVillagesString(scheme)}\n'
                          '• You can drill down per household (next version) to see which family got benefit, who is pending, and exact reason.',
                          style: const TextStyle(fontSize: 13.5, height: 1.4),
                        ),
                      ],
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

  String _topVillagesString(Scheme s) {
    if (s.villageCoverage.isEmpty) return 'No data';
    final sorted = s.villageCoverage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).map((e) => e.key).join(', ');
    return top;
  }
}

/// LHS scheme tile card
class _SchemeCard extends StatelessWidget {
  final Scheme scheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _SchemeCard({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? scheme.color.withOpacity(0.18)
        : const Color(0xFF1C2033);
    final borderColor = isSelected
        ? scheme.color
        : Colors.white.withOpacity(0.06);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(scheme.icon, color: scheme.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.shortCode,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scheme.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.groups, size: 14, color: Colors.white54),
                      const SizedBox(width: 3),
                      Text(
                        '${scheme.totalFamilies}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${scheme.coveragePercentage.toStringAsFixed(0)}% covered',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isSelected ? Icons.keyboard_arrow_right : Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stat card at top of right pane
class _InfoStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _InfoStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      padding: const EdgeInsets.all(14),
      title: title,
      subtitle: subtitle,
      trailing: Icon(icon, size: 20, color: Colors.grey.shade700),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }
}

/// Generic card container
class _CardContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  const _CardContainer({
    required this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Bullet text row
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13.5, height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple bar chart for Poor / Middle / Rich
class _SocioEconomicChart extends StatelessWidget {
  final Scheme scheme;

  const _SocioEconomicChart({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final int maxVal = [
      scheme.poorCount,
      scheme.middleCount,
      scheme.richCount,
    ].reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No data available'),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BarColumn(label: 'Poor', value: scheme.poorCount, maxValue: maxVal),
          _BarColumn(
            label: 'Middle',
            value: scheme.middleCount,
            maxValue: maxVal,
          ),
          _BarColumn(label: 'Rich', value: scheme.richCount, maxValue: maxVal),
        ],
      ),
    );
  }
}

/// Simple horizontal bar chart for village-wise coverage
class _VillageCoverageChart extends StatelessWidget {
  final Scheme scheme;

  const _VillageCoverageChart({required this.scheme});

  @override
  Widget build(BuildContext context) {
    if (scheme.villageCoverage.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No village data available'),
        ),
      );
    }

    final entries = scheme.villageCoverage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = entries.first.value;

    return Column(
      children: [
        const SizedBox(height: 4),
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 12.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.indigo.withOpacity(0.12),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: maxValue == 0
                            ? 0
                            : (e.value / maxValue).clamp(0, 1).toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${e.value}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// vertical bar for socio-economic chart
class _BarColumn extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const _BarColumn({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final double heightFactor = maxValue == 0
        ? 0
        : (value / maxValue).clamp(0, 1).toDouble();

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$value', style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 26,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.grey.shade200,
                ),
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: heightFactor,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

final List<Scheme> _mockSchemes = [
  Scheme(
    id: '1',
    name: 'Pradhan Mantri Awas Yojana (PMAY)',
    shortCode: 'PMAY – Housing for All',
    icon: Icons.home_work,
    color: Colors.indigo,
    totalFamilies: 1200,
    coveredFamilies: 860,
    poorCount: 640,
    middleCount: 180,
    richCount: 40,
    villageCoverage: {
      'Village A': 240,
      'Village B': 210,
      'Village C': 180,
      'Village D': 120,
      'Village E': 110,
    },
    eligibilityPoints: [
      'Family does not own a pucca house.',
      'Valid Aadhaar and ration card.',
      'EWS/LIG income category.',
    ],
    reasonsNotAvailing: [
      'Land dispute.',
      'Lack of proper documentation.',
      'Unaware of eligibility.',
    ],
  ),

  Scheme(
    id: '2',
    name: 'Ayushman Bharat – PM-JAY',
    shortCode: 'PMJAY – Health Insurance',
    icon: Icons.health_and_safety,
    color: Colors.green,
    totalFamilies: 950,
    coveredFamilies: 670,
    poorCount: 520,
    middleCount: 120,
    richCount: 30,
    villageCoverage: {
      'Village A': 190,
      'Village C': 160,
      'Village F': 120,
      'Village G': 90,
      'Village H': 60,
    },
    eligibilityPoints: [
      'Name must be in NFSA/SECC list',
      'No tax-paying member',
      'Aadhaar & e-KYC required',
    ],
    reasonsNotAvailing: [
      'No knowledge of empanelled hospitals',
      'Hospitals refusing cashless claims',
    ],
  ),

  Scheme(
    id: '3',
    name: 'PM Kisan Samman Nidhi',
    shortCode: 'PM-KISAN',
    icon: Icons.agriculture,
    color: Colors.orange,
    totalFamilies: 600,
    coveredFamilies: 420,
    poorCount: 310,
    middleCount: 90,
    richCount: 20,
    villageCoverage: {
      'Village B': 140,
      'Village D': 120,
      'Village I': 80,
      'Village J': 60,
    },
    eligibilityPoints: [
      'Farmer with cultivable land',
      'Bank account linked with Aadhaar',
    ],
    reasonsNotAvailing: ['Mismatch in records', 'Land not updated'],
  ),

  Scheme(
    id: '4',
    name: 'Ujjwala Yojana (PMUY)',
    shortCode: 'PMUY – LPG Scheme',
    icon: Icons.local_gas_station,
    color: Colors.deepPurple,
    totalFamilies: 780,
    coveredFamilies: 540,
    poorCount: 480,
    middleCount: 50,
    richCount: 10,
    villageCoverage: {'Village A': 200, 'Village B': 140, 'Village D': 100},
    eligibilityPoints: ['BPL household', 'Female applicant', 'Aadhaar'],
    reasonsNotAvailing: ['Cylinder refill cost is high', 'No awareness'],
  ),

  Scheme(
    id: '5',
    name: 'Sukanya Samriddhi Yojana',
    shortCode: 'SSY – Girl Child Savings',
    icon: Icons.child_friendly,
    color: Colors.pink,
    totalFamilies: 500,
    coveredFamilies: 300,
    poorCount: 240,
    middleCount: 50,
    richCount: 10,
    villageCoverage: {'Village C': 140, 'Village A': 100, 'Village E': 60},
    eligibilityPoints: [
      'Girl child age < 10 years',
      'Parent identity & passbook',
    ],
    reasonsNotAvailing: ['Parents unaware', 'Bank form complexity'],
  ),

  Scheme(
    id: '6',
    name: 'MGNREGA Employment Scheme',
    shortCode: 'MGNREGA – Rural Jobs',
    icon: Icons.construction,
    color: Colors.brown,
    totalFamilies: 1400,
    coveredFamilies: 980,
    poorCount: 820,
    middleCount: 140,
    richCount: 20,
    villageCoverage: {
      'Village A': 300,
      'Village B': 260,
      'Village F': 240,
      'Village K': 180,
    },
    eligibilityPoints: ['Family in rural India', 'Job card mandatory'],
    reasonsNotAvailing: ['Payment delay', 'No job card'],
  ),

  Scheme(
    id: '7',
    name: 'Jan Dhan Yojana',
    shortCode: 'PMJDY – Banking Access',
    icon: Icons.account_balance_wallet,
    color: Colors.teal,
    totalFamilies: 1100,
    coveredFamilies: 900,
    poorCount: 750,
    middleCount: 130,
    richCount: 20,
    villageCoverage: {'Village H': 260, 'Village A': 240, 'Village C': 220},
    eligibilityPoints: ['No bank account previously', 'Aadhaar mandatory'],
    reasonsNotAvailing: ['No KYC documents', 'Migration'],
  ),

  Scheme(
    id: '8',
    name: 'Swachh Bharat Mission – Toilets',
    shortCode: 'SBM – Sanitation',
    icon: Icons.wc,
    color: Colors.blueGrey,
    totalFamilies: 880,
    coveredFamilies: 740,
    poorCount: 680,
    middleCount: 50,
    richCount: 10,
    villageCoverage: {'Village D': 260, 'Village B': 200, 'Village F': 180},
    eligibilityPoints: [
      'Must not already have toilet',
      'Permanent rural residence',
    ],
    reasonsNotAvailing: ['Space issues', 'Construction delay'],
  ),

  Scheme(
    id: '9',
    name: 'National Scholarship Portal',
    shortCode: 'NSP – Student Scholarship',
    icon: Icons.school,
    color: Colors.blue,
    totalFamilies: 430,
    coveredFamilies: 260,
    poorCount: 210,
    middleCount: 40,
    richCount: 10,
    villageCoverage: {'Village A': 90, 'Village E': 80, 'Village M': 60},
    eligibilityPoints: [
      'Student enrolled in recognised school/college',
      'Income proof required',
    ],
    reasonsNotAvailing: ['Portal errors', 'Document upload issues'],
  ),

  Scheme(
    id: '10',
    name: 'PM Fasal Bima Yojana',
    shortCode: 'PMFBY – Crop Insurance',
    icon: Icons.grass,
    color: Colors.lime,
    totalFamilies: 520,
    coveredFamilies: 390,
    poorCount: 310,
    middleCount: 60,
    richCount: 20,
    villageCoverage: {'Village B': 180, 'Village H': 120, 'Village D': 90},
    eligibilityPoints: [
      'Farmer growing notified crop',
      'Aadhaar & land record verified',
    ],
    reasonsNotAvailing: ['Claim settlement delays', 'Premium confusion'],
  ),
];
