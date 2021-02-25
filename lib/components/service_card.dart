import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:testestest/constants/colors.dart';
import 'package:testestest/models/service.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final bool initExpanded;

  const ServiceCard({Key key, this.service, this.initExpanded})
      : super(key: key);

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _initExpanded;

  @override
  void initState() {
    _initExpanded = widget.initExpanded ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ExpandableNotifier(
          initialExpanded: _initExpanded,
          child: ScrollOnExpand(
            child: Container(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cLightGrey,
                borderRadius: BorderRadius.circular(20),

              ),
              child: Expandable(
                collapsed: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Builder(
                        builder: (context) {
                          var controller = ExpandableController.of(context);
                          return GestureDetector(
                            onTap: () => controller.toggle(),
                            child: Padding(
                              padding: EdgeInsets.only(left:24, right: 24, bottom: 15, top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.service.name, style: TextStyle(color: cDarkPurpleColor, fontSize: 18, fontWeight: FontWeight.w700),),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.service.duration, style: TextStyle(color: cDarkPurpleColor, fontSize: 14, fontWeight: FontWeight.w500)),
                                      Text('${widget.service.price} USD', style: TextStyle(color: cDarkPurpleColor, fontSize: 14, fontWeight: FontWeight.w700))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ]),
                expanded: Builder(
                  builder: (context) {
                    var controller = ExpandableController.of(context);
                    return GestureDetector(
                      onTap: () => controller.toggle(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                widget.service.slideShow,
                                Padding(
                                  padding: EdgeInsets.only(left:24, right: 24, bottom: 15, top: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom:11.0),
                                        child: Text(widget.service.name, style: TextStyle(color: cDarkPurpleColor, fontSize: 18, fontWeight: FontWeight.w700)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom:21.0),
                                        child: Text(widget.service.description, style: TextStyle(color: cDarkPurpleColor, fontSize: 14, fontWeight: FontWeight.w500)),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(widget.service.duration, style: TextStyle(color: cDarkPurpleColor, fontSize: 14, fontWeight: FontWeight.w500)),
                                          Text('${widget.service.price} USD', style: TextStyle(color: cDarkPurpleColor, fontSize: 14, fontWeight: FontWeight.w700))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    );
                  },
                ),
              ),
            ),
          )),
    );
  }

  buildImg(Color color, double height) {
    return SizedBox(
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
          ),
        ));
  }
}
