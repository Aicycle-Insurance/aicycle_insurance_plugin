import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../constants/strings.dart';
import 'bottom_action_bar/bottom_action_bar.dart';
import 'camera_argument.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameraArgument}) : super(key: key);

  final CameraArgument cameraArgument;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  final double toolbarHeight = 80.0;

  var currentTabIndex = 0.obs;

  late Rx<CameraArgument> _currentArg;
  late TabController _tabController;
  late Rx<XFile?> previewFile;

  @override
  void initState() {
    super.initState();
    _currentArg = Rx<CameraArgument>(widget.cameraArgument);
    _tabController = TabController(length: 3, vsync: this);
    previewFile = Rx<XFile?>(null);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.black,
            leadingWidth: 0,
            toolbarHeight: toolbarHeight,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  // minSize: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        StringKeys.close.toUpperCase(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  onPressed: _onWillPop,
                ),
                Center(
                  child: Obx(
                    () => Text(
                      _currentArg.value.partDirection.partDirectionName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DefaultColors.ink100,
                      border: Border.all(width: 1, color: DefaultColors.ink100),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      CupertinoIcons.photo_on_rectangle,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {},
                )
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) {
                // if (index == 2 &&
                //     controller.listCarPartFromMiddleView.isEmpty) {
                //   Snackbar.show(
                //     type: SnackbarType.warning,
                //     message: LocalizationKeys.closeUpViewWarning.tr,
                //   );
                //   controller.changeTab(1);
                // } else if (controller.previewFile.value != null) {
                //   controller.wantToEdit.value = false;
                //   controller.onDrawingMode.value = false;
                //   controller.autoSwitchTab(
                //     controller.previewFile.value!,
                //     index: index,
                //   );
                // } else {
                //   controller.changeTab(index);
                // }
              },
              tabs: const <Widget>[
                Tab(
                  text: StringKeys.overViewShot,
                ),
                Tab(
                  text: StringKeys.middleViewShot,
                ),
                Tab(
                  text: StringKeys.closeUpViewShot,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              const Expanded(child: SizedBox()),
              BottomActionBar(
                currentArg: _currentArg,
                currentTabIndex: currentTabIndex,
                previewFile: previewFile,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Get.back(result: _currentArg.value);
    Navigator.pop<CameraArgument>(context, _currentArg.value);
    return false;
  }
}
