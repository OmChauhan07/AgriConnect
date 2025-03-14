import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/models/user.dart';
import 'package:agri_connect/models/order.dart';
import 'package:agri_connect/utils/constants.dart';

// Sample farmers
final List<User> dummyFarmers = [
  User(
    id: '1',
    name: 'Green Farm Organics',
    email: 'farmer1@example.com',
    role: UserRole.farmer,
    profileImageUrl: 'https://cdn-icons-png.flaticon.com/512/2421/2421733.png',
    rating: 4.7,
    phone: '9876543210',
  ),
  User(
    id: '2',
    name: 'Natural Harvest',
    email: 'farmer2@example.com',
    role: UserRole.farmer,
    profileImageUrl: 'https://cdn-icons-png.flaticon.com/512/2454/2454286.png',
    rating: 4.5,
    phone: '9876543211',
  ),
  User(
    id: '3',
    name: 'Valley Fresh Produces',
    email: 'farmer3@example.com',
    role: UserRole.farmer,
    profileImageUrl: 'https://cdn-icons-png.flaticon.com/512/2421/2421730.png',
    rating: 4.2,
    phone: '9876543212',
  ),
];

// Sample consumers
final List<User> dummyConsumers = [
  User(
    id: '101',
    name: 'John Consumer',
    email: 'consumer1@example.com',
    role: UserRole.consumer,
    profileImageUrl: 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
    rating: 4.8,
    phone: '9876543200',
  ),
  User(
    id: '102',
    name: 'Sarah Buyer',
    email: 'consumer2@example.com',
    role: UserRole.consumer,
    profileImageUrl: 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
    rating: 4.6,
    phone: '9876543201',
  ),
];

// Sample products
final List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'Organic Tomatoes',
    price: 40.0,
    quantity: 5.0,
    unit: 'kg',
    description: 'Fresh organic tomatoes grown without pesticides',
    farmingMethod: FarmingMethod.organic,
    farmerId: '1',
    rating: 4.7,
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/5247/5247786.png',
    dateAdded: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Product(
    id: 'p2',
    name: 'Fresh Carrots',
    price: 30.0,
    quantity: 2.0,
    unit: 'kg',
    description: 'Naturally grown carrots with rich vitamins',
    farmingMethod: FarmingMethod.natural,
    farmerId: '1',
    rating: 4.3,
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/5267/5267092.png',
    dateAdded: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Product(
    id: 'p3',
    name: 'Organic Spinach',
    price: 25.0,
    quantity: 1.0,
    unit: 'kg',
    description: 'Healthy spinach grown in a natural environment',
    farmingMethod: FarmingMethod.organic,
    farmerId: '2',
    rating: 4.5,
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/5346/5346071.png',
    dateAdded: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Product(
    id: 'p4',
    name: 'Farm Fresh Milk',
    price: 60.0,
    quantity: 1.0,
    unit: 'liter',
    description: 'Pure cow milk from grass-fed cattle',
    farmingMethod: FarmingMethod.organic,
    farmerId: '3',
    rating: 4.8,
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/3500/3500267.png',
    dateAdded: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Product(
    id: 'p5',
    name: 'Hydroponic Lettuce',
    price: 50.0,
    quantity: 0.5,
    unit: 'kg',
    description: 'Lettuce grown using advanced hydroponic techniques',
    farmingMethod: FarmingMethod.hydroponic,
    farmerId: '2',
    rating: 4.6,
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/5346/5346071.png',
    dateAdded: DateTime.now().subtract(const Duration(days: 10)),
  ),
];

// Sample orders
final List<Order> dummyOrders = [
  Order(
    id: 'o1',
    consumerId: '101',
    farmerId: '1',
    products: [
      OrderItem(productId: 'p1', quantity: 2.0, price: 40.0),
      OrderItem(productId: 'p2', quantity: 1.0, price: 30.0),
    ],
    totalAmount: 110.0,
    status: OrderStatus.pending,
    orderDate: DateTime.now().subtract(const Duration(hours: 5)),
    deliveryAddress: '123 Main St, City',
  ),
  Order(
    id: 'o2',
    consumerId: '101',
    farmerId: '2',
    products: [
      OrderItem(productId: 'p3', quantity: 3.0, price: 25.0),
    ],
    totalAmount: 75.0,
    status: OrderStatus.accepted,
    orderDate: DateTime.now().subtract(const Duration(days: 1)),
    deliveryAddress: '123 Main St, City',
  ),
  Order(
    id: 'o3',
    consumerId: '102',
    farmerId: '1',
    products: [
      OrderItem(productId: 'p2', quantity: 2.0, price: 30.0),
    ],
    totalAmount: 60.0,
    status: OrderStatus.delivered,
    orderDate: DateTime.now().subtract(const Duration(days: 3)),
    deliveryAddress: '456 Elm St, Town',
  ),
  Order(
    id: 'o4',
    consumerId: '102',
    farmerId: '3',
    products: [
      OrderItem(productId: 'p4', quantity: 2.0, price: 60.0),
    ],
    totalAmount: 120.0,
    status: OrderStatus.shipped,
    orderDate: DateTime.now().subtract(const Duration(days: 2)),
    deliveryAddress: '456 Elm St, Town',
  ),
];
