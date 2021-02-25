import 'package:flutter/material.dart';
import 'package:testestest/constants/colors.dart';
import 'package:testestest/models/provider.dart';

class ProviderCard extends StatelessWidget {
  final Provider provider;

  const ProviderCard({Key key, this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 216,
        width: 133,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cWhiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              offset: Offset(0.0, 1.0),
              spreadRadius: 1, //(x,y)
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                provider.image,
                height: 124,
                width: 133,
                fit: BoxFit.cover,
              ),
            ),
            Center(child: Text(provider.firstName + ' ' + provider.lastName)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cDarkPurpleColor,
              ),
              height: 32,
              width: 133,
              child: Center(
                  child: Text(
                'ЗАПИСАТЬСЯ',
                style: TextStyle(
                    color: cWhiteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              )),
            )
          ],
        ),
      ),
    );
  }
}
