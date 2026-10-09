import 'package:flutter/material.dart';
import '../../../core/services/nearby_journeys.dart';
import '../../../theme/app_theme.dart';

class DiscoveryAreaSheet extends StatefulWidget {
  final NearbyLocationService service;
  const DiscoveryAreaSheet({required this.service, super.key});
  @override
  State<DiscoveryAreaSheet> createState() => _DiscoveryAreaSheetState();
}

class _DiscoveryAreaSheetState extends State<DiscoveryAreaSheet> {
  String _query = '';
  String? _error;
  bool _locating = false;

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final area = await widget.service.locate();
      if (mounted) Navigator.pop(context, area);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is LocationIssue
              ? error.message
              : 'We couldn’t find your area. Choose a city or try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = discoveryCities
        .where(
          (a) => '${a.city} ${a.country}'.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Where shall we look?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Find objects around you, or explore another city.'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _locating ? null : _locate,
                  icon: _locating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.near_me_outlined),
                  label: Text(
                    _locating ? 'Finding your area…' : 'Use my location',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Only used to sort nearby objects. Your device location is not saved or shared.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                enabled: !_locating,
                decoration: const InputDecoration(
                  hintText: 'Search a city',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              SizedBox(
                child: cities.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching city. Try your device location.',
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(city.city),
                            subtitle: Text(city.country),
                            trailing: const Icon(
                              Icons.arrow_outward_rounded,
                              size: 18,
                            ),
                            onTap: _locating
                                ? null
                                : () => Navigator.pop(context, city),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
