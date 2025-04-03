import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Resultscreen extends StatefulWidget {
  const Resultscreen({super.key});

  @override
  State<Resultscreen> createState() => _ResultscreenState();
}

class _ResultscreenState extends State<Resultscreen> {
  List<dynamic> matchData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMatchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
              onPressed: () {
                matchData = [];
                setState(() {});
                fetchMatchData();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: matchData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: matchData.length,
              itemBuilder: (context, index) {
                final match = matchData[index];
                // Extract team names from the JSON.
                final team1Name = match['team1']?['teamName'] ?? 'Team 1';
                final team2Name = match['team2']?['teamName'] ?? 'Team 2';

                // Use matchDateTimeUTC if available, otherwise fallback to matchDateTime.
                final rawDate =
                    match['matchDateTimeUTC'] ?? match['matchDateTime'] ?? '';
                final formattedDate = rawDate.isNotEmpty
                    ? formatMatchDate(rawDate)
                    : 'Unknown Date';

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0,
                  
                  child: ListTile(
                    leading: const Icon(Icons.sports_soccer),
                    trailing: const Icon(Icons.arrow_forward),
                    title: Text('$team1Name vs $team2Name'),
                    subtitle: Text('Date: $formattedDate'),
                    onTap: () {
                      // When tapped, show a dialog with detailed match info.
                      showDialog(
                        context: context,
                        builder: (context) {
                          // Extract the match results if available.
                          List<dynamic> results = match['matchResults'] ?? [];
                          return AlertDialog(
                            title: Text('$team1Name vs $team2Name'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: $formattedDate'),
                                  SizedBox(height: 10),
                                  if (results.isNotEmpty)
                                    ...results.map((result) {
                                      final resultName =
                                          result['resultName'] ?? 'Result';
                                      final pointsTeam1 =
                                          result['pointsTeam1']?.toString() ??
                                              '0';
                                      final pointsTeam2 =
                                          result['pointsTeam2']?.toString() ??
                                              '0';
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          '$resultName:\n  $team1Name $pointsTeam1 - $pointsTeam2 $team2Name',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList()
                                  else
                                    Text('No match results available.'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  /// Formats a raw UTC date string into a readable format.
  String formatMatchDate(String rawDate) {
    try {
      // Parse the UTC date string and convert it to local time.
      DateTime dateTime = DateTime.parse(rawDate).toLocal();
      // Format the date into a readable string.
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      // Return the raw date if parsing fails.
      return rawDate;
    }
  }

  /// Fetches match data from the OpenLigaDB API.
  Future<void> fetchMatchData() async {
    // Define the API URL.
    final apiUrl = Uri.parse('https://api.openligadb.de/getmatchdata/bl3');
    try {
      // Make an HTTP GET request.
      final response = await http.get(apiUrl);

      // Check if the response is OK (status code 200).
      if (response.statusCode == 200) {
        // Decode the JSON response.
        final List<dynamic> data = json.decode(response.body);

        // Update the state with the fetched data.
        setState(() {
          matchData = data;
        });
      } else {
        print(
            'Error: Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request.
      print('Exception caught: $e');
    }
  }
}
