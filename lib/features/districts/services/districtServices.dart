import 'package:dio/dio.dart';

Future getDistricts() async {
  final dio = Dio();

  try {
    final response = await dio.get("https://www.nepallocation.com.np/api/v1/district/list",
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer oNBT8UY-LWlBc-Izt4wPFuaE",
        }));
    var distri = response.data['data'];
    return distri;
  } on DioError catch (e) {
    print(e);
  }
}
