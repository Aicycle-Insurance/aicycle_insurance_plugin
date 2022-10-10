import '../../src/common/dialog/notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../src/common/dialog/process_dialog.dart';
import '../../types/damage_summary_result.dart';
import '../../src/constants/colors.dart';
import '../../src/constants/strings.dart';
import '../../aicycle_insurance.dart';
import '../../gen/assets.gen.dart';
// import '../../src/common/snack_bar/snack_bar.dart';
import '../../src/constants/endpoints.dart';
import '../../src/damage_result_page/widgets/_bottom_bar.dart';
import '../../src/modules/module_types/common_response.dart';
import '../../src/modules/resful_module.dart';
import '../../src/modules/resful_module_impl.dart';
import '../../src/damage_result_page/widgets/damage_result_card.dart';

class DamageResultPage extends StatefulWidget {
  DamageResultPage({
    Key key,
    this.damage,
    this.token,
    this.sessionId,
    this.onError,
    this.disableSaveButton,
  }) : super(key: key);

  final PTIDamageSumary damage;
  final String token;
  final String sessionId;
  final Function(String) onError;
  final bool disableSaveButton;
  @override
  _DamageResultPageState createState() => _DamageResultPageState();
}

class _DamageResultPageState extends State<DamageResultPage> {
  final double _toolbarHeight = 64.0;
  var _disableSaveButton = true.obs;
  var reloadWhenBack = false;

  @override
  void initState() {
    super.initState();
    _disableSaveButton.value = widget.disableSaveButton;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => willPop(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          // elevation: 0.5,
          shadowColor: DefaultColors.shadowColor,
          toolbarHeight: _toolbarHeight,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: DefaultColors.iconColor),
          title: Text(
            StringKeys.damageResult,
            style: const TextStyle(
                color: DefaultColors.ink500,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: widget.damage.results == null || widget.damage.results.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.emptyFolder
                        .image(height: 180, package: packageName),
                    const SizedBox(height: 16),
                    Text(
                      StringKeys.noDamage,
                      style: const TextStyle(
                          color: DefaultColors.ink400,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    // style: t14M.copyWith(color: AppColors.ink[400]),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ...widget.damage.results.map((damageResult) {
                      if (damageResult.damages.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DamageResultCard(damageResult: damageResult),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }).toList(),
                    const SizedBox(height: 24)
                  ],
                ),
              ),
        bottomNavigationBar: Obx(
          () => DamageResultBottomBar(
            totalCost: widget.damage.sumaryPrice.toDouble() ?? 0,
            onAddMoreImage: () => Navigator.pop(context, reloadWhenBack),
            onSubmited: _sendDamageAssessmentResultToPTI,
            onChecked: () => checkIsSentData(context),
            disableSaveButton: _disableSaveButton.value,
          ),
        ),
      ),
    );
  }

  Future<void> _sendDamageAssessmentResultToPTI() async {
    RestfulModule restfulModule = RestfulModuleImpl();
    ProgressDialog.showWithCircleIndicator(context);
    try {
      CommonResponse response = await restfulModule.post(
        Endpoints.sendDamageAssessmentResultToPTI(widget.sessionId),
        {},
        token: widget.token,
      );
      ProgressDialog.hide(context);
      if (response.statusCode == 200 && response.body != null) {
        _disableSaveButton(false);
        reloadWhenBack = true;
        NotificationDialog.show(
          context,
          type: NotiType.success,
          content: StringKeys.saveSuccessfuly,
          confirmCallBack: () {},
        );
      } else {
        _disableSaveButton(true);
        if (widget.onError != null) {
          widget.onError('Package error: http code ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      _disableSaveButton(true);
      if (widget.onError != null) {
        widget.onError('Package error: $e');
      }
      rethrow;
    }
  }

  void checkIsSentData(BuildContext context) async {
    RestfulModule restfulModule = RestfulModuleImpl();
    ProgressDialog.showWithCircleIndicator(context);
    try {
      CommonResponse response = await restfulModule.get(
        Endpoints.checkDamageAssessmentSubmited(widget.sessionId),
        token: widget.token,
      );
      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['isSendData'] == true) {
        ProgressDialog.hide(context);

        /// Cho phép lưu/gửi kết quả sang PTI
        _disableSaveButton(false);
        NotificationDialog.show(
          context,
          type: NotiType.success,
          content: StringKeys.availableToSave,
          confirmCallBack: () {},
        );
      } else {
        ProgressDialog.hide(context);

        /// ko cho phép lưu
        _disableSaveButton(true);
        NotificationDialog.show(
          context,
          type: NotiType.warning,
          content: StringKeys.claimIsProcessing,
          confirmCallBack: () {},
        );
        return null;
      }
    } catch (e) {
      _disableSaveButton(true);
      if (widget.onError != null) {
        widget.onError('Package error: $e');
      }
      rethrow;
    }
  }

  Future<bool> willPop() async {
    Navigator.pop(context, reloadWhenBack);
    return false;
  }
}
