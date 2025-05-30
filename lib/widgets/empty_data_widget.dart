import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/sad.svg',
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.4),
              BlendMode.srcIn,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Looks like there are no links yet. Stay tuned!',
              style: TextStyle(
                fontFamily: 'Questrial',
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w400,
                fontSize: 14,
                letterSpacing: 0.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
