import 'package:flutter/material.dart';
import 'package:hockeyapp/theme/app_theme.dart';
import '../services/coach_service.dart';
import 'coach_detail_page.dart';
import 'create_coach_page.dart';

class CoachListPage extends StatefulWidget {
  const CoachListPage({super.key});

  @override
  State<CoachListPage> createState() => _CoachListPageState();
}

class _CoachListPageState extends State<CoachListPage> {
  List<Coach> _coaches = [];
  List<Coach> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  Future<void> _load() async {
    setState(()  {
      _loading = true;
      _error = null;
    });
    try {
      final list = await CoachService().listCoaches();
      setState(() {
        _coaches = list;
        _filtered = list;
        _loading = false;
      });
    } catch(e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _coaches.where((c) {
        final fullName = '${c.firstName} ${c.lastName}'.toLowerCase();
        return fullName.contains(q);
      }).toList();
    });
  }

  Future<void> _handleRefresh() async {
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Coaches', style: TextStyle(color: Colors.white),),
          backgroundColor: AppTheme.primaryColor,
          leadingWidth: 140,
          leading: Row(
            children: [
              const BackButton(color: Colors.white),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Image.asset(
                  'images/logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final created = await Navigator.push<Coach>(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCoachPage()),
                );
                if (created != null) _load();
              },
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search players...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: _buildBody()
      );

      Widget _buildBody() {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_filtered.isEmpty) {
          return const Center(child: Text('No players found'));
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final c = _filtered[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoachDetailPage(id: c.id),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(c.photo ?? ''),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${c.firstName} ${c.lastName}', style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
}
