import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Providers
import 'package:frontend/providers/auth_provider.dart';

// Import Screens
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/dashboard_screen.dart';

// หมายเหตุ: หน้าเหล่านี้คุณต้องสร้างไฟล์รอไว้ในโฟลเดอร์ screens 
// หรือสร้าง Class เปล่าๆ ไว้ก่อนเพื่อให้รันผ่านครับ
// import 'package:frontend/screens/stock_in_screen.dart';
// import 'package:frontend/screens/stock_out_screen.dart';
// import 'package:frontend/screens/borrow_screen.dart';
// import 'package:frontend/screens/return_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Management System',
      
      // การตั้งค่า Theme ของแอป
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // หน้าแรกที่จะเปิดขึ้นมา
      // เช็คว่าถ้า Login ค้างไว้ให้ไป Dashboard ถ้าไม่ให้ไป Login
      initialRoute: '/login', 

      // การกำหนดเส้นทาง (Routes) ทั้งหมดในแอป
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        
        // --- ส่วนหน้าจอที่ต้องพัฒนาต่อ ---
        '/stock-in': (context) => const PlaceholderScreen(title: 'Stock In (รับสินค้า)'),
        '/stock-out': (context) => const PlaceholderScreen(title: 'Stock Out (เบิกสินค้า)'),
        '/borrow': (context) => const PlaceholderScreen(title: 'การยืมสินค้า'),
        '/return': (context) => const PlaceholderScreen(title: 'การคืนสินค้า'),
        '/inventory': (context) => const PlaceholderScreen(title: 'จัดการคลังสินค้า'),
        '/reports': (context) => const PlaceholderScreen(title: 'รายงานสรุป'),
      },
    );
  }
}

// Widget ชั่วคราวสำหรับหน้าที่ยังไม่ได้เขียน Code จริง
// เพื่อให้กดปุ่มจาก Dashboard แล้วไม่ Error
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              'หน้าจอ "$title" \nกำลังอยู่ในระหว่างการพัฒนา',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('กลับหน้าหลัก'),
            )
          ],
        ),
      ),
    );
  }
}