import 'package:flutter/material.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:prava_vrecica/screens/main_screen.dart';
import 'package:provider/provider.dart';

class ModeStatus extends StatefulWidget {
  const ModeStatus({super.key});

  @override
  ModeStatusState createState() => ModeStatusState();
}

class ModeStatusState extends State<ModeStatus> {
  bool isAuth = false;
  late Future<bool> userStatus;

  @override
  void initState() {
    super.initState();
    userStatus = checkUserStatus();
  }

  Future<bool> checkUserStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int userId = userProvider.userId;
    return (userId != -1);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    return FutureBuilder(
        future: checkUserStatus(),
        builder: (context, snapshot){

          if(snapshot.hasData){
            if(snapshot.data == true){
              child = const MainScreen();
            } else {
              child = const AccountModeScreen();
            }
          } else{
            child = const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Scaffold(
            body: child,
          );
        }
    );
  }
}