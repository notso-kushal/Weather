// import 'package:weather/features/core/services/dio-service.dart';
// import 'package:weather/features/districts/models/district.dart';

// class LocationService{
//   final DioService dioService = DioService();

//   final String locationBase = "https://www.nepallocation.com.np/api/v1";

//   Future<List<District>> getAllDistricts() async {
//     String endpoint = '$locationBase/district/list';
//     var response = (await dioService.get(endpoint))["data"];
//     var districts = List<District>.empty(growable:true);
//     print(response);
//     throw Error();
//   }
// }

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
