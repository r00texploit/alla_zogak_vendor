import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:alla_zogak_vendor/api/user_service.dart';
import '../models/vendors.dart';

class ChangeLocationWidget extends StatefulWidget {
  final Vendors? vendor;
  final Future<void> Function() pull;
  const ChangeLocationWidget({Key? key, required this.pull, this.vendor})
      : super(key: key);

  @override
  State<ChangeLocationWidget> createState() => _ChangeLocationWidgetState();
}

class _ChangeLocationWidgetState extends State<ChangeLocationWidget> {
  TextEditingController location = TextEditingController();
  double? lat;
  double? lng;
  double? newLat;
  double? newLng;
  bool loading = false;
  bool loadingLocation = false;

  @override
  void initState() {
    super.initState();
    location.text = widget.vendor?.address ?? "";
    lat = widget.vendor?.lat;
    lng = widget.vendor?.lng;
  }

  updateProfileData()async{
    try {
      setState(() {
        loading = true;
      });
      Map<String, dynamic> map = {};
      if(location.text.isNotEmpty){
        map['address'] = location.text;
      }
      if (newLat != null) {
        map['lat'] = newLat;
        map['lng'] = newLng;
      }
      final resp = await updateProfile(map);
      if(resp.success){
        await widget.pull();
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
        setState(() {
          loading = false;
        });
    }
  }

  getLocation() async {
    try {
      setState(() {
        loadingLocation = true;
      });
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      locationData = await location.getLocation();
      setState(() {
        newLat = locationData.latitude;
        newLng = locationData.longitude;
        loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            height: 5,
            width: MediaQuery.of(context).size.width * .6,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: location,
                    decoration: const InputDecoration(
                      label: Text("أكتب عنوان المتجر"),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (newLat == null && newLng == null && !loadingLocation)
                        ElevatedButton.icon(
                          autofocus: true,
                          label: Text(lat != null && lng != null
                              ? "تجديد موقع المتجر الجغرافي"
                              : "تحديد الموقع الجغرافي للمتجر"),
                          icon: const Icon(Icons.location_on),
                          onPressed: () => getLocation(),
                        ),
                      if (loadingLocation || loading)
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if ((lat != null && lng != null) ||
                          (newLat != null && newLng != null))
                        Icon(
                          Icons.map,
                          color: newLat != null ? Colors.blue : Colors.green,
                          size: 35,
                        ),
                      if (newLat != null && newLng != null)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .7,
                          child: Text(
                            "تم إختيار موقع جديد لحفظ الموقع إضغط حفظ التغيرات",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if(!loading && !loadingLocation)
                  ElevatedButton.icon(
                    onPressed: () => updateProfileData(),
                    icon: const Icon(Icons.save),
                    label: const Text("حفظ التغيرات"),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
