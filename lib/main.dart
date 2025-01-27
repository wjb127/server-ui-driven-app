import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Center(child: Text('오류가 발생했습니다. 앱을 다시 시작해주세요.'));
    };
    runApp(const MyApp());
  }, (error, stack) {
    print('앱 오류 발생: $error');
    print('스택 트레이스: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
      builder: (context, child) {
        return child ?? Container();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = '';
  String packageName = '';
  bool adsEnabled = false;
  String activeStatus = '';
  String id = '';
  String appStyleId = '';
  String appToolbarId = '';
  String appStyleMenu = '';
  String toolbarColor = '';
  String buttonColor = '';
  String indicatorColor = '';
  String buttonTextColor = '';
  String toolbarMenu = '';
  String toolbarTitle = '';
  String toolbarSubtitle = '';
  bool hasHome = false;
  bool hasProfile = false;
  bool hasSettings = false;
  bool isHomeEnabled = false;
  bool isProfileEnabled = false;
  bool isSettingsEnabled = false;
  Map<String, String> toolbarItems = {};
  String toolbarStatus = '';
  String menuId = '';
  String menuTitle = '';
  String menuDescription = '';
  int menuPosition = 0;
  String menuCategory = '';
  String menuKeyword = '';
  String menuUiType = '';
  String menuActiveStatus = '';
  String fcmTopicId = '';
  String fcmTopicTitle = '';
  String fcmTopic = '';
  String fcmTopicType = '';
  Map<String, String> fcmTopicTranslations = {};
  int fcmTopicPosition = 0;

  @override
  void initState() {
    super.initState();
    fetchAppData();
  }

  Future<void> fetchStyleData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/style/${appStyleId}'));
      print('스타일 API 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> currentStyle = jsonDecode(response.body);
        print('받아온 스타일 데이터: $currentStyle');
        
        setState(() {
          appStyleMenu = currentStyle['app_style_menu'] ?? '';
          toolbarColor = currentStyle['toolbar_color'] ?? '#FFFFFF';
          indicatorColor = currentStyle['indicator_color'] ?? '#000000';
          buttonColor = currentStyle['button_color'] ?? '#007BFF';
          buttonTextColor = currentStyle['button_text_color'] ?? '#FFFFFF';
        });
      }
    } catch (e) {
      print('스타일 데이터 로딩 오류: $e');
    }
  }

  Future<void> fetchToolbarData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/toolbar/${appToolbarId}'));
      print('툴바 API 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> toolbarData = jsonDecode(response.body);
        print('받아온 툴바 데이터: $toolbarData');
        
        setState(() {
          toolbarItems = Map<String, String>.from(toolbarData['toolbar_items'] ?? {});
          toolbarStatus = toolbarData['active_status'] ?? '';
        });
      }
    } catch (e) {
      print('툴바 데이터 로딩 오류: $e');
    }
  }

  Future<void> fetchMenuData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/menu/app/${id}'));
      print('메뉴 API 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        // 배열 형태의 응답을 처리
        List<dynamic> menuList = jsonDecode(response.body);
        if (menuList.isNotEmpty) {
          // 첫 번째 메뉴 항목 사용
          Map<String, dynamic> menuData = menuList[0];
          print('받아온 메뉴 데이터: $menuData');
          
          setState(() {
            menuId = menuData['id'] ?? '';
            menuTitle = menuData['title'] ?? '';
            menuDescription = menuData['description'] ?? '';
            menuPosition = menuData['position'] ?? 0;
            menuCategory = menuData['category'] ?? '';
            menuKeyword = menuData['keyword'] ?? '';
            menuUiType = menuData['ui_type'] ?? '';
            menuActiveStatus = menuData['active_status'] ?? '';
          });
        }
      }
    } catch (e) {
      print('메뉴 데이터 로딩 오류: $e');
    }
  }

  Future<void> fetchFcmTopicData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/fcm_topic/app/3'));
      print('FCM 토픽 API 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> topicList = jsonDecode(response.body);
        if (topicList.isNotEmpty) {
          Map<String, dynamic> topicData = topicList[0];
          print('받아온 FCM 토픽 데이터: $topicData');
          
          setState(() {
            fcmTopicId = topicData['id'] ?? '';
            fcmTopicTitle = topicData['title'] ?? '';
            fcmTopic = topicData['fcm_topic'] ?? '';
            fcmTopicType = topicData['type'] ?? '';
            fcmTopicPosition = topicData['position'] ?? 0;
            
            // translation_title_json 처리
            if (topicData['translation_title_json'] != null) {
              fcmTopicTranslations = Map<String, String>.from(topicData['translation_title_json']);
            } else {
              fcmTopicTranslations = {};
            }
          });
        }
      }
    } catch (e) {
      print('FCM 토픽 데이터 로딩 오류: $e');
    }
  }

  Future<void> fetchAppData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/app/3'));
      print('앱 데이터 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          id = data['id'] ?? '';
          name = data['name'] ?? '로딩 실패';
          packageName = data['package_name'] ?? '';
          adsEnabled = data['ads_status']['enabled'] ?? false;
          activeStatus = data['active_status'] ?? '';
          appStyleId = data['app_style_id'] ?? '';
          appToolbarId = data['app_toolbar_id'] ?? '';
        });
        
        if (id.isNotEmpty) {
          await fetchStyleData();
          await fetchToolbarData();
          await fetchMenuData();
          await fetchFcmTopicData();
        }
      }
    } catch (e) {
      print('앱 데이터 로딩 오류: $e');
      setState(() {
        name = '오류 발생';
      });
    }
  }

  Color? hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      print('변환할 색상 문자열: $hexString');
      print('변환된 색상 문자열: ${buffer.toString()}');
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      print('색상 변환 오류: $e');
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: hexToColor(toolbarColor) ?? Colors.blue,
      ),
      body: name.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('기본 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Text('앱 ID: $id', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('앱 이름: $name', 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('패키지명: $packageName', 
                              style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('상태 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Row(
                              children: [
                                Icon(adsEnabled ? Icons.check_circle : Icons.cancel,
                                    color: adsEnabled ? Colors.green : Colors.red),
                                SizedBox(width: 8),
                                Text('광고 상태: ${adsEnabled ? "활성화" : "비활성화"}', 
                                  style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('활성화 상태: $activeStatus', 
                              style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('스타일 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Text('앱 스타일 ID: $appStyleId', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('앱 툴바 ID: $appToolbarId', 
                              style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('스타일 상세 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Text('스타일 메뉴: $appStyleMenu', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text('툴바 색상: ', style: TextStyle(fontSize: 16)),
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: hexToColor(toolbarColor) ?? Colors.grey,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(toolbarColor),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text('버튼 색상: ', style: TextStyle(fontSize: 16)),
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: hexToColor(buttonColor) ?? Colors.grey,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(buttonColor),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text('인디케이터 색상: ', style: TextStyle(fontSize: 16)),
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: hexToColor(indicatorColor) ?? Colors.grey,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(indicatorColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('툴바 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Text('툴바 메뉴: $toolbarMenu', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('툴바 제목: $toolbarTitle', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('툴바 부제목: $toolbarSubtitle', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('툴바 상태: $toolbarStatus', 
                              style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('툴바 설정', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.home),
                              title: Text('홈'),
                              subtitle: Text(toolbarItems.containsKey('home') ? toolbarItems['home']! : '없음'),
                              trailing: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: toolbarItems.containsKey('home') ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  toolbarItems.containsKey('home') ? '활성화' : '비활성화',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('설정'),
                              subtitle: Text(toolbarItems.containsKey('settings') ? toolbarItems['settings']! : '없음'),
                              trailing: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: toolbarItems.containsKey('settings') ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  toolbarItems.containsKey('settings') ? '활성화' : '비활성화',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('툴바 상태: $toolbarStatus', 
                              style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('메뉴 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Text('메뉴 ID: $menuId', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('메뉴 제목: $menuTitle', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('메뉴 설명: $menuDescription', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('메뉴 위치: $menuPosition', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('카테고리: $menuCategory', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('키워드: $menuKeyword', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('UI 타입: $menuUiType', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('활성화 상태: $menuActiveStatus', 
                              style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FCM 토픽 정보', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Divider(),
                            Text('토픽 ID: $fcmTopicId', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('제목: $fcmTopicTitle', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('FCM 토픽: $fcmTopic', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('토픽 타입: $fcmTopicType', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('위치: $fcmTopicPosition', 
                              style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('번역:', 
                              style: TextStyle(fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: fcmTopicTranslations.entries.map((entry) => 
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text('${entry.key}: ${entry.value}',
                                      style: TextStyle(fontSize: 16)),
                                  )
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
