import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล User จาก AuthProvider
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => auth.logout().then((_) {
              Navigator.pushReplacementNamed(context, '/login');
            }),
          )
        ],
      ),
      body: Column(
        children: [
          // ส่วนที่ 1: Header แสดงข้อมูลผู้ใช้
          _buildHeader(user),

          // ส่วนที่ 2: เมนูหลัก 4 ปุ่ม (Stock In, Out, ยืม, คืน)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2, // แบ่ง 2 คอลัมน์
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(
                    context, 
                    'Stock In', 
                    Icons.move_to_inbox, 
                    Colors.green, 
                    '/stock-in'
                  ),
                  _buildMenuCard(
                    context, 
                    'Stock Out', 
                    Icons.outbox, 
                    Colors.orange, 
                    '/stock-out'
                  ),
                  _buildMenuCard(
                    context, 
                    'การยืม', 
                    Icons.handshake_outlined, 
                    Colors.blue, 
                    '/borrow'
                  ),
                  _buildMenuCard(
                    context, 
                    'การคืน', 
                    Icons.settings_backup_restore, 
                    Colors.purple, 
                    '/return'
                  ),
                ],
              ),
            ),
          ),

          // ส่วนที่ 3: เมนูเพิ่มเติมสำหรับ Admin / Stock Manager
          if (user?['role'] == 'Admin' || user?['role'] == 'Stock_Manager')
            _buildAdminPanel(context),
        ],
      ),
    );
  }

  // Widget: ส่วนหัวแสดงชื่อและบทบาท
  Widget _buildHeader(Map<String, dynamic>? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ยินดีต้อนรับ,',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            user?['name'] ?? 'Guest User',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 24, 
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'สิทธิ์: ${user?['role']}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: การ์ดเมนูหลัก
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 35, color: color),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: แถบเมนูสำหรับผู้ดูแลระบบ
  Widget _buildAdminPanel(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Management",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallAction(context, Icons.inventory, 'คลังสินค้า', '/inventory'),
              _buildSmallAction(context, Icons.bar_chart, 'รายงาน', '/reports'),
              _buildSmallAction(context, Icons.people, 'ผู้ใช้งาน', '/users'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallAction(BuildContext context, IconData icon, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueGrey),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}