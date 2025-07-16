# Label Printing Template

A Flutter application for printing labels using Bluetooth thermal printers. This project follows clean architecture principles with proper separation of concerns using repositories and services.

## Architecture Overview

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────┐
│              Views                  │  ← UI Layer
├─────────────────────────────────────┤
│           ViewModels                │  ← Business Logic Layer
├─────────────────────────────────────┤
│           Repositories              │  ← Data Access Layer
├─────────────────────────────────────┤
│            Services                 │  ← External Services Layer
├─────────────────────────────────────┤
│             Models                  │  ← Data Models Layer
└─────────────────────────────────────┘
```

## Project Structure

```
lib/
├── models/                    # Data models
│   ├── label_model.dart       # Label data model
│   └── printer_settings_model.dart # Printer settings model
├── services/                  # External services
│   ├── bluetooth_service.dart # Bluetooth operations
│   ├── printing_service.dart  # Printing operations
│   └── storage_service.dart   # Local storage operations
├── repositories/              # Data access layer
│   ├── bluetooth_repository.dart
│   ├── printing_repository.dart
│   ├── settings_repository.dart
│   └── label_repository.dart
├── viewmodels/               # Business logic
│   ├── printing_viewmodel.dart
│   ├── settings_viewmodel.dart
│   └── label_viewmodel.dart
├── views/                    # UI components
│   ├── home_screen.dart
│   └── settings_screen.dart
├── utils/                    # Utilities
│   └── logger.dart
└── main.dart                 # App entry point
```

## Features

### Core Functionality
- **Bluetooth Printing**: Connect to and print to thermal printers
- **Label Management**: Create, save, and manage labels
- **Settings Management**: Configure printer settings
- **QR Code Generation**: Generate QR codes for labels
- **Local Storage**: Persist data locally using SharedPreferences

### Advanced Features
- **Batch Printing**: Print multiple labels at once
- **Label Search**: Search through saved labels
- **Label Statistics**: View printing statistics
- **Import/Export**: Import and export label data
- **Test Printing**: Test printer functionality
- **Multiple Units**: Support for mm, inch, and dots
- **Printer Types**: Support for TSPL, ESC/POS, and ZPL

## Dependencies

### Core Dependencies
- `flutter`: Flutter framework
- `provider`: State management
- `bluetooth_print_plus`: Bluetooth printing functionality
- `shared_preferences`: Local data storage
- `qr_flutter`: QR code generation
- `logger`: Logging functionality

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code linting

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / VS Code
- Physical device with Bluetooth capability

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd label_printing_template
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Usage

### Connecting to a Printer
1. Open the app
2. Navigate to the home screen
3. Tap "Scan for Devices" to find available Bluetooth printers
4. Select your printer from the list
5. The app will attempt to connect automatically

### Creating and Printing Labels
1. Enter the content for your label
2. Enter the QR code data
3. Tap "Print" to send the label to the printer
4. The label will be saved automatically for future use

### Managing Settings
1. Navigate to the settings screen
2. Configure paper width, density, gap, and other settings
3. Settings are automatically saved

### Managing Labels
- View all saved labels
- Search for specific labels
- Delete unwanted labels
- Export/import label data

## Architecture Details

### Models Layer
The models layer contains data classes that represent the core entities:

- **LabelModel**: Represents a label with content, QR data, and metadata
- **PrinterSettingsModel**: Represents printer configuration settings

### Services Layer
The services layer handles external operations:

- **BluetoothService**: Manages Bluetooth device connections and scanning
- **PrintingService**: Handles actual printing operations using TSPL commands
- **StorageService**: Manages local data persistence using SharedPreferences

### Repositories Layer
The repositories layer provides a clean interface for data access:

- **BluetoothRepository**: Abstracts Bluetooth operations
- **PrintingRepository**: Abstracts printing operations with validation
- **SettingsRepository**: Manages printer settings with validation
- **LabelRepository**: Manages label CRUD operations

### ViewModels Layer
The viewmodels layer contains business logic and state management:

- **PrintingViewModel**: Manages printing state and operations
- **SettingsViewModel**: Manages settings state and operations
- **LabelViewModel**: Manages label state and operations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on the GitHub repository.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
