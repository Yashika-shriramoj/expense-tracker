import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login.dart';
import 'add_expenses.dart';
import 'expense_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;

  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // A fixed color per category so the chart stays consistent
  final Map<String, Color> _categoryColors = {
    'Food': const Color(0xFFFF8A65),          // warm coral
    'Transport': const Color(0xFF4FC3F7),     // sky blue
    'Shopping': const Color(0xFFBA68C8),      // soft purple
    'Bills': const Color(0xFFE57373),         // muted red
    'Entertainment': const Color(0xFF4DB6AC), // teal
    'Other': const Color(0xFFB0BEC5),         // blue-grey
  };

  // Add this helper inside _HomePageState
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

// Groups expenses (already sorted newest-first from Supabase) by date header
  Map<String, List<Expense>> get _groupedExpenses {
    final Map<String, List<Expense>> groups = {};
    for (final e in _expenses) {
      final header = _formatDateHeader(e.createdAt);
      groups.putIfAbsent(header, () => []).add(e);
    }
    return groups;
  }

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User is not logged in');

      final data = await _supabase
          .from('expenses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final expenses = (data as List)
          .map((row) => Expense.fromMap(row as Map<String, dynamic>))
          .toList();

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load expenses: $e';
        _isLoading = false;
      });
    }
  }

  double get _totalSpent =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get _categoryTotals {
    final Map<String, double> totals = {};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Color _colorForCategory(String category) {
    return _categoryColors[category] ?? Colors.grey;
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink[300]),
              child: const Column(
                children: [
                  Icon(Icons.person, color: Colors.white, size: 48),
                  Text(
                    'profile info',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchExpenses,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[300],
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensesPage()),
          );
          if (result == true) {
            _fetchExpenses();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total card
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.pink[100]!.withValues(alpha: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Spent',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Chart or empty state
        if (_expenses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No expenses yet. Tap + to add one.')),
          )
        else ...[
          const Text(
            "Today's expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _categoryTotals.entries.map((entry) {
                  final percent = (entry.value / _totalSpent) * 100;
                  return PieChartSectionData(
                    color: _colorForCategory(entry.key),
                    value: entry.value,
                    title: '${percent.toStringAsFixed(0)}%',
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _categoryTotals.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: _colorForCategory(entry.key),
                  ),
                  const SizedBox(width: 6),
                  Text('${entry.key} (₹${entry.value.toStringAsFixed(0)})'),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          const Text(
            'Recent Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // List of expenses
          // List of expenses, grouped by date
          ..._groupedExpenses.entries.expand((group) {
            final header = group.key;
            final items = group.value;

            return [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  header,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...items.map((e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorForCategory(e.category).withValues(alpha: 0.15),
                    child: Icon(
                      _iconForCategory(e.category),
                      color: _colorForCategory(e.category),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    e.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(e.category),
                  trailing: Text(
                    '₹${e.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              )),
            ];
          }),
        ],
      ],
    );
  }
}