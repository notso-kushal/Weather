import 'package:flutter/material.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  final List<dynamic> filteredData;

  SearchBarDelegate(this.filteredData);

  @override
  appBarTheme(BuildContext context) {
    return ThemeData(
      inputDecorationTheme:
          const InputDecorationTheme(focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none)),
      hintColor: Color(0xFFadefd1),
      canvasColor: Color(0xFF00203f),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Color(0xFFadefd1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: const Color(0xFF00203f),
        elevation: 0,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(
            Icons.close_rounded,
            size: 20,
            color: Color(0xFFadefd1),
          ))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: Color(0xFFadefd1),
      ),
      onPressed: () {
        Navigator.pop(context, query = 'Kathmandu');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile();
    // final results = filteredData.where((district) {
    //   String name = district['name'].toString().toLowerCase();
    //   String altName = district['alt_name'].toString().toLowerCase();
    //   String searchValue = query.toLowerCase();
    //   return name.contains(searchValue) || altName.contains(searchValue);
    // }).toList();

    // return ListView.builder(
    //   itemCount: results.length,
    //   itemBuilder: (context, index) {
    //     return Padding(
    //         padding: EdgeInsets.only(left: 0),
    //         child: ListTile(
    //           title: Text(
    //             results[index]['name'].toString(),
    //             style: TextStyle(color: Color(0xFFAADDAA)),
    //           ),
    //           subtitle: Text(
    //             results[index]['alt_name'].toString(),
    //           ),
    //           onTap: () {
    //             close(context, results[index]['name'].toString());
    //           },
    //         ));
    //   },
    // );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = filteredData.where((district) {
      String name = district['name'].toString().toLowerCase();
      String altName = district['alt_name'].toString().toLowerCase();
      String searchValue = query.toLowerCase();
      return name.contains(searchValue) || altName.contains(searchValue);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.only(left: 30),
          title: Text(
            suggestions[index]['name'].toString(),
            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFadefd1)),
          ),
          subtitle: Text(
            ' ' + suggestions[index]['alt_name'].toString(),
            style: TextStyle(color: Color(0xFFadefd1).withOpacity(0.5)),
          ),
          onTap: () {
            close(context, suggestions[index]['name'].toString());
          },
          enabled: true,
        );
      },
    );
  }
}
