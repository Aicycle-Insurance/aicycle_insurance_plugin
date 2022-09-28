import '../../src/common/dialog/notification_dialog.dart';
import 'package:flutter/material.dart';

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
  }) : super(key: key);

  final PTIDamageSumary damage;
  final String token;
  final String sessionId;
  final Function(String) onError;
  @override
  _DamageResultPageState createState() => _DamageResultPageState();
}

class _DamageResultPageState extends State<DamageResultPage> {
  final double _toolbarHeight = 64.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: DamageResultBottomBar(
        totalCost: widget.damage.sumaryPrice.toDouble() ?? 0,
        onAddMoreImage: () => Navigator.pop(context),
        onSubmited: _sendDamageAssessmentResultToPTI,
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
        NotificationDialog.show(
          context,
          type: NotiType.success,
          content: StringKeys.saveSuccessfuly,
          confirmCallBack: () {},
        );
      } else {
        NotificationDialog.show(
          context,
          type: NotiType.error,
          content: StringKeys.haveError,
          confirmCallBack: () {},
        );
        if (widget.onError != null) {
          widget.onError('Package error: http code ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError('Package error: $e');
      }
      rethrow;
    }
  }
}
