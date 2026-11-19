class OrderItem {
  final int id;
  final int orderId;
  final int? productId;
  final String productName;
  final String productImageUrl;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    String name = 'Product';
    String image = '';

    if (map['products'] != null && map['products'] is Map) {
      final p = map['products'] as Map;
      name = p['name'] as String? ?? 'Product';
      image = p['image_url'] as String? ?? '';
    }
    if (map['product_name'] != null) {
      name = map['product_name'] as String;
    }
    final color = map['color_name'] as String?;
    if (color != null && color.isNotEmpty) {
      name = '$name ($color)';
    }

    return OrderItem(
      id: (map['id'] as num).toInt(),
      orderId: (map['order_id'] as num).toInt(),
      productId: (map['product_id'] as num?)?.toInt(),
      productName: name,
      productImageUrl: image,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OrderModel {
  final int id;
  final String userId;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String? customerName;
  final String? customerEmail;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.total,
    required this.createdAt,
    this.items = const [],
    this.customerName,
    this.customerEmail,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
        .toList();

    String? custName;
    String? custEmail;
    if (map['profiles'] != null && map['profiles'] is Map) {
      final prof = map['profiles'] as Map;
      final fn = prof['firstname'] as String? ?? '';
      final ln = prof['lastname'] as String? ?? '';
      custName = '$fn $ln'.trim();
      custEmail = prof['email'] as String?;
    }

    return OrderModel(
      id: (map['id'] as num).toInt(),
      userId: map['user_id'] as String? ?? '',
      status: map['status'] as String? ?? 'done',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: itemsList,
      customerName: custName,
      customerEmail: custEmail,
    );
  }
}

