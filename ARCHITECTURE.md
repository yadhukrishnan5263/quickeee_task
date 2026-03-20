# Architecture Documentation

## Overview
This Flutter application follows a Clean Architecture pattern with feature-first organization, implementing a robust price tracking and purchasing system.

## State Management

### Choice: BLoC Pattern
- **Framework**: flutter_bloc
- **Reason**: Predictable state management with clear separation of business logic from UI
- **Benefits**: 
  - Unidirectional data flow
  - Time-travel debugging capabilities
  - Testable business logic
  - Reactive UI updates

### State Structure
```dart
class ProductState extends Equatable {
  final List<PriceData> historicalData;
  final List<PriceData> liveData;
  final double currentPrice;
  final int remainingInventory;
  final bool isLoading;
  final String? error;
}
```

### Event-Driven Architecture
- **Events**: User actions (LoadInitialData, PriceUpdated, InventoryUpdated)
- **States**: Immutable state snapshots
- **Transitions**: Clear state mutations through event handlers

## Isolate Communication

### Heavy JSON Parsing
**Problem**: Large JSON file (50,000+ entries) blocking UI thread
**Solution**: Isolate-based parsing with progress reporting

```dart
Future<List<PriceData>> _parseMassiveJsonInIsolate(String jsonString) async {
  return await Isolate.run(() {
    // Heavy computation happens in separate isolate
    final List<dynamic> jsonData = json.decode(jsonString);
    final List<PriceData> priceData = [];
    
    for (int i = 0; i < jsonData.length; i++) {
      // Process each entry
      priceData.add(PriceData(...));
      
      // Progress reporting without blocking main thread
      if (i % 10000 == 0) {
        print('📊 Parsed $i entries...');
      }
    }
    return priceData;
  });
}
```

### Benefits
- **Non-blocking UI**: Main thread remains responsive
- **Memory safety**: Isolate has separate memory space
- **Progress feedback**: Real-time parsing progress
- **Error isolation**: Parsing errors don't crash UI

## Folder Structure

### Feature-First Organization
```
lib/
├── main.dart                    # App entry point
├── core/
│   └── di/
│       └── dependency_injection.dart    # Service locator
└── feature/
    ├── data/                    # Data layer
    │   ├── datasources/
    │   │   └── local/
    │   │       └── asset_datasource.dart  # Raw data access
    │   └── repositories/
    │       └── product_repository_impl.dart  # Repository implementation
    ├── domain/                   # Business logic
    │   ├── models/
    │   │   └── price_data.dart           # Data models
    │   ├── repositories/
    │   │   └── product_repository.dart   # Repository contracts
    │   └── usecases/
    │       └── get_product_data_usecase.dart  # Business rules
    └── presentation/              # UI layer
        ├── bloc/
        │   ├── product_bloc.dart          # State management
        │   ├── product_event.dart        # Events
        │   └── product_state.dart        # State definitions
        ├── pages/
        │   └── product_detail_page.dart # Main screen
        └── widgets/
            ├── price_chart.dart          # Custom chart painting
            ├── animated_price_display.dart # Price animations
            ├── hold_to_secure_button.dart # Interactive button
            ├── data_loading_widget.dart   # Loading indicator
            ├── product_image.dart       # Product showcase
            └── animated_background.dart   # Visual effects
```

## Data Flow

### 1. Initialization Flow
```
main.dart
    ↓
DependencyInjection.initialize()
    ↓
ProductBloc created with dependencies
    ↓
LoadInitialData event
    ↓
AssetDataSource.getHistoricalData() → Isolate parsing
    ↓
Historical data loaded → State updated
    ↓
Price stream started → Live updates
```

### 2. Live Data Flow
```
AssetDataSource.getPriceStream()
    ↓
PriceUpdate emitted
    ↓
ProductBloc receives PriceUpdated event
    ↓
State updated → UI rebuilds
    ↓
Chart and price display updated
```

## Key Architectural Decisions

### 1. Separation of Concerns
- **Data Layer**: Raw data access and transformation
- **Domain Layer**: Business rules and use cases
- **Presentation Layer**: UI components and state management

### 2. Dependency Injection
- **Service Locator Pattern**: Centralized dependency management
- **Testability**: Easy mocking for unit tests
- **Flexibility**: Runtime dependency swapping

### 3. Reactive Programming
- **Streams**: Real-time data updates
- **BLoC**: State management with clear event handling
- **Widgets**: Reactive UI components

### 4. Performance Optimizations
- **Isolates**: Heavy computation off main thread
- **Sliding Window**: Fixed memory usage (100 data points)
- **Selective Rebuilds**: `buildWhen` conditions in BLoC builders

### 5. Error Handling
- **Graceful Degradation**: Error states in UI
- **Data Validation**: Filter invalid price entries
- **Recovery Mechanisms**: Retry and fallback values

## Technology Choices

### State Management: BLoC
- **Predictable**: Clear state transitions
- **Testable**: Business logic separated from UI
- **Scalable**: Handles complex state interactions

### Data Processing: Isolates
- **Performance**: Non-blocking heavy computations
- **Stability**: Memory isolation
- **Progress**: User feedback during operations

### Architecture: Clean Architecture
- **Maintainability**: Clear layer boundaries
- **Testability**: Each layer independently testable
- **Flexibility**: Easy to modify and extend

This architecture provides a solid foundation for a responsive, scalable Flutter application with excellent performance characteristics and maintainable codebase.

## Design References

### Visual Design Inspiration
- **Dribbble**: Modern glassmorphism and micro-interactions
  - Glass morphism effects with backdrop filters
  - Smooth hold-to-secure button animations
  - Fluid gradient backgrounds with nebula effects
  - Clean typography and spacing

- **Pinterest**: Product showcase and data visualization
  - Elegant product image presentations
  - Clean price chart designs
  - Minimalist loading states
  - Sophisticated color palettes

### Key Design Elements Implemented
- **Glassmorphism**: Translucent backgrounds with blur effects
- **Micro-interactions**: Haptic feedback and smooth transitions
- **Data Visualization**: Custom painted charts with gradient fills
- **Loading States**: Animated indicators with progress feedback
- **Typography**: SF Pro Display for premium feel

### Assets
- **Product Image**: `assets/images/pngegg.png` - Premium watch visualization
- **Price Data**: `assets/massive_price_data.json` - Historical price information
