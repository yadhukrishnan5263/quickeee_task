import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../../presentation/widgets/product_header.dart';
import '../../presentation/widgets/price_chart.dart';
import '../../presentation/widgets/animated_price_display.dart';
import '../../presentation/widgets/hold_to_secure_button.dart';
import '../../presentation/widgets/product_image.dart';
import '../../presentation/widgets/data_loading_widget.dart';
import '../widgets/animated_background.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late ProductBloc _productBloc;
  double _previousPrice = 0.0;
  
  late AnimationController _fadeController;


  @override
  void initState() {
    super.initState();
    
    _productBloc = context.read<ProductBloc>();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _productBloc.stream.listen((state) {
      if (state.currentPrice != _previousPrice) {
        setState(() {
          _previousPrice = state.currentPrice;
        });
      }
    });

    _productBloc.add(LoadInitialData());

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return const _ProductDetailScaffold();
  }
}

class _ProductDetailScaffold extends StatelessWidget {
  const _ProductDetailScaffold();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: _ProductContent(),
        ),
      ),
    );
  }
}

class _ProductContent extends StatelessWidget {
  const _ProductContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) => 
          previous.isLoading != current.isLoading ||
          previous.error != current.error ||
          previous.currentPrice != current.currentPrice ||
          previous.remainingInventory != current.remainingInventory,
      builder: (context, state) {
        if (state.isLoading) {
          return const DataLoadingWidget();
        }
        
        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading data',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProductHeader(),
              const SizedBox(height: 16),
              const ProductImage(),
              const SizedBox(height: 24),
              const AnimatedPriceDisplay(),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: BlocBuilder<ProductBloc, ProductState>(
                  buildWhen: (previous, current) =>
                      previous.liveData.length != current.liveData.length ||
                      (previous.liveData.isNotEmpty && current.liveData.isNotEmpty &&
                       previous.liveData.last.price != current.liveData.last.price),
                  builder: (context, state) {
                    return BuildPriceChart(
                      key: ValueKey('chart_${state.liveData.length}_${state.liveData.isNotEmpty ? state.liveData.last.price : 0}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: HoldButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}





