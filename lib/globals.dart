import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:convert';

class Dorm {
  const Dorm({ this.name, this.url, this.numWash, this.numDry, this.numInWash, this.numInDry });
  final String name, url, numWash, numDry, numInWash, numInDry;
}

class Machine {
  const Machine({ this.id, this.type, this.status, this.timeLeft });
  final String id, type, status, timeLeft;
}

final List<Dorm> kDorms = <Dorm>[];

final Map<String, WidgetBuilder> kRoutes = new Map<String, WidgetBuilder>();

class Page {
  Page({ this.label });

  final GlobalKey<ScrollableState<Scrollable>> key = new GlobalKey<ScrollableState<Scrollable>>();
  final String label;
}

bool isInt(String s) {
  if(s == null) {
    return false;
  }
  return int.parse(s, onError: (e) => null) != null;
}


var jsonObj = {};

//TODO make all these async?
void configPut(String key, var data) {
  initialize();
}

String configGet(String key) {
  initialize();
  return "";
}

bool _initializedFile = false;

void initialize() {
  if(_initializedFile==true) return;
  else {
    PathProvider.getApplicationDocumentsDirectory().then((Directory d) {
      File dataFile = new File(d.path+"/data.json");
      dataFile.exists().then((bool b) {
        if(b) {
          dataFile.readAsString().then((String data) {
            jsonObj = JSON.decode(data);
          });
        }
        else {
          dataFile.create().then((File f)=>f.writeAsString(JSON.encode(jsonObj)));
        }
      });
    });
  }
}
