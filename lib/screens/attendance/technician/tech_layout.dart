import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:av_master_mobile/controllers/attendance/tech_page_controller.dart';
import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TechLayout extends StatefulWidget {
  const TechLayout({super.key, required this.portalName});
  final String portalName;

  @override
  State<TechLayout> createState() => _TechLayoutState();
}

class _TechLayoutState extends State<TechLayout> {
  final TechPageController pageController = Get.put(TechPageController());

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //portal home pages
              Obx(
                    () => IndexedStack(
                  index: pageController.currentPage.value,
                  // Use a distinct list for Attendance, and a placeholder/general list for others
                  children: widget.portalName == 'Attendance'
                      ? pageController.attendancePages
                      : pageController
                      .pages, // Ensure this list is always defined and not empty
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.portalName == 'Attendance'
          ? FloatingActionButton(
              onPressed: () {
                pageController.onAttendanceHomeTap;
                pageController.currentPage.value = 0;
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(Icons.home),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => widget.portalName == 'Attendance'
            ? AnimatedBottomNavigationBar(
          // height: 60,
                icons: const [Icons.calendar_month_rounded, Icons.account_circle],
                iconSize: 25,

                activeIndex: pageController.currentPage.value == 1
                    ? 0
                    : (pageController.currentPage.value == 2 ? 1 : -1),
                onTap: pageController.onAttendanceBottomNavTap,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.verySmoothEdge,
                backgroundColor: colorScheme.secondary,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.onSurface,
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
