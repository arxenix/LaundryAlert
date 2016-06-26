import 'package:flutter/material.dart';

import 'globals.dart';
import 'dormlist.dart';

import 'package:flutter/http.dart' as http;

final Map<String, String> _kMap = {
  "University of Illinois: Urbana-Champaign": "urba7723",
  "Xavier University": "xu9207",
  "Duke University": "du9458",
  "Rensselaer Polytechnic Institute": "rpi2012",
  "Iowa State University": "isulaundry",
  "Fordham University": "w155",
  "Arkansas State University": "redwolves",
  "Arkansas Tech University": "atu423",
  "American University": "eagles",
  "Auburn University at Montgomery": "aum367",
  "Georgetown University": "hoya",
  "Henderson State University": "hsu4100",
  "Howard Plaza Towers": "how3847",
  "Lander University": "bearcats",
  "Louisiana State University": "lsu3733",
  "Marymount University": "mu4944",
  "Methodist University": "monarchs",
  "Mississippi University for Women": "miss2421",
  "North Carolina State University": "wolfpack",
  "Shippensburg University": "ship2418",
  "Temple University": "owls",
  "University of Arkansas": "bollweevil",
  "University of Louisiana at Lafayette": "ull2512",
  "University of Central Oklahoma": "bronchos",
  "University of Delaware": "bluehens",
  "University of Virginia": "uva2571",
  "Valdosta State University": "vsu6168",
  "Washington College": "wash3388",
  "University of Pennsylvania": "penn6389",
  "University of California - LA": "ucla6023",
  "Rice University": "rice3927",
  "Juniata College": "julaundry",
  "Stanford University": "STAN9568"
};

class UniversityList extends StatefulWidget {
  UniversityList({ Key key }) : super(key: key) {
    //initialize dormlist routes
    _kMap.forEach((name, pass) => kRoutes['dormlist/$pass'] = (BuildContext context) => new DormList(code: pass, name: name));
  }

  @override
  _UniversityListState createState() => new _UniversityListState();
}

final List<Page> _pages = <Page>[
  new Page(label: 'Default'),
  new Page(label: 'Other')
];

class _UniversityListState extends State<UniversityList> {
  String _code;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Page _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage = _pages[0];
  }
  void _showInSnackBar(String value) {
   _scaffoldKey.currentState.showSnackBar(new SnackBar(
     content: new Text(value)
   ));
  }

  void _handleSubmitted() {
    print('submitted form');
    http.get("https://www.laundryalert.com/cgi-bin/${_code}/LMPage").then((response) {
      if(response.statusCode!=404) {
        if(!kRoutes.containsKey('dormlist/$_code')) {
          kRoutes['dormlist/$_code'] = (BuildContext context) => new DormList(code: _code, name: _code);
        }
        Navigator.pushNamed(context, 'dormlist/${_code}');
      }
      else {
        Focus.clear(context);
        _showInSnackBar("Error - Invalid school code! Please report this to the app authors if you believe it is an error.");
      }
    });
  }

  String _validatePassword(String value) {
    if (value.isEmpty)
      return 'Password is required.';
    return null;
  }

  Widget buildListItem(BuildContext context, String item) {
    return new ListItem(
      isThreeLine: false,
      dense: false,
      enabled: true,
      onTap: () {
        _code = _kMap[item];
        _handleSubmitted();
      },
      leading: new CircleAvatar(child: new Text(item.substring(0,1)), backgroundColor: Colors.deepPurple[500]),
      title: new Text(item)
    );
  }

  @override
  Widget build(BuildContext context) {

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return new TabBarSelection<Page>(
      values: _pages,
      child: new Scaffold(
        appBarBehavior: AppBarBehavior.under,
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('LaundryAlert - Select School'),
          bottom: new TabBar<Page>(
            labels: new Map<Page, TabLabel>.fromIterable(_pages, value: (Page page) {
              return new TabLabel(text: page.label);
            })
          )
        ),
        body: new TabBarView<Page>(
          children: _pages.map((Page page) {
            if(page.label=="Default") {
              var listItems = _kMap.keys.toList();
              listItems.sort();
              listItems = listItems.map((String uni) => buildListItem(context, uni));
              listItems = ListItem.divideItems(context: context, items: listItems);

              var contents = new MaterialList(
                type: MaterialListType.oneLineWithAvatar,
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                children: listItems
              );
              return new Block(
                padding: new EdgeInsets.only(top: kTextTabBarHeight + kToolBarHeight + statusBarHeight),
                scrollableKey: page.key,
                children: <Widget>[contents]
              );
            }
            else {
              return new Block(
                padding: new EdgeInsets.only(top: kTextTabBarHeight + kToolBarHeight + statusBarHeight),
                scrollableKey: page.key,
                children: <Widget>[
                  new Form(
                    onSubmitted: _handleSubmitted,
                    child: new Block(
                      padding: const EdgeInsets.all(8.0),
                      children: <Widget>[
                        new Center(
                          child: new Text(
                            "Enter the LaundryAlert login code for your university",
                            textAlign: TextAlign.center
                          )
                        ),
                        new Input(
                          hintText: 'The LaundryAlert password for your school',
                          labelText: 'Password',
                          formField: new FormField<String>(
                            setter: (String val) { _code = val; },
                            validator: _validatePassword
                          )
                        ),
                        new RaisedButton(
                          child: new Text('Go!'),
                          onPressed: _handleSubmitted
                        )
                      ]
                    )
                  )
                ]
              );
            }
          }).toList()
        )
      )
    );
  }
}
