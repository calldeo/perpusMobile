import 'package:flutter/material.dart';

class DetailMemberPage extends StatelessWidget {
  final Map<String, dynamic> member;

  DetailMemberPage({required this.member});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari objek member
    final String name = member['name'] ?? 'No Name';
    final String email = member['email'] ?? 'No Email';
    final List<dynamic> roles = member['roles'] ?? ['No Roles'];
    final String password = member['password'] != null
        ? '********'
        : 'No Password'; // Placeholder untuk password

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Member'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start, // Menaikkan card ke atas
        children: [
          Container(
            width: 400, // Lebar card yang lebih besar secara horizontal
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $name',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Email: $email',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Roles:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    // Menampilkan nama role yang dimiliki member
                    ...roles.map((role) => Text(role['name'].toString(),
                        style: TextStyle(fontSize: 14))),
                    SizedBox(height: 10),
                    Text(
                      'Password: $password', // Password disembunyikan dengan placeholder
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    // Tombol kembali di dalam card
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent),
                        child: Text('Back'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
