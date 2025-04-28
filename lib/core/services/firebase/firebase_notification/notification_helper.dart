// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;

// class NotificationService {
//   // 1) الصق هنا JSON الخاص بك
//   static const _serviceAccountJson = r'''
// {
//   "type": "service_account",
//   "project_id": "tabibsoftcrm",
//   "private_key_id": "d08cd5e88d440b69c527d498fd1517a550559a1b",
//   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDMEMz3D8WiTcnG\nNpy36HZrjFYDYVplN1lFTzsZx3eUSpehpTuRCeY+rA5c1YGPCsvUGfjRDy+vH9eZ\nHiUOvUBc4DTfFQIk2MKfXDdp9ngXO5O3EaBTyhBmo/mgs4G5Oxkzk4iIVbSszM27\neZAMBfml4ftDd07tVyXOGXC2TXY3QHOr8X8YbyyQx3fiB1xrnc3D1R2NhKRFl9Ur\nN4qYSlJ4hVyp6AG02CQRLf3bBlIpixh99ic72+dIDwBIJVsVutJMuCIgby0PFJCN\nvTdrBpReW7XjYxKZbbxvJHnEvKMMdfVN2jVysi20mYRPKjK7X2kchx1AS+REuZk3\nF++IJInXAgMBAAECggEARiXmV22QCh2EZYNDd0LNZmYM8UeHe/C9WsKENfXoCM1l\nd3cl1VNaVyPtIgNw8HuNGsG80xzNzvz6r5N5uKnc1LBr7F276W+r430fPWkw2ges\nXQuNmhAFeEsY1iGuz75diOnHztnrbFVQyYfduQxax6e5qHT8aEEDaWg8YyaYoyAD\nHq0V2e5ngDF+aOFC7zqOlAW0vnbxAxgHGvazDP7idHLn1vtyHw3eCSxCCSpp033B\nhBECHnfun9sq2PkssszrPTTQ160iUIRIdRbS42ITKPlcvE7yT7159U8bHR0Ba9gj\nOahsgPK5Qosc46wQguf87k8R9Of1GOZnuSVup3kBcQKBgQDl9+g20aT8VC+xlOhx\n+AQ7LVdabvBfKgJ2gBobi0rVhJdhvs/CVS/MlzwpK2o+zyKb8triK1H6jraTsw7H\nrnSqBCG87cgIPWMC47Ju2NPZz4GJPGMMY22VFZ/7kHH//G+sA8ulR/IVlCyXvb41\nvd8mp2Kg2BnUk0RHX2aSbXmG0QKBgQDjKkaPHxDxfKpV5WZHrUfQtHQJrDoyxzik\nbxtvBShyrqeBwHkdEU6jXE48R/hy2iSc6IfCdEHvxZSYvSe8/O2xZf1XYUzD55+w\nwAhi1RVdgiXRbktz+qbtGQSsPwdR49TpXhsbQw9Lb1tkItKRsRrgmTLS02j5jaKb\naJRzqtEAJwKBgFxtOuNtdwYDP/f7hUDpEapHGui51doppDvEWLnhTf5q//zFF/Nf\nEYsE7aUOUfFUhvButxJXnuc5HKBYQwR2VWVPq8+nMdI9+eFbaoeqldrgz4s8vgJo\no85blqUg9PCRoMBd9idDt0R8/T8vf5dR7LI4bCeBM0CAv9x/t1X6sfFBAoGBAJRX\nCvRy6PGI4wJsZrnvobHb5NpcKTT3ezmFhHie+abJ/oBwW6ZrotpycHRU2xzE7pu4\nDM8ic9xLPZnwC38R+3WYkDL7StGy80jMXa2MUANb9a4pRARcbZzudWq1TeZfzK0H\n0tOemuI7uYZOZwrUiCSaZeHeQ/KSVtj9FdPie9CJAoGAGCDOwygM6HKUqsyZr8dR\nPUcn5d1o+QIUzeLiUwByCCA2uZgRXFdh4PtRWbFT6a1zdoAN3U7zllrLbPw0rj9d\nO6EUl5c4I24uZg0flZY6o61T4N3a3G8xxvwC3dnCIIWyUBY2R0ZlMFr28C9ffswZ\nfHs65MuZN+n83xjrqpMqefs=\n-----END PRIVATE KEY-----\n",
//   "client_email": "problem@tabibsoftcrm.iam.gserviceaccount.com",
//   "client_id": "111158141859180339165",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/problem%40tabibsoftcrm.iam.gserviceaccount.com",
//   "universe_domain": "googleapis.com"
// }
// ''';

//   // 2) النطاقات المطلوبة لإرسال رسائل FCM
//   static const _scopes = <String>[
//     'https://www.googleapis.com/auth/firebase.messaging',
//   ];

//   // 3) يحصل على توكن OAuth آليًا باستخدام Service Account :contentReference[oaicite:1]{index=1}
//   static Future<String> _getAccessToken() async {
//     final creds = auth.ServiceAccountCredentials.fromJson(_serviceAccountJson);
//     final client = await auth.clientViaServiceAccount(creds, _scopes);
//     // احصل على بيانات التوكن
//     final accessCredentials = await auth.obtainAccessCredentialsViaServiceAccount(
//       creds, _scopes, client);
//     client.close();
//     return accessCredentials.accessToken.data;
//   }

//   /// يرسل إشعار إلى جهاز محدد (token)
//   static Future<void> sendNotification({
//     required String deviceToken,
//     required String title,
//     required String body,
//     Map<String, String>? data,
//   }) async {
//     final token = await _getAccessToken();
//     final url = Uri.parse(
//       'https://fcm.googleapis.com/v1/projects/tabibsoftcrm/messages:send'
//     );
//     final message = {
//       'message': {
//         'token': deviceToken,
//         'notification': {'title': title, 'body': body},
//         if (data != null) 'data': data,
//       }
//     };
//     final resp = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode(message),
//     );
//     if (resp.statusCode != 200) {
//       throw Exception('Failed to send notification: ${resp.body}');
//     }
//   }
// }
