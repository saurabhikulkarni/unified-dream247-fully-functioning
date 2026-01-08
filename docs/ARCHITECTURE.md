# Clean Architecture in Unified Dream247

This document explains the Clean Architecture implementation in this project.

## Overview

Clean Architecture separates the codebase into layers with clear boundaries and dependencies flowing inward.

```
Presentation -> Domain <- Data
     ↓           ↓        ↓
    UI      Business   External
  (BLoC)     Logic     (API/DB)
```

## Layers

### 1. Domain Layer (Business Logic)

**Location**: `lib/features/*/domain/`

The innermost layer containing business logic and rules. It has no dependencies on outer layers.

#### Components:

- **Entities**: Pure business objects
- **Repository Interfaces**: Contracts for data operations
- **Use Cases**: Single business operations

### 2. Data Layer (Data Management)

**Location**: `lib/features/*/data/`

Handles data from external sources (APIs, databases, cache).

#### Components:

- **Models**: Data transfer objects with serialization
- **Data Sources**: API/database implementations
- **Repository Implementations**: Concrete implementations

### 3. Presentation Layer (UI)

**Location**: `lib/features/*/presentation/`

Handles UI and user interactions using BLoC pattern.

#### Components:

- **Pages**: Full screen widgets
- **Widgets**: Reusable UI components
- **BLoC**: Business Logic Component for state management

## Data Flow

1. User Interaction → UI Event
2. UI → BLoC Event
3. BLoC → Use Case
4. Use Case → Repository
5. Repository → Data Source
6. Data Source → API
7. Response flows back
8. BLoC emits state
9. UI rebuilds

## Benefits

1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Clear separation of concerns
3. **Scalability**: Easy to add new features
4. **Flexibility**: Can swap implementations
5. **Independence**: Business logic independent of frameworks

## Adding a New Feature

1. Create domain layer (entity, repository, use cases)
2. Create data layer (model, data sources, repository impl)
3. Create presentation layer (BLoC, pages, widgets)
4. Register dependencies in DI container
