
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_widget/product_middel_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_widget/product_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductScreenNew extends StatefulWidget {
   ProductScreenNew() ;

  @override
  _ProductScreenNewState createState() => _ProductScreenNewState();
}

class _ProductScreenNewState extends State<ProductScreenNew> {




  ProductsController productsController = Get.put(ProductsController());

  List<Vehicle> vehicles = [
    Vehicle(
      'Aaaa',
      ['Aaa', 'Aaa1'],

    ),
    Vehicle(
      'Apple',
      ['Grren Apple'],

    ),

    Vehicle(
      'Cloths',
      ['Ladies','Gents'],

    ),
    Vehicle(
      'Aaaa',
      ['Aaa', 'Aaa1'],

    ),
    Vehicle(
      'Apple',
      ['Grren Apple'],

    ),

    Vehicle(
      'Cloths',
      ['Ladies','Gents'],

    ),
    Vehicle(
      'Aaaa',
      ['Aaa', 'Aaa1'],

    ),
    Vehicle(
      'Apple',
      ['Grren Apple'],

    ),

    Vehicle(
      'Cloths',
      ['Ladies','Gents'],

    ),

  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        
        children: [
          
          Padding(padding: EdgeInsets.all((MediaQuery.of(context).orientation ==
              Orientation.portrait)
              ? (ResponsiveInfo.isMobileDimension(context)
              ?   5
              : 8)
              : (ResponsiveInfo.isMobileDimension(context)
              ? 10
              : 12)) ,
          
            child: Row(
              
              children: [
                
                Expanded(child:     ProductTopWidget(productsController: productsController),flex: 1,)
                
                
              ],
            ),
          
          
          ),

          Padding(padding: EdgeInsets.all((MediaQuery.of(context).orientation ==
              Orientation.portrait)
              ? (ResponsiveInfo.isMobileDimension(context)
              ?   5
              : 8)
              : (ResponsiveInfo.isMobileDimension(context)
              ? 10
              : 12)) ,


          child: ProductMiddelWidget(
            productsController: productsController,
          )

          )
          
          
          
        ],
      ),
      

    );
  }


  _buildExpandableContent(Vehicle vehicle) {
    List<Widget> columnContent = [];

    for (String content in vehicle.contents)
      columnContent.add(
        ListTile(
          title: Text(content, style: TextStyle(fontSize: (MediaQuery.of(
              context)
              .orientation ==
              Orientation
                  .portrait)
              ? (ResponsiveInfo
              .isMobileDimension(
              context)
              ? 5
              : 8)
              : (ResponsiveInfo
              .isMobileDimension(
              context)
              ? 10
              : 12),color: Colors.black87),),

        ),
      );

    return columnContent;
  }
}


class Vehicle {
  final String title;
  List<String> contents = [];


  Vehicle(this.title, this.contents);
}


