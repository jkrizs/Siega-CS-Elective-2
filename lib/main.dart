import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My First Flutter UI',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ), 
      home: const MobileMockupWrapper(),
    );
  }
}

class MobileMockupWrapper extends StatelessWidget {
  const MobileMockupWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: 380, 
              height: 780, 
              decoration: BoxDecoration(
                color: const Color(0xFF0D0E12), 
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF1C2029), 
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 35,
                    spreadRadius: 2,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(46), 
                child: const WalletProfileScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WalletProfileScreen extends StatelessWidget {
  const WalletProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6), 
      body: Column(
        children: [
          const TopHeaderCard(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: const [
                        TransactionItem(
                          title: 'Received Money',
                          date: 'November 02, 2023',
                          time: '10:12 PM',
                          amount: '+ \$213.00',
                          imageAsset: 'assets/transaction_1.jpg',
                        ),
                        TransactionItem(
                          title: 'Received Money',
                          date: 'October 29, 2023',
                          time: '10:12 PM',
                          amount: '+ \$102.00',
                          imageAsset: 'assets/transaction_2.jpg',
                        ),
                        TransactionItem(
                          title: 'Received Money',
                          date: 'October 16, 2023',
                          time: '10:12 PM',
                          amount: '+ \$300.00',
                          imageAsset: 'assets/transaction_3.jpg',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopHeaderCard extends StatelessWidget {
  const TopHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF121721),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF3DB7F8), 
            Color(0xFF1B82D3), 
            Color(0xFF121721), 
          ],
          stops: [0.0, 0.45, 0.85],
        ),
      ),
      padding: const EdgeInsets.only(
        top: 48,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF46B3F6).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Carl Rey Roque',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rmcx_dn8v87d_ljh8589',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.65),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '\$98,325',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String amount;
  final String imageAsset;

  const TransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.amount,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0EA), 
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
