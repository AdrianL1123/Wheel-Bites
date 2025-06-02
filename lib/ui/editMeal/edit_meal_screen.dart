import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_repo.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/storage_service.dart';
import 'package:flutter_spin_to_eat/utils/show_toast.dart';
import 'package:go_router/go_router.dart';

class EditMealScreen extends StatefulWidget {
  const EditMealScreen({super.key, required this.id});
  final String id;

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final repo = MealRepo();
  final storageService = StorageService();
  final _mealNameController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceEstimateController = TextEditingController();

  late Meal? meals;
  String? _tagsError;
  String? _mealNameError;
  String? _restaurantNameError;
  String? fileName;
  Uint8List? bytes;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _loadMealData();
  }

  void _loadMealData() async {
    final fetchedMeal = await repo.getUserMealsById(int.parse(widget.id));
    final imageBytes = await storageService.getImage(fetchedMeal.img);

    setState(() {
      meals = fetchedMeal;
      _mealNameController.text = meals!.mealName;
      _restaurantNameController.text = meals!.restaurantName;
      _tagsController.text = meals!.tags.join(', ');
      _notesController.text = meals!.notes;
      _priceEstimateController.text = meals!.priceEstimate?.toString() ?? '';
      _isPublic = meals!.isPublic;
      // load image
      bytes = imageBytes;
      fileName = meals!.img;
    });
  }

  void _editMeal() async {
    if (_mealNameController.text.isEmpty) {
      setState(() {
        _mealNameError = "Meal cannot be empty";
      });
      return;
    }

    if (_restaurantNameController.text.isEmpty) {
      setState(() {
        _restaurantNameError = "Restaurant cannot be empty";
      });
      return;
    }

    if (fileName != null && bytes != null) {
      await storageService.uploadImage(fileName!, bytes!);
    }
    await repo.editMeal(
      meals!.copy(
        mealName: _mealNameController.text,
        restaurantName: _restaurantNameController.text,
        notes: _notesController.text,
        priceEstimate: double.tryParse(_priceEstimateController.text),
        tags:
            _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
        isPublic: _isPublic,
        img: fileName ?? '',
      ),
    );
    if (mounted) {
      context.pushReplacementNamed(Screen.home.name);
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          ShowToast.success("Successfully edited meal !", context);
        }
      });
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      bytes = await file.readAsBytes();
      setState(() {
        fileName = result.files.single.name;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Meal",
          style: TextStyle(
            color: Color(0xFFff6b6b),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /** Picture upload field */
              GestureDetector(
                onTap: _pickFile,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Color(0xFFf2f2f2),
                    child:
                        bytes != null
                            // ClipRRect is used to clip (or crop) its child widget using a rounded
                            // rectangle shape—like giving the child rounded corners.
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.memory(
                                bytes!,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            )
                            : Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFdddddd)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              width: double.infinity,
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_rounded,
                                    size: 32.0,
                                    color: Color(0xFF888888),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Tap to add photo",
                                    style: TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Meal Name & Restaurant Name Fields
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: customTextField(
                          controller: _mealNameController,
                          errorText: _mealNameError,
                          label: "Meal Name",
                          hintText: "What did you eat?",
                          maxLines: 1,
                          textInputType: null,
                        ),
                      ),
                      //SizedBox(width: 12),
                      Expanded(
                        child: customTextField(
                          controller: _restaurantNameController,
                          errorText: _restaurantNameError,
                          label: "Restaurant",
                          hintText: "Where?",
                          maxLines: 1,
                          textInputType: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Location Field
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      customTextField(
                        controller: _tagsController,
                        errorText: _tagsError,
                        label: "Tags",
                        hintText: "Separate by commas eg. spicy, bussin",
                        maxLines: 1,
                        textInputType: null,
                      ),
                      SizedBox(height: 12),
                      // Price Estimate Field
                      customTextField(
                        controller: _priceEstimateController,
                        errorText: null,
                        label: "Price Estimate",
                        hintText: "Price Estimate",
                        maxLines: 1,
                        textInputType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      // Notes Field
                      customTextField(
                        controller: _notesController,
                        errorText: null,
                        label: "Notes",
                        hintText: "Share your thoughts...",
                        maxLines: 2,
                        textInputType: null,
                      ),
                      // Public Switch
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Switch(
                              value: _isPublic,
                              activeColor: Color(0xFFff6b6b),
                              onChanged: (val) {
                                setState(() {
                                  _isPublic = !_isPublic;
                                });
                              },
                            ),
                            Flex(
                              direction: Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Public",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "Others can see this meal",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Public Switch END
                      SizedBox(height: 12.0),
                      // submit
                      SizedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFff6b6b),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: _editMeal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Edit Meal",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget customTextField({
  required TextEditingController controller,
  String? errorText,
  required String label,
  required String hintText,
  int maxLines = 1,
  TextInputType? textInputType,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16, right: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: textInputType,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
