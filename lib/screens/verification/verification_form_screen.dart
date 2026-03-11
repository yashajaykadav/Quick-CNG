import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/services/firestore_services.dart';

class VerificationFormScreen extends StatefulWidget {
  const VerificationFormScreen({super.key});

  @override
  State<VerificationFormScreen> createState() => _VerificationFormScreenState();
}

class _Station {
  final String id;
  final String name;
  final String city;
  _Station({required this.id, required this.name, required this.city});
}

class _VerificationFormScreenState extends State<VerificationFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _stationSearchController = TextEditingController();

  String _selectedRole = 'worker';
  bool _isSubmitting = false;
  bool _isLoadingUser = true;

  // Existing request (if any)
  Map<String, dynamic>? _existingRequest;

  final _firestoreService = FirestoreService();

  // Station picker state
  List<_Station> _allStations = [];
  List<_Station> _filteredStations = [];
  _Station? _selectedStation;
  bool _showStationDropdown = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _stationSearchController.addListener(_onStationSearchChanged);
    _loadInitialData();
  }

  void _onStationSearchChanged() {
    final query = _stationSearchController.text.toLowerCase();
    setState(() {
      _showStationDropdown = query.isNotEmpty;
      _filteredStations = _allStations
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.city.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check for existing request first
    final existing = await _firestoreService.checkExistingVerificationRequest();
    if (existing != null && mounted) {
      setState(() {
        _existingRequest = existing;
        _isLoadingUser = false;
      });
      _animController.forward();
      return; // Don't load form data
    }

    // No existing request — load form data in parallel
    await Future.wait([_fetchUserProfile(user.uid), _fetchStations()]);

    setState(() => _isLoadingUser = false);
    _animController.forward();
  }

  Future<void> _fetchUserProfile(String uid) async {
    final data = await _firestoreService.fetchCurrentUserProfile();
    if (data != null && mounted) {
      _nameController.text = data['displayName'] ?? '';
      if (data['contact'] != null) {
        _contactController.text = data['contact'];
      }
    }
  }

  Future<void> _fetchStations() async {
    final stations = await _firestoreService.fetchAllStationsOnce();
    if (mounted) {
      _allStations = stations
          .map(
            (s) => _Station(id: s['id']!, name: s['name']!, city: s['city']!),
          )
          .toList();
      _filteredStations = _allStations;
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a station from the list.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.submitVerificationRequest(
        userId: user.uid,
        fullName: _nameController.text.trim(),
        stationId: _selectedStation!.id,
        stationName: _selectedStation!.name,
        contact: _contactController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Request submitted! Admin will verify you shortly.'),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _stationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
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
                'Get Verified',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[800]!, Colors.green[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 160,
                      color: Colors.white.withAlpha(25),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Verified Staff Application',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _isLoadingUser
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : _existingRequest != null
            ? _buildStatusView()
            : FadeTransition(
                opacity: _fadeAnim,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withAlpha(40)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Submit your details and our admin team will verify your request within 24 hours.',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _sectionLabel('Personal Details'),
                      const SizedBox(height: 12),

                      // Name Field
                      _buildCard(
                        child: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter your full name'
                              : null,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Contact Field
                      _buildCard(
                        child: TextFormField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            label: 'Contact Number',
                            icon: Icons.phone_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your contact number';
                            }
                            if (v.trim().length < 10) {
                              return 'Enter a valid contact number';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      _sectionLabel('Station Details'),
                      const SizedBox(height: 12),

                      // Station Picker
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _stationSearchController,
                              decoration:
                                  _inputDecoration(
                                    label: _selectedStation != null
                                        ? _selectedStation!.name
                                        : 'Search CNG Station...',
                                    icon: Icons.local_gas_station_outlined,
                                  ).copyWith(
                                    suffixIcon: _selectedStation != null
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () => setState(() {
                                              _selectedStation = null;
                                              _stationSearchController.clear();
                                              _showStationDropdown = false;
                                            }),
                                          )
                                        : const Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                          ),
                                  ),
                              validator: (_) => _selectedStation == null
                                  ? 'Please select a station'
                                  : null,
                            ),
                            if (_showStationDropdown &&
                                _filteredStations.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  itemCount: _filteredStations.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final s = _filteredStations[index];
                                    return ListTile(
                                      leading: Icon(
                                        Icons.local_gas_station,
                                        color: Colors.green[600],
                                        size: 20,
                                      ),
                                      title: Text(
                                        s.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        s.city,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedStation = s;
                                          _stationSearchController.clear();
                                          _showStationDropdown = false;
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                    );
                                  },
                                ),
                              ),
                            if (_selectedStation != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${_selectedStation!.name}, ${_selectedStation!.city}',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _sectionLabel('I am applying as'),
                      const SizedBox(height: 12),

                      // Role Selector
                      Row(
                        children: [
                          _roleCard(
                            role: 'worker',
                            label: 'Worker',
                            subtitle: 'Station staff member',
                            icon: Icons.badge_outlined,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _roleCard(
                            role: 'owner',
                            label: 'Owner',
                            subtitle: 'Station owner / manager',
                            icon: Icons.store_outlined,
                            color: Colors.purple,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Submit Verification Request',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _roleCard({
    required String role,
    required String label,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color[400]! : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? color[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? color[700] : Colors.grey[600],
                      size: 22,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color[600], size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? color[800] : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? color[600] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green[700], size: 22),
      border: InputBorder.none,
      labelStyle: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildStatusView() {
    final request = _existingRequest!;
    final status = (request['status'] ?? 'pending') as String;
    final stationName = (request['stationName'] ?? '') as String;
    final role = (request['role'] ?? '') as String;

    final isPending = status == 'pending';
    final isApproved = status == 'approved';

    final Color statusColor = isApproved
        ? Colors.green
        : isPending
        ? Colors.amber
        : Colors.red;
    final IconData statusIcon = isApproved
        ? Icons.verified_user
        : isPending
        ? Icons.hourglass_top_rounded
        : Icons.cancel_outlined;
    final String statusTitle = isApproved
        ? 'Verification Approved!'
        : isPending
        ? 'Request Under Review'
        : 'Verification Rejected';
    final String statusMessage = isApproved
        ? 'Your account has been verified. You can now access staff features.'
        : isPending
        ? 'Your request has been received. Our admin team will review it within 24 hours.'
        : 'Your verification was not approved. Please contact support for more details.';

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 52, color: statusColor),
            ),
            const SizedBox(height: 24),

            // Status Title
            Text(
              statusTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 10),

            // Message
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Request Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUBMISSION DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.local_gas_station_outlined,
                    'Station',
                    stationName,
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    role == 'owner'
                        ? Icons.store_outlined
                        : Icons.badge_outlined,
                    'Role',
                    role[0].toUpperCase() + role.substring(1),
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.circle,
                    'Status',
                    status[0].toUpperCase() + status.substring(1),
                    valueColor: statusColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Back button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
