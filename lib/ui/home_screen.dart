import 'dart:async';

import 'package:bloc_rxdart/bloc/example_bloc.dart';
import 'package:bloc_rxdart/database/database_helper.dart';
import 'package:bloc_rxdart/model/eventMessageModel.dart';
import 'package:bloc_rxdart/model/exampleModel.dart';
import 'package:bloc_rxdart/utils/utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxbus/rxbus.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  bool isConnect;

  @override
  void initState() {
    _registerBus();
    initConnectivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Bloc and RXDart"),
      ),
      body: StreamBuilder(
        stream: blocExample.allExample,
        builder: (context, AsyncSnapshot<List<ExampleModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, position) {
                return Container(
                  margin:
                      EdgeInsets.only(top: 12, bottom: 4, left: 12, right: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        snapshot.data[position].name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        snapshot.data[position].manufacturer,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        snapshot.data[position].productCode,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: ListView.builder(
              itemBuilder: (_, __) => Container(
                height: 56,
                padding: EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              itemCount: 20,
            ),
          );
        },
      ),
    );
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        isConnect = true;
        blocExample.fetchAllExample(isConnect);
        break;
      case ConnectivityResult.mobile:
        isConnect = true;
        blocExample.fetchAllExample(isConnect);
        break;
      case ConnectivityResult.none:
        isConnect = false;
        blocExample.fetchAllExample(isConnect);
        break;
      default:
        isConnect = false;
        blocExample.fetchAllExample(isConnect);
        break;
    }
  }

  Future<void> _registerBus() async {
    RxBus.register<EventMessageModel>(tag: "EVENT_INTERNET_ERROR").listen(
      (event) => {
        Utils.dialogMessage(context, event.message),
      },
    );
  }
}
