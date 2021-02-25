import 'dart:async';

import 'package:flutter/material.dart';
import 'package:testestest/constants/colors.dart';

class SlideShow extends StatefulWidget {
  SlideShow({
    @required this.imgList,
    this.width = double.infinity,
    this.height = 202,
    this.initialPage = 0,
    this.onPageChanged,
  });

  final List<Widget> imgList;
  final double width;
  final double height;
  final int initialPage;
  final ValueChanged<int> onPageChanged;

  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {
  final StreamController<int> _pageStreamController =
      StreamController<int>.broadcast();
  PageController _pageController;

  void _onPageChanged(int value) {
    _pageStreamController.sink.add(value);
    if (widget.onPageChanged != null) {
      widget.onPageChanged(value);
    }
  }

  Widget _indicator(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(
        widget.imgList.length,
        (index) {
          return StreamBuilder<int>(
            initialData: _pageController.initialPage,
            stream: _pageStreamController.stream.where(
              (pageIndex) {
                return index >= pageIndex - 1 && index <= pageIndex + 1;
              },
            ),
            builder: (_, AsyncSnapshot<int> snapshot) {
              return Container(
                width: 30,
                height: snapshot.data == index ? 4 : 2,
                decoration: BoxDecoration(
                  color: cWhiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    _pageController = PageController(
      initialPage: widget.initialPage,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: _onPageChanged,
            itemCount: widget.imgList.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              return widget.imgList[index];
            },
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 32.0,
            child: _indicator(context),
          ),
        ],
      ),
    );
  }
}
