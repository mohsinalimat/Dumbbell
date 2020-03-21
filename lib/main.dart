import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'package:workout_planner/ui/calender_page.dart';
import 'package:workout_planner/ui/components/routine_overview_card.dart';
import 'resource/db_provider.dart';
import 'resource/firebase_provider.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/recommend_page.dart';
import 'package:workout_planner/ui/routine_edit_page.dart';
import 'package:workout_planner/ui/scan_page.dart';
import 'package:workout_planner/ui/setting_page.dart';
import 'package:workout_planner/ui/statistics_page.dart';
import 'bloc/routines_bloc.dart';
import 'package:workout_planner/ui/components/custom_snack_bars.dart';
import 'resource/firebase_provider.dart';
import 'resource/shared_prefs_provider.dart';

import 'ui/main_page.dart';

//typedef void StringCallback(String val);
//const String FirstRunDateKey = "firstRunDate";
//const String AppVersionKey = "appVersion";
//const String DailyRankKey = "dailyRank";
//const String DatabaseStatusKey = "databaseStatus";
//const String WeeklyAmountKey = "weeklyAmount";
//
/////format: {"2019-01-01":50} (use UTC time)
//String firstRunDate;
//bool isFirstRun;
//String dailyRankInfo;
//int dailyRank;
//int weeklyAmount;
//
//GoogleSignIn _googleSignIn = GoogleSignIn(
//  scopes: <String>[
//    'email',
//  ],
//);
//
//GoogleSignInAccount currentUser;

void main() {
  runApp(App());
}

/// This widget is the root of our application.
/// Currently, we just show one widget in our app.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: 'Staa',
            primaryColor: Colors.orange,
            buttonColor: Colors.orange[300],
            toggleableActiveColor: Colors.orangeAccent,
            indicatorColor: Colors.orangeAccent,
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent)),
        debugShowCheckedModeBanner: false,
        title: 'Workout Planner',
        routes: {'/routine_edit_page': (context) => RoutineEditPage()},
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    routinesBloc.fetchAllRoutines();
    routinesBloc.fetchAllRecRoutines();

    firebaseProvider.signInSilently().then((_){
      print("Sign in silently end.");
    });

    sharedPrefsProvider.prepareData();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }

