import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ai/app/modules/navbar/controllers/navbar_controller.dart';

class NavbarView extends GetView<NavbarController> {
  const NavbarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: controller.currentTabIndex.value,
      onTap: controller.changeTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD84040),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: controller.bottomNavItems.map((item) => BottomNavigationBarItem(
        icon: Column(
          children: [
            Icon(item['icon']),
            if (controller.currentTabIndex.value == controller.bottomNavItems.indexOf(item))
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: const Color(0xFFD84040),
              )
          ],
        ),
        label: item['label'],
      )).toList(),
    ));
  }
}