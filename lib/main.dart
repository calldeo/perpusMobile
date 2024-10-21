import 'package:belajar_flutter_perpus/view/book/form_peminjaman_member.dart';
import 'package:flutter/material.dart';
import 'package:belajar_flutter_perpus/view/book/list_member_book.dart';
import 'package:belajar_flutter_perpus/view/bar/dashboard.dart';
import 'package:belajar_flutter_perpus/view/auth/login.dart';
import 'package:belajar_flutter_perpus/view/auth/sign_up.dart';
import 'package:belajar_flutter_perpus/view/auth/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null ||
                !args.containsKey('user') ||
                !args.containsKey('token')) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text('Error')),
                  body: Center(child: Text('Argumen yang diberikan tidak valid.')),
                ),
              );
            }

            final user = args['user'];
            final token = args['token'];
            final namaMember = user['name'] ?? '';
            final memberId = user['id'] ?? 0;

            return MaterialPageRoute(
              builder: (context) => DashboardPage(
                token: token,
                user: user,
                namaMember: namaMember,
                memberId: memberId,
              ),
            );

          case '/login':
            return MaterialPageRoute(
              builder: (context) => LoginPage(),
            );
          case '/form_member_peminjaman':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null ||
                !args.containsKey('token') ||
                !args.containsKey('bukuId') ||
                !args.containsKey('namaMember') ||
                !args.containsKey('memberId')) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text('Error')),
                  body: Center(
                      child: Text(
                          'Argumen tidak valid untuk FormMemberPeminjamanPage.')),
                ),
              );
            }

            final token = args['token'] as String;
            final bukuId = args['bukuId'] as String;
            final namaMember = args['namaMember'] as String;
            final memberId = args['memberId'] as int;

            return MaterialPageRoute(
              builder: (context) => FormPeminjamanMember(
                bukuId: bukuId,
                namaMember: namaMember,
                memberId: memberId,
              ),
            );
          case '/list_member_book':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null ||
                !args.containsKey('namaMember') ||
                !args.containsKey('memberId')) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text('Error')),
                  body: Center(
                      child: Text('Argumen tidak valid untuk ListMemberBookPage.')),
                ),
              );
            }

            final namaMember = args['namaMember'] as String;
            final memberId = args['memberId'] as int;
            final token = args['token'];

            return MaterialPageRoute(
              builder: (context) => ListMemberBookPage(
                namaMember: namaMember,
                memberId: memberId,
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Tidak Ditemukan')),
                body: Center(child: Text('Halaman tidak ditemukan')),
              ),
            );
        }
      },
      initialRoute: '/login',
    );
  }
}
