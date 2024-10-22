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
      memberList = [];
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _refreshMembers,
                color: Colors.white,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text('Daftar Anggota',
                            style: TextStyle(color: Colors.white)),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(_isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
                          onPressed: _toggleSortOrder,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari Anggota',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search,
                                    color: Color(0xFF03346E)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final member = filteredMembers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFF03346E),
                                  child: Text(
                                    member['name'][0].toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  member['name'] ?? 'Tidak Ada Nama',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF03346E),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      member['email'] ?? 'Tidak Ada Email',
                                      style:
                                          TextStyle(color: Color(0xFF1E5AA8)),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'ID: ${member['id'] ?? 'N/A'}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    color: Color(0xFF03346E)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailMemberPage(member: member),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        childCount: filteredMembers.length,
                      ),
                    ),
                    if (totalPage > 1)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    currentPage > 1 ? _previousPage : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03346E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                icon: Icon(Icons.arrow_back, size: 16),
                                label: Text('Sebelumnya',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              Text(
                                'Halaman $currentPage dari $totalPage',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed:
                                    currentPage < totalPage ? _nextPage : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03346E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                icon: Icon(Icons.arrow_forward, size: 16),
                                label: Text('Selanjutnya',
                                    style: TextStyle(fontSize: 12)),
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

  void _nextPage() async {
    if (currentPage < totalPage && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
        currentPage++;
      });

      if (currentPage * 10 >= memberList.length) {
        final fetchedMembers = await fetchMembers(page: currentPage);
        if (fetchedMembers.isNotEmpty) {
          setState(() {
            memberList.addAll(fetchedMembers);
          });
        }
      }

      _updateDisplayedMembers();

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void _previousPage() async {
    if (currentPage > 1 && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
        currentPage--;
      });

      _updateDisplayedMembers();

      setState(() {
        isLoadingMore = false;
      });
    }
  }

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
