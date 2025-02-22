import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/reservation_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/sign_in.dart';
import 'package:frontend/loading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/myPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification.dart';
import 'return.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'select_reserve.dart';
import 'congestion.dart';
import 'select_reserve_cf.dart';
import 'notice.dart';
import 'sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 사용자 탭 감지 키보드 내려감
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
      },
      child: MaterialApp(
        title: 'keyboard unfocus',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _permissionWithNotification();
  }

  void _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == 'true') {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      });
    } else if (token == 'false') {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      });
    } else {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/app_logo.svg',
            width: 100,
            height: 90,
          ),
        ],
      )),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final ExpansionTileController controller = ExpansionTileController();
  bool is_tap = false;
  bool isLoading = false; // 추가: 로딩 상태를 나타내는 변수
  String time = '';
  String people = '';
  String roomName = '';
  String roomImage = '';
  String designImage = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initNotification(context);
    _checkRoomStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 실행될 로직
      _checkRoomStatus();
    }
  }

  _checkRoomStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    setState(() {
      isLoading = true; // 로딩 시작
    });

    final url = 'http://3.35.96.145:3000/reserveclub/main_lentroom/:uid';

    final Map<String, String> data = {
      'uid': uid ?? '',
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'successfully get lentroom') {
        setState(() {
          spaceData = responseData['share_room_data'];
          isLoading = false; // 로딩 끝
        });
      } else {
        setState(() {
          isLoading = false; // 로딩 끝
          String errorMessage = 'Failed to get room data';
        });
      }
    } else {
      setState(() {
        isLoading = false; // 로딩 끝
        String errorMessage = 'Failed to get room data';
      });
    }
  }

  _checkRoom2Status() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    setState(() {
      isLoading = true; // 로딩 시작
    });
    const url = 'http://3.35.96.145:3000/reserveclub/main_conference_room/:uid';

    final Map<String, String> data = {
      'uid': uid ?? '',
    };

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'successfully get lentroom') {
        setState(() {
          spaceData2 = responseData['share_room_data'];
          isLoading = false; // 로딩 끝
        });
      } else {
        setState(() {
          isLoading = false; // 로딩 끝
          String errorMessage = 'Failed to get room data';
        });
      }
    } else {
      setState(() {
        isLoading = false; // 로딩 끝
        String errorMessage = 'Failed to get room data';
      });
    }
  }

  List<dynamic> spaceData = [];
  List<dynamic> spaceData2 = [];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '공간대여',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Container(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyNotice()),
                );
              },
              icon: SvgPicture.asset('assets/icons/notice_none.svg'),
            ),
          ],
          backgroundColor: Colors.transparent, // 상단바 배경색
          foregroundColor: Colors.black, //상단바 아이콘색
          bottomOpacity: 0.0,
          elevation: 0.0,
          scrolledUnderElevation: 0,
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          is_tap = !is_tap;

                          _checkRoomStatus();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: 15, // Set the button text size
                          fontWeight:
                              FontWeight.bold, // Set the button text weight
                          color: Color(0XFF004F9E),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                              width: 0.50,
                              color: is_tap
                                  ? Color(0xFFD6D6D6)
                                  : const Color(0xFF004F9E)),
                        ),
                        minimumSize:
                            Size(193.7, 50), // Set the button minimum size
                        backgroundColor:
                            is_tap ? Colors.white : Color(0X0C004F9E),

                        elevation: 0, // Set the elevation for the button shadow
                        shadowColor: Colors.white.withOpacity(
                            0.5), // Set the color of the button shadow
                      ),
                      child: Text('공유공간 대여',
                          style: TextStyle(
                              color: is_tap
                                  ? Color(0XFF7C7C7C)
                                  : Color(0xFF004F9E))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          is_tap = !is_tap;
                          _checkRoom2Status();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: 15, // Set the button text size
                          fontWeight:
                              FontWeight.bold, // Set the button text weight
                          color: Color(0XFF004F9E),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                              width: 0.50,
                              color: is_tap
                                  ? const Color(0xFF004F9E)
                                  : Color(0xFFD6D6D6)),
                        ),
                        minimumSize:
                            Size(193.7, 50), // Set the button minimum size
                        backgroundColor:
                            is_tap ? Color(0X0C004F9E) : Colors.white,

                        elevation: 0, // Set the elevation for the button shadow
                        shadowColor: Colors.white.withOpacity(
                            0.5), // Set the color of the button shadow
                      ),
                      child: Text('강의실 대여',
                          style: TextStyle(
                              color: is_tap
                                  ? Color(0xFF004F9E)
                                  : Color(0XFF7C7C7C))),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: is_tap
                      ? (spaceData2.isEmpty ? 0 : spaceData2.length)
                      : (spaceData.isEmpty ? 0 : spaceData.length),
                  itemBuilder: (context, index) {
                    final data = is_tap
                        ? (spaceData2.isNotEmpty ? spaceData2[index] : null)
                        : (spaceData.isNotEmpty ? spaceData[index] : null);

                    List<dynamic> tableList = [];
                    if (data != null && data['tableList'] is String) {
                      try {
                        tableList = json.decode(data['tableList']);
                      } catch (e) {
                        print('Error decoding tableList: $e');
                      }
                    } else if (data != null && data['tableList'] is List) {
                      tableList = data['tableList'];
                    }

                    return Column(
                      children: [
                        SizedBox(height: 10), // Add spacing here

                        data != null
                            ? _CustomScrollViewWidget(
                                time: data['time']!,
                                people: data['people']!,
                                roomName: data['roomName']!,
                                roomImage: data['clubRoomImage'] ??
                                    data['conferenceImage'],
                                designImage: data['clubRoomDesignImage'] ?? '',
                                tableList: tableList,
                                istap: is_tap,
                              )
                            : Container(), // Return empty container if data is null
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // 하단 바
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,

          currentIndex: 0, // Adjust the index according to your need
          onTap: (index) {
            switch (index) {
              case 0:
                break;

              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Congestion()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Details()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPage()),
                );
                break;
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/lent.svg'),
              label: '공간대여',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/congestion_off.svg'),
              label: '혼잡도',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/reserved.svg'),
              label: '예약내역',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/mypage.svg'),
              label: '마이페이지',
            ),
          ],
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          selectedItemColor: Colors.black,
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          unselectedItemColor: Colors.grey,
        ),
      );
    }
  }
}

