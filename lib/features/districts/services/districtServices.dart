import 'package:dio/dio.dart';

Future getDistricts() async {
  final dio = Dio();

  try {
    final response = await dio.get(" Nepal's First Location API ",
        options: Options(headers: {
          "Content-Type": " CONTENT TYPE ",
          "Authorization": " AUTHORIZATION KEY ",
        }));
    var distri = response.data['data'];
    return distri;
  } on DioError catch (e) {
    print(e);
  }
}
