// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Load your Riot API Key from .env file
  final String apiKey = dotenv.env['RIOT_API_KEY']!;
  String gameName = ''; // Store the Riot ID
  String tagLine = ''; // Store the Riot Tag
  // Function to fetch account data by Riot ID
  Future<void> fetchAccountData(
    String gameName,
    String tagLine,

    //   String puuid,
  ) async {
    print('Fetching account for: $gameName$tagLine');
    // Ensure Riot ID and TagLine are URL-encoded
    // final String riotId = Uri.encodeComponent(gameName);
    // final String riotTag = Uri.encodeComponent(tagLine);
    final String encodedGameName = Uri.encodeComponent(gameName);
    final String encodedTagLine = Uri.encodeComponent(tagLine);
    //final String riotId = 'Eung';
    //final String riotTag = '777';
    //final String puuid = Uri.encodeComponent(puuid);
    // Construct the endpoint dynamically
    final String endpoint =
        'https://europe.api.riotgames.com/riot/account/v1/accounts/by-riot-id/$encodedGameName/$encodedTagLine';
    //'https://europe.api.riotgames.com/riot/account/v1/accounts/by-puuid/WSr2qDThGK0wsdxQj5JxPK5elIMRbHt2-NblXR5FkyOOse_DZyOYN30qWqtBtzyXPfq8PqAZOTbdMw';
    // const String baseUrl = 'https://eu.api.riotgames.com';

    // Construct the full URL
    // final String url = baseUrl;

    try {
      // Send the GET request
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          "X-Riot-Token": apiKey, // Include your API key in the header
        },
      );

      // Log request details for debugging
      //print('URL: $url');
      print('Endpoint: $endpoint');
      print('Headers: ${{'X-Riot-Token': apiKey}}');

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String puuid = data['puuid']; // Extract PUUID
        print("PUUID: $puuid");
        Fluttertoast.showToast(
          msg:
              "PUUID fetched :$puuid", //${data['gameName']}#${data['tagLine']}", //'#${data['puuid']}}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
        Fluttertoast.showToast(
          msg: "Failed to fetch PUUID: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      print("Error: $error");
      Fluttertoast.showToast(
        msg: "An error occurred: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example input for testing
    // String gameName = newGameName; // Replace with actual Riot ID
    //String tagLine = newTagline; // Replace with actual TagLine
    // final String puuid = "";
    //  'WSr2qDThGK0wsdxQj5JxPK5elIMRbHt2-NblXR5FkyOOse_DZyOYN30qWqtBtzyXPfq8PqAZOTbdMw';
    return Scaffold(
      appBar: AppBar(title: const Text('Login Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Fetch Riot Account',
              style: TextStyle(
                fontSize: 35,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Riot ID',
                  hintText: 'e.g. your username',
                ),
                onChanged: (value) {
                  setState(() {
                    gameName = value;
                  });
                  print('Riot ID: $value');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Riot Tag',
                  hintText: 'e.g. EUW',
                ),
                onChanged: (value) {
                  setState(() {
                    tagLine = value;
                  });
                  print('Riot Tag: $value');
                },
              ),
            ),
            const SizedBox(height: 30),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: () {
                print('Riot ID: $gameName, TagLine: $tagLine');
                fetchAccountData(
                  gameName,
                  tagLine,
                ); // gameName, tagLine); //puuid);
              },
              color: Colors.blue,
              textColor: Colors.white,
              child: const Text('Fetch Account Data'),
            ),
          ],
        ),
      ),
    );
  }
}
