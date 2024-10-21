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
      TransaksiPage(),
    ];

    final List<BottomNavigationBarItem> itemsAdmin = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Buku'),
      BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Kategori'),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: 'User'),
      BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transaksi'),
    ];

    final List<Widget> pagesMember = [
      TampilanHomePage(),
      BookMemberPage(namaMember: widget.namaMember, memberId: widget.memberId),
      TransaksiMemberPage(token: widget.token, memberId: widget.memberId),
    ];

    final List<BottomNavigationBarItem> itemsMember = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Buku'),
      BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transaksi'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: isAdmin ? pagesAdmin : pagesMember,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: isAdmin ? itemsAdmin : itemsMember,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    PeminjamanPage(),
    PersetujuanPage(),
    PengembalianPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Peminjaman'),
          BottomNavigationBarItem(
              icon: Icon(Icons.approval), label: 'Persetujuan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_return), label: 'Pengembalian'),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class TransaksiMemberPage extends StatefulWidget {
  final String token;
  final int memberId;

  TransaksiMemberPage({required this.token, required this.memberId});

  @override
  _TransaksiMemberPageState createState() => _TransaksiMemberPageState();
}

class _TransaksiMemberPageState extends State<TransaksiMemberPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PeminjamanMemberPage(token: widget.token, memberId: widget.memberId),
          PengembalianMemberPage(
              token: widget.token, memberId: widget.memberId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Peminjaman'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_return), label: 'Pengembalian'),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
