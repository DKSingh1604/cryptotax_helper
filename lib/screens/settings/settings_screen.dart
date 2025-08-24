import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cryptotax_helper/models/user_settings.dart';
import 'package:cryptotax_helper/models/transaction.dart';
import 'package:cryptotax_helper/services/crypto_repository.dart';
import 'package:cryptotax_helper/utils/constants.dart';
import 'package:cryptotax_helper/utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  final Function(UserSettings)? onSettingsChanged;

  const SettingsScreen({super.key, this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  UserSettings _settings = UserSettings();
  final _taxRateController = TextEditingController();
  final _repository = CryptoRepository();
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      _repository.getUserSettings().listen((settings) {
        if (settings != null && mounted) {
          setState(() {
            _settings = settings;
            _taxRateController.text = settings.taxRate.toString();
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading settings: $e',
            isError: true);
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _repository.saveUserSettings(_settings);
      widget.onSettingsChanged?.call(_settings);
      if (mounted) {
        Helpers.showSnackBar(context, AppStrings.settingsSaved);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error saving settings: $e',
            isError: true);
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repository.signOut();
                Navigator.pop(context);
                if (mounted) {
                  Helpers.showSnackBar(context, 'Logged out successfully');
                }
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  Helpers.showSnackBar(context, 'Error logging out: $e', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _updateCurrency(Currency currency) {
    setState(() => _settings = _settings.copyWith(currency: currency));
    _saveSettings();
  }

  void _updateTaxRate(String value) {
    final taxRate = double.tryParse(value);
    if (taxRate != null && taxRate >= 0 && taxRate <= 100) {
      setState(() => _settings = _settings.copyWith(taxRate: taxRate));
      _saveSettings();
    }
  }

  void _updateThemeMode(bool isDarkMode) {
    setState(() => _settings = _settings.copyWith(isDarkMode: isDarkMode));
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              padding: AppConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 32),

                  // Preferences Section
                  _buildPreferencesSection(),
                  const SizedBox(height: 32),

                  // App Section
                  _buildAppSection(),
                  const SizedBox(height: 32),

                  // About Section
                  _buildAboutSection(),
                  const SizedBox(height: 32),

                  // Account Section
                  _buildAccountSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: AppConstants.cardPadding,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crypto Trader',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'trader@cryptotax.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement edit profile
                  Helpers.showSnackBar(context, 'Edit profile coming soon!');
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),

        // Currency Setting
        _buildSettingCard(
          title: 'Currency',
          subtitle: 'Choose your preferred currency',
          child: DropdownButton<Currency>(
            value: _settings.currency,
            underline: const SizedBox(),
            items: Currency.values.map((currency) {
              return DropdownMenuItem<Currency>(
                value: currency,
                child: Text(currency.displayName),
              );
            }).toList(),
            onChanged: (currency) {
              if (currency != null) _updateCurrency(currency);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Tax Rate Setting
        _buildSettingCard(
          title: 'Tax Rate',
          subtitle: 'Set your tax rate percentage (0-100%)',
          child: SizedBox(
            width: 80,
            child: TextFormField(
              controller: _taxRateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                suffix: Text('%'),
              ),
              validator: Helpers.validateTaxRate,
              onFieldSubmitted: _updateTaxRate,
              onEditingComplete: () => _updateTaxRate(_taxRateController.text),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),

        // Theme Setting
        _buildSettingCard(
          title: 'Dark Mode',
          subtitle: 'Choose your preferred theme',
          child: Switch(
            value: _settings.isDarkMode,
            onChanged: _updateThemeMode,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 16),

        // Notifications Setting
        _buildSettingCard(
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          trailing: Icon(
            Icons.arrow_forward_ios,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          onTap: () {
            // TODO: Implement notifications settings
            Helpers.showSnackBar(context, 'Notification settings coming soon!');
          },
        ),

        const SizedBox(height: 16),

        // Export Data Setting
        _buildSettingCard(
          title: 'Export Data',
          subtitle: 'Export your transactions and reports',
          trailing: Icon(
            Icons.arrow_forward_ios,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          onTap: _showExportDialog,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),

        // Version Info
        _buildSettingCard(
          title: 'Version',
          subtitle: 'App version ${AppConstants.appVersion}',
          trailing: Icon(
            Icons.info_outline,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        // Help & Support
        _buildSettingCard(
          title: 'Help & Support',
          subtitle: 'Get help with the app',
          trailing: Icon(
            Icons.arrow_forward_ios,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          onTap: () {
            // TODO: Implement help & support
            Helpers.showSnackBar(context, 'Help & support coming soon!');
          },
        ),

        const SizedBox(height: 16),

        // Privacy Policy
        _buildSettingCard(
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          trailing: Icon(
            Icons.arrow_forward_ios,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          onTap: () {
            // TODO: Implement privacy policy
            Helpers.showSnackBar(context, 'Privacy policy coming soon!');
          },
        ),

        const SizedBox(height: 32),

        // Clear Data Button
        Center(
          child: TextButton.icon(
            onPressed: _showClearDataDialog,
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            label: Text(
              'Clear All Data',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    Widget? child,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppConstants.cardPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (child != null) child,
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Export your transactions and settings data. You can copy it to clipboard or share it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportToCsv();
            },
            child: const Text('Export CSV'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportToJson();
            },
            child: const Text('Export JSON'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCsv() async {
    try {
      final transactions = await _repository.getUserTransactions().first;
      final settings = await _repository.getUserSettings().first;

      // Create CSV content
      final StringBuffer csvBuffer = StringBuffer();
      csvBuffer.writeln(
          'Date,Coin Name,Symbol,Type,Amount,Price Per Unit,Total Value');

      for (final transaction in transactions) {
        csvBuffer.writeln(
          '${transaction.date.toIso8601String()},${transaction.coinName},${transaction.coinSymbol},${transaction.type.displayName},${transaction.amount},${transaction.pricePerUnit},${transaction.totalValue}',
        );
      }

      // Add settings section
      if (settings != null) {
        csvBuffer.writeln('\n--- Settings ---');
        csvBuffer.writeln('Currency,${settings.currency.displayName}');
        csvBuffer.writeln('Tax Rate,${settings.taxRate}%');
        csvBuffer.writeln('Dark Mode,${settings.isDarkMode}');
      }

      await Clipboard.setData(ClipboardData(text: csvBuffer.toString()));

      if (mounted) {
        Helpers.showSnackBar(context, 'CSV data copied to clipboard');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error exporting CSV: $e', isError: true);
      }
    }
  }

  Future<void> _exportToJson() async {
    try {
      final transactions = await _repository.getUserTransactions().first;
      final settings = await _repository.getUserSettings().first;

      // Create JSON export data
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': AppConstants.appVersion,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'settings': settings?.toJson(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        Helpers.showSnackBar(context, 'JSON data copied to clipboard');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error exporting JSON: $e',
            isError: true);
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear data functionality would delete user account
              // This is a dangerous operation, so we'll just show a warning
              if (mounted) {
                Helpers.showSnackBar(
                  context, 
                  'Clear data functionality would delete your entire account. Use logout instead.', 
                  isError: true
                );
              }
            },
            child: Text(
              'Clear Data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    final user = _repository.currentUser;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        
        // User Info
        if (user != null) ...[
          Container(
            padding: AppConstants.cardPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                      Text(
                        user.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Logout Button
        Container(
          width: double.infinity,
          padding: AppConstants.cardPadding,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
