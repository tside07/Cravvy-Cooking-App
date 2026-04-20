import 'package:cravvy_cooking_app/init.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _mealReminder = true;
  bool _dailySuggestion = true;
  bool _waterReminder = false;
  bool _newsUpdates = true;
  bool _isDarkMode = false;
  bool _showDeleteConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  Text('Settings', style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Banner
                    _PremiumBanner(onTap: () => context.push(AppRouter.premium)),
                    const SizedBox(height: 20),

                    // Notifications
                    _SectionTitle(title: 'Notifications'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _SwitchTile(
                        icon: Icons.restaurant_menu_outlined,
                        iconColor: AppColors.primary,
                        title: 'Meal Reminders',
                        subtitle: 'Notify me at meal times',
                        value: _mealReminder,
                        onChanged: (v) => setState(() => _mealReminder = v),
                      ),
                      _Divider(),
                      _SwitchTile(
                        icon: Icons.auto_awesome_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Daily Suggestions',
                        subtitle: 'AI meal ideas every morning',
                        value: _dailySuggestion,
                        onChanged: (v) => setState(() => _dailySuggestion = v),
                      ),
                      _Divider(),
                      _SwitchTile(
                        icon: Icons.water_drop_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        title: 'Water Reminder',
                        subtitle: 'Every 2 hours',
                        value: _waterReminder,
                        onChanged: (v) => setState(() => _waterReminder = v),
                      ),
                      _Divider(),
                      _SwitchTile(
                        icon: Icons.campaign_outlined,
                        iconColor: AppColors.warning,
                        title: 'News & Updates',
                        subtitle: 'New recipes and tips',
                        value: _newsUpdates,
                        onChanged: (v) => setState(() => _newsUpdates = v),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Appearance
                    _SectionTitle(title: 'Appearance'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _SwitchTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: 'Dark Mode',
                        subtitle: 'Switch to dark theme',
                        value: _isDarkMode,
                        onChanged: (v) => setState(() => _isDarkMode = v),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.language_outlined,
                        iconColor: AppColors.secondary,
                        title: 'Language',
                        trailing: 'English',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Account
                    _SectionTitle(title: 'Account'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _NavTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: AppColors.primary,
                        title: 'Edit Profile',
                        onTap: () => context.push(AppRouter.editProfile),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFF6366F1),
                        title: 'Change Password',
                        onTap: () => context.push(AppRouter.forgotPassword),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.download_outlined,
                        iconColor: AppColors.secondary,
                        title: 'Export My Data',
                        onTap: () => _showExportDialog(),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Legal
                    _SectionTitle(title: 'Legal & Support'),
                    const SizedBox(height: 8),
                    _SettingsCard(children: [
                      _NavTile(
                        icon: Icons.help_outline_rounded,
                        iconColor: AppColors.primary,
                        title: 'FAQ',
                        onTap: () => context.push(AppRouter.faq),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        title: 'Privacy Policy',
                        onTap: () => context.push(AppRouter.privacyPolicy),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Terms of Service',
                        onTap: () => context.push(AppRouter.termsOfService),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.warning,
                        title: 'Disclaimer',
                        onTap: () => context.push(AppRouter.disclaimer),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Danger zone
                    _SettingsCard(children: [
                      _NavTile(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.error,
                        title: 'Sign Out',
                        titleColor: AppColors.error,
                        onTap: () => _showSignOutDialog(),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.delete_outline_rounded,
                        iconColor: AppColors.error,
                        title: 'Delete Account',
                        titleColor: AppColors.error,
                        onTap: () => setState(() => _showDeleteConfirm = true),
                      ),
                    ]),

                    if (_showDeleteConfirm) ...[
                      const SizedBox(height: 12),
                      _DeleteConfirmCard(
                        onCancel: () => setState(() => _showDeleteConfirm = false),
                        onConfirm: () {},
                      ),
                    ],

                    const SizedBox(height: 32),
                    Center(
                      child: Text('Cravvy v1.0.0',
                          style: AppTextStyles.s12.copyWith(color: AppColors.textHint)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Data'),
        content: const Text('Your data will be compiled and sent to your email address within 24 hours.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Request Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); context.go(AppRouter.login); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to Premium', style: AppTextStyles.s16.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('Unlock AI meals, 1000+ recipes & more', style: AppTextStyles.s12.copyWith(color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(title,
            style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(height: 1, indent: 56, color: AppColors.border);
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;
  final Color? titleColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textPrimary)),
            ),
            if (trailing != null) ...[
              Text(trailing!, style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmCard extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  const _DeleteConfirmCard({required this.onCancel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure?', style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700, color: AppColors.error)),
          const SizedBox(height: 6),
          Text('Deleting your account is permanent. All your data, meal plans, and progress will be erased.',
              style: AppTextStyles.s12.copyWith(color: AppColors.error)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text('Cancel', style: TextStyle(color: AppColors.error)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
