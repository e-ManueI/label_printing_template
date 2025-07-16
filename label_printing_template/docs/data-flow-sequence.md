# Data Flow Sequence Diagram

This document illustrates the data flow and sequence of operations in the Label Printing Template application, showing how data moves through the Clean Architecture layers.

## 🔄 Overview

The application follows a unidirectional data flow pattern where:
1. **UI Layer** (Presentation) triggers actions
2. **Domain Layer** contains business logic
3. **Data Layer** handles data persistence and external services
4. **External Services** (Bluetooth, Local Storage) provide platform-specific functionality

## 📱 Bluetooth Connection Flow

```mermaid
sequenceDiagram
    participant UI as Presentation Layer
    participant VM as ViewModel
    participant Repo as Repository
    participant Service as Bluetooth Service
    participant BT as BluetoothPrintPlus
    participant Device as Bluetooth Device

    UI->>VM: scanForDevices()
    VM->>Repo: getAvailableDevices()
    Repo->>Service: scanForDevices()
    Service->>BT: stopScan()
    Service->>BT: startScan(timeout: 4s)
    BT-->>Service: scanResults
    Service-->>Repo: List<BluetoothDevice>
    Repo-->>VM: List<BluetoothDevice>
    VM-->>UI: Update device list

    UI->>VM: connectToDevice(device)
    VM->>Repo: connectToDevice(device)
    Repo->>Service: connectToDevice(device)
    Service->>BT: connect(device)
    BT->>Device: Establish connection
    Device-->>BT: Connection status
    BT-->>Service: Connection result
    Service-->>Repo: Connection success/failure
    Repo-->>VM: Connection result
    VM-->>UI: Update connection status
```

## 🖨️ Print Job Execution Flow

```mermaid
sequenceDiagram
    participant UI as Presentation Layer
    participant VM as PrintingViewModel
    participant Repo as PrintingRepository
    participant Service as PrintingService
    participant BT as BluetoothPrintPlus
    participant TSC as TscCommand
    participant Printer as Thermal Printer

    UI->>VM: printCurrentLabel()
    VM->>Repo: printLabel(label, settings)
    Repo->>Service: printLabel(labelModel, settingsModel)
    
    Service->>Service: checkConnectionStatus()
    Service->>BT: isConnected
    BT-->>Service: Connection status
    
    alt Connection Active
        Service->>TSC: cleanCommand()
        Service->>TSC: size(width, height)
        Service->>TSC: gap(settings.gap)
        Service->>TSC: density(settings.density)
        Service->>TSC: cls()
        
        Service->>TSC: qrCode(content, x, y)
        Service->>TSC: text(content, x, y)
        Service->>TSC: print(copies)
        
        Service->>TSC: getCommand()
        TSC-->>Service: Uint8List commands
        
        Service->>BT: write(commands)
        BT->>Printer: Send TSC commands
        Printer-->>BT: Print result
        BT-->>Service: Write result
        
        Service->>Service: delay(500ms)
        Service-->>Repo: Print success
        Repo-->>VM: Print success
        VM-->>UI: Update print status
    else Connection Failed
        Service-->>Repo: Print failed
        Repo-->>VM: Print failed
        VM-->>UI: Show error message
    end
```

## 🏷️ Label Management Flow

```mermaid
sequenceDiagram
    participant UI as Presentation Layer
    participant VM as LabelViewModel
    participant Repo as LabelRepository
    participant Service as LocalStorageService
    participant Storage as SharedPreferences

    UI->>VM: createLabel(content, qrData)
    VM->>Repo: createLabel(label)
    Repo->>Service: saveLabel(labelModel)
    Service->>Storage: setString(key, json)
    Storage-->>Service: Save result
    Service-->>Repo: Save success
    Repo-->>VM: Label created
    VM-->>UI: Update label list

    UI->>VM: getLabels()
    VM->>Repo: getLabels()
    Repo->>Service: getLabels()
    Service->>Storage: getString(key)
    Storage-->>Service: JSON string
    Service->>Service: parse JSON to List<LabelModel>
    Service-->>Repo: List<LabelModel>
    Repo->>Repo: convertToDomainEntities()
    Repo-->>VM: List<Label>
    VM-->>UI: Update label list

    UI->>VM: updateLabel(label)
    VM->>Repo: updateLabel(label)
    Repo->>Service: updateLabel(labelModel)
    Service->>Storage: setString(key, json)
    Storage-->>Service: Update result
    Service-->>Repo: Update success
    Repo-->>VM: Label updated
    VM-->>UI: Update label list

    UI->>VM: deleteLabel(labelId)
    VM->>Repo: deleteLabel(labelId)
    Repo->>Service: deleteLabel(labelId)
    Service->>Storage: remove(key)
    Storage-->>Service: Delete result
    Service-->>Repo: Delete success
    Repo-->>VM: Label deleted
    VM-->>UI: Update label list
```

