import 'package:flutter/material.dart';
import 'package:flutter/http.dart' as http;
import 'package:html/parser.dart' as parselib;
import 'package:html/dom.dart' as domlib;

import 'globals.dart';

class SingleDormView extends StatefulWidget {
  SingleDormView({Key key, this.dorm}) : super(key: key);
  final Dorm dorm;
  @override
  _SingleDormViewState createState() => new _SingleDormViewState();
}

class _SingleDormViewState extends State<SingleDormView> {
  List<Machine> _machineList = new List<Machine>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
   _scaffoldKey.currentState.showSnackBar(new SnackBar(
     content: new Text(value),
     duration: new Duration(seconds:10)
   ));
  }

  @override
  void initState() {
    super.initState();
    print("Init singledormviewstate");
    http.get(config.dorm.url).then((response) {
      domlib.Document doc = parselib.parse(response.body);
      var tbodys = doc.getElementsByTagName('tbody');
      var availability = tbodys[1];
      var availRows = availability.getElementsByTagName('tr');
      var availElements = availRows[2].getElementsByTagName('font');

      var washerStr = availElements[2].innerHtml.trim();
      var dryerStr = availElements[4].innerHtml.trim();
      var waitingStr = availElements[5].innerHtml.trim();

      print(washerStr);
      print(dryerStr);
      print(waitingStr);

      var rows = tbodys[tbodys.length-1].getElementsByTagName('tr');
      int i=1;
      var firstRow = rows[0];
      var firstRowCols = firstRow.getElementsByTagName('td');
      if(firstRowCols.length==3) {
        var announcement = firstRowCols[2].children[0].innerHtml;
        //print("Announcement: $announcement");
        i++;
        showInSnackBar("Announcement: $announcement");
      }

      for(;i<rows.length-2;i++) {
        var cols = rows[i].getElementsByTagName('td');

        var id = cols[2].getElementsByTagName('font')[1].innerHtml.trim();
        var type = cols[3].getElementsByTagName('font')[1].innerHtml.trim();
        var status = cols[4].getElementsByTagName('font')[1].innerHtml.trim();
        var timeLeft = cols[5].getElementsByTagName('font');
        if(timeLeft.length!=0)
          timeLeft = timeLeft[0].innerHtml.trim();
        else timeLeft = "";

        setState(() => _machineList.add(new Machine(id: id, type: type, status: status, timeLeft: timeLeft)));
      }
    });
  }

  Widget buildListItem(BuildContext context, Machine item) {
    Color c = Colors.black;
    if(item.type.toLowerCase().contains("wash")) {
      if(item.status=="Available")
        c = Colors.blue[500];
      else c = Colors.blue[100];
    }
    else if(item.type.toLowerCase().contains("dry")) {
      if(item.status=="Available")
        c = Colors.red[500];
      else c = Colors.red[100];
    }

    var trailing = null;
    if(item.timeLeft!=null && item.timeLeft.length!=0) {
      trailing = new IconButton(
        icon: new Icon(Icons.alarm_add),
        color: Colors.green[500],
        tooltip: "Set an alarm for this machine",
        onPressed: () {
          print("Pressed icon button!");
        }
      );
    }

    return new ListItem(
      isThreeLine: true,
      dense: false,
      leading: new CircleAvatar(child: new Text("${item.id}"), backgroundColor: c),
      title: new Text(item.type),
      subtitle: new Text('${item.status}\n${item.timeLeft}'),
      trailing: trailing
    );
  }

  @override
  Widget build(BuildContext context) {

    var content = new Center(child: new CircularProgressIndicator());
    if(_machineList.length>0) {
      Iterable<Widget> listItems = _machineList.map((Machine machine) => buildListItem(context, machine));
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
        title: new Text(config.dorm.name)
      ),
      key: _scaffoldKey,
      body: content
    );
  }
}
