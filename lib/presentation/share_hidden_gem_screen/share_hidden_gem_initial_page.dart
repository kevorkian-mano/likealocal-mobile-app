import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import './provider/share_hidden_gem_provider.dart';

class ShareHiddenGemInitialPage extends StatelessWidget {
  const ShareHiddenGemInitialPage({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ShareHiddenGemInitialPage();
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: appTheme.gray_50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.h, 17.h, 24.h, 8.h),
          decoration: BoxDecoration(
            color: appTheme.colorCCFBFD,
            boxShadow: [
              BoxShadow(
                color: appTheme.color220F1B,
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                    // Try to pop normally (for sheet), fallback if necessary
                    if(Navigator.of(context).canPop()) {
                       Navigator.of(context).pop();
                    } else {
                       NavigatorService.goBack();
                    }
                },
                child: CustomImageView(
                  imagePath: ImageConstant.imgButton,
                  height: 30.h,
                  width: 30.h,
                ),
              ),
              Text(
                'LikeALocal',
                style: TextStyleHelper.instance.title20ExtraBoldPlusJakartaSans
                    .copyWith(height: 1.3),
              ),
              CustomImageView(
                imagePath: ImageConstant.imgImage1,
                height: 46.h,
                width: 46.h,
                radius: BorderRadius.circular(22.h),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<ShareHiddenGemProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.h, 32.h, 24.h, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share a Hidden\nGem',
                    style: TextStyleHelper
                        .instance
                        .display36ExtraBoldPlusJakartaSans
                        .copyWith(height: 1.25),
                  ),
                  SizedBox(height: 38.h),
                  _buildMediaUploadSection(context, provider),
                  SizedBox(height: 32.h),
                  _buildInformationSection(context, provider),
                  SizedBox(height: 32.h),
                  _buildExpandableSections(context, provider),
                  SizedBox(height: 20.h),
                  _buildPinLocationSection(context, provider),
                  SizedBox(height: 52.h),
                  _buildPublishButton(context, provider),
                  SizedBox(height: 16.h),
                  _buildGuidelinesText(context),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaUploadSection(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context, provider),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 68.h),
        decoration: BoxDecoration(
          color: appTheme.gray_100,
          border: Border.all(color: appTheme.colorC54CC4, width: 2),
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.shareHiddenGemModel.selectedMediaPath != null)
              Container(
                height: 120.h,
                width: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: CustomImageView(
                  imagePath: provider.shareHiddenGemModel.selectedMediaPath!,
                  height: 120.h,
                  width: 120.h,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(12.h),
                ),
              )
            else ...[
              CustomImageView(
                imagePath: ImageConstant.imgMargin,
                height: 32.h,
                width: 26.h,
              ),
              SizedBox(height: 1.h),
              Text(
                'Add Media',
                style: TextStyleHelper.instance.body12SemiBoldInter.copyWith(
                  height: 1.25,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInformationSection(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomImageView(
              imagePath: ImageConstant.imgIcon,
              height: 16.h,
              width: 18.h,
            ),
            SizedBox(width: 8.h),
            Text(
              'Information about the place',
              style: TextStyleHelper.instance.title20BoldPlusJakartaSans
                  .copyWith(height: 1.3),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildPlaceTitleField(context, provider),
        SizedBox(height: 16.h),
        _buildCategoryField(context, provider),
        SizedBox(height: 16.h),
        _buildLocationField(context, provider),
      ],
    );
  }

  Widget _buildPlaceTitleField(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.h),
          child: Text(
            'PLACE TITLE',
            style: TextStyleHelper.instance.body12BoldInter.copyWith(
              letterSpacing: 1,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        CustomEditText(
          hintText: 'e.g., The Secret Bakery in Trastevere',
          controller: provider.placeTitleController,
          backgroundColor: appTheme.gray_100,
          validator: provider.validatePlaceTitle,
        ),
      ],
    );
  }

  Widget _buildCategoryField(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.h),
          child: Text(
            'CATEGORY',
            style: TextStyleHelper.instance.body12BoldInter.copyWith(
              letterSpacing: 1,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        CustomDropdown(
          items: [
            DropdownMenuItem(
              value: 'Hidden Dining',
              child: Text('Hidden Dining'),
            ),
            DropdownMenuItem(
              value: 'Secret Spots',
              child: Text('Secret Spots'),
            ),
            DropdownMenuItem(
              value: 'Local Markets',
              child: Text('Local Markets'),
            ),
            DropdownMenuItem(
              value: 'Cultural Sites',
              child: Text('Cultural Sites'),
            ),
            DropdownMenuItem(
              value: 'Nature Spots',
              child: Text('Nature Spots'),
            ),
          ],
          placeholder: 'Hidden Dining',
          value: provider.shareHiddenGemModel.selectedCategory,
          onChanged: provider.updateCategory,
          validator: provider.validateCategory,
        ),
      ],
    );
  }

  Widget _buildLocationField(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.h),
          child: Text(
            'LOCATION',
            style: TextStyleHelper.instance.body12BoldInter.copyWith(
              letterSpacing: 1,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        CustomEditText(
          hintText: 'Search city or street...',
          prefixIconPath: ImageConstant.imgContainer,
          controller: provider.locationController,
          backgroundColor: appTheme.gray_100,
          validator: provider.validateLocation,
        ),
      ],
    );
  }

