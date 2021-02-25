import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:testestest/components/business_card.dart';
import 'package:testestest/components/comment_card.dart';
import 'package:testestest/components/slide_show.dart';
import 'package:testestest/constants/colors.dart';
import 'package:testestest/constants/images.dart';

import '../dummy_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cGreyColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: cWhiteColor,
        leading: IconButton(
            onPressed: () => print('tapped back button'),
            icon: SvgPicture.asset(
              iBackIcon,
              height: 18.0,
              width: 18.0,
              fit: BoxFit.fitHeight,
              color: cDarkPurpleColor,
            )),
        title: Text(
          'Winchester',
          style: TextStyle(color: cDarkPurpleColor),
        ),
        actions: [
          IconButton(
              onPressed: () => print('tapped heart button'),
              icon: SvgPicture.asset(
                iHeartIcon,
                height: 15.0,
                width: 15.0,
                fit: BoxFit.fitHeight,
                color: cDarkPurpleColor,
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cDarkPurpleColor,
        label: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("ЗАПИСАТЬСЯ"),
        ),
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40)),
                  color: cWhiteColor,
                ),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    SlideShow(
                      imgList: initSlider(true),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: BusinessCard(
                        name: 'Winchester',
                        address: 'Ожешко 39/1',
                        rating: 3.9,
                        ratingName: 'Отлично',
                        providers: providerList,
                        services: serviceList,
                        newStatus: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom:5.0, left: 24),
                    child: Text('Отзывы',style: TextStyle(
                    color: cDarkPurpleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom:28, left: 24),
                    child: Text('Всего 69 отзыва', style: TextStyle(
                        color: cDarkPurpleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                  ),
                  ...commentsList.map((comment) {
                    var com = CommentCard(comment: comment,);
                    return com;
                  }),
                  Container(
                    height: 50,
                    width: 367,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: cWhiteColor),
                    child: Center(
                        child: Text(
                          'ВСЕ ОТЗЫВЫ',
                          style: TextStyle(
                              color: cDarkPurpleColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700),
                        )),
                  ),
                  SizedBox(
                    height: 100.0,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
