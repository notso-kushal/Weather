import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'features/districts/services/districtServices.dart';
import 'view/sebar.dart';

class Start extends StatefulWidget {
  const Start({
    Key? key,
  }) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  var date = DateFormat("yMMMMEEEEd").format(DateTime.now());
  var time = DateFormat.jm().format(DateTime.now());
  String? currentAddress;
  Position? currentPosition;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String search = ' ';
  var kelvin = 273.15;
  List<dynamic> filteredData = []; // Added a list to store filtered data

  @override
  void initState() {
    handleLocationPermission();
    getCurrentPosition();
    getData();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        time = DateFormat.jm().format(DateTime.now());
      });
    });

    super.initState();
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable the services')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      setState(() => currentPosition = position);
      _getAddressFromLatLng(currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        currentAddress = '${place.subAdministrativeArea}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<dynamic> getData() async {
    final dio = Dio();

    if (currentAddress != null) {
      setState(() {
        isLoading = true; // Show loading animation
      });

      try {
        final response = await dio.get(
          "https://api.openweathermap.org/data/2.5/weather?q=$currentAddress&appid=55eb6cd8fdfbb62d95316b9ea6eb08ad",
        );
        if (response.statusCode == 200) {
          var results = response.data;

          if (results['cod'] == '404') {
            // Handle error when API returns 404 code
            return null;
          } else {
            return results;
          }
        }
      } on DioError catch (e) {
        print(e);
        return null;
      } finally {
        setState(() {
          isLoading = false; // Hide loading animation
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00203f),
      appBar: AppBar(
        iconTheme: const IconThemeData(size: 5),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'माैसम',
          style: TextStyle(
              color: Color(0xFFadefd1), fontSize: 30, shadows: [Shadow(color: Colors.yellow, offset: Offset(1, 1))]),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              showSearchBar(context); // Open the SearchBar
            },
            icon: const Icon(
              Icons.search_rounded,
              size: 30,
              color: Color(0xFFadefd1),
            )),

        //
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFadefd1),
                    size: 30,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("$currentAddress",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFadefd1),
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  "$time - $date",
                  style: const TextStyle(
                    fontSize: 12.7,
                    color: Color(0xFFadefd1),
                  ),
                ),
              ),
              FutureBuilder(
                  future: getData(),
                  initialData: null,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var tempo = snapshot.data['main']['temp'] - kelvin;
                      var feels = snapshot.data['main']['feels_like'] - kelvin;
                      int feelslike = feels.toInt();
                      int temperature = tempo.toInt();
                      String description = snapshot.data['weather'][0]['description'];
                      var visibility = snapshot.data['visibility'] / 1000;
                      var sunr = snapshot.data['sys']['sunrise'];
                      var dateTime = DateTime.fromMillisecondsSinceEpoch(sunr * 1000, isUtc: true);
                      var sunrise = DateFormat.jm().format(dateTime.toLocal());
                      var sunt = snapshot.data['sys']['sunset'];
                      var dateTimee = DateTime.fromMillisecondsSinceEpoch(sunt * 1000, isUtc: true);
                      var sunset = DateFormat.jm().format(dateTimee.toLocal());

                      return Column(
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Column(
                            children: [
                              Container(
                                  child: Image(
                                image: NetworkImage(
                                    "https://openweathermap.org/img/wn/${snapshot.data['weather'][0]['icon']}.png"),
                                height: 80,
                                width: 80,
                                fit: BoxFit.fill,
                              )),
                              Text("$temperature°C",
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Color(0xFFadefd1),
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(("Feels like: $feelslike°C"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFadefd1),
                                    fontWeight: FontWeight.w400,
                                  )),
                              Text(description,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.dotted,
                                    fontSize: 10,
                                    color: Color(0xFFadefd1),
                                    fontWeight: FontWeight.w400,
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.yellow,
                                      offset: Offset(2, 3),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFadefd1),
                                ),
                                child: Column(children: [
                                  const Text(
                                    'Wind',
                                    style:
                                        TextStyle(color: Color(0xFF00203f), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Image.asset('assets/images/wind.png', height: 30),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "${snapshot.data['wind']['speed']} m/s",
                                    style: const TextStyle(color: Color(0xFF00203f), fontSize: 12),
                                  )
                                ]),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  boxShadow: const [BoxShadow(color: Colors.yellow, offset: Offset(2, 3))],
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFadefd1),
                                ),
                                child: Column(children: [
                                  const Text(
                                    'Visibility',
                                    style:
                                        TextStyle(color: Color(0xFF00203f), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Image.asset('assets/images/visibility.png', height: 30),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "$visibility km",
                                    style: const TextStyle(color: Color(0xFF00203f), fontSize: 12),
                                  )
                                ]),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  boxShadow: const [BoxShadow(color: Colors.yellow, offset: Offset(2, 3))],
                                  color: const Color(0xFFadefd1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(children: [
                                  const Text(
                                    'Humidity',
                                    style:
                                        TextStyle(color: Color(0xFF00203f), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Image.asset('assets/images/drop.png', height: 40),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "${snapshot.data['main']['humidity']} %",
                                    style: const TextStyle(color: Color(0xFF00203f), fontSize: 12),
                                  )
                                ]),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xFFadefd1),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: const [BoxShadow(color: Colors.yellow, offset: Offset(2, 3))]),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/sun.png',
                                            height: 40,
                                          ),
                                          const Text('\tSunrise', style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                      Text(
                                        sunrise,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xFFadefd1),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: const [BoxShadow(color: Colors.yellow, offset: Offset(2, 3))]),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/sunset-.png',
                                            height: 40,
                                          ),
                                          const Text('\tSunset', style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                      Text(
                                        sunset,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFadefd1),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [BoxShadow(color: Colors.yellow, offset: Offset(2, 3))]),
                            child: Column(
                              children: [
                                Container(
                                    padding: const EdgeInsets.only(top: 10, left: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/images/clouds.png',
                                          height: 40,
                                        ),
                                        const Text(
                                          ' Clouds Cover',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          " ${snapshot.data['clouds']['all']} %",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    )),
                                Container(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    Image.asset(
                                      'assets/images/pressure.png',
                                      height: 50,
                                    ),
                                    const Text(
                                      ' Pressure',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      " ${snapshot.data['main']['pressure']} hPa",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.only(top: 150),
                        child: Image(
                          image: AssetImage('assets/images/404.png'),
                          fit: BoxFit.contain,
                          height: 180,
                          width: 400,
                        ),
                      );
                    }
                  }),
              FutureBuilder(
                future: getDistricts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    filteredData = snapshot.data['data'].where((district) {
                      String name = district['name'].toString().toLowerCase();
                      String altName = district['alt_name'].toString().toLowerCase();
                      String searchValue = searchController.text.toLowerCase();
                      return name.contains(searchValue) || altName.contains(searchValue);
                    }).toList();
                  }
                  return const ListTile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  showSearchBar(BuildContext context) async {
    var selectedAddress = await showSearch(
      context: context,
      delegate: SearchBarDelegate(filteredData),
    );

    if (selectedAddress != null) {
      setState(() {
        currentAddress = selectedAddress;
      });
    }
    // Handle the selected address
  }
}
