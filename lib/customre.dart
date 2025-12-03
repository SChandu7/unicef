import 'package:flutter/material.dart';

// ------------------------ DATA MODEL ------------------------

class Scheme {
  final String name;
  final String desc;
  final IconData icon;
  final String status; // eligible | applied | approved | not-eligible

  Scheme({
    required this.name,
    required this.desc,
    required this.icon,
    required this.status,
  });
}

// ------------------------ DASHBOARD UI ------------------------

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  Scheme? selected;

  final List<Scheme> schemes = [
    Scheme(
      name: "PMAY - Housing",
      desc: "Affordable housing subsidy.",
      icon: Icons.home,
      status: "eligible",
    ),
    Scheme(
      name: "Ayushman Bharat (PMJAY)",
      desc: "₹5 lakh health insurance.",
      icon: Icons.health_and_safety,
      status: "approved",
    ),
    Scheme(
      name: "PM Kisan Samman",
      desc: "₹6000 yearly for farmers.",
      icon: Icons.agriculture,
      status: "applied",
    ),
    Scheme(
      name: "Sukanya Samriddhi Yojana",
      desc: "Girl child savings program.",
      icon: Icons.child_friendly,
      status: "not-eligible",
    ),
    Scheme(
      name: "MGNREGA Work Guarantee",
      desc: "100 days guaranteed work.",
      icon: Icons.construction,
      status: "eligible",
    ),
    Scheme(
      name: "PM Ujjwala - LPG",
      desc: "Free LPG gas connection.",
      icon: Icons.local_gas_station,
      status: "approved",
    ),
    Scheme(
      name: "Jan Dhan Banking",
      desc: "Zero-balance bank account.",
      icon: Icons.account_balance_wallet,
      status: "approved",
    ),
    Scheme(
      name: "NSP Scholarships",
      desc: "Scholarships for students.",
      icon: Icons.school,
      status: "eligible",
    ),
    Scheme(
      name: "Fasal Bima Yojana",
      desc: "Crop insurance for farmers.",
      icon: Icons.grass,
      status: "eligible",
    ),
    Scheme(
      name: "Digital India Literacy",
      desc: "Free digital training.",
      icon: Icons.laptop,
      status: "eligible",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildRightSection()),
        ],
      ),
    );
  }

  // ------------------------ LEFT USER PANEL ------------------------

  Widget _buildSidebar() {
    return Container(
      width: 290,
      color: const Color(0xFF0F1424),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage("assets/imgicon1.png"),
          ),

          const SizedBox(height: 10),
          const Text(
            "Chandra Sekhar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Village: Vijaywada, Andhra Pradesh",
            style: TextStyle(color: Colors.white60, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const Divider(color: Colors.white24, height: 30),
          _sideItem(Icons.family_restroom, "Family Members Registered: 6"),
          _sideItem(Icons.check_circle, "Schemes Availed: 4"),
          _sideItem(Icons.hourglass_bottom, "Pending: 1"),
          _sideItem(Icons.security, "Verified with Aadhaar ✓"),
          const Spacer(),
          Text(
            "Last Updated: Feb 2025",
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          const Text(
            "Powered by Govt. of India",
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------ RIGHT MAIN PANEL ------------------------

  Widget _buildRightSection() {
    return Row(
      children: [
        Expanded(child: _buildSchemesGrid()),
        if (selected != null)
          SizedBox(width: 400, child: _buildSchemeDetailPanel()),
      ],
    );
  }

  Widget _buildSchemesGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.35,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: schemes.map((s) => _schemeTile(s)).toList(),
      ),
    );
  }

  // ------------------------ SCHEME CARD ------------------------

  Widget _schemeTile(Scheme s) {
    return InkWell(
      onTap: () => setState(() => selected = s),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(s.icon, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                s.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(s.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _statusText(s.status),
                  style: TextStyle(
                    color: _statusColor(s.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------ RIGHT SCHEME DETAILS PANEL ------------------------

  Widget _buildSchemeDetailPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: selected == null
          ? const Center(child: Text("Select a scheme"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(selected!.icon, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selected!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  selected!.desc,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _infoRow("Status", _statusText(selected!.status)),
                _infoRow(
                  "Required Documents",
                  "Aadhaar, Address Proof, Bank Details",
                ),
                _infoRow(
                  "Estimated Benefit",
                  "₹25,000 - ₹2,50,000 (depends on category)",
                ),
                const Spacer(),
                _actionButton(selected!.status),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String status) {
    if (status == "eligible") {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.app_registration),
        label: const Text("Apply Now"),
      );
    } else if (status == "applied") {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.track_changes),
        label: const Text("Track Application"),
      );
    } else if (status == "approved") {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download),
        label: const Text("Download Certificate"),
      );
    } else {
      return const Text(
        "You are not eligible for this scheme",
        style: TextStyle(color: Colors.red),
      );
    }
  }

  // ------------------------ HELPERS ------------------------

  Color _statusColor(String status) {
    switch (status) {
      case "eligible":
        return Colors.blue;
      case "applied":
        return Colors.orange;
      case "approved":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case "eligible":
        return "Eligible";
      case "applied":
        return "Applied";
      case "approved":
        return "Approved";
      default:
        return "Not Eligible";
    }
  }
}