  Widget _buildExpandableSections(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      decoration: BoxDecoration(
        color: appTheme.colorEDF0ED,
        borderRadius: BorderRadius.circular(24.h),
      ),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          _buildDescriptionSection(context, provider),
          SizedBox(height: 24.h),
          _buildLocalTipsSection(context, provider),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomImageView(
              imagePath: ImageConstant.imgIconBlueGray700,
              height: 20.h,
              width: 16.h,
            ),
            SizedBox(width: 8.h),
            Text(
              'DESCRIPTION',
              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                letterSpacing: 1,
                height: 1.21,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        CustomEditText(
          hintText:
              'What makes this place special? \nDescribe the atmosphere, the \npeople, and why it\'s a local \nfavorite...',
          controller: provider.descriptionController,
          isMultiline: true,
          hasBorder: true,
          backgroundColor: appTheme.white_A700,
          validator: provider.validateDescription,
        ),
      ],
    );
  }

  Widget _buildLocalTipsSection(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomImageView(
              imagePath: ImageConstant.imgIconGray80001,
              height: 20.h,
              width: 14.h,
            ),
            SizedBox(width: 8.h),
            Text(
              'LOCAL TIPS',
              style: TextStyleHelper.instance.body14BoldInter.copyWith(
                letterSpacing: 1,
                height: 1.21,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        CustomEditText(
          hintText:
              'Best time to visit, how to get a \ntable, or hidden features...',
          controller: provider.localTipsController,
          isMultiline: true,
          hasBorder: true,
          backgroundColor: appTheme.white_A700,
        ),
      ],
    );
  }

  Widget _buildPinLocationSection(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pin Location',
              style: TextStyleHelper.instance.title20BoldPlusJakartaSans
                  .copyWith(height: 1.3),
            ),
            GestureDetector(
              onTap: () => provider.adjustPin(),
              child: Text(
                'Adjust Pin',
                style: TextStyleHelper.instance.body14BoldInter.copyWith(
                  color: appTheme.gray_800_01,
                  height: 1.21,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          height: 160.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: appTheme.gray_300,
            border: Border.all(color: appTheme.colorC1C2C8),
            borderRadius: BorderRadius.circular(48.h),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgMap,
                height: 158.h,
                width: 340.h,
                fit: BoxFit.cover,
              ),
              CustomIconButton(
                iconPath: ImageConstant.imgBackground,
                backgroundColor: appTheme.gray_900_01,
                size: 40.h,
                onPressed: () => provider.adjustPin(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPublishButton(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    return CustomButton(
      text: 'Publish to Community',
      backgroundColor: appTheme.gray_900_01,
      textColor: appTheme.whiteCustom,
      borderRadius: 30,
      fontFamily: 'Inter',
      fontSize: 18.fSize,
      fontWeight: FontWeight.w700,
      boxShadow: [
        BoxShadow(
          color: appTheme.color223F1B,
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ],
      onPressed: () => provider.publishToommunity(context),
    );
  }

  Widget _buildGuidelinesText(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'By publishing, you agree to our ',
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              height: 1.25,
            ),
          ),
          TextSpan(
            text: 'Community Guidelines.',
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              height: 1.17,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(
    BuildContext context,
    ShareHiddenGemProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyleHelper.instance.title18SemiBold,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      provider.pickImageFromCamera();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.h),
                          decoration: BoxDecoration(
                            color: appTheme.gray_900_01,
                            borderRadius: BorderRadius.circular(12.h),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: appTheme.whiteCustom,
                            size: 32.h,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text('Camera', style: TextStyleHelper.instance.body14),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      provider.pickImageFromGallery();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.h),
                          decoration: BoxDecoration(
                            color: appTheme.gray_900_01,
                            borderRadius: BorderRadius.circular(12.h),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: appTheme.whiteCustom,
                            size: 32.h,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text('Gallery', style: TextStyleHelper.instance.body14),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
