// Copyright © 2022 AICycle. All rights reserved.
// found in the LICENSE file.

// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.dart';
import 'widgets/summary_image_section.dart';
import 'controller/claim_folder_controller.dart';
import 'widgets/part_direction_section.dart';

class ClaimFolderView extends StatefulWidget {
  /// Hiển thị các góc chụp và thông tin liên quan.
  /// Khởi tạo hồ sơ bảo hiểm phía AICycle

  const ClaimFolderView({
    Key key,
    this.sessionId,
    // this.carBrand,
    this.uTokenKey,
    this.loadingWidget,
    this.onError,
    this.onGetResultCallBack,
    // this.onFrontLeftChanged,
    // this.onFrontRightChanged,
    // this.onFrontChanged,
    // this.onLeftRearChanged,
    // this.onRightRearChanged,
    // this.onRearChanged,
    this.maDonVi,
    this.kieuCongViec,
    this.loaiCongViec,
    this.deviceId,
    this.hangXe,
    this.hieuXe,
    // this.noiDungSuVu,
    this.maDonViNguoiDangNhap,
    this.maGiamDinhVien,
    this.phoneNumber,
    this.bienSoXe,
    // this.soIdCongViec,
  }) : super(key: key);

  /// ID hồ sơ
  /// PTI key: so_id
  final String sessionId;

  /// Hãng xe hỗ trợ
  // final CarBrandType carBrand;

  /// Token key khi đăng nhập phía AICycle
  final String uTokenKey;

  /// Custom loading widget
  final Widget loadingWidget;

  /// Khi xử lý lỗi
  final Function(String message) onError;

  /// Khi trả về kết quả
  final Function(Map<String, dynamic>) onGetResultCallBack;

  /// Hàm call back trả về danh sách ảnh Trái - Trước
  // final Function(List<File>) onFrontLeftChanged;

  /// Hàm call back trả về danh sách ảnh Phải - Trước
  // final Function(List<File>) onFrontRightChanged;

  /// Hàm call back trả về danh sách ảnh Trước
  // final Function(List<File>) onFrontChanged;

  /// Hàm call back trả về danh sách ảnh Trái - Sau
  // final Function(List<File>) onLeftRearChanged;

  /// Hàm call back trả về danh sách ảnh Phải - Sau
  // final Function(List<File>) onRightRearChanged;

  /// Hàm call back trả về danh sách ảnh Sau
  // final Function(List<File>) onRearChanged;

  /// Các thông tin cần cung cấp từ phía PTI
  /// PTI key: ma_id
  final String maDonVi;

  /// PTI key: KIEU_CV
  final String kieuCongViec;

  /// PTI key: loai
  final String loaiCongViec;

  /// PTI key: deviceId
  final String deviceId;

  /// PTI key: HANG_XE
  final String hangXe;

  /// PTI key: HIEU_XE
  final String hieuXe;

  /// PTI key: nd
  // final String noiDungSuVu;

  /// PTI key: ma_dvi_nh
  final String maDonViNguoiDangNhap;

  /// PTI key: nsd_nh
  final String maGiamDinhVien;

  /// PTI key: bien_xe
  final String bienSoXe;

  /// PTI key: so_id
  // final String soIdCongViec;

  /// PTI key: phone
  final String phoneNumber;

  @override
  State<ClaimFolderView> createState() => _ClaimFolderViewState();
}

class _ClaimFolderViewState extends State<ClaimFolderView> {
  ClaimFolderController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ClaimFolderController>()) {
      controller = Get.find<ClaimFolderController>();
    } else {
      controller = Get.put(ClaimFolderController(
        ClaimArgument(
          bienSoXe: widget.bienSoXe,
          deviceId: widget.deviceId,
          hangXe: widget.hangXe,
          hieuXe: widget.hieuXe,
          kieuCongViec: widget.kieuCongViec,
          loadingWidget: widget.loadingWidget,
          loaiCongViec: widget.loaiCongViec,
          maDonVi: widget.maDonVi,
          maDonViNguoiDangNhap: widget.maDonViNguoiDangNhap,
          maGiamDinhVien: widget.maGiamDinhVien,
          onError: widget.onError,
          onGetResultCallBack: widget.onGetResultCallBack,
          phoneNumber: widget.phoneNumber,
          sessionId: widget.sessionId,
          uTokenKey: widget.uTokenKey,
        ),
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<ClaimFolderController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
        // future: _createAndCallImage(),
        // builder: (context, AsyncSnapshot<String> snapShot) {
        () {
      if (controller.isCreatingClaim.isTrue) {
        return Center(
            child: widget.loadingWidget ?? const CircularProgressIndicator());
      }
      if (controller.isCreatingClaim.isFalse) {
        if (controller.claimID.isEmpty) {
          return Container();
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryImagesSection(
                      claimId: controller.claimID.value,
                      token: widget.uTokenKey,
                      sessionId: widget.sessionId,
                      images: controller.summaryImages,
                      onError: (message) {
                        if (widget.onError != null) {
                          widget.onError(message);
                        }
                      },
                      imagesOnChanged: (images) =>
                          controller.summaryImages = images,
                    ),
                    // _partDirectionsSection(),
                    PartDirectionSection(controller: controller)
                  ],
                ),
              ),
            ),
            Obx(() {
              bool isHaveImage = controller.listPartDirections.any((element) {
                if (element.value.images.isNotEmpty ||
                    element.value.imageFiles.isNotEmpty) {
                  return true;
                } else {
                  return false;
                }
              });
              if (isHaveImage) {
                return SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (controller.disableSaveButton.isTrue) ...[
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: DefaultColors.primaryA200,
                            child: Text(
                              'Kiểm tra hồ sơ',
                              style:
                                  TextStyle(color: DefaultColors.primaryA500),
                            ),
                            onPressed: () =>
                                controller.checkIsSentData(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (controller.disableSaveButton.isFalse) ...[
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: DefaultColors.primaryA200,
                            child: Text(
                              'Lưu kết quả',
                              style:
                                  TextStyle(color: DefaultColors.primaryA500),
                            ),
                            onPressed: () =>
                                controller.saveResultTapped(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(8),
                          color: DefaultColors.primaryA500, //blue
                          child: Text(
                            'Xem kết quả',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => controller.showResultTapped(context),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            }),
          ],
        );
      } else {
        return Container();
      }
    });
  }
}
