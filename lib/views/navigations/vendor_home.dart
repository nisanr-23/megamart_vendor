import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class VendorHomePage extends StatefulWidget {
  @override
  _VendorHomePageState createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Map<String, int> orderStatusCounts = {
    "Products Added": 0,
    "Pending": 0,
    "Order Confirmed": 0,
    "Order Shipped": 0,
    "Out for Delivery": 0,
    "Order Delivered": 0,
    "Order Cancelled": 0,
    "Order Returned": 0,
    "Order Refunded": 0,
    "Order Processing Failed": 0,
  };

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _listenToPendingOrders();
    _fetchCounts();
  }

  void _listenToPendingOrders() {
    User? user = _auth.currentUser;

    if (user != null) {
      _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: user.uid)
          .where('orderStatus', isEqualTo: 'Pending')
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _showNotification(change.doc);
          }
        }
      });
    }
  }

  Future<void> _showNotification(DocumentSnapshot order) async {
    var orderData = order.data() as Map<String, dynamic>;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'new_order_channel',
      'New Orders',
      'Channel for new order notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Pending Order',
      'You have received a new pending order: ${orderData['orderStatus']}',
      platformChannelSpecifics,
      payload: order.id,
    );
  }

  Future<void> _fetchCounts() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Fetch product count
      var productQuerySnapshot = await _firestore
          .collection('products')
          .where('vendorId', isEqualTo: user.uid)
          .get();
      setState(() {
        orderStatusCounts["Products Added"] = productQuerySnapshot.docs.length;
      });

      // Fetch order counts
      for (var status in orderStatusCounts.keys.where((key) => key != "Products Added")) {
        var querySnapshot = await _firestore
            .collection('orders')
            .where('vendorId', isEqualTo: user.uid)
            .where('orderStatus', isEqualTo: status)
            .get();
        setState(() {
          orderStatusCounts[status] = querySnapshot.docs.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            int crossAxisCount;

            if (maxWidth < 600) {
              crossAxisCount = 2;
            } else if (maxWidth < 900) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 4;
            }

            double cardWidth = (maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

            return SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: cardWidth / cardWidth,
                    ),
                    itemCount: orderStatusCounts.length,
                    itemBuilder: (context, index) {
                      String status = orderStatusCounts.keys.elementAt(index);
                      int count = orderStatusCounts[status]!;
                      return _buildStatusCard(context, status, count, cardWidth);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, int count, double cardWidth) {
    var screenWidth = MediaQuery.of(context).size.width;

    double titleFontSize;
    double countFontSize;

    if (screenWidth < 600) {
      titleFontSize = 14;
      countFontSize = 24;
    } else if (screenWidth < 900) {
      titleFontSize = 16;
      countFontSize = 28;
    } else {
      titleFontSize = 18;
      countFontSize = 36;
    }

    return Container(
      width: cardWidth,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: countFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
