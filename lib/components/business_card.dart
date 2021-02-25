import 'package:flutter/material.dart';
import 'package:testestest/components/provider_card.dart';
import 'package:testestest/components/service_card.dart';
import 'package:testestest/constants/colors.dart';
import 'package:testestest/models/provider.dart';
import 'package:testestest/models/service.dart';

import '../dummy_data.dart';

class BusinessCard extends StatefulWidget {
  final String name;
  final String address;
  final double rating;
  final String ratingName;
  final List<Provider> providers;
  final List<Service> services;
  final bool newStatus;

  const BusinessCard(
      {Key key,
      this.name,
      this.address,
      this.rating,
      this.ratingName,
      this.providers,
      this.services,
      this.newStatus})
      : super(key: key);

  @override
  _BusinessCardState createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: cWhiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.3),
                offset: Offset(0.0, 1.0),
                spreadRadius: 1, //(x,y)
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                        color: cDarkPurpleColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(widget.address,
                      style: TextStyle(
                          color: cDarkPurpleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Row(
                    children: [
                      Text('${widget.rating}',
                          style: TextStyle(
                              color: cDarkPurpleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      Text('  ${widget.ratingName}  ',
                          style: TextStyle(
                              color: cDarkPurpleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      widget.newStatus
                          ? Container(
                              decoration: BoxDecoration(
                                color: cNewIndicColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              height: 20.0,
                              width: 74.0,
                              child: Center(
                                  child: Text('Новинка',
                                      style: TextStyle(
                                          color: cWhiteColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500))))
                          : Container(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cDarkPurpleColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 200.0,
                    height: 30.0,
                    child: Center(
                      child: Text(
                        'Открыто 10:00 -21:00',
                        style: TextStyle(
                            color: cWhiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Text('Услуги',
                      style: TextStyle(
                          color: cDarkPurpleColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
                ),
                ...serviceList.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Service val = entry.value;
                  var serviceCard = ServiceCard(
                    service: val,
                    initExpanded: idx == 0 ? true : false,
                  );
                  return serviceCard;
                }),
                Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: cLightGrey),
                  child: Center(
                      child: Text(
                    'ВСЕ УСЛУГИ',
                    style: TextStyle(
                        color: cDarkPurpleColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700),
                  )),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 26.0, top: 22, left: 30),
          child: Text('Команда',
              style: TextStyle(
                  color: cDarkPurpleColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
        ),
        Container(
          height: 220,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: providerList.map((provider) {
              var providerCard = ProviderCard(provider: provider);
              return providerCard;
            }).toList(),
          ),
        )
      ],
    );
  }
}
