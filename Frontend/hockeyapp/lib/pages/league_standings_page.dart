import 'package:flutter/material.dart';

class LeagueStandingsPage extends StatelessWidget {
  const LeagueStandingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> standings = [
      {
        'team': 'Windhoek Hockey',
        'P': 22, 'W': 18, 'D': 2, 'L': 2, 'GF': 76, 'GA': 23
      },
      {
        'team': 'Swakopmund Hockey Club',
        'P': 22, 'W': 16, 'D': 3, 'L': 3, 'GF': 68, 'GA': 31
      },
      {
        'team': 'Walvis Bay Hockey Club',
        'P': 22, 'W': 12, 'D': 3, 'L': 7, 'GF': 52, 'GA': 41
      },
      {
        'team': 'Oshakati HC',
        'P': 22, 'W': 10, 'D': 5, 'L': 7, 'GF': 48, 'GA': 44
      },
      {
        'team': 'Keetmanshoop HC',
        'P': 22, 'W': 9, 'D': 4, 'L': 9, 'GF': 43, 'GA': 46
      },
      {
        'team': 'Unam Hockey Club',
        'P': 22, 'W': 7, 'D': 6, 'L': 9, 'GF': 38, 'GA': 49
      },
      {
        'team': 'Nust Hockey Club',
        'P': 22, 'W': 5, 'D': 4, 'L': 13, 'GF': 29, 'GA': 58
      },
      {
        'team': 'Saints Hockey Club',
        'P': 22, 'W': 3, 'D': 3, 'L': 16, 'GF': 24, 'GA': 67
      },
      {
        'team': 'Luderitz HC',
        'P': 22, 'W': 2, 'D': 2, 'L': 18, 'GF': 18, 'GA': 73
      },
      {
        'team': 'Otjiwarongo HC',
        'P': 22, 'W': 14, 'D': 4, 'L': 4, 'GF': 59, 'GA': 38
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('League Standings'),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.blue[900],
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Image.asset(
                    'images/logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2024/2025 Namibian Hockey Union - Premier League',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Updated after Round 22 • 6 matches remaining',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DataTable(
                columnSpacing: 10,
                headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Team', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('P', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('W', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('D', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('L', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('GF', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('GA', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: standings.asMap().entries.map((entry) {
                  int index = entry.key;
                  var team = entry.value;
                  return DataRow(cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(Text(team['team'])),
                    DataCell(Text(team['P'].toString())),
                    DataCell(Text(team['W'].toString())),
                    DataCell(Text(team['D'].toString())),
                    DataCell(Text(team['L'].toString())),
                    DataCell(Text(team['GF'].toString())),
                    DataCell(Text(team['GA'].toString())),
                  ]);
                }).toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                'Qualification:\n⬛ League Champion    🔵 Continental Cup    🔴 Relegation',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
