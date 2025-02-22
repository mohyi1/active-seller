import 'package:active_ecommerce_seller_app/const/app_style.dart';
import 'package:active_ecommerce_seller_app/const/homepage_features.dart';
import 'package:active_ecommerce_seller_app/custom/device_info.dart';
import 'package:active_ecommerce_seller_app/custom/localization.dart';
import 'package:active_ecommerce_seller_app/custom/my_widget.dart';
import 'package:active_ecommerce_seller_app/custom/route_transaction.dart';
import 'package:active_ecommerce_seller_app/data_model/category_wise_product_response.dart';
import 'package:active_ecommerce_seller_app/data_model/top_12_product_response.dart';
import 'package:active_ecommerce_seller_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_seller_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_seller_app/helpers/shop_info_helper.dart';
import 'package:active_ecommerce_seller_app/my_theme.dart';
import 'package:active_ecommerce_seller_app/repositories/shop_repository.dart';
import 'package:active_ecommerce_seller_app/screens/packages.dart';
import 'package:active_ecommerce_seller_app/screens/payment_setting.dart';
import 'package:active_ecommerce_seller_app/screens/shop_settings/shop_settings.dart';
import 'package:active_ecommerce_seller_app/screens/verify_page.dart';
import 'package:flutter/material.dart';

import '../custom/chart2.dart';

class Home extends StatefulWidget {
  final bool fromBottombar;

