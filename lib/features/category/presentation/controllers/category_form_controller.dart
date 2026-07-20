import 'package:flutter/material.dart';
import 'package:dio_complete/features/category/domain/entities/category.dart';


class CategoryFormController {
  CategoryFormController({Category? initial}) : isEditing = initial != null {
    if (initial != null) {
      nameController.text = initial.name;
    }
  }

  final bool isEditing;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();


  String? submit() {
    if (!formKey.currentState!.validate()) return null;
    return nameController.text.trim();
  }
}