## ⚙️ Settings Management Flow

```mermaid
sequenceDiagram
    participant UI as Presentation Layer
    participant VM as SettingsViewModel
    participant Repo as SettingsRepository
    participant Service as LocalStorageService
    participant Storage as SharedPreferences

    UI->>VM: loadSettings()
    VM->>Repo: getSettings()
    Repo->>Service: getSettings()
    Service->>Storage: getString('printer_settings')
    Storage-->>Service: JSON string or null
    
    alt Settings Exist
        Service->>Service: parse JSON to PrinterSettingsModel
        Service-->>Repo: PrinterSettingsModel
        Repo->>Repo: convertToDomainEntity()
        Repo-->>VM: PrinterSettings
        VM-->>UI: Update settings form
    else No Settings
        Service-->>Repo: null
        Repo->>Repo: createDefaultSettings()
        Repo-->>VM: Default PrinterSettings
        VM-->>UI: Show default settings
    end

    UI->>VM: updateSettings(settings)
    VM->>Repo: updateSettings(settings)
    Repo->>Service: updateSettings(settingsModel)
    Service->>Storage: setString('printer_settings', json)
    Storage-->>Service: Save result
    Service-->>Repo: Save success
    Repo-->>VM: Settings updated
    VM-->>UI: Confirm settings saved
```

## 🚨 Error Handling Flow

```mermaid
sequenceDiagram
    participant UI as Presentation Layer
    participant VM as ViewModel
    participant Repo as Repository
    participant Service as Service Layer
    participant External as External Service

    UI->>VM: performAction()
    VM->>Repo: executeAction()
    Repo->>Service: performOperation()
    Service->>External: callExternalService()
    
    alt Success
        External-->>Service: Success result
        Service-->>Repo: Success
        Repo-->>VM: Success
        VM-->>UI: Update UI with success
    else Error Occurs
        External-->>Service: Error
        Service->>Service: logError(error)
        Service-->>Repo: Exception
        Repo->>Repo: handleError(error)
        Repo-->>VM: Error result
        VM->>VM: setErrorState(error)
        VM-->>UI: Show error message
    end
```

## 🔄 State Management Flow

```mermaid
sequenceDiagram
    participant UI as Widget
    participant VM as ViewModel
    participant Repo as Repository
    participant Service as Service

    UI->>UI: User interaction
    UI->>VM: updateState()
    VM->>VM: setState(newState)
    VM->>VM: notifyListeners()
    VM-->>UI: Rebuild with new state
    
    UI->>VM: performAsyncAction()
    VM->>VM: setLoadingState()
    VM->>VM: notifyListeners()
    VM-->>UI: Show loading indicator
    
    VM->>Repo: asyncOperation()
    Repo->>Service: performOperation()
    Service-->>Repo: Result
    Repo-->>VM: Result
    
    VM->>VM: setSuccessState(result)
    VM->>VM: notifyListeners()
    VM-->>UI: Update with result
```

## 📊 Data Transformation Flow

```mermaid
graph TD
    A[UI Input] --> B[ViewModel]
    B --> C[Repository]
    C --> D[Service Layer]
    D --> E[External Service]
    
    E --> F[Raw Data]
    F --> G[Data Model]
    G --> H[Domain Entity]
    H --> I[ViewModel State]
    I --> J[UI Display]
    
    style A fill:#e1f5fe
    style J fill:#e1f5fe
    style G fill:#fff3e0
    style H fill:#f3e5f5
```

## 🔧 Key Design Patterns

### 1. **Repository Pattern**
- Abstracts data access logic
- Provides consistent interface for data operations
- Handles data transformation between layers

### 2. **Dependency Injection**
- Services are injected into repositories
- ViewModels receive repository dependencies
- Enables easy testing and modularity

### 3. **Observer Pattern**
- ViewModels notify UI of state changes
- UI rebuilds automatically when state updates
- Maintains loose coupling between layers

### 4. **Command Pattern**
- TSC commands encapsulate printer operations
- Commands can be queued and executed
- Provides consistent interface for printer communication

## 🎯 Benefits of This Architecture

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Business logic can be tested independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features or modify existing ones
5. **Error Handling**: Centralized error handling and recovery
6. **State Management**: Predictable state updates and UI synchronization

## 📝 Notes

- **Async Operations**: All external service calls are asynchronous
- **Error Propagation**: Errors bubble up through layers with appropriate handling
- **State Synchronization**: UI automatically updates when ViewModel state changes
- **Resource Management**: Proper cleanup of Bluetooth connections and streams
- **Logging**: Comprehensive logging at each layer for debugging 