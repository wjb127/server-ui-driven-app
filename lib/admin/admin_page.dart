import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Apps'),
            Tab(text: 'Styles'),
            Tab(text: 'Toolbars'),
            Tab(text: 'Menus'),
            Tab(text: 'FCM Topics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AppManagementTab(),
          StyleManagementTab(),
          ToolbarManagementTab(),
          MenuManagementTab(),
          FcmTopicManagementTab(),
        ],
      ),
    );
  }
}

class AppManagementTab extends StatefulWidget {
  @override
  _AppManagementTabState createState() => _AppManagementTabState();
}

class _AppManagementTabState extends State<AppManagementTab> {
  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApps();
  }

  Future<void> fetchApps() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.6:3000/api/apps'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          apps = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      print('앱 목록 로딩 오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createApp(Map<String, dynamic> appData) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.6:3000/api/app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appData),
      );
      if (response.statusCode == 201) {
        fetchApps();  // 목록 새로고침
      }
    } catch (e) {
      print('앱 생성 오류: $e');
    }
  }

  Future<void> updateApp(String id, Map<String, dynamic> appData) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.0.6:3000/api/app/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appData),
      );
      if (response.statusCode == 200) {
        fetchApps();  // 목록 새로고침
      }
    } catch (e) {
      print('앱 수정 오류: $e');
    }
  }

  Future<void> deleteApp(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.6:3000/api/app/$id'),
      );
      if (response.statusCode == 200) {
        fetchApps();  // 목록 새로고침
      }
    } catch (e) {
      print('앱 삭제 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(app['name'] ?? '이름 없음'),
              subtitle: Text(app['package_name'] ?? '패키지명 없음'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditDialog(app),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(app['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog() {
    // 앱 생성 다이얼로그 구현
    showDialog(
      context: context,
      builder: (context) => AppFormDialog(
        onSubmit: createApp,
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (context) => AppFormDialog(
        app: app,
        onSubmit: (data) => updateApp(app['id'].toString(), data),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱 삭제'),
        content: Text('정말로 이 앱을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              deleteApp(id.toString());
              Navigator.pop(context);
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class AppFormDialog extends StatefulWidget {
  final Map<String, dynamic>? app;
  final Function(Map<String, dynamic>) onSubmit;

  AppFormDialog({this.app, required this.onSubmit});

  @override
  _AppFormDialogState createState() => _AppFormDialogState();
}

class _AppFormDialogState extends State<AppFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _packageNameController;
  bool _adsEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.app?['name'] ?? '');
    _packageNameController = TextEditingController(text: widget.app?['package_name'] ?? '');
    _adsEnabled = widget.app?['ads_status']?['enabled'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.app == null ? '앱 생성' : '앱 수정'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '앱 이름'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '앱 이름을 입력하세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _packageNameController,
              decoration: InputDecoration(labelText: '패키지명'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '패키지명을 입력하세요';
                }
                return null;
              },
            ),
            CheckboxListTile(
              title: Text('광고 활성화'),
              value: _adsEnabled,
              onChanged: (value) {
                setState(() {
                  _adsEnabled = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSubmit({
                'name': _nameController.text,
                'package_name': _packageNameController.text,
                'ads_status': {'enabled': _adsEnabled},
              });
              Navigator.pop(context);
            }
          },
          child: Text('저장'),
        ),
      ],
    );
  }
}

// 임시 탭 위젯들 추가
class StyleManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Style Management - Coming Soon'));
  }
}

class ToolbarManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Toolbar Management - Coming Soon'));
  }
}

class MenuManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Menu Management - Coming Soon'));
  }
}

class FcmTopicManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('FCM Topic Management - Coming Soon'));
  }
} 