//  @override
//  Widget build(BuildContext context) {
//    var child =  DefaultTabController(
//        length: 2,
//        child: Scaffold(
//            key: scaffoldKey,
//            drawer: Drawer(
//              child: ListView(
//                padding: EdgeInsets.zero,
//                children: <Widget>[
//                  Container(
//                    height: 300,
//                    child: DrawerHeader(
//                      child: Column(
//                        children: <Widget>[
//                          currentUser == null
//                              ? Container()
//                              : ClipRRect(
//                                  borderRadius: BorderRadius.circular(30),
//                                  child: Image.network(
//                                    currentUser.photoUrl,
//                                    width: 60,
//                                    height: 60,
//                                  ),
//                                ),
//                          currentUser == null
//                              ? Container()
//                              : Padding(
//                                  padding: EdgeInsets.only(top: 8),
//                                  child: Text(
//                                    currentUser.displayName,
//                                    textAlign: TextAlign.center,
//                                    style: TextStyle(color: Colors.white),
//                                  ),
//                                ),
//                          Padding(
//                            padding: EdgeInsets.only(top: 8),
//                            child: Text(
//                              currentUser == null ? "Sign in to sync your data" : currentUser.email,
//                              textAlign: TextAlign.center,
//                              style: TextStyle(color: Colors.white),
//                            ),
//                          ),
//                          Padding(
//                            padding: EdgeInsets.only(top: 8),
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                currentUser == null
//                                    ? RaisedButton(
//                                        child: const Text('SIGN IN'),
//                                        onPressed: _handleSignIn,
//                                      )
//                                    : RaisedButton(
//                                        child: const Text('SIGN OUT'),
//                                        onPressed: _handleSignOut,
//                                      ),
//                              ],
//                            ),
//                          ),
//                          Flexible(
//                            child: Container(
//                              child: Padding(
//                                padding: EdgeInsets.only(top: 8),
//                                child: Center(
//                                  child: FutureBuilder(
//                                      future: FirestoreHelper().getDailyData(),
//                                      builder: (context, snapshot) {
//                                        if (snapshot.hasData) {
//                                          if (snapshot.data as int == -1) {
//                                            return Text(
//                                              'NO DATA',
//                                              textAlign: TextAlign.center,
//                                              style: TextStyle(color: Colors.white),
//                                            );
//                                          } else {
//                                            return dailyRank == 0
//                                                ? Text(
//                                                    "${snapshot.data} people have worked out out today",
//                                                    softWrap: true,
//                                                    textAlign: TextAlign.center,
//                                                    style: TextStyle(color: Colors.white, fontSize: 14),
//                                                  )
//                                                : Text(
//                                                    "${snapshot.data} people have worked out today\nYou are in the ${dailyRank.toString() + _getNumberSuffix(dailyRank)} place",
//                                                    softWrap: true,
//                                                    textAlign: TextAlign.center,
//                                                    style: TextStyle(color: Colors.white, fontSize: 14),
//                                                  );
//                                          }
//                                        } else {
//                                          return Text(
//                                            'NO DATA',
//                                            textAlign: TextAlign.center,
//                                            style: TextStyle(color: Colors.white),
//                                          );
//                                        }
//                                      }),
//                                ),
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//                      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//                    ),
//                  ),
//                  StreamBuilder(
//                    stream: routinesBloc.allRoutines,
//                    builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
//                      if (snapshot.hasData) {
//                        return ListTile(
//                          leading: Icon(
//                            Icons.calendar_today,
//                            color: Colors.black,
//                          ),
//                          title: Text('This Year'),
//                          onTap: () {
//                            Navigator.push(context, MaterialPageRoute(builder: (context) => CalenderPage(_getWorkoutDates(snapshot.data))));
//                          },
//                        );
//                      } else {
//                        return ListTile(
//                            leading: Icon(
//                              Icons.calendar_today,
//                              color: Colors.black,
//                            ),
//                            title: Text('This Year'),
//                            onTap: () {});
//                      }
//                    },
//                  ),
//                  StreamBuilder(
//                    stream: routinesBloc.allRoutines,
//                    builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
//                      if (snapshot.hasData) {
//                        return ListTile(
//                          leading: Icon(
//                            Icons.assessment,
//                            color: Colors.black,
//                          ),
//                          title: Text('Statistics'),
//                          onTap: () {
//                            Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) => StatisticsPage(
//                                          routines: snapshot.data,
//                                        )));
//                          },
//                        );
//                      } else {
//                        return ListTile(
//                            leading: Icon(
//                              Icons.assessment,
//                              color: Colors.black,
//                            ),
//                            title: Text('Statistics'),
//                            onTap: () {});
//                      }
//                    },
//                  ),
//                  ListTile(
//                    leading: Icon(
//                      Icons.favorite,
//                      color: Colors.red,
//                    ),
//                    title: Text("Dev's recommendations"),
//                    onTap: () {
//                      Navigator.push(context, MaterialPageRoute(builder: (context) => RecommendPage()));
//                    },
//                  ),
//                  ListTile(
//                    leading: Icon(
//                      Icons.settings,
//                      color: Colors.black,
//                    ),
//                    title: Text("Settings"),
//                    onTap: () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) => SettingPage(
//                                    currentUser: currentUser,
//                                    signInCallback: _handleSignIn,
//                                  )));
//                    },
//                  ),
//                  ListTile(
//                    leading: Icon(
//                      Icons.gradient,
//                      color: Colors.black,
//                    ),
//                    title: Text('About'),
//                    onTap: () {
//                      Navigator.pop(context);
//                      showAboutDialog(
//                          context: context,
//                          applicationName: 'Workout Planner',
//                          applicationVersion: '0.1 beta',
//                          applicationIcon: Image.asset(
//                            'assets/ic_launcher.png',
//                            scale: 2,
//                          ),
//                          children: <Widget>[
//                            Text('A simple app to plan out your workout routines, made by Jiaqi Feng, as a gift to those who sweat for a better self')
//                          ]);
//                    },
//                  ),
//                ],
//              ),
//            ),
//            appBar: AppBar(
//              actions: <Widget>[
//                Builder(
//                  builder: (context) => IconButton(
//                        icon: Transform.rotate(
//                          origin: Offset(0, 0),
//                          angle: pi / 2,
//                          child: Icon(Icons.flip),
//                        ),
//                        onPressed: () {
//                          Navigator.push(context, MaterialPageRoute(builder: (context) => ScanPage()));
//                        },
//                      ),
//                ),
//                Builder(
//                  builder: (context) => IconButton(
//                        icon: Icon(Icons.add),
//                        onPressed: () {
//                          var tempRoutine = Routine(mainTargetedBodyPart: null, routineName: null, parts: new List<Part>(), createdDate: null);
//                          routinesBloc.setCurrentRoutine(tempRoutine);
//                          Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => RoutineEditPage(
//                                        addOrEdit: AddOrEdit.Add,
//                                      )));
//                        },
//                      ),
//                ),
//              ],
//              bottom: TabBar(tabs: [
//                Tab(
//                  text: 'MY ROUTINES',
//                ),
//                Tab(
//                  text: 'TODAY',
//                )
//              ]),
//            ),
//            backgroundColor: Colors.white,
//            body: TabBarView(children: [
//              _buildCategories(),
//              StreamBuilder(
//                stream: routinesBloc.allRoutines,
//                builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
//                  if (snapshot.hasData) {
//                    return Container(
//                        child: ListView(
//                      children: snapshot.data
//                          .where((routine) => routine.weekdays.contains(DateTime.now().weekday))
//                          .map((routine) => RoutineOverview(
//                                routine: routine,
//                              ))
//                          .toList(),
//                    ));
//                  } else {
//                    return Container(
//                      alignment: Alignment.center,
//                      child: CircularProgressIndicator(),
//                    );
//                  }
//                },
//              )
//            ])));
//
//    return FutureBuilder(
//      future: SharedPreferences.getInstance(),
//      builder: (context, AsyncSnapshot<SharedPreferences> snapshot){
//        if(snapshot.hasData){
//          SharedPreferences prefs = snapshot.data;
//
//          pepareData(prefs);
//
//          return child;
//        }else{
//          return Container();
//        }
//      },
//    );
//  }

  Widget _buildCategories() {
    return StreamBuilder(
      stream: routinesBloc.allRoutines,
      builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
          return Center(
              child: RaisedButton(
            child: Text("Refresh"),
            onPressed: () => setState(() {
              DBProvider.db.initDB();
            }),
          ));
        }
        if (snapshot.hasData) {
          sharedPrefsProvider.setDatabaseStatus(true);
          //RoutinesContext.of(context).routines = snapshot.data;
          var routines = snapshot.data;
          var children = <Widget>[];
          children.addAll(routines.map((routine) => RoutineOverview(routine: routine)));
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: children,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: RaisedButton(
              onPressed: () {
                DBProvider.db.initDB().whenComplete(() {
                  routinesBloc.fetchAllRoutines();
                  routinesBloc.fetchAllRecRoutines();
                });
              },
              shape: StadiumBorder(),
              color: Colors.black,
              child: Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  String _getNumberSuffix(int num) {
    if (num > 3)
      return 'th';
    else if (num == 3)
      return 'rd';
    else if (num == 2)
      return 'nd';
    else
      return 'st';
  }

  Map<String, Routine> _getWorkoutDates(List<Routine> routines) {
    Map<String, Routine> dates = {};

    for (var routine in routines) {
      print("${routine.routineName} has a length of history: ${routine.routineHistory.length}");
      if (routine.routineHistory.isNotEmpty) {
        for (var date in routine.routineHistory) {
          dates[date] = routine;
        }
      }
    }
    return dates;
  }

  Future<void> _handleSignIn() async {
    try {
      await firebaseProvider.signInApple().whenComplete(() async {
        var db = Firestore.instance;
        var snapshot = await db.collection("users").document(firebaseProvider.appleIdCredential.user).get();

        if (snapshot.exists) {
          //TODO: restore user's data after a successful login
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                if (Platform.isAndroid) {
                  return AlertDialog(
                    title: const Text('Restore your data'),
                    content: const Text('Looks like you have your data on the cloud, do you want to restore them to this device?'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleRestore();
                        },
                      )
                    ],
                  );
                } else {
                  return CupertinoAlertDialog(
                    title: const Text('Restore your data?'),
                    content: const Text('Looks like you have your data on the cloud, do you want to restore them to this device?'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('No'),
                        textStyle: TextStyle(color: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Yes'),
                        textStyle: TextStyle(color: Colors.blue),
                        onPressed: () {
                          Navigator.pop(context);
                          _handleRestore();
                        },
                      )
                    ],
                  );
                }
              });
        }
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleRestore() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
      } else {
        var db = Firestore.instance;
        var snapshot = await db.collection("users").document(firebaseProvider.appleIdCredential.user).get();

        firebaseProvider.firstRunDate = snapshot.data["registerDate"];
        var routines = (json.decode(snapshot.data["routines"]) as List).map((map) => Routine.fromMap(map)).toList();
//          DBProvider.db.deleteAllRoutines();
//          DBProvider.db.addAllRoutines(RoutinesContext.of(context).routines);
        routinesBloc.restoreRoutines();
        _showSuccessSnackBar("RESTORED SUCCESSFULLY!");
      }
    });
  }

  void _showSuccessSnackBar(String msg) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          Text(
            msg,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));
  }
}
