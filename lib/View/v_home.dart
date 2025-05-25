import 'package:covid_survey/ViewModel/vm_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../Class/cls_hospital.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.sizeOf(context);

    return PopScope(
      canPop: false,
      child: GetBuilder<HomeVM>(
        init: HomeVM(),
        builder: (HomeVM controller) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('General Hospital'),
              actions: [
                IconButton(
                  onPressed: () {
                    controller.load();
                    controller.hospitals = controller.allHospital;
                  },
                  icon: Icon(Icons.refresh),
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        controller.buildBottomSheet(context);
                      },
                      icon: Icon(Icons.filter_list),
                    );
                  },
                ),
              ],
            ),
            body: CupertinoScrollbar(
              controller: scrollController,
              radius: const Radius.circular(8.0),
              thumbVisibility: true,
              thickness: 8.0,
              child: ListView.builder(
                controller: scrollController,
                itemCount: controller.hospitals.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Hospital h = controller.hospitals[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 75,
                        child: Image.asset(h.imagePath!, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(
                      h.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(h.address, overflow: TextOverflow.ellipsis),
                    trailing: MenuAnchor(
                      menuChildren: [
                        ListTile(
                          title: Text('Tampilkan Gambar'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Stack(
                                  children: [
                                    PhotoView(
                                      imageProvider: AssetImage(h.imagePath!),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Center(
                                          child: InkWell(
                                            child: IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: Text('Lihat di Peta'),
                          onTap: () {
                            controller.getLocation(context, h.address);
                          },
                        ),
                      ],
                      builder: (context, controller, child) {
                        return IconButton(
                          onPressed: () {
                            controller.isOpen
                                ? controller.close()
                                : controller.open();
                          },
                          icon: Icon(Icons.more_vert),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
