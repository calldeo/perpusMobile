import 'package:belajar_flutter_perpus/view/member/detail_member.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class MemberListPage extends StatefulWidget {
  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  List<dynamic> memberList = [];
  List<dynamic> filteredMembers = [];
  final String baseUrl = "http://perpus-api.mamorasoft.com/";
  final String endpoint = "api/user/all";
  bool _isAscending = true;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  int totalPage = 6;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(_filterMembers);
  }

  Future<List<dynamic>> fetchMembers({int page = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().get(
        '$baseUrl$endpoint?page=$page',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Full Response Data: ${response.data.toString()}');

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data.containsKey('data') &&
          data['data'].containsKey('users') &&
          data['data']['users'].containsKey('data')) {
        // Update totalPage
        totalPage = data['data']['users']['last_page'];
        return data['data']['users']['data'];
      } else {
        throw Exception('Unexpected data format');
      }
    } catch (e) {
      log('Error fetching members: $e');
      return [];
    }
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      memberList = []; // Reset member list
    });

    final fetchedMembers = await fetchMembers(page: currentPage);
    setState(() {
      memberList = _sortMembers(fetchedMembers);
      filteredMembers = memberList;
      _isLoading = false;
    });
  }

  Future<void> _loadMoreMembers() async {
    if (currentPage >= totalPage || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    final fetchedMembers = await fetchMembers(page: currentPage);
    setState(() {
      memberList.addAll(_sortMembers(fetchedMembers));
      filteredMembers = memberList;
      isLoadingMore = false;
    });
  }

  List<dynamic> _sortMembers(List<dynamic> data) {
    data.sort((a, b) {
      final nameA = a['name']?.toLowerCase() ?? '';
      final nameB = b['name']?.toLowerCase() ?? '';
      return _isAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });
    return data;
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      memberList = _sortMembers(memberList);
      _filterMembers();
    });
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMembers = memberList.where((member) {
        final name = member['name']?.toLowerCase() ?? '';
        final email = member['email']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _refreshMembers() async {
    await _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshMembers,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Data Users',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search Anggota',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search,
                                    color: Colors.orangeAccent),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 10.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: _toggleSortOrder,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredMembers.length,
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
                                return Card(
                                  elevation: 0,
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      leading: Icon(Icons.people_outline,
                                          size: 50, color: Colors.orangeAccent),
                                      title: Text(
                                        member['name'] ?? 'No Name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      subtitle:
                                          Text(member['email'] ?? 'No Email'),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.orangeAccent,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailMemberPage(
                                              member: member,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isLoadingMore)
                            Center(child: CircularProgressIndicator())
                        ],
                      ),
                    ),
                  ),
                  if (totalPage > 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    currentPage > 1 ? _previousPage : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentPage > 1
                                      ? Colors.orangeAccent
                                      : Colors
                                          .deepOrangeAccent, // Warna saat tombol tidak aktif
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Tambahkan radius pada tombol
                                  ),
                                ),
                                child: Text('Previous'),
                              ),
                              Text(
                                'Page $currentPage of $totalPage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              ElevatedButton(
                                onPressed:
                                    currentPage < totalPage ? _nextPage : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentPage < totalPage
                                      ? Colors.orangeAccent
                                      : Colors
                                          .deepOrangeAccent, // Warna saat tombol tidak aktif
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Tambahkan radius pada tombol
                                  ),
                                ),
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _nextPage() async {
    if (currentPage < totalPage && !isLoadingMore) {
      setState(() {
        isLoadingMore = true; // Menampilkan loading indicator
        currentPage++; // Tambah currentPage sebelum memuat data baru
      });

      // Hanya jika belum memuat data di page selanjutnya, fetch data baru
      if (currentPage * 10 >= memberList.length) {
        final fetchedMembers = await fetchMembers(page: currentPage);
        if (fetchedMembers.isNotEmpty) {
          setState(() {
            memberList.addAll(
                fetchedMembers); // Menambahkan data dari halaman berikutnya
          });
        }
      }

      // Mengupdate filteredMembers untuk hanya menampilkan data dari halaman saat ini
      _updateDisplayedMembers();

      setState(() {
        isLoadingMore = false; // Sembunyikan loading indicator
      });
    }
  }

  void _previousPage() async {
    if (currentPage > 1 && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
        currentPage--; // Kurangi currentPage sebelum memuat data baru
      });

      // Mengupdate filteredMembers untuk hanya menampilkan data dari halaman saat ini
      _updateDisplayedMembers();

      setState(() {
        isLoadingMore = false; // Sembunyikan loading indicator
      });
    }
  }

// Fungsi untuk menampilkan data yang sesuai dengan halaman saat ini
  void _updateDisplayedMembers() {
    final startIndex = (currentPage - 1) * 10;
    final endIndex = startIndex + 10;
    setState(() {
      filteredMembers = memberList.sublist(
        startIndex,
        endIndex > memberList.length ? memberList.length : endIndex,
      );
    });
  }
}
