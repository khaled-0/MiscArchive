import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

final Dio _dio = Dio();
PersistCookieJar? _cookieJar;

Dio get dio => _dio;

PersistCookieJar get cookieJar => _cookieJar!;

Future<void> initDioClient() async {
  if (_cookieJar == null) {
    final String appDocDir = (await getApplicationSupportDirectory()).path;
    _cookieJar = PersistCookieJar(
      storage: FileStorage("$appDocDir/.cookies/"),
    );
  }
  dio.options.baseUrl = "https://trickbd.com";
  dio.interceptors.add(CookieManager(_cookieJar!));
  dio.options.queryParameters.addAll({"theme_change": "mobile"});
}

Future<void> launchUrlInBrowser(String? url) async {
  try {
    await launchUrlString(url ?? "", mode: LaunchMode.externalApplication);
  } catch (_) {}
}
