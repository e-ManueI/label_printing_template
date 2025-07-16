# Label Printing Template

A Flutter application for managing and printing labels with QR codes using Bluetooth thermal printers. Built with Clean Architecture principles and optimized for reliable Bluetooth communication.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with a clear separation of concerns across three main layers:

### 📁 Project Structure

```
lib/
├── domain/                    # Business Logic Layer
│   ├── entities/             # Core business objects
│   ├── repositories/         # Abstract repository interfaces
│   └── usecases/            # Business use cases
├── data/                     # Data Layer
│   ├── models/              # Data transfer objects (DTOs)
│   ├── datasources/         # Data sources (local, remote)
│   └── repositories/        # Repository implementations
└── presentation/            # Presentation Layer
    ├── pages/               # UI screens
    └── viewmodels/          # State management
```

## 🔄 Data Flow Sequence

For a detailed understanding of how data flows through the application, see the [Data Flow Sequence Diagram](./docs/data-flow-sequence.md). This diagram illustrates:

- **Bluetooth Connection Flow**: Device discovery, connection, and status monitoring
- **Print Job Execution**: From UI interaction to printer command execution
- **Label Management**: CRUD operations and data persistence
- **Error Handling**: How errors are propagated through the layers

## 🎯 Layer Responsibilities

### Domain Layer (`domain/`)
- **Entities**: Core business objects (pure Dart classes)
- **Repositories**: Abstract interfaces for data access
- **Use Cases**: Business logic and rules

### Data Layer (`data/`)
- **Models**: Data transfer objects and serialization
- **Data Sources**: Implementation of data access (local storage, APIs)
- **Repository Implementations**: Concrete implementations of domain repositories

### Presentation Layer (`presentation/`)
- **Pages**: UI screens and widgets
- **ViewModels**: State management using ChangeNotifier

## 📋 Domain Entities vs Data Models

### Domain Entities (`domain/entities`)

**Purpose:**
- Core business objects
- Pure Dart classes with minimal dependencies
- Represent essential data structures independent of any framework or data source
- Should not depend on anything in the data layer

**Examples:**
- `label.dart` (with the `Label` class)
- `printer_settings.dart` (with the `PrinterSettings` class)

**Usage:**
- Used throughout the domain and presentation layers
- Used in repositories, use cases, and viewmodels

### Data Models (`data/models`)

**Purpose:**
- Data transfer objects (DTOs) or models for serialization
- Used to convert data to/from external sources (APIs, databases, local storage)
- Often include `fromJson`, `toJson`, or similar methods for mapping
- May depend on serialization libraries or data source specifics

**Examples:**
- `label_model.dart` (with the `LabelModel` class)
- `printer_settings_model.dart` (with the `PrinterSettingsModel` class)

**Usage:**
- Used in the data layer only
- Used by data sources and repository implementations to convert between raw data and domain entities

### Summary Table

| Layer/Folder | Class Example | Purpose/Usage |
|--------------|---------------|---------------|
| `domain/entities` | `Label`, `PrinterSettings` | Core business objects, pure Dart, no dependencies |
| `data/models` | `LabelModel`, `PrinterSettingsModel` | Serialization, mapping, DTOs, data source specific |

### Which is correct?

- **If you are defining the core business object:** Place it in `domain/entities`
- **If you are defining a class for mapping/serialization (e.g., for API or storage):** Place it in `data/models`

In this project, both are correct but for different purposes:
- Use `domain/entities` for your app's core logic and business rules
- Use `data/models` for data source interaction and mapping

If you want to avoid duplication, you can sometimes use the entity directly as a model, but in clean architecture, keeping them separate is best practice.

## 🚀 Features

- **Label Management**: Create, edit, delete, and search labels
- **QR Code Generation**: Generate QR codes for labels
- **Bluetooth Printing**: Connect to and print with Bluetooth thermal printers
- **Settings Management**: Configure printer settings and preferences
- **Local Storage**: Persistent storage using SharedPreferences
- **Clean Architecture**: Well-structured, maintainable codebase
- **Robust Error Handling**: Comprehensive error handling and recovery
- **Connection Monitoring**: Real-time Bluetooth connection status monitoring

## 🔧 Bluetooth Printing Implementation

### Key Features
- **TSC Command Support**: Full support for TSC (Thermal Printer Command) protocol
- **Connection Verification**: Active connection status checking before printing
- **Error Recovery**: Automatic retry mechanisms and graceful error handling
- **Print Queue Management**: Efficient handling of single and batch print jobs
- **Device Discovery**: Robust Bluetooth device scanning and connection

### Technical Improvements
- **Connection State Management**: Uses `BluetoothPrintPlus.isConnected` for accurate status
- **Scan Optimization**: Proper scan cleanup and timeout handling
- **Command Timing**: Strategic delays for reliable Bluetooth communication
- **Comprehensive Logging**: Detailed logging for debugging and monitoring

## 📱 Screens

### Home Screen
- QR code preview
- Label content and QR data input
- Bluetooth printer connection
- Print functionality

### Settings Screen
- Printer configuration (paper width, density, gap)
- Unit selection (mm, inch, dots)
- Printer type selection
- Reset to defaults

### Label Management Screen
- List of all created labels
- Search and filter functionality
- Create, edit, and delete labels
- Label statistics

## 🛠️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5
  qr_flutter: ^4.1.0
  shared_preferences: ^2.5.3
  bluetooth_print_plus: ^2.4.6
  logger: ^2.0.2
```

## 🏃‍♂️ Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd label_printing_template
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 State Management

This project uses **Provider** with **ChangeNotifier** for state management:

- `SettingsViewModel`: Manages printer settings and configuration
- `PrintingViewModel`: Handles Bluetooth connection and printing operations
- `LabelViewModel`: Manages label CRUD operations and search

## 🔧 Configuration

### Bluetooth Permissions

For Android, add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

For iOS, add the following to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs bluetooth to connect to label printers</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs bluetooth to connect to label printers</string>
```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Support

If you encounter any issues or have questions, please open an issue on GitHub.

## 🔍 Troubleshooting

### Common Bluetooth Issues

1. **Printer Not Found**: Ensure Bluetooth is enabled and printer is in pairing mode
2. **Connection Drops**: Check for interference and ensure printer is within range
3. **Print Commands Not Executing**: Verify connection status and check printer settings
4. **Permission Errors**: Ensure all required permissions are granted

### Debug Mode

Enable detailed logging by checking the console output. The app provides comprehensive logging for:
- Bluetooth connection status
- Print command execution
- Error details and recovery attempts

---

**Note**: This project is designed as a template and can be extended with additional features like:
- Cloud synchronization
- Multiple printer support
- Advanced label templates
- Barcode generation
- Export/import functionality
- Print job scheduling
- Printer status monitoring
