import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc_demo/firebase_options.dart';
import 'package:http/http.dart' as http;

class DynamicLinkHelper {
  static Future<String>? buildDynamicLinks(String selfId) async {
    var urlToReturn;
    final String postUrl = 'https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${DefaultFirebaseOptions.web.apiKey}';
    String theUrl = "https://winehouse.page.link/webrtc/?peerId=$selfId";

    await http
        .post(Uri.tryParse(postUrl)!,
            headers: {"content-type": "application/json"},
            body: jsonEncode({
              'dynamicLinkInfo': {
                'domainUriPrefix': 'https://winehouse.page.link',
                'link': theUrl,
                'androidInfo': {
                  'androidPackageName': 'com.cloudwebrtc.flutterwebrtcdemo',
                  'androidFallbackLink': theUrl,
                },
                'iosInfo': {
                  'iosBundleId': 'com.cloudwebrtc.flutterwebrtcdemo',
                  'iosFallbackLink': theUrl,
                },
              },
            }))
        .then(
      (http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode < 200 || statusCode > 400 || response == null) {
          throw new Exception("Error while fetching data");
        }
        var decoded = json.decode(response.body);
        urlToReturn = decoded['shortLink'];
        print('decoded: $decoded');
        print('urlToReturn: $urlToReturn');
        return decoded['shortLink'];
      },
    ).catchError((e) => debugPrint('error $e'));
    return urlToReturn;
  }
}
