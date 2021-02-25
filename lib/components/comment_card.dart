import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:testestest/constants/colors.dart';
import 'package:testestest/constants/images.dart';
import 'package:testestest/models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({Key key, this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:13.0),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(21.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 13.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(comment.image),
                    ),
                  ),
                  Text(
                    comment.firstName,
                    style: TextStyle(
                        color: cDarkPurpleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 22.0),
                child: Text(comment.comment,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: cDarkPurpleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w300)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(comment.date,
                      style: TextStyle(
                          color: cDarkPurpleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      SvgPicture.asset(
                        iStarIcon,
                        height: 13,
                        width: 13,
                      ),
                      Text('${comment.rating} ${comment.ratingName}',
                          style: TextStyle(
                              color: cDarkPurpleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
