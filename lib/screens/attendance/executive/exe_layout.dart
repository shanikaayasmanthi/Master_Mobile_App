import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:av_master_mobile/controllers/attendance/exe_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExeLayout extends StatefulWidget {
  const ExeLayout({super.key, required this.portalName});

  final String portalName;

  @override
  State<ExeLayout> createState() => _ExeLayoutState();
}

ExePageController pageController = Get.put(ExePageController());

class _ExeLayoutState extends State<ExeLayout> {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(
                () => IndexedStack(
                  index: pageController.currentPage.value,
                  children: widget.portalName == "Attendance"
                      ? pageController.attendancePages
                      : pageController.pages,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.portalName == "Attendance"
          ? FloatingActionButton(
              onPressed: () {
                pageController.onAttendanceHomeTap();
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
                icons: const [
                  Icons.calendar_month_rounded,
                  Icons.account_circle,
                ],
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
