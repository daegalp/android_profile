import 'dart:convert';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:profile_app_ui/constants.dart';
import 'package:profile_app_ui/widgets/profile_list_item.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: kDarkTheme,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.of(context),
            home: ProfileScreen(),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  Future<Profile> fetchProfiles() async {
    final response = await http.get('192.168.1.13/api/profiles');

    if (response.statusCode == 200) {
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: 896, width: 414, allowFontScaling: true);

    var profileInfo = FutureBuilder<Profile>(
      future: fetchProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: kSpacingUnit.w * 10,
                  width: kSpacingUnit.w * 10,
                  margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: kSpacingUnit.w * 5,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: kSpacingUnit.w * 2.5,
                          width: kSpacingUnit.w * 2.5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            heightFactor: kSpacingUnit.w * 1.5,
                            widthFactor: kSpacingUnit.w * 1.5,
                            child: Icon(
                              LineAwesomeIcons.pen,
                              color: kDarkPrimaryColor,
                              size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: kSpacingUnit.w * 2),
                Text(
                  snapshot.data.name,
                  style: kTitleTextStyle,
                ),
                SizedBox(height: kSpacingUnit.w * 0.5),
                Text(
                  'daegalprayoga141298@gmail.com',
                  style: kCaptionTextStyle,
                ),
                SizedBox(height: kSpacingUnit.w * 2),
                Container(
                  height: kSpacingUnit.w * 4,
                  width: kSpacingUnit.w * 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
                    color: Theme.of(context).accentColor,
                  ),
                  child: Center(
                    child: Text(
                      snapshot.data.nrp,
                      style: kButtonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          );
//          return Text(snapshot.data.nrp);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );

    var themeSwitcher = ThemeSwitcher(
      builder: (context) {
        return AnimatedCrossFade(
          duration: Duration(milliseconds: 200),
          crossFadeState:
          ThemeProvider.of(context).brightness == Brightness.dark
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: GestureDetector(
            onTap: () =>
                ThemeSwitcher.of(context).changeTheme(theme: kLightTheme),
            child: Icon(
              LineAwesomeIcons.sun,
              size: ScreenUtil().setSp(kSpacingUnit.w * 3),
            ),
          ),
          secondChild: GestureDetector(
            onTap: () =>
                ThemeSwitcher.of(context).changeTheme(theme: kDarkTheme),
            child: Icon(
              LineAwesomeIcons.moon,
              size: ScreenUtil().setSp(kSpacingUnit.w * 3),
            ),
          ),
        );
      },
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        Icon(
          LineAwesomeIcons.arrow_left,
          size: ScreenUtil().setSp(kSpacingUnit.w * 3),
        ),
        profileInfo,
        themeSwitcher,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                SizedBox(height: kSpacingUnit.w * 5),
                header,
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      ProfileListItem(
                        icon: LineAwesomeIcons.user_shield,
                        text: 'Privacy',
                      ),
                      ProfileListItem(
                        icon: LineAwesomeIcons.history,
                        text: 'Purchase History',
                      ),
                      ProfileListItem(
                        icon: LineAwesomeIcons.question_circle,
                        text: 'Help & Support',
                      ),
                      ProfileListItem(
                        icon: LineAwesomeIcons.cog,
                        text: 'Settings',
                      ),
                      ProfileListItem(
                        icon: LineAwesomeIcons.user_plus,
                        text: 'Invite a Friend',
                      ),
                      ProfileListItem(
                        icon: LineAwesomeIcons.alternate_sign_out,
                        text: 'Logout',
                        hasNavigation: false,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class Profile {
  final String nrp;
  final String name;

  Profile({this.nrp, this.name});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nrp: json['nrp'],
      name: json['name'],
    );
  }
}