import 'package:flutter/material.dart';
import 'package:flutter/http.dart' as http;
import 'package:html/parser.dart' as parselib;
import 'package:html/dom.dart' as domlib;

import 'globals.dart';
import 'dorm.dart';

class DormList extends StatefulWidget {
  DormList({ Key key, this.name, this.code}) : super(key: key);

  final String code, name;

  @override
  _DormListState createState() => new _DormListState();
}

class _DormListState extends State<DormList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Dorm> _dorms = new List<Dorm>();

  void showInSnackBar(String value) {
   _scaffoldKey.currentState.showSnackBar(new SnackBar(
     content: new Text(value),
     duration: new Duration(seconds:10)
   ));
  }

  @override
  void initState() {
    super.initState();

    print("Init dormliststate");
    if(_dorms.length==0) {
      http.get("https://www.laundryalert.com/cgi-bin/${config.code}/LMPage").then((response) {
        domlib.Document doc = parselib.parse(response.body);
        //print(doc.outerHtml);
        var rows = doc.getElementsByTagName('tbody')[2].getElementsByTagName('tr');

        int i = 1;
        var firstRow = rows[0];
        var firstRowCols = firstRow.getElementsByTagName('td');
        if(firstRowCols.length == 2) {
          var announcement = firstRowCols[1].innerHtml;
          //print("Announcement: $announcement");
          i++;
          showInSnackBar("Announcement: $announcement");
        }


        for(; i<rows.length-1 ; i++) {
          var row = rows[i];
          var cols = row.getElementsByTagName('td');

          String name = cols[1].getElementsByTagName('font')[0].innerHtml.trim();
          String url = "https://www.laundryalert.com/cgi-bin/${config.code}/"+cols[1].attributes["onclick"].split("href=")[1].replaceAll("'","");
          String numWash = cols[2].getElementsByTagName('font')[0].innerHtml.trim();
          String numDry = cols[3].getElementsByTagName('font')[0].innerHtml.trim();
          String numInWash = cols[5].getElementsByTagName('font')[0].innerHtml.trim();
          String numInDry = cols[7].getElementsByTagName('font')[0].innerHtml.trim();

          var newDorm = new Dorm(name: name,
            url: url,
            numWash: numWash,
            numDry: numDry,
            numInWash: numInWash,
            numInDry: numInDry);

          kRoutes['dormlist/${config.code}/dorm/${name}'] = (BuildContext context) => new SingleDormView(dorm: newDorm);

          setState(() => _dorms.add(newDorm));
        }
      });
    }
  }

  Widget buildListItem(BuildContext context, Dorm dorm) {

    var washStr = "?";
    if(isInt(dorm.numWash) && isInt(dorm.numInWash)) {
      var avail = int.parse(dorm.numWash);
      var tot = avail+int.parse(dorm.numInWash);
      washStr = "$avail/$tot available";
    }
    var dryStr = "?";
    if(isInt(dorm.numDry) && isInt(dorm.numInDry)) {
      var avail = int.parse(dorm.numDry);
      var tot = avail+int.parse(dorm.numInDry);
      dryStr = "$avail/$tot available";
    }

    return new ListItem(
      isThreeLine: true,
      dense: false,
      enabled: true,
      onTap: () {
        Navigator.pushNamed(context, "dormlist/${config.code}/dorm/${dorm.name}");
      },
      leading: new CircleAvatar(child: new Text("${dorm.name.substring(0,1)}")),
      title: new Text(dorm.name),
      subtitle: new Text('Washing Machines: $washStr\nDryers: $dryStr')
    );
  }

  @override
  Widget build(BuildContext context) {
    var content = new Center(child: new CircularProgressIndicator());
    if(_dorms.length>0) {
      Iterable<Widget> listItems = _dorms.map((Dorm dorm) => buildListItem(context, dorm));
      listItems = ListItem.divideItems(context: context, items: listItems);

      content = new Scrollbar(
        child: new MaterialList(
          type: MaterialListType.threeLine,
          padding: new EdgeInsets.symmetric(vertical: 8.0),
          children: listItems
        )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(config.name)
      ),
      key: _scaffoldKey,
      body: content
    );
  }
}
