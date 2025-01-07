// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 3;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      statusCode: fields[0] as int?,
      status: fields[1] as bool?,
      message: fields[2] as String?,
      data: (fields[3] as List?)?.cast<CategoryData>(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.statusCode)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryDataAdapter extends TypeAdapter<CategoryData> {
  @override
  final int typeId = 4;

  @override
  CategoryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryData(
      categoryName: fields[0] as String?,
      id: fields[1] as String?,
      subCategoryItem: (fields[2] as List?)?.cast<SubCategoryItem>(),
      categoryTax: (fields[4] as List?)?.cast<CategoryTax>(),
    )..isExpand = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, CategoryData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.categoryName)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.subCategoryItem)
      ..writeByte(3)
      ..write(obj.isExpand)
      ..writeByte(4)
      ..write(obj.categoryTax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubCategoryItemAdapter extends TypeAdapter<SubCategoryItem> {
  @override
  final int typeId = 5;

  @override
  SubCategoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubCategoryItem(
      subCategory: fields[0] as String?,
      id: fields[1] as String?,
    )..isEdit = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, SubCategoryItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.subCategory)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.isEdit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubCategoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryTaxAdapter extends TypeAdapter<CategoryTax> {
  @override
  final int typeId = 6;

  @override
  CategoryTax read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryTax(
      taxId: fields[0] as int?,
      taxName: fields[1] as String?,
      tax: fields[2] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryTax obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.taxId)
      ..writeByte(1)
      ..write(obj.taxName)
      ..writeByte(2)
      ..write(obj.tax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTaxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