class _CustomScrollViewWidget extends StatelessWidget {
  final String time;
  final String people;
  final String roomName;
  final String roomImage;
  final String designImage;
  final List<dynamic> tableList;
  final bool istap;

  const _CustomScrollViewWidget({
    Key? key,
    required this.time,
    required this.people,
    required this.roomName,
    required this.roomImage,
    required this.designImage,
    required this.tableList,
    required this.istap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.50, color: Color(0xFFE3E3E3)),
          borderRadius: BorderRadius.circular(4),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Image.memory(
                  base64Decode(roomImage),
                  width: 340.63,
                  height: 164.03,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 100.15,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: TextButton(
                    onPressed: null,
                    child: Text(
                      roomName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 105,
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/group-fill.svg',
                        width: 14,
                        height: 14,
                      ),
                      SizedBox(width: 2), // Add spacing here
                      Text(
                        people,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2), // Add spacing here
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    // 맵 버튼 눌렀을 때 이동할 화면
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/time-fill.svg',
                        width: 14,
                        height: 14,
                      ),
                      SizedBox(width: 2), // Add spacing here
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => istap
                        ? Select_reserve_cf(
                            roomName: roomName,
                          )
                        : Select_reserve(
                            roomName: roomName,
                            time: time,
                            designImage: designImage,
                            tableList: tableList,
                          )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(340.75, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              elevation: 0, // Remove button shadow
            ),
            child: Text(
              '예약하기',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
