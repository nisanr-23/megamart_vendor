# Vendor Management System

A comprehensive system designed to manage products, orders, and vendor profiles. This project facilitates seamless updates to vendor profiles, management of product details, and tracking of order statuses and histories. The frontend is built using **Flutter**, while backend services are powered by **Firestore**. The system also supports adding notes to orders and updating order statuses via an intuitive user interface.

---

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nisanray/megamart_vendor.git
   ```

2. **Navigate to the project directory**:
   ```bash
   cd megamart_vendor
   ```

3. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

4. **Configure Firestore**:
    - Set up a Firebase project and Firestore database.
    - Download the `google-services.json` file and place it in the appropriate directory (`android/app/`).

5. **Run the project**:
   ```bash
   flutter run
   ```

---

## Usage

1. **Start the application**:
   Use the following command to run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

2. **Core Functionalities**:
    - Manage vendor profiles (create, update, delete).
    - Add, update, and delete products.
    - View and update order statuses, including adding notes to specific orders.

3. **Example API Requests** (if applicable):
    - Fetch order history:
      ```http
      GET /api/orders/{orderId}
      ```

---

## Features

- **Vendor Management**: Add, edit, and maintain vendor profiles.
- **Product Management**: Manage product details such as inventory, pricing, and categories.
- **Order Tracking**: View and update order statuses, including history logs.
- **Firestore Integration**: Real-time database updates and synchronization.
- **User-Friendly Interface**: Built with Flutter for a smooth and intuitive experience.
- **Custom Notes**: Add notes to specific orders for better tracking.

--

## Dependencies

This project relies on the following key dependencies:

- **Flutter SDK**: UI framework for building natively compiled applications.
- **Firebase Core**: Core integration for Firebase services.
- **Cloud Firestore**: Database service for real-time updates.
- **Provider**: State management for Flutter.
- Additional dependencies are listed in the `pubspec.yaml` file.

---

## Contributing

Contributions are welcome! Follow these steps to contribute:

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/manage-products
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your commit message"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/manage-products
   ```
5. Open a pull request.

Please adhere to the [contributing guidelines](CONTRIBUTING.md).

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

Maintainer: [Nisan Ray](https://github.com/nisanray)  
Feel free to reach out for questions or contributions!