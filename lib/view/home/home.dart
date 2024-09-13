import 'package:flutter/material.dart';

class TampilanHomePage extends StatefulWidget {
  @override
  _TampilanHomePageState createState() => _TampilanHomePageState();
}

class _TampilanHomePageState extends State<TampilanHomePage> {
  bool _obscureText = true;
  bool _isAmountVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background half-circle
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: MediaQuery.of(context).size.width * 1.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 233, 132, 0),
                borderRadius: BorderRadius.only(
                  bottomRight:
                      Radius.circular(MediaQuery.of(context).size.width),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 165.0), // Adjust padding as needed
                      child: Icon(
                        Icons
                            .wb_cloudy_rounded, // Replace with your desired icon
                        size: 250, // Adjust the size as needed
                        color: Colors.white, // Icon color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text "Hallo GILANG !" positioned above the card
                Text(
                  "Hello, Gilang!",
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                    fontSize: 20, // Adjust font size as needed
                    fontWeight: FontWeight.bold, // Set text to bold
                  ),
                ),
                SizedBox(height: 70), // Add space between text and the card
                // Icon buttons with explanations                // New card added here
                Container(
                  width: double.infinity, // Full width of the screen
                  margin: const EdgeInsets.only(
                      bottom: 8.0), // Add margin below the new card
                  child: _buildNewFeatureCard(),
                ),
                Container(
                  width: double.infinity, // Full width of the screen
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0), // Add vertical margin if needed
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Catatan Keuangan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isAmountVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isAmountVisible = !_isAmountVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Saldo Keuangan dari jumlah pemasukkan dan jumlah pengeluaran:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Pemasukkan and Pengeluaran rows with icons and dividers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jumlah Pemasukkan',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                _isAmountVisible
                                                    ? 'Rp 1.000.000' // Replace with actual amount
                                                    : '******',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.attach_money,
                                                color: Colors.green,
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: Colors.black26,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jumlah Pengeluaran',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                _isAmountVisible
                                                    ? 'Rp 500.000' // Replace with actual amount
                                                    : '******',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.money_off,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                    height:
                        5), // Add space between "Catatan Keuangan" card and "Histori Transaksi" card
                // Add space between the new card and the icon buttons
                // Main Feature card will expand to fill the remaining space
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity, // Full width of the screen
                      child: _buildCard(
                          'Main Feature', Icons.dashboard, Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8.0), // Adjust padding around the icon
          decoration: BoxDecoration(
            color: Colors.orangeAccent, // Background color of the icon
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.6), // Shadow color

                blurRadius: 1,
                offset: Offset(0, 1), // Shadow position
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 40, // Adjusted icon size
            color: Colors.white, // Icon color
          ),
        ),
        SizedBox(
          height: 5,
        ), // Adjust space between icon and text
        Container(
          width: 100, // Adjust width to be consistent with icon width
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, // Font size for text below icons
              fontWeight: FontWeight.bold, // Bold text for emphasis
              color: Colors.white, // Set text color to white
              // Removed shadows from text
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 10, // Increase elevation for a more pronounced shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Radius for the card
      ),
      shadowColor: Colors.black.withOpacity(0.3), // Shadow color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text "Histori Transaksi" in the top left
            Text(
              'Histori Transaksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10), // Space between text and search bar

            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color for search bar
                borderRadius:
                    BorderRadius.circular(8.0), // Add radius to search bar
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari data...',
                  prefixIcon: Icon(Icons.search,
                      color: Colors.grey[600]), // Color for search icon
                  border: InputBorder.none, // Remove border
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
            SizedBox(height: 10), // Space between search bar and filters

            // Filter labels
            Container(
              margin:
                  const EdgeInsets.only(bottom: 10.0), // Space below the filter
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterLabel('Filter', Icons.filter_list),
                  SizedBox(width: 10), // Space between filter labels
                  _buildFilterLabel('Pemasukan'),
                  SizedBox(width: 10), // Space between filter labels
                  _buildFilterLabel('Pengeluaran'),
                ],
              ),
            ),

            // List view
            Expanded(
              child: ListView(
                children: [
                  // Example list items; replace with your data
                  ListTile(
                    leading: Icon(Icons.attach_money,
                        color: Colors.green), // Icon color for Pemasukan
                    title: Text('Pemasukan 1'),
                    subtitle: Text('Detail Pemasukan 1'),
                    trailing: Text(
                      '+Rp. 500.000', // Amount with plus sign for Pemasukan
                      style: TextStyle(
                        color: Colors.green, // Text color for positive amount
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey, // Menghilangkan warna divider
                    thickness: 0.2,
                    height:
                        1.2, // Mengurangi tinggi divider agar tidak ada jarak
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money,
                        color: Colors.green), // Icon color for Pemasukan
                    title: Text('Pemasukan 2'),
                    subtitle: Text('Detail Pemasukan 2'),
                    trailing: Text(
                      '+Rp. 300.000', // Amount with plus sign for Pemasukan
                      style: TextStyle(
                        color: Colors.green, // Text color for positive amount
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey, // Menghilangkan warna divider
                    thickness: 0.2,
                    height:
                        1.2, // Mengurangi tinggi divider agar tidak ada jarak
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money,
                        color: Colors.red), // Icon color for Pengeluaran
                    title: Text('Pengeluaran 1'),
                    subtitle: Text('Detail Pengeluaran 1'),
                    trailing: Text(
                      '-Rp. 150.000', // Amount with minus sign for Pengeluaran
                      style: TextStyle(
                        color: Colors.red, // Text color for negative amount
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey, // Menghilangkan warna divider
                    thickness: 0.2,
                    height:
                        1.2, // Mengurangi tinggi divider agar tidak ada jarak
                  ),
                  // Add more ListTile widgets here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label, [IconData? icon]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Warna latar belakang label filter
        borderRadius: BorderRadius.circular(16.0), // Sudut melingkar
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Menyesuaikan lebar dengan isi
        children: [
          if (icon != null) // Tampilkan ikon jika ada
            Icon(icon, size: 18, color: Colors.grey),
          if (icon != null)
            SizedBox(width: 5), // Tambahkan jarak antara ikon dan teks
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewFeatureCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16.0), // Radius pada sudut-sudut Card
      ),
      shadowColor: Colors.black.withOpacity(0.3),
      margin: EdgeInsets.zero, // Pastikan Card mengambil lebar penuh
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orangeAccent, // Warna latar belakang bagian atas
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.0)), // Radius atas
            ),
            width:
                double.infinity, // Memastikan bagian ini memenuhi lebar penuh
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Anda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _obscureText
                            ? 'Rp. ****.***'
                            : 'Rp. 1.000.000', // Menampilkan atau menyembunyikan teks
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText =
                              !_obscureText; // Mengubah status visibilitas
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.transparent, // Menghilangkan warna divider
            thickness: 0.2,
            height: 0.2, // Mengurangi tinggi divider agar tidak ada jarak
          ),
          GestureDetector(
            onTap: () {
              // Add your onTap functionality here
              print('Container tapped!');
              // For better visibility, show a dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Pencet Terus !'),
                    content: Text('Hayoloh'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orangeAccent, // Background color
                borderRadius: BorderRadius.vertical(), // Bottom radius
              ),
              width: double.infinity, // Ensures full width
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lihat Pemasukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.transparent, // Menghilangkan warna divider
            thickness: 0.2,
            height: 0.2, // Mengurangi tinggi divider agar tidak ada jarak
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, 255, 145, 0), // Warna latar belakang bagian bawah
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16.0)), // Radius bawah
            ),
            width:
                double.infinity, // Memastikan bagian ini memenuhi lebar penuh
            padding: const EdgeInsets.all(7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildIconButton(Icons.book_outlined, 'Daftar Buku'),
                    SizedBox(width: 1),
                    _buildIconButton(Icons.swap_horiz, 'Peminjaman'),
                    SizedBox(width: 1),
                    _buildIconButton(Icons.approval_outlined, 'Persetujuan'),
                    SizedBox(width: 1),
                    _buildIconButton(Icons.history, 'Pengembalian'),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
