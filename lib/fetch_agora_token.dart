import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchAgoraToken {
  Future<String> fetchAgoraToken(String channelName, int uid) async {
    final url = Uri.parse(
      'https://us-central1-taskapp-45e27.cloudfunctions.net/generateToken?channelName=$channelName&uid=$uid',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to fetch Agora token');
    }
  }
}
