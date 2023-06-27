import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AutoCompleteSearch extends StatefulWidget {
  final Function(LatLng latLng, String address) getCoordinates;

  const AutoCompleteSearch({super.key, required this.getCoordinates});
  @override
  _AutoCompleteSearchState createState() => _AutoCompleteSearchState();
}

class _AutoCompleteSearchState extends State<AutoCompleteSearch> {
  final _controller = TextEditingController();
  var uuid = new Uuid();
  String? _sessionToken;
  List<dynamic> _placeList = [];
  LatLng? latLng;
  String API_KEY = "YOUR_API_KEY";
  FocusNode focusNode = FocusNode();
  bool isSearchComplete = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _controller.addListener(() {
      _onChanged();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 60),
      child: Column(
        children: <Widget>[
          Container(
            child: TextField(
              enableSuggestions: true,
              onTap: () {
                setState(() {
                  isSearchComplete = true;
                });
              },
              focusNode: focusNode,
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
              cursorColor: Colors.green,
              decoration: new InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 255, 255, 0.95),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_placeList.isEmpty && _controller.text.isEmpty) return;
                    setState(() {
                      isSearchComplete = false;
                      focusNode.unfocus();
                      _controller.text = '';
                      _placeList.clear();
                    });
                  },
                  icon: Icon(
                    Icons.highlight_remove_sharp,
                    size: 25,
                    color: _placeList.isEmpty && _controller.text.isEmpty
                        ? Colors.grey
                        : Color.fromARGB(255, 255, 127, 118),
                  ),
                ),
                isDense: true,
                hintText: 'Search here',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 104, 104, 104),
                  // fontSize: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Color.fromRGBO(255, 255, 255, 0.9),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Color.fromARGB(255, 206, 206, 206),
                      ),
                    ),
                  ),
                  child: ListTile(
                    onTap: () =>
                        onLocationSelected(_placeList[index]['description']),
                    title: Text(
                      _placeList[index]['description'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  _onChanged() {
    if (_controller.text.isEmpty) {
      setState(() {
        _controller.text = '';
        _placeList.clear();
      });
    }
    if (_sessionToken == null) {
      _sessionToken = uuid.v4();
    }
    if (isSearchComplete && _controller.text.isNotEmpty)
      getSuggestion(_controller.text);
  }

  getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position p) {
      latLng = LatLng(p.latitude, p.longitude);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void getSuggestion(String input) async {
    String request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&location=${latLng!.latitude},${latLng!.longitude}&key=$API_KEY&sessiontoken=$_sessionToken&radius=10000';
    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200 && input.isNotEmpty) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
          print(_placeList[0]['description']);
        });
      } else {
        setState(() {
          _placeList.clear();
        });
        throw Exception('Failed to load predictions');
      }
    } catch (error) {}
  }

  onLocationSelected(String address) async {
    setState(() {
      isSearchComplete = false;
      _controller.text = address;
      _placeList.clear();
      focusNode.unfocus();
    });

    Location location = (await locationFromAddress(address))[0];
    widget.getCoordinates(
        LatLng(location.latitude, location.longitude), address.split(',')[0]);
  }
}
