import 'package:flutter/material.dart';
import 'package:weather/features/districts/services/districtServices.dart';

class Listd extends StatefulWidget {
  Listd({Key? key}) : super(key: key);

  @override
  State<Listd> createState() => _ListdState();
}

class _ListdState extends State<Listd> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredData = [];
  String? currentAddress;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDistricts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          filteredData = snapshot.data['data'].where((district) {
            String name = district['name'].toString().toLowerCase();
            String altName = district['alt_name'].toString().toLowerCase();
            String searchValue = searchController.text.toLowerCase();
            return name.contains(searchValue) || altName.contains(searchValue);
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                  child: Text(filteredData[index]['district_id'].toString()),
                ),
                title: Text(filteredData[index]['name'].toString()),
                subtitle: Text(filteredData[index]['alt_name'].toString()),
              );
            },
          );
        } else {
          return const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }
      },
    );
  }
}
