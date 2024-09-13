import 'package:belajar_flutter_perpus/view/auth/home_page.dart';
import 'package:belajar_flutter_perpus/view/home/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_flutter_perpus/view/book/book.dart';
import 'package:belajar_flutter_perpus/view/book/book_member.dart';
import 'package:belajar_flutter_perpus/view/categories/categories.dart';
import 'package:belajar_flutter_perpus/view/member/member.dart';
import 'package:belajar_flutter_perpus/view/peminjaman/peminjaman.dart';
import 'package:belajar_flutter_perpus/view/peminjaman/peminjaman_member.dart';
import 'package:belajar_flutter_perpus/view/pengembalian/pengembalian.dart';
import 'package:belajar_flutter_perpus/view/pengembalian/pengembalian_member.dart';
import 'package:belajar_flutter_perpus/view/persetujuan/persetujuan.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final int memberId;
  final String token;
  final String namaMember;

  DashboardPage({
    required this.memberId,
    required this.user,
    required this.token,
    required this.namaMember,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _saveToken(widget.token);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.of(context).pop();
  }

  bool get isAdmin =>
      widget.user['roles'].any((role) => role['name'] == 'admin');
  bool get isMember =>
      widget.user['roles'].any((role) => role['name'] == 'member');

  @override
  Widget build(BuildContext context) {
    final List<Widget> pagesAdmin = [
      TampilanHomePage(),
      BookPage(),
      CategoriesPage(),
      MemberListPage(),
      PeminjamanPage(),
      PersetujuanPage(),
      PengembalianPage(),
    ];

    final List<String> titlesAdmin = [
      'Dashboard',
      'Daftar Buku',
      'Kategori Buku',
      'User',
      'Peminjaman',
      'Persetujuan',
      'Pengembalian',
    ];

    final List<Widget> pagesMember = [
      TampilanHomePage(),
      BookMemberPage(namaMember: widget.namaMember, memberId: widget.memberId),
      PeminjamanMemberPage(token: widget.token, memberId: widget.memberId),
      PengembalianMemberPage(token: widget.token, memberId: widget.memberId),
    ];

    final List<String> titlesMember = [
      'Dashboard',
      'Daftar Buku',
      'Peminjaman',
      'Pengembalian',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perpustakaan',
          style: TextStyle(
            color: Colors.deepOrange,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.orange),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.orange),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'email',
                  child: Row(
                    children: [
                      Icon(Icons.email, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Email: ${widget.user['email']}'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'roles',
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                          'Roles: ${widget.user['roles'].map((role) => role['name']).join(', ')}'),
                    ],
                  ),
                ),
                PopupMenuDivider(), // Divider untuk pemisah
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: isAdmin ? pagesAdmin : pagesMember,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.user['name']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${widget.user['email']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Roles: ${widget.user['roles'].map((role) => role['name']).join(', ')}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin) ...[
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.orange),
                      title: Text('Dashboard'),
                      onTap: () {
                        _onDrawerItemTapped(0);
                      },
                    ),
                    SizedBox(height: 5),
                    _buildDrawerSection('Buku', [
                      ListTile(
                        leading: Icon(Icons.book, color: Colors.orange),
                        title: Text('Daftar Buku'),
                        onTap: () {
                          _onDrawerItemTapped(1);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.category, color: Colors.orange),
                        title: Text('Kategori Buku'),
                        onTap: () {
                          _onDrawerItemTapped(2);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.people, color: Colors.orange),
                        title: Text('User'),
                        onTap: () {
                          _onDrawerItemTapped(3);
                        },
                      ),
                    ]),
                    SizedBox(height: 5),
                    _buildDrawerSection('Transaksi', [
                      ListTile(
                        leading:
                            Icon(Icons.library_books, color: Colors.orange),
                        title: Text('Peminjaman'),
                        onTap: () {
                          _onDrawerItemTapped(4);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.approval, color: Colors.orange),
                        title: Text('Persetujuan'),
                        onTap: () {
                          _onDrawerItemTapped(5);
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.assignment_return, color: Colors.orange),
                        title: Text('Pengembalian'),
                        onTap: () {
                          _onDrawerItemTapped(6);
                        },
                      ),
                    ]),
                  ],
                  if (isMember) ...[
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.orange),
                      title: Text('Dashboard'),
                      onTap: () {
                        _onDrawerItemTapped(0);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.book, color: Colors.orange),
                      title: Text('Daftar Buku'),
                      onTap: () {
                        _onDrawerItemTapped(1);
                      },
                    ),
                    SizedBox(height: 5),
                    _buildDrawerSection('Transaksi', [
                      ListTile(
                        leading:
                            Icon(Icons.library_books, color: Colors.orange),
                        title: Text('Peminjaman'),
                        onTap: () {
                          _onDrawerItemTapped(2);
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.assignment_return, color: Colors.orange),
                        title: Text('Pengembalian'),
                        onTap: () {
                          _onDrawerItemTapped(3);
                        },
                      ),
                    ]),
                  ],
                  SizedBox(height: 10),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.2, color: Colors.grey[350]),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: Divider(
            color: Colors.grey[350],
            height: 0.5,
            thickness: 0.5,
          ),
        ),
        ...items,
      ],
    );
  }
}