  const Home({Key? key, this.fromBottombar = false}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //String variables
  // String homePageTitle = "Dashboard";

  //bool type
  bool _faceTopProducts = false;
  bool _faceCategoryWiseProducts = false;

  // double variables
  double mHeight = 0.0, mWidht = 0.0;

  //List
  List<ChartData> chartValues = [];
  List<ProductOfTop> product = [];
  List<String> logoSliders = [];
  List<CategoryWiseProductResponse> categoryWiseProducts = [];

  String? _productsCount = '...',
      _rattingCount = "...",
      _totalOrdersCount = "...",
      _totalSalesCount = '...',
      _soldOutProducts = "...",
      _lowStockProducts = "...",
      _currentPackageName = "...",
      _prodcutUploadLimit = "...",
      _pacakgeExpDate = "...";

  // Future<bool> _getTop12Product() async {
  //   var response = await ShopRepository().getTop12ProductRequest();
  //   product.addAll(response.data!);
  //   _faceTopProducts = true;
  //   setState(() {});

  //   return true;
  // }
  Future<bool> _getTop12Product() async {
    try {
      var response = await ShopRepository().getTop12ProductRequest();

      if (response.data != null) {
        product.addAll(response.data!);
        _faceTopProducts = true;
        setState(() {});
        return true;
      } else {
        // Handle case when response.data is null
        debugPrint('No data found in response.');
        return false;
      }
    } catch (e) {
      // Handle other exceptions (like network errors)
      debugPrint('Error fetching top products: $e');
      return false;
    }
  }

  Future<bool> _getCategoryWiseProduct() async {
    var response = await ShopRepository().getCategoryWiseProductRequest();
    categoryWiseProducts.addAll(response);
    _faceCategoryWiseProducts = true;
    setState(() {});
    return true;
  }

  Future<bool> _getShopInfo() async {
    var response = await ShopRepository().getShopInfo();

    _productsCount = response.shopInfo!.products.toString();
    _rattingCount = response.shopInfo!.rating.toString();
    _totalOrdersCount = response.shopInfo!.orders.toString();
    _totalSalesCount = response.shopInfo!.sales.toString();
    _pacakgeExpDate = response.shopInfo!.packageInvalidAt;
    _currentPackageName = response.shopInfo!.sellerPackage;
    _prodcutUploadLimit = response.shopInfo!.productUploadLimit.toString();
    logoSliders.addAll(response.shopInfo!.sliders!);

    ShopInfoHelper().setShopInfo();
    setState(() {});
    return true;
  }

  cleanAll() {
    _productsCount = '...';
    _rattingCount = "...";
    _totalOrdersCount = "...";
    _totalSalesCount = '...';
    _soldOutProducts = "...";
    _lowStockProducts = "...";
    _currentPackageName = "...";
    _prodcutUploadLimit = "...";
    _pacakgeExpDate = "...";
    chartValues = [];
    product = [];
    categoryWiseProducts = [];
    _faceTopProducts = false;
    _faceCategoryWiseProducts = false;
    setState(() {});
  }

  Future<void> reFresh() {
    cleanAll();
    facingAll();
    return Future.delayed(Duration(seconds: 1));
  }

  facingAll() async {
    _getTop12Product();
    _getCategoryWiseProduct();
    _getShopInfo();
  }

  @override
  void initState() {
    // TODO: implement initState
    facingAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(AppBar().preferredSize.height);
    mHeight = MediaQuery.of(context).size.height;
    mWidht = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: reFresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: dashboard(),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        top4Boxes(),
        packageContainer(),
        SizedBox(
          height: AppStyles.listItemsMargin,
        ),
        featureContainer(),
        SizedBox(
          height: AppStyles.listItemsMargin,
        ),
        if (!verify_form_submitted.$ && !shop_verify.$)
          Column(
            children: [
              verifyContainer(),
              SizedBox(
                height: AppStyles.listItemsMargin,
              ),
            ],
          ),
        settingContainer(),
        SizedBox(
          height: AppStyles.listItemsMargin,
        ),
        chartContainer(),
        SizedBox(
          height: AppStyles.listItemsMargin,
        ),
        categoryWiseProduct(),
        Container(
          height: AppStyles.listItemsMargin,
        ),
        topProductsContainer(),
        SizedBox(
          height: AppStyles.listItemsMargin,
        ),
      ],
    ));
  }

  Widget buildTopProductsShimmer() {
    return Container(
      height: DeviceInfo(context).getHeight(),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(
                  bottom: 15, top: index == product.length - 1 ? 15 : 0),
              child: MyWidget.customCardView(
                elevation: 5,
                height: 112,
                width: DeviceInfo(context).getWidth(),
                borderRadius: 10.0,
                borderColor: MyTheme.light_grey,
                child: ShimmerHelper().buildBasicShimmer(
                    height: 112.0, width: DeviceInfo(context).getWidth()),
              ),
            );
          }),
    );
  }

  // Container topProductsContainer() {
  //   return Container(
  //       padding: const EdgeInsets.only(left: 15.0, right: 15),
  //       alignment: Alignment.topLeft,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Container(
  //             height: 17,
  //             child: Text(
  //               LangText(context: context).getLocal()!.top_products_ucf,
  //               style: TextStyle(
  //                   fontSize: 14,
  //                   color: MyTheme.app_accent_color,
  //                   fontWeight: FontWeight.bold),
  //             ),
  //           ),
  //           SizedBox(
  //             height: AppStyles.itemMargin,
  //           ),
  //           _faceTopProducts
  //               ? product.length == 0
  //                   ? Container(
  //                       alignment: Alignment.center,
  //                       height: 205,
  //                       padding: const EdgeInsets.only(left: 15.0),
  //                       child: Text(
  //                         LangText(context: context)
  //                             .getLocal()!
  //                             .no_data_is_available,
  //                         style: TextStyle(
  //                             fontSize: 14,
  //                             color: MyTheme.app_accent_color,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                     )
  //                   : ListView.builder(
  //                       physics: const NeverScrollableScrollPhysics(),
  //                       shrinkWrap: true,
  //                       itemCount: product.length,
  //                       itemBuilder: (context, index) {
  //                         return buildTopProductItem(index);
  //                       },
  //                     )
  //               : buildTopProductsShimmer(),
  //         ],
  //       ));
  // }

  Container topProductsContainer() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title
          Container(
            height: 17,
            child: Text(
              LangText(context: context).getLocal()!.top_products_ucf,
              style: TextStyle(
                fontSize: 14,
                color: MyTheme.app_accent_color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppStyles.itemMargin),
          // Main content
          _faceTopProducts
              ? product.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      height: 205,
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        LangText(context: context)
                            .getLocal()!
                            .no_data_is_available,
                        style: TextStyle(
                          fontSize: 14,
                          color: MyTheme.app_accent_color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: product.length,
                      itemBuilder: (context, index) {
                        return buildTopProductItem(index);
                      },
                    )
              : buildTopProductsShimmer(),
        ],
      ),
    );
  }

  Widget buildTopProductItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: MyWidget.customCardView(
        backgroundColor: MyTheme.white,
        elevation: 5,
        height: 112,
        width: DeviceInfo(context).getWidth(),
        borderRadius: 10.0,
        borderColor: MyTheme.light_grey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyWidget.imageWithPlaceholder(
              url: product[index].thumbnailImg,
              width: 112.0,
              height: 112.0,
              radius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    product[index].name!,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12, color: MyTheme.font_grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    product[index].category!,
                    style: TextStyle(
                      fontSize: 10,
                      color: MyTheme.grey_153,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    product[index].price!,
                    style: TextStyle(
                      fontSize: 12,
                      color: MyTheme.app_accent_color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesShimmer() {
    return Container(
      height: 112,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return ShimmerHelper()
                .buildBasicShimmer(height: 112.0, width: 89.0);
          }),
    );
  }

  Widget categoryWiseProductShimmer() {
    return Column(
      children: [
        ShimmerHelper().buildBasicShimmer(height: 20),
        SizedBox(
          height: 5,
        ),
        ShimmerHelper().buildBasicShimmer(height: 20),
        SizedBox(
          height: 5,
        ),
        ShimmerHelper().buildBasicShimmer(height: 20),
        SizedBox(
          height: 5,
        ),
        ShimmerHelper().buildBasicShimmer(height: 20),
      ],
    );
  }

  Container categoryWiseProduct() {
    return MyWidget.customContainer(
        alignment: Alignment.topLeft,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 17,
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                LangText(context: context).getLocal()!.your_categories_ucf +
                    " (${categoryWiseProducts.length})",
                style: TextStyle(
                    fontSize: 14,
                    color: MyTheme.app_accent_color,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            _faceCategoryWiseProducts
                ? product.length == 0
                    ? Container(
                        alignment: Alignment.center,
                        height: 112,
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          LangText(context: context)
                              .getLocal()!
                              .no_data_is_available,
                          style: TextStyle(
                              fontSize: 14,
                              color: MyTheme.app_accent_color,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(
                        height: 112,
                        child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppStyles.itemMargin),
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: AppStyles.itemMargin,
                              );
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryWiseProducts.length,
                            itemBuilder: (context, index) {
                              return buildCategoryItem(index);
                            }),
                      )
                : buildCategoriesShimmer(),
          ],
        ));
  }

  Widget buildCategoryItem(int index) {
    return MyWidget.customCardView(
        backgroundColor: MyTheme.noColor,
        elevation: 5,
        blurSize: 20,
        height: 112,
        width: 89,
        // borderRadius: 12.0,
        shadowColor: MyTheme.app_accent_shado,
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: MyWidget.imageWithPlaceholder(
                  url: categoryWiseProducts[index].banner,
                  width: 89.0,
                  height: 112.0,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(12),
                ),
              ),
              Container(
                height: 112,
                width: 89,
                decoration: BoxDecoration(
                    color: MyTheme.app_accent_tranparent,
                    borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        categoryWiseProducts[index].name!,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: 10,
                            color: MyTheme.white,
                            fontWeight: FontWeight.normal),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    Text(
                      "(" +
                          categoryWiseProducts[index].cntProduct.toString() +
                          ")",
                      style: TextStyle(
                          fontSize: 10,
                          color: MyTheme.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget chartShimmer() {
    return Container(
      height: 130,
      width: DeviceInfo(context).getWidth() / 1.5,
      child:
          ShimmerHelper().buildListShimmer(item_height: 20.0, item_count: 10),
    );
  }

  Widget chartContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      // padding: EdgeInsets.symmetric(vertical: 10),
      child: MyWidget.customCardView(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        elevation: 5,
        height: 190,
        shadowColor: MyTheme.app_accent_color_extra_light,
        backgroundColor: MyTheme.white,
        width: DeviceInfo(context).getWidth(),
        borderRadius: 10,
        child: Stack(
          children: [
            // Positioned(
            //   right: 5,
            //   child: Text(
            //     "20-26 Feb, 2022",
            //     style: TextStyle(
            //         fontSize: 10, color: MyTheme.app_accent_color),
            //   ),
            // ),
            Positioned(
              left: 0,
              child: Text(
                LangText(context: context).getLocal()!.sales_stat_ucf,
                style: const TextStyle(
                    fontSize: 14,
                    color: MyTheme.app_accent_color,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: SizedBox(
                  height: 190,
                  width: DeviceInfo(context).getWidth(),
                  child: const MChart()),
            ),
          ],
        ),
      ),
    );
  }

  Widget packageContainer() {
    return seller_package_addon.$
        ? Column(
            children: [
              SizedBox(
                height: AppStyles.listItemsMargin,
              ),
              MyWidget.customCardView(
                  width: DeviceInfo(context).getWidth(),
                  height: 128,
                  borderRadius: 10,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  backgroundColor: MyTheme.white,
                  elevation: 5,
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      Image.asset(
                        'assets/icon/package.png',
                        width: 64,
                        height: 64,
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                LangText(context: context)
                                    .getLocal()!
                                    .current_package_ucf,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MyTheme.app_accent_color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                _currentPackageName!,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: MyTheme.app_accent_color,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                LangText(context: context)
                                    .getLocal()!
                                    .product_upload_limit_ucf,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: MyTheme.grey_153,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                _prodcutUploadLimit! +
                                    " " +
                                    LangText(context: context)
                                        .getLocal()!
                                        .times_all_lower,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: MyTheme.grey_153,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                LangText(context: context)
                                    .getLocal()!
                                    .package_expires_at_ucf,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: MyTheme.grey_153,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                _pacakgeExpDate!,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: MyTheme.grey_153,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              MyTransaction(context: context).push(Packages());
                            },
                            child: MyWidget().myContainer(
                                bgColor: MyTheme.app_accent_color,
                                borderRadius: 6,
                                height: 36,
                                width: DeviceInfo(context).getWidth() / 2.2,
                                child: Text(
                                  LangText(context: context)
                                      .getLocal()!
                                      .upgrade_package_ucf,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: MyTheme.black,
                                      fontWeight: FontWeight.w400),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                      Spacer(),
                    ],
                  )),
            ],
          )
        : Container();
  }

  Widget settingContainer() {
    return Container(
      width: DeviceInfo(context).getWidth(),
      padding: EdgeInsets.symmetric(horizontal: AppStyles.layoutMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyWidget.customCardView(
              borderWidth: 1,
              elevation: 5,
              borderRadius: 10,
              padding: EdgeInsets.symmetric(vertical: 5),
              width: DeviceInfo(context).getWidth() / 2 - 23,
              height: DeviceInfo(context).getWidth() / 2 - 20,
              borderColor: MyTheme.app_accent_color,
              backgroundColor: MyTheme.app_accent_color_extra_light,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        LangText(context: context)
                            .getLocal()!
                            .shop_settings_ucf,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MyTheme.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        LangText(context: context)
                            .getLocal()!
                            .manage_n_organize_your_shop,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: MyTheme.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Image.asset(
                    "assets/icon/shop_setting.png",
                    color: MyTheme.black,
                    height: 32,
                    width: 32,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      MyTransaction(context: context).push(ShopSettings());
                    },
                    child: MyWidget().myContainer(
                      bgColor: MyTheme.app_accent_color,
                      child: Text(
                        LangText(context: context).getLocal()!.go_to_settings,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      width: DeviceInfo(context).getWidth() / 3,
                      height: 30,
                      borderRadius: 6,
                    ),
                  )
                ],
              )),
          SizedBox(
            width: 14,
          ),
          MyWidget.customCardView(
              elevation: 5,
              borderRadius: 10,
              borderWidth: 1,
              padding: EdgeInsets.symmetric(vertical: 5),
              width: DeviceInfo(context).getWidth() / 2 - 23,
              height: DeviceInfo(context).getWidth() / 2 - 20,
              borderColor: MyTheme.app_accent_color,
              backgroundColor: MyTheme.app_accent_color_extra_light,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        LangText(context: context)
                            .getLocal()!
                            .payment_settings_ucf,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MyTheme.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        LangText(context: context)
                            .getLocal()!
                            .configure_your_payment_method,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: MyTheme.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Image.asset(
                    "assets/icon/payment_setting.png",
                    color: MyTheme.black,
                    height: 32,
                    width: 32,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      MyTransaction(context: context).push(PaymentSetting());
                    },
                    child: MyWidget().myContainer(
                      bgColor: MyTheme.app_accent_color,
                      child: Text(
                        LangText(context: context)
                            .getLocal()!
                            .configure_now_ucf,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      width: DeviceInfo(context).getWidth() / 3,
                      height: 30,
                      borderRadius: 6,
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  Widget verifyContainer() {
    return Container(
      width: DeviceInfo(context).getWidth(),
      padding: EdgeInsets.symmetric(horizontal: AppStyles.layoutMargin),
      child: MyWidget.customCardView(
        elevation: 5,
        borderRadius: 10,
        borderWidth: 1,
        //padding:EdgeInsets.symmetric(vertical: 5),
        width: DeviceInfo(context).getWidth(),
        height: DeviceInfo(context).getWidth() / 2 - 20,
        borderColor: MyTheme.app_accent_border,
        backgroundColor: MyTheme.app_accent_color_extra_light,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  LangText(context: context)
                      .getLocal()!
                      .your_account_is_unverified,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: MyTheme.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  LangText(context: context).getLocal()!.verify_your_account,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: MyTheme.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Image.asset(
              "assets/icon/unverify.png",
              height: 32,
              width: 32,
            ),
            InkWell(
              onTap: () {
                MyTransaction(context: context)
                    .push(const VerifyPage())
                    .then((value) {
                  if (!verify_form_submitted.$!) {
                    setState(() {});
                  }
                });
              },
              child: MyWidget().myContainer(
                bgColor: MyTheme.app_accent_color,
                child: Text(
                  LangText(context: context).getLocal()!.verify_now,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
                width: DeviceInfo(context).getWidth() / 3,
                height: 30,
                borderRadius: 6,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget featureContainer() {
    return Container(
        width: DeviceInfo(context).getWidth(),
        alignment: Alignment.center,
        color: MyTheme.app_accent_color,
        //padding: EdgeInsets.symmetric(horizontal: 15.0,),
        height: 90,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 8,right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  FeaturesList(context).getFeatureList().length, (index) {
                return Container(
                  padding: EdgeInsets.only(left: 10,right: 10),
                    child: FeaturesList(context).getFeatureList()[index]);
              }),
            ),
          ),
        ));
  }

  Widget top4Boxes() {
    return Stack(
      children: [
        /* Container(
          height: 240,
          child: Column(
            children: [
              Container(
                height: 170,
                width: DeviceInfo(context).getWidth(),
                child: MyWidget.imageSlider(
                    imageUrl: logoSliders, context: context),
              ),
              Container(

                height: 70,
                width: DeviceInfo(context).getWidth(),
              ),
            ],
          ),
        ),*/
        Positioned(
          top: 0,
          child: SizedBox(
            height: 170,
            width: DeviceInfo(context).getWidth(),
            child:
                MyWidget.imageSlider(imageUrl: logoSliders, context: context),
          ),
        ),

        // this container only for transparent color
        Container(
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(255, 255, 255, 0),
                Color.fromRGBO(255, 255, 255, .15),
                Color.fromRGBO(255, 255, 255, .25),
                Color.fromRGBO(255, 255, 255, .50),
                Color.fromRGBO(255, 255, 255, .9),
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(255, 255, 255, 1),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          child: Container(
            color: Colors.transparent,
            // margin: EdgeInsets.only(top: 60),
            //color: MyTheme.red,
            //height: 190,
            width: DeviceInfo(context).getWidth(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyWidget.homePageTopBox(context,
                        elevation: 5,
                        title: LangText(context: context)
                            .getLocal()!
                            .products_ucf,
                        counter: _productsCount,
                        iconUrl: 'assets/icon/products.png'),
                    MyWidget.homePageTopBox(context,
                        title:
                            LangText(context: context).getLocal()!.rating_ucf,
                        counter: _rattingCount,
                        iconUrl: 'assets/icon/rating.png'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    MyWidget.homePageTopBox(context,
                        elevation: 5,
                        title: LangText(context: context)
                            .getLocal()!
                            .total_orders_ucf,
                        counter: _totalOrdersCount,
                        iconUrl: 'assets/icon/orders.png'),
                    MyWidget.homePageTopBox(context,
                        elevation: 5,
                        title: LangText(context: context)
                            .getLocal()!
                            .total_sales_ucf,
                        counter: _totalSalesCount,
                        iconUrl: 'assets/icon/sales.png'),
                  ],
                )
              ],
            )
        
        /*
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            primary: false,
            padding:  EdgeInsets.all(AppStyles.layoutMargin),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            crossAxisCount: 2,
            childAspectRatio:DeviceInfo(context).getHeightInPercent(),
            children: <Widget>[
              MyWidget.homePageTopBox(context,
                  elevation: 5,
                  title: LangText(context: context)
                      .getLocal()
                      .product_screen_products,
                  counter: _productsCount,
                  iconUrl: 'assets/icon/products.png'),
              MyWidget.homePageTopBox(context,
                  title:
                  LangText(context: context).getLocal().common_rating,
                  counter: _rattingCount,
                  iconUrl: 'assets/icon/rating.png'),
        
              MyWidget.homePageTopBox(context,
                  elevation: 5,
                  title: LangText(context: context)
                      .getLocal()
                      .common_total_orders,
                  counter: _totalOrdersCount,
                  iconUrl: 'assets/icon/orders.png'),
              MyWidget.homePageTopBox(context,
                  elevation: 5,
                  title: LangText(context: context)
                      .getLocal()
                      .common_total_sales,
                  counter: _totalSalesCount,
                  iconUrl: 'assets/icon/sales.png')
            ],
          ),*/
        
            ),
        ),
      ],
    );
  }
  // Widget top4Boxes() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       // Container(
  //       //   height: 240,
  //       //   child: Column(
  //       //     children: [
  //       //       Container(
  //       //         height: 170,
  //       //         width: DeviceInfo(context).getWidth(),
  //       //         child: MyWidget.imageSlider(
  //       //             imageUrl: logoSliders, context: context),
  //       //       ),
  //       //       Container(

  //       //         height: 70,
  //       //         width: DeviceInfo(context).getWidth(),
  //       //       ),
  //       //     ],
  //       //   ),
  //       // ),
  //       Positioned(
  //         top: 0,
  //         child: SizedBox(
  //           height: 170,
  //           width: DeviceInfo(context).getWidth(),
  //           child:
  //               MyWidget.imageSlider(imageUrl: logoSliders, context: context),
  //         ),
  //       ),

  //       Container(
  //         height: 240,
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topCenter,
  //             end: Alignment.bottomCenter,
  //             colors: [
  //               Color.fromRGBO(255, 255, 255, 0),
  //               Color.fromRGBO(255, 255, 255, .15),
  //               Color.fromRGBO(255, 255, 255, .25),
  //               Color.fromRGBO(255, 255, 255, .50),
  //               Color.fromRGBO(255, 255, 255, .9),
  //               Color.fromRGBO(255, 255, 255, 1),
  //               Color.fromRGBO(255, 255, 255, 1),
  //               Color.fromRGBO(255, 255, 255, 1),
  //             ],
  //           ),
  //         ),
  //       ),

  //       Container(
  //           color: Colors.transparent,
  //           // margin: EdgeInsets.only(top: 60),
  //           //color: MyTheme.red,
  //           //height: 190,
  //           width: DeviceInfo(context).getWidth(),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   MyWidget.homePageTopBox(context,
  //                       elevation: 5,
  //                       title: LangText(context: context)
  //                           .getLocal()!
  //                           .products_ucf,
  //                       counter: _productsCount,
  //                       iconUrl: 'assets/icon/products.png'),
  //                   MyWidget.homePageTopBox(context,
  //                       title:
  //                           LangText(context: context).getLocal()!.rating_ucf,
  //                       counter: _rattingCount,
  //                       iconUrl: 'assets/icon/rating.png'),
  //                 ],
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,

  //                 children: [
  //                   MyWidget.homePageTopBox(context,
  //                       elevation: 5,
  //                       title: LangText(context: context)
  //                           .getLocal()!
  //                           .total_orders_ucf,
  //                       counter: _totalOrdersCount,
  //                       iconUrl: 'assets/icon/orders.png'),
  //                   MyWidget.homePageTopBox(context,
  //                       elevation: 5,
  //                       title: LangText(context: context)
  //                           .getLocal()!
  //                           .total_sales_ucf,
  //                       counter: _totalSalesCount,
  //                       iconUrl: 'assets/icon/sales.png'),
  //                 ],
  //               )
  //             ],
  //           )
        
  //       /*
  //         GridView.count(
  //           physics: NeverScrollableScrollPhysics(),
  //           primary: false,
  //           padding:  EdgeInsets.all(AppStyles.layoutMargin),
  //           crossAxisSpacing: 14,
  //           mainAxisSpacing: 14,
  //           crossAxisCount: 2,
  //           childAspectRatio:DeviceInfo(context).getHeightInPercent(),
  //           children: <Widget>[
  //             MyWidget.homePageTopBox(context,
  //                 elevation: 5,
  //                 title: LangText(context: context)
  //                     .getLocal()
  //                     .product_screen_products,
  //                 counter: _productsCount,
  //                 iconUrl: 'assets/icon/products.png'),
  //             MyWidget.homePageTopBox(context,
  //                 title:
  //                 LangText(context: context).getLocal().common_rating,
  //                 counter: _rattingCount,
  //                 iconUrl: 'assets/icon/rating.png'),
        
  //             MyWidget.homePageTopBox(context,
  //                 elevation: 5,
  //                 title: LangText(context: context)
  //                     .getLocal()
  //                     .common_total_orders,
  //                 counter: _totalOrdersCount,
  //                 iconUrl: 'assets/icon/orders.png'),
  //             MyWidget.homePageTopBox(context,
  //                 elevation: 5,
  //                 title: LangText(context: context)
  //                     .getLocal()
  //                     .common_total_sales,
  //                 counter: _totalSalesCount,
  //                 iconUrl: 'assets/icon/sales.png')
  //           ],
  //         ),*/
        
  //           ),
  //     ],
  //   );
  // }
}

class ChartData {
  int salesValue;
  String date;

  ChartData(this.date, this.salesValue);
}
