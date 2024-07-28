import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../../models/employee.dart';
import '../../models/code.dart';

class EmployeeDao {
  static const String _employeeBoxName = 'employeeBox';
  static const String _codeBoxName = 'codeBox';

  Future<void> createEmployee(Employee employee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    print('Adding employee: ${employee.toMap()}');
    await box.add(employee); // Use add to let Hive manage the key
    print('Employee added');
  }

  Future<List<Employee>> getAllEmployees() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.toList();
  }

  Future<void> updateEmployee(int id, Employee updatedEmployee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as Employee).id == id,
      orElse: () => throw Exception('Employee not found'),
    );
    await box.put(key, updatedEmployee);
  }

  Future<void> deleteEmployee(int id) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as Employee).id == id,
      orElse: () => throw Exception('Employee not found'),
    );
    await box.delete(key);
  }

  Future<bool> authenticateUser(String email, String password) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final hashedPassword = _hashPassword(password);

    final employee = box.values.firstWhere(
      (employee) =>
          employee.email == email.toLowerCase() &&
          employee.password == hashedPassword,
      orElse: () => Employee(
          id: -1,
          companyId: '',
          name: '',
          email: '',
          password: '',
          personalPhoto: '',
          jobTitle: '',
          directorId: '',
          isAdmin: false),
    );

    return employee.id != -1;
  }

  Future<bool> emailExists(String email) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);

    try {
      final employee = box.values.firstWhere(
        (employee) => employee.email == email.toLowerCase(),
        orElse: () => Employee(
            id: -1,
            companyId: '',
            name: '',
            email: '',
            password: '',
            personalPhoto: '',
            jobTitle: '',
            directorId: '',
            isAdmin: false),
      );
      return employee.id != -1;
    } catch (e) {
      // Handle the exception if needed
      return false;
    }
  }

  Future<bool> doesDirectorExist(String directorId) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final director = box.values.firstWhere(
      (employee) => employee.id.toString() == directorId && employee.isAdmin,
      orElse: () => Employee(
        id: -1,
        companyId: '',
        name: '',
        email: '',
        password: '',
        personalPhoto: '',
        jobTitle: '',
        directorId: '',
        isAdmin: false,
      ),
    );

    return director.id != -1;
  }

  Future<List<Employee>> getAllDirectors() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.where((employee) => employee.isAdmin).toList();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> insertDummyData() async {
    // var box = await Hive.openBox<Employee>(_employeeBoxName);

    // Load the image from assets and convert it to base64
    final byteData = await rootBundle.load('assets/Apartments.PNG');
    final imageBytes = byteData.buffer.asUint8List();
    final base64Image = base64Encode(imageBytes);

    final byteData1 = await rootBundle.load('assets/Nouna.jpg');
    final imageBytes1 = byteData1.buffer.asUint8List();
    final base64Image1 = base64Encode(imageBytes1);

    final dummyEmployees = [
      Employee(
        id: 1,
        companyId: '123456',
        name: 'dina aref',
        email: 'dinaref@gmail.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image1,
        jobTitle: 'Software Engineer Intern',
        directorId: '456789',
        isAdmin: true,
      ),
      Employee(
        id: 2,
        companyId: '654321',
        name: 'Minna Hany',
        email: 'minnaabdelhady@gmail.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'Software Engineer Intern',
        directorId: '123',
        isAdmin: true,
      ),
      Employee(
        id: 3,
        companyId: '789012',
        name: 'mike johnson',
        email: 'mike@example.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'UX Designer',
        directorId: '789',
        isAdmin: false,
      ),
    ];

    for (var employee in dummyEmployees) {
      await createEmployee(employee);
    }
  }

  // Save verification code
  Future<void> saveVerificationCode(String email, String code) async {
    var box = await Hive.openBox<Code>(_codeBoxName);
    var employeeBox = await Hive.openBox<Employee>(_employeeBoxName);
    final employee = employeeBox.values.firstWhere(
      (employee) => employee.email == email.toLowerCase(),
      orElse: () => throw Exception('Employee not found'),
    );

    final verificationCode = Code(
      userId: employee.id,
      code: int.parse(code),
      timestamp: DateTime.now(),
    );

    try {
      print('Saving verification code: ${verificationCode.toMap()}');
      await box.put(employee.id, verificationCode);
      print('Verification code saved successfully');
    } catch (e) {
      print('Error saving verification code: $e');
    }
  }

  // Retrieve verification code
  Future<Code?> getVerificationCode(String email) async {
    var box = await Hive.openBox<Code>(_codeBoxName);
    var employeeBox = await Hive.openBox<Employee>(_employeeBoxName);
    final employee = employeeBox.values.firstWhere(
      (employee) => employee.email == email.toLowerCase(),
      orElse: () => throw Exception('Employee not found'),
    );
    return box.get(employee.id);
  }
}
