import 'package:mysql1/mysql1.dart';
import 'dart:io';

// MySQL database settings
final String host = 'localhost';
final int port = 3306;
final String user = 'root';
final String password = ''; // Add your MySQL root password here
final String db = 'finalism';

// A class to represent menu items
class MenuItem {
  int id;
  String food;
  int foodPrice;
  String beverage;
  int beveragePrice;

  MenuItem(this.id, this.food, this.foodPrice, this.beverage, this.beveragePrice);
}

// Function to check if a string is numeric (optional but useful for validation)
bool isNumeric(String s) {
  return int.tryParse(s) != null;
}

// Function to retrieve the menu from the database
Future<List<MenuItem>> getMenu() async {
  // Create a connection to the MySQL database
  var settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    
    db: "finalism",
  );

  var conn = await MySqlConnection.connect(settings);

  // Fetch the menu data from the 'menu' table
  var results = await conn.query('SELECT * FROM menu');

  List<MenuItem> menu = [];

  // Display the menu and store the items in a list
  print('+----+--------------+---------+--------------+---------+');
  print('| NO |     FOOD     | PRICE_1 |   BEVERAGES   | PRICE_2 |');
  print('+----+--------------+---------+--------------+---------+');


  for (var row in results) {
    try {
      // Parse price values as integers
      int foodPrice = int.parse(row[2].toString());
      int beveragePrice = int.parse(row[4].toString());

      // Print the menu item
      print('| ${row[0].toString().padRight(2)} | ${row[1].toString().padRight(12)} | ${foodPrice.toString().padLeft(7)} | ${row[3].toString().padRight(12)} | ${beveragePrice.toString().padLeft(7)} |');

      // Add the item to the menu list
      menu.add(MenuItem(row[0], row[1], foodPrice, row[3], beveragePrice));

    } catch (e) {
      print('Error parsing prices: ${e.toString()}');
    }
  }

  print('+----+--------------+---------+--------------+---------+');

  // Close the connection
  await conn.close();

  return menu;
}

// Function to allow the customer to place an order
void takeOrder(List<MenuItem> menu) {
  List<MenuItem> foodOrder = [];
  List<MenuItem> beverageOrder = [];

  // Give the user options to select food, beverage, or exit
  print('\nSelect an option:');
  print('1 - Select food');
  print('2 - Select beverage');
  print('0 - Exit');

  // Get the user's choice
  int choice = int.parse(stdin.readLineSync()!);

  // Exit if user selects 0
  if (choice == 0) {
    print('Exiting the order process.');
    return; // End the program
  }

  // Handle food selection
  if (choice == 1) {
    print('\nEnter the number of the food you want to order:');
    int foodChoice = int.parse(stdin.readLineSync()!);

    // Find the selected food item by ID
    MenuItem? selectedFood = menu.firstWhere(
        (item) => item.id == foodChoice, orElse: () => MenuItem(0, '', 0, '', 0));

    if (selectedFood.id == 0) {
      print('Invalid choice. Order not placed.');
    } else {
      foodOrder.add(selectedFood);
      print('You selected: ${selectedFood.food} for ${selectedFood.foodPrice} TZS');
    }
  }

  // Handle beverage selection
  else if (choice == 2) {
    print('\nEnter the number of the beverage you want to order:');
    int beverageChoice = int.parse(stdin.readLineSync()!);

    // Find the selected beverage item by ID
    MenuItem? selectedBeverage = menu.firstWhere(
        (item) => item.id == beverageChoice, orElse: () => MenuItem(0, '', 0, '', 0));

    if (selectedBeverage.id == 0) {
      print('Invalid choice. Order not placed.');
    } else {
      beverageOrder.add(selectedBeverage);
      print('You selected: ${selectedBeverage.beverage} for ${selectedBeverage.beveragePrice} TZS');
    }
  } else {
    print('Invalid option. Please select 1, 2, or 0.');
    return; // End the program
  }

  // Display the order summary
  printOrderSummary(foodOrder, beverageOrder);
}

// Function to print the order summary
void printOrderSummary(List<MenuItem> foodOrder, List<MenuItem> beverageOrder) {
  // Display the food order summary
  if (foodOrder.isNotEmpty) {
    print('\nYour food order summary:');
    print('+----+--------------+---------+');
    print('| NO |     FOOD     |  PRICE  |');
    print('+----+--------------+---------+');
    int totalFoodPrice = 0;
    for (var item in foodOrder) {
      print('| ${item.id.toString().padRight(2)} | ${item.food.padRight(12)} | ${item.foodPrice.toString().padLeft(7)} |');
      totalFoodPrice += item.foodPrice;
    }
    print('+----+--------------+---------+');
    print('Total food price: $totalFoodPrice TZS');
  }

  // Display the beverage order summary
  if (beverageOrder.isNotEmpty) {
    print('\nYour beverage order summary:');
    print('+----+--------------+---------+');
    print('| NO |   BEVERAGES   |  PRICE  |');
    print('+----+--------------+---------+');
    int totalBeveragePrice = 0;
    for (var item in beverageOrder) {
      print('| ${item.id.toString().padRight(2)} | ${item.beverage.padRight(12)} | ${item.beveragePrice.toString().padLeft(7)} |');
      totalBeveragePrice += item.beveragePrice;
    }
    print('+----+--------------+---------+');
    print('Total beverage price: $totalBeveragePrice TZS');
  }

  // Display total amount to pay
  int totalPrice = foodOrder.fold(0, (sum, item) => sum + item.foodPrice) +
  beverageOrder.fold(0, (sum, item) => sum + item.beveragePrice);
  print('\nTotal amount to pay: $totalPrice TZS');
}



// Main function to run the program
void main() async {
  print('HERE IS OUR HOTEL MENU...\n');
  List<MenuItem> menu = await getMenu();
  takeOrder(menu);
}
