
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/dependency_injection.dart';
import 'feature/presentation/pages/product_detail_page.dart';
import 'feature/presentation/bloc/product_bloc.dart';

void main() {
  DependencyInjection.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Product Detail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: BlocProvider(
        create: (context) => ProductBloc(
          getProductDataUseCase: DependencyInjection.getProductDataUseCase,
        ),
        child: const ProductDetailPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